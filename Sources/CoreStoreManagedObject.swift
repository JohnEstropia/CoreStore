//
//  CoreStoreManagedObject.swift
//  CoreStore
//
//  Created by John Rommel Estropia on 2017/06/04.
//  Copyright © 2017 John Rommel Estropia. All rights reserved.
//

import CoreData


// MARK: - CoreStoreManagedObject

@objc internal class CoreStoreManagedObject: NSManagedObject {
    
    @nonobjc @inline(__always)
    internal static func cs_subclassName(for entity: DynamicEntity, in modelVersion: ModelVersion) -> String {
        
        return "_\(NSStringFromClass(CoreStoreManagedObject.self))__\(modelVersion)__\(NSStringFromClass(entity.type))__\(entity.entityName)"
    }
    
    @nonobjc
    internal class func cs_setKeyPathsForValuesAffectingKeys(_ keyPathsForValuesAffectingKeys: [KeyPath: Set<KeyPath>], for managedObjectClass: CoreStoreManagedObject.Type) {
        
        Static.queue.sync(flags: .barrier) {
            
            Static.cache[ObjectIdentifier(managedObjectClass)] = keyPathsForValuesAffectingKeys
        }
    }
    
    // MARK: NSManagedObject
    
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        
        return Static.queue.sync(flags: .barrier) {
            
            let cacheKey = ObjectIdentifier(self)
            if let keyPathsForValuesAffectingKeys = Static.cache[cacheKey] {
                
                return keyPathsForValuesAffectingKeys[key] ?? []
            }
            return super.keyPathsForValuesAffectingValue(forKey: key)
        }
    }
}


// MARK: - Private

private enum Static {
    
    static let queue = DispatchQueue.concurrent("com.coreStore.coreStoreManagerObjectBarrierQueue")
    static var cache: [ObjectIdentifier: [KeyPath: Set<KeyPath>]] = [:]
}
