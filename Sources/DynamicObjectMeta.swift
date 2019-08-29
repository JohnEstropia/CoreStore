//
//  DynamicObjectMeta.swift
//  CoreStore iOS
//
//  Created by John Estropia on 2019/08/20.
//  Copyright © 2019 John Rommel Estropia. All rights reserved.
//

#if swift(>=5.1)

import CoreData
import Foundation


// MARK: - DynamicObjectMeta

@dynamicMemberLookup
public struct DynamicObjectMeta<R, D>: CustomDebugStringConvertible {

    // MARK: Public

    public typealias Root = R
    public typealias Destination = D

    
    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {

        return self.keyPathString
    }


    // MARK: Internal

    internal let keyPathString: KeyPathString

    internal init(keyPathString: KeyPathString) {

        self.keyPathString = keyPathString
    }

    internal func appending<D2>(keyPathString: KeyPathString) -> DynamicObjectMeta<(R, D), D2> {

        return .init(keyPathString: [self.keyPathString, keyPathString].joined(separator: "."))
    }
}


// MARK: - DynamicObjectMeta where Destination: NSManagedObject

extension DynamicObjectMeta where Destination: NSManagedObject {

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V: AllowedObjectiveCAttributeKeyPathValue>(dynamicMember member: KeyPath<Destination, V>) -> DynamicObjectMeta<(Root, Destination), V.ReturnValueType> {

        let keyPathString = String(keyPath: member)
        return self.appending(keyPathString: keyPathString)
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V: NSManagedObject>(dynamicMember member: KeyPath<Destination, V>) -> DynamicObjectMeta<(Root, Destination), V> {

        let keyPathString = String(keyPath: member)
        return self.appending(keyPathString: keyPathString)
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V: NSManagedObject>(dynamicMember member: KeyPath<Destination, V?>) -> DynamicObjectMeta<(Root, Destination), V> {

        // TODO: not working
        let keyPathString = String(keyPath: member)
        return self.appending(keyPathString: keyPathString)
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V: NSOrderedSet>(dynamicMember member: KeyPath<Destination, V>) -> DynamicObjectMeta<(Root, Destination), V> {

        let keyPathString = String(keyPath: member)
        return self.appending(keyPathString: keyPathString)
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V: NSOrderedSet>(dynamicMember member: KeyPath<Destination, V?>) -> DynamicObjectMeta<(Root, Destination), V> {

        let keyPathString = String(keyPath: member)
        return self.appending(keyPathString: keyPathString)
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V: NSSet>(dynamicMember member: KeyPath<Destination, V>) -> DynamicObjectMeta<(Root, Destination), V> {

        let keyPathString = String(keyPath: member)
        return self.appending(keyPathString: keyPathString)
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V: NSSet>(dynamicMember member: KeyPath<Destination, V?>) -> DynamicObjectMeta<(Root, Destination), V> {

        let keyPathString = String(keyPath: member)
        return self.appending(keyPathString: keyPathString)
    }
}


// MARK: - DynamicObjectMeta where Destination: CoreStoreObject

extension DynamicObjectMeta where Destination: CoreStoreObject {

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<K: AttributeKeyPathStringConvertible>(dynamicMember member: KeyPath<Destination, K>) -> DynamicObjectMeta<(Root, Destination), K.ReturnValueType> {

        let keyPathString = String(keyPath: member)
        return self.appending(keyPathString: keyPathString)
    }

    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<K: RelationshipKeyPathStringConvertible>(dynamicMember member: KeyPath<Destination, K>) -> DynamicObjectMeta<(Root, Destination), K.DestinationValueType> {

        let keyPathString = String(keyPath: member)
        return self.appending(keyPathString: keyPathString)
    }
}

#endif
