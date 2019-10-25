//
//  ObjectSnapshot.swift
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

#if canImport(UIKit)
import UIKit

#elseif canImport(AppKit)
import AppKit

#endif


// MARK: - ObjectSnapshot

/**
 The `ObjectSnapshot` is a full copy of a `DynamicObject`'s properties at a given point in time. This is useful especially when keeping thread-safe state values, in ViewModels for example. Since this is a value type, any changes in this `struct` does not affect the actual object.
 */
@dynamicMemberLookup
public struct ObjectSnapshot<O: DynamicObject>: ObjectRepresentation, Hashable {
    
    // MARK: ObjectRepresentation

    public typealias ObjectType = O
    
    public func objectID() -> O.ObjectID {
        
        return self.id
    }
    
    public func asPublisher(in dataStack: DataStack) -> ObjectPublisher<O> {
        
        let context = dataStack.unsafeContext()
        return ObjectPublisher<O>(objectID: self.id, context: context)
    }

    public func asReadOnly(in dataStack: DataStack) -> O? {

        return dataStack.unsafeContext().fetchExisting(self.id)
    }
    
    public func asEditable(in transaction: BaseDataTransaction) -> O? {
        
        return transaction.unsafeContext().fetchExisting(self.id)
    }
    
    public func asSnapshot(in dataStack: DataStack) -> ObjectSnapshot<O>? {
        
        let context = dataStack.unsafeContext()
        return ObjectSnapshot<O>(objectID: self.id, context: context)
    }
    
    public func asSnapshot(in transaction: BaseDataTransaction) -> ObjectSnapshot<O>? {
        
        let context = transaction.unsafeContext()
        return ObjectSnapshot<O>(objectID: self.id, context: context)
    }


    // MARK: Equatable

    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {

        return lhs.id == rhs.id
            && lhs.valuesRef == rhs.valuesRef
    }


    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {

        hasher.combine(self.id)
        hasher.combine(self.valuesRef)
    }


    // MARK: Internal

    internal init?(objectID: O.ObjectID, context: NSManagedObjectContext) {

        guard let values = O.cs_snapshotDictionary(id: objectID, context: context) else {

            return nil
        }
        self.id = objectID
        self.values = values
    }


    // MARK: Private

    private let id: O.ObjectID
    private var values: [String: Any]

    private var valuesRef: NSDictionary {

        return self.values as NSDictionary
    }
}


// MARK: - ObjectSnapshot where O: NSManagedObject

@available(*, unavailable, message: "KeyPaths accessed from @dynamicMemberLookup types can't generate KVC keys yet (https://bugs.swift.org/browse/SR-11351)")
extension ObjectSnapshot where O: NSManagedObject {

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V: AllowedObjectiveCKeyPathValue>(dynamicMember member: KeyPath<O, V>) -> V {

        let key = String(keyPath: member)
        return self.values[key] as! V
    }
}


// MARK: - ObjectSnapshot where O: CoreStoreObject

extension ObjectSnapshot where O: CoreStoreObject {

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<OBase, V>(dynamicMember member: KeyPath<O, ValueContainer<OBase>.Required<V>>) -> V {

        get {

            let key = String(keyPath: member)
            return self.values[key] as! V
        }
        set {

            let key = String(keyPath: member)
            self.values[key] = newValue
        }
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<OBase, V>(dynamicMember member: KeyPath<O, ValueContainer<OBase>.Optional<V>>) -> V? {

        get {

            let key = String(keyPath: member)
            return self.values[key] as! V?
        }
        set {

            let key = String(keyPath: member)
            self.values[key] = newValue
        }
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<OBase, V>(dynamicMember member: KeyPath<O, TransformableContainer<OBase>.Required<V>>) -> V {

        get {

            let key = String(keyPath: member)
            return self.values[key] as! V
        }
        set {

            let key = String(keyPath: member)
            self.values[key] = newValue
        }
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<OBase, V>(dynamicMember member: KeyPath<O, TransformableContainer<OBase>.Optional<V>>) -> V? {

        get {

            let key = String(keyPath: member)
            return self.values[key] as! V?
        }
        set {

            let key = String(keyPath: member)
            self.values[key] = newValue
        }
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<OBase, D>(dynamicMember member: KeyPath<O, RelationshipContainer<OBase>.ToOne<D>>) -> D.ObjectID? {

        get {

            let key = String(keyPath: member)
            return self.values[key] as! D.ObjectID?
        }
        set {

            let key = String(keyPath: member)
            self.values[key] = newValue
        }
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<OBase, D>(dynamicMember member: KeyPath<O, RelationshipContainer<OBase>.ToManyOrdered<D>>) -> [D.ObjectID] {

        get {

            let key = String(keyPath: member)
            return self.values[key] as! [D.ObjectID]
        }
        set {

            let key = String(keyPath: member)
            self.values[key] = newValue
        }
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<OBase, D>(dynamicMember member: KeyPath<O, RelationshipContainer<OBase>.ToManyUnordered<D>>) -> Set<D.ObjectID> {

        get {

            let key = String(keyPath: member)
            return self.values[key] as! Set<D.ObjectID>
        }
        set {

            let key = String(keyPath: member)
            self.values[key] = newValue
        }
    }
}
