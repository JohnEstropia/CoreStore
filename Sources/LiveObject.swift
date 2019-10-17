//
//  LiveObject.swift
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import CoreData

#if canImport(Combine)
import Combine

#endif

#if canImport(SwiftUI)
import SwiftUI

#endif


// MARK: - LiveObject

@dynamicMemberLookup
public final class LiveObject<O: DynamicObject>: ObjectRepresentation, Hashable {

    // MARK: Public

    public typealias SectionID = String
    public typealias ItemID = O.ObjectID

    public var snapshot: ObjectSnapshot<O>? {

        return self.lazySnapshot
    }

    public lazy var object: O? = self.context.fetchExisting(self.id)
    
    public func addObserver<T: AnyObject>(_ observer: T, _ callback: @escaping (LiveObject<O>) -> Void) {
        
        self.observers.setObject(
            Internals.Closure(callback),
            forKey: observer
        )
    }
    
    public func removeObserver<T: AnyObject>(_ observer: T) {
        
        self.observers.removeObject(forKey: observer)
    }

    deinit {

        self.observers.removeAllObjects()
    }
    
    
    // MARK: ObjectRepresentation

    public typealias ObjectType = O
    
    public func objectID() -> O.ObjectID {
        
        return self.id
    }
    
    public func asLiveObject(in dataStack: DataStack) -> LiveObject<O> {
        
        let context = dataStack.unsafeContext()
        if self.context == context {
            
            return self
        }
        return Self.init(objectID: self.id, context: context)
    }

    public func asReadOnly(in dataStack: DataStack) -> O? {

        return dataStack.unsafeContext().fetchExisting(self.id)
    }
    
    public func asEditable(in transaction: BaseDataTransaction) -> O? {
        
        return transaction.unsafeContext().fetchExisting(self.id)
    }
    
    public func asSnapshot(in dataStack: DataStack) -> ObjectSnapshot<O>? {
        
        let context = dataStack.unsafeContext()
        if self.context == context {
            
            return self.lazySnapshot
        }
        return ObjectSnapshot<O>(objectID: self.id, context: context)
    }
    
    public func asSnapshot(in transaction: BaseDataTransaction) -> ObjectSnapshot<O>? {
        
        let context = transaction.unsafeContext()
        if self.context == context {
            
            return self.lazySnapshot
        }
        return ObjectSnapshot<O>(objectID: self.id, context: context)
    }


    // MARK: Equatable

    public static func == (_ lhs: LiveObject, _ rhs: LiveObject) -> Bool {

        return lhs.id == rhs.id
            && lhs.context == rhs.context
    }


    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {

        hasher.combine(self.id)
        hasher.combine(self.context)
    }


    // MARK: LiveResult

    public typealias SnapshotType = ObjectSnapshot<O>


    // MARK: Internal

    internal convenience init(objectID: O.ObjectID, context: NSManagedObjectContext) {

        self.init(
            objectID: objectID,
            context: context,
            initializer: ObjectSnapshot<O>.init(objectID:context:)
        )
    }


    // MARK: FilePrivate

    fileprivate let rawObjectWillChange: Any?

    fileprivate init(objectID: O.ObjectID, context: NSManagedObjectContext, initializer: @escaping (NSManagedObjectID, NSManagedObjectContext) -> ObjectSnapshot<O>?) {

        self.id = objectID
        self.context = context
        if #available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *) {

            #if canImport(Combine)
            self.rawObjectWillChange = ObservableObjectPublisher()

            #else
            self.rawObjectWillChange = nil

            #endif
        }
        else {

            self.rawObjectWillChange = nil
        }
        self.$lazySnapshot.initialize({ initializer(objectID, context) })
        
        context.objectsDidChangeObserver(for: self).addObserver(self) { [weak self] (updatedIDs, deletedIDs) in

            guard let self = self else {

                return
            }
            if deletedIDs.contains(objectID) {

                self.object = nil

                self.willChange()
                self.$lazySnapshot.reset({ nil })
                self.notifyObservers()
                self.didChange()
            }
            else if updatedIDs.contains(objectID) {

                self.willChange()
                self.$lazySnapshot.reset({ initializer(objectID, context) })
                self.notifyObservers()
                self.didChange()
            }
        }
    }


    // MARK: Private
    
    private let id: O.ObjectID
    private let context: NSManagedObjectContext

    @Internals.LazyNonmutating(uninitialized: ())
    private var lazySnapshot: ObjectSnapshot<O>?
    
    private lazy var observers: NSMapTable<AnyObject, Internals.Closure<LiveObject<O>, Void>> = .weakToStrongObjects()

    private func notifyObservers() {

        guard let enumerator = self.observers.objectEnumerator() else {

            return
        }
        for closure in enumerator {

            (closure as! Internals.Closure<LiveObject
                <O>, Void>).invoke(with: self)
        }
    }
}


#if canImport(Combine)
import Combine

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
extension LiveObject: ObservableObject {}

#endif

// MARK: - LiveObject: LiveResult

extension LiveObject: LiveResult {

    // MARK: ObservableObject

    #if canImport(Combine)

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    public var objectWillChange: ObservableObjectPublisher {

        return self.rawObjectWillChange! as! ObservableObjectPublisher
    }
    
    #endif

    public func willChange() {

        guard #available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *) else {

            return
        }
        #if canImport(Combine)

        #if canImport(SwiftUI)
        withAnimation {

            self.objectWillChange.send()
        }

        #endif

        self.objectWillChange.send()

        #endif
    }

    public func didChange() {

        // TODO:
    }
}


// MARK: - LiveObject where O: NSManagedObject

@available(*, unavailable, message: "KeyPaths accessed from @dynamicMemberLookup types can't generate KVC keys yet (https://bugs.swift.org/browse/SR-11351)")
extension LiveObject where O: NSManagedObject {

    // MARK: Public

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V: AllowedObjectiveCKeyPathValue>(dynamicMember member: KeyPath<O, V>) -> V {

        fatalError()
//        return self.snapshot[dynamicMember: member]
    }
}


// MARK: - LiveObject where O: CoreStoreObject

extension LiveObject where O: CoreStoreObject {

    // MARK: Public

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V>(dynamicMember member: KeyPath<O, ValueContainer<O>.Required<V>>) -> V? {

        return self.object?[keyPath: member].value
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V>(dynamicMember member: KeyPath<O, ValueContainer<O>.Optional<V>>) -> V? {

        return self.object?[keyPath: member].value
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V>(dynamicMember member: KeyPath<O, TransformableContainer<O>.Required<V>>) -> V? {

        return self.object?[keyPath: member].value
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V>(dynamicMember member: KeyPath<O, TransformableContainer<O>.Optional<V>>) -> V? {

        return self.object?[keyPath: member].value
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<D>(dynamicMember member: KeyPath<O, RelationshipContainer<O>.ToOne<D>>) -> D? {

        return self.object?[keyPath: member].value
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<D>(dynamicMember member: KeyPath<O, RelationshipContainer<O>.ToManyOrdered<D>>) -> [D]? {

        return self.object?[keyPath: member].value
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<D>(dynamicMember member: KeyPath<O, RelationshipContainer<O>.ToManyUnordered<D>>) -> Set<D>? {

        return self.object?[keyPath: member].value
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V>(dynamicMember member: KeyPath<O, V>) -> V? {

        return self.object?[keyPath: member]
    }
}
