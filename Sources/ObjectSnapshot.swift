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

@dynamicMemberLookup
public struct ObjectSnapshot<O: DynamicObject>: SnapshotResult, Identifiable, Hashable {

    // MARK: SnapshotResult

    public typealias ObjectType = O


    // MARK: Identifiable

    public let id: O.ObjectID


    // MARK: Equatable

    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {

        return lhs.id == rhs.id
            && lhs.values == rhs.values
    }


    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {

        hasher.combine(self.id)
        hasher.combine(self.values)
    }


    // MARK: Internal

    internal init(id: ID, context: NSManagedObjectContext) {

        self.id = id
        self.context = context
        self.values = O.cs_snapshotDictionary(id: id, context: context) as NSDictionary
    }


    // MARK: Private

    private let context: NSManagedObjectContext
    private let values: NSDictionary
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
    public subscript<V>(dynamicMember member: KeyPath<O, ValueContainer<O>.Required<V>>) -> V {

        let key = String(keyPath: member)
        return self.values[key] as! V
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V>(dynamicMember member: KeyPath<O, ValueContainer<O>.Optional<V>>) -> V? {

        let key = String(keyPath: member)
        return self.values[key] as! V?
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V>(dynamicMember member: KeyPath<O, TransformableContainer<O>.Required<V>>) -> V {

        let key = String(keyPath: member)
        return self.values[key] as! V
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V>(dynamicMember member: KeyPath<O, TransformableContainer<O>.Optional<V>>) -> V? {

        let key = String(keyPath: member)
        return self.values[key] as! V?
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<D>(dynamicMember member: KeyPath<O, RelationshipContainer<O>.ToOne<D>>) -> D? {

        let key = String(keyPath: member)
        return self.values[key] as! D?
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<D>(dynamicMember member: KeyPath<O, RelationshipContainer<O>.ToManyOrdered<D>>) -> [D] {

        let key = String(keyPath: member)
        return self.values[key] as! [D]
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<D>(dynamicMember member: KeyPath<O, RelationshipContainer<O>.ToManyUnordered<D>>) -> Set<D> {

        let key = String(keyPath: member)
        return self.values[key] as! Set<D>
    }
}
