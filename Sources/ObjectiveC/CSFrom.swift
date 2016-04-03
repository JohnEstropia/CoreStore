//
//  CSFrom.swift
//  CoreStore
//
//  Copyright © 2016 John Rommel Estropia
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

import Foundation
import CoreData


// MARK: - CSFrom

/**
 The `CSFrom` serves as the Objective-C bridging type for `From`.
 
 - SeeAlso: `From`
 */
@objc
public final class CSFrom: NSObject, CoreStoreObjectiveCType {
    
    /**
     Initializes a `CSFrom` clause with the specified entity class.
     ```
     MyPersonEntity *people = [transaction fetchAllFrom:[CSFrom entityClass:[MyPersonEntity class]]];
     ```
     
     - parameter entityClass: the `NSManagedObject` class type to be created
     - returns: a `CSFrom` clause with the specified entity class
     */
    @objc
    public static func entityClass(entityClass: AnyClass) -> CSFrom {
        
        return self.init(From(entityClass))
    }
    
    /**
     Initializes a `CSFrom` clause with the specified configurations.
     ```
     MyPersonEntity *people = [transaction fetchAllFrom:[CSFrom entityClass:[MyPersonEntity class] configuration:@"Configuration1"]];
     ```
     
     - parameter configuration: the `NSPersistentStore` configuration name to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     - parameter otherConfigurations: an optional list of other configuration names to associate objects from (see `configuration` parameter)
     - returns: a `CSFrom` clause with the specified configurations
     */
    @objc
    public static func entityClass(entityClass: AnyClass, configuration: String?) -> CSFrom {
        
        return self.init(From(entityClass, configuration))
    }
    
    /**
     Initializes a `CSFrom` clause with the specified configurations.
     ```
     MyPersonEntity *people = [transaction fetchAllFrom:[CSFrom entityClass:[MyPersonEntity class] configurations:@[[NSNull null], @"Configuration1"]]];
     ```
     
     - parameter entity: the associated `NSManagedObject` entity class
     - parameter configurations: a list of `NSPersistentStore` configuration names to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `[NSNull null]` to use the default configuration.
     - returns: a `CSFrom` clause with the specified configurations
     */
    @objc
    public static func entityClass(entityClass: AnyClass, configurations: [AnyObject]) -> CSFrom {
        
        return self.init(From(entityClass, configurations.map { $0 is NSNull ? nil : ($0 as! String) }))
    }
    
    /**
     Initializes a `CSFrom` clause with the specified store URLs.
     
     - parameter entity: the associated `NSManagedObject` entity class
     - parameter storeURLs: the persistent store URLs to associate objects from.
     - returns: a `CSFrom` clause with the specified store URLs
     */
    @objc
    public static func entityClass(entityClass: AnyClass, storeURLs: [NSURL]) -> CSFrom {
        
        return self.init(From(entityClass, storeURLs))
    }
    
    /**
     Initializes a `CSFrom` clause with the specified `NSPersistentStore`s.
     
     - parameter entity: the associated `NSManagedObject` entity class
     - parameter persistentStores: the `NSPersistentStore`s to associate objects from.
     - returns: a `CSFrom` clause with the specified `NSPersistentStore`s
     */
    @objc
    public static func entityClass(entityClass: AnyClass, persistentStores: [NSPersistentStore]) -> CSFrom {
        
        return self.init(From(entityClass, persistentStores))
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: From<NSManagedObject>
    
    public init<T: NSManagedObject>(_ swiftValue: From<T>) {
        
        self.bridgeToSwift = swiftValue.upcast()
        super.init()
    }
}


// MARK: - From

extension From: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSFrom {
        
        return CSFrom(self)
    }
}
