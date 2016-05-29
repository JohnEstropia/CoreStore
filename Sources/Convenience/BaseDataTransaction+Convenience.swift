//
//  BaseDataTransaction+Convenience.swift
//  CoreStore
//
//  Created by Aleksandar Petrov on 5/27/16.
//  Copyright © 2016 John Rommel Estropia. All rights reserved.
//

import Foundation
import CoreData

public extension BaseDataTransaction {
    
    /**
    Provides a convenience wrapper for deleting all `NSManagedObject`s from entity.
    
    - parameter from: a `From` clause indicating the entity type
    - returns: the number of `NSManagedObject`s deleted.
    */
    public func truncateTable<T: NSManagedObject>(from: From<T>) -> Int? {
        return self.deleteAll(from, Where())
    }
    
    /**
     Provides a convenience wrapper for deleting all entities from `DataStack`.
     
     - parameter dataStack: the `DataStack` to delete objects from
     - parameter shouldSkip: an optional closure providing caller with the ability to preserve some entities from being deleted.
     */
    public func truncateDataStack(dataStack: DataStack = CoreStore.defaultStack, shouldSkip: ((entity:  NSManagedObject.Type)-> Bool)?) {
        for (_, entityType) in dataStack.entityTypesByName {
            if let shouldSkip = shouldSkip where shouldSkip(entity: entityType) {
                continue
            }
            self.truncateTable(From(entityType))
        }
    }
    
}
