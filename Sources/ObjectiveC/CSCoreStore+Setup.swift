//
//  CSCoreStore+Setup.swift
//  CoreStore
//
//  Created by John Rommel Estropia on 2016/03/17.
//  Copyright © 2016 John Rommel Estropia. All rights reserved.
//

import Foundation

public extension CSCoreStore {
    
    /**
     Returns the `defaultStack`'s model version. The version string is the same as the name of the version-specific .xcdatamodeld file.
     */
    @objc
    public class var modelVersion: String {
        
        return CoreStore.defaultStack.modelVersion
    }
    
    /**
     Returns the entity name-to-class type mapping from the `defaultStack`'s model.
     */
    @objc
    public static var entityClassesByName: [String: NSManagedObject.Type] {
        
        return CoreStore.defaultStack.entityTypesByName
    }
    
    /**
     Returns the entity class for the given entity name from the `defaultStack`'s model.
     - parameter name: the entity name
     - returns: the `NSManagedObject` class for the given entity name, or `nil` if not found
     */
    @objc
    public static func entityClassWithName(name: String) -> NSManagedObject.Type? {
        
        return CoreStore.defaultStack.entityTypesByName[name]
    }
    
    /**
     Returns the `NSEntityDescription` for the specified `NSManagedObject` subclass from `defaultStack`'s model.
     */
    @objc
    public static func entityDescriptionForClass(type: NSManagedObject.Type) -> NSEntityDescription? {
        
        return CoreStore.defaultStack.entityDescriptionForType(type)
    }
    
    /**
     Creates an `CSInMemoryStore` with default parameters and adds it to the `defaultStack`. This method blocks until completion.
     ```
     CSSQLiteStore *storage = [CSCoreStore addInMemoryStorageAndWaitAndReturnError:&error];
     ```
     
     - returns: the `CSInMemoryStore` added to the `defaultStack`
     */
    @objc
    public static func addInMemoryStorageAndWait() throws -> CSInMemoryStore {
        
        return try bridge {
            
            try CoreStore.defaultStack.addStorageAndWait(InMemoryStore)
        }
    }
    
    /**
     Creates an `CSSQLiteStore` with default parameters and adds it to the `defaultStack`. This method blocks until completion.
     ```
     CSSQLiteStore *storage = [CSCoreStore addSQLiteStorageAndWaitAndReturnError:&error];
     ```
     
     - returns: the `CSSQLiteStore` added to the `defaultStack`
     */
    @objc
    public static func addSQLiteStorageAndWait() throws -> CSSQLiteStore {
        
        return try bridge {
            
            try CoreStore.defaultStack.addStorageAndWait(SQLiteStore)
        }
    }
    
    /**
     Adds a `CSInMemoryStore` to the `defaultStack` and blocks until completion.
     ```
     NSError *error;
     CSInMemoryStore *storage = [CSCoreStore
         addStorageAndWait: [[CSInMemoryStore alloc] initWithConfiguration: @"Config1"]
         error: &error];
     ```
     
     - parameter storage: the `CSInMemoryStore`
     - returns: the `CSInMemoryStore` added to the `defaultStack`
     */
    @objc
    public static func addInMemoryStorageAndWait(storage: CSInMemoryStore) throws -> CSInMemoryStore {
        
        return try bridge {
            
            try CoreStore.defaultStack.addStorageAndWait(storage.swift)
        }
    }
    
    /**
     Adds a `CSSQLiteStore` to the `defaultStack` and blocks until completion.
     ```
     NSError *error;
     CSSQLiteStore *storage = [CSCoreStore
         addStorageAndWait: [[CSSQLiteStore alloc] initWithConfiguration: @"Config1"]
         error: &error];
     ```
     
     - parameter storage: the `CSSQLiteStore`
     - returns: the `CSSQLiteStore` added to the `defaultStack`
     */
    @objc
    public static func addSQLiteStorageAndWait(storage: CSSQLiteStore) throws -> CSSQLiteStore {
        
        return try bridge {
            
            try CoreStore.defaultStack.addStorageAndWait(storage.swift)
        }
    }
}