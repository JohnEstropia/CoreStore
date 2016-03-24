//
//  CSInto.swift
//  CoreStore
//
//  Created by John Estropia on 2016/03/24.
//  Copyright © 2016年 John Rommel Estropia. All rights reserved.
//

import UIKit


// MARK: - CSInto

/**
 The `CSInto` serves as the Objective-C bridging type for `Into<T>`.
 */
@objc
public final class CSInto: NSObject, CoreStoreBridge {
    
    /**
     Initializes a `CSInto` clause with the specified entity class.
     Sample Usage:
     ```
     MyPersonEntity *person = [transaction create:[CSInto entityClass:[MyPersonEntity class]]];
     ```
     - parameter entityClass: the `NSManagedObject` class type to be created
     - returns: a new `CSInto` with the specified entity class
     */
    @objc
    public static func entityClass(entityClass: AnyClass) -> CSInto {
        
        return self.init(Into(entityClass))
    }
    
    /**
     Initializes an `CSInto` clause with the specified configuration.
     Sample Usage:
     ```
     MyPersonEntity *person = [transaction create:[CSInto entityClass:[MyPersonEntity class]]];
     ```
     - parameter entityClass: the `NSManagedObject` class type to be created
     - parameter configuration: the `NSPersistentStore` configuration name to associate the object to. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     - returns: a new `CSInto` with the specified configuration
     */
    @objc
    public static func entityClass(entityClass: AnyClass, configuration: String?) -> CSInto {
        
        return self.init(Into(entityClass, configuration))
    }
    

    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.swift.hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSInto else {
            
            return false
        }
        return self.swift == object.swift
    }
    
    
    // MARK: CoreStoreBridge
    
    internal let swift: Into<NSManagedObject>
    
    public required init<T: NSManagedObject>(_ swiftObject: Into<T>) {
        
        self.swift = Into<NSManagedObject>(
            entityClass: swiftObject.entityClass,
            configuration: swiftObject.configuration,
            inferStoreIfPossible: swiftObject.inferStoreIfPossible
        )
        super.init()
    }
}


// MARK: - Into

extension Into: CoreStoreBridgeable {
    
    // MARK: CoreStoreBridgeable
    
    internal var objc: CSInto {
        
        return CSInto(self)
    }
}
