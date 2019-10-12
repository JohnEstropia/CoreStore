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
public final class LiveObject<O: DynamicObject>: Identifiable, Hashable {

    // MARK: Public

    public typealias SectionID = String
    public typealias ItemID = O.ObjectID

    public var snapshot: SnapshotType {

        return self.lazySnapshot
    }

    public private(set) lazy var object: O = self.context.fetchExisting(self.id)!


    // MARK: Identifiable

    public let id: O.ObjectID


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

    public typealias ObjectType = O

    public typealias SnapshotType = ObjectSnapshot<O>


    // MARK: Internal

    internal convenience init(id: ID, context: NSManagedObjectContext) {

        self.init(id: id, context: context, initializer: ObjectSnapshot<O>.init(id:context:))
    }


    // MARK: FilePrivate

    fileprivate let rawObjectWillChange: Any?

    fileprivate init(id: O.ObjectID, context: NSManagedObjectContext, initializer: @escaping (NSManagedObjectID, NSManagedObjectContext) -> ObjectSnapshot<O>) {

        self.id = id
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
        self.$lazySnapshot.initialize({ initializer(id, context) })
        
        context.objectsDidChangeObserver(for: self).addObserver(self) { [weak self] (objectIDs) in

            guard let self = self else {

                return
            }
            self.$lazySnapshot.reset({ initializer(id, context) })
            self.willChange()
        }
    }


    // MARK: Private
    
    private let context: NSManagedObjectContext

    @Internals.LazyNonmutating(uninitialized: ())
    private var lazySnapshot: ObjectSnapshot<O>
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
    public subscript<V>(dynamicMember member: KeyPath<O, ValueContainer<O>.Required<V>>) -> V {

        return self.snapshot[dynamicMember: member]
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V>(dynamicMember member: KeyPath<O, ValueContainer<O>.Optional<V>>) -> V? {

        return self.snapshot[dynamicMember: member]
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V>(dynamicMember member: KeyPath<O, TransformableContainer<O>.Required<V>>) -> V {

        return self.snapshot[dynamicMember: member]
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V>(dynamicMember member: KeyPath<O, TransformableContainer<O>.Optional<V>>) -> V? {

        return self.snapshot[dynamicMember: member]
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<D>(dynamicMember member: KeyPath<O, RelationshipContainer<O>.ToOne<D>>) -> D? {

        return self.snapshot[dynamicMember: member]
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<D>(dynamicMember member: KeyPath<O, RelationshipContainer<O>.ToManyOrdered<D>>) -> [D] {

        return self.snapshot[dynamicMember: member]
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<D>(dynamicMember member: KeyPath<O, RelationshipContainer<O>.ToManyUnordered<D>>) -> Set<D> {

        return self.snapshot[dynamicMember: member]
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<T>(dynamicMember member: KeyPath<O, T>) -> T {

        return self.object[keyPath: member]
    }
}
