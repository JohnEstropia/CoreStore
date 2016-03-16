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
    public static var entityTypesByName: [String: NSManagedObject.Type] {
        
        return CoreStore.defaultStack.entityTypesByName
    }
    
    /**
     Returns the `NSEntityDescription` for the specified `NSManagedObject` subclass from `defaultStack`'s model.
     */
    @objc
    public static func entityDescriptionForType(type: NSManagedObject.Type) -> NSEntityDescription? {
        
        return CoreStore.defaultStack.entityDescriptionForType(type)
    }
    
    /**
     Creates an `CSSQLiteStore` with default parameters and adds it to the `defaultStack`. This method blocks until completion.
     ```
     try CSCoreStore.addStorageAndWait()
     ```
     
     - returns: the local SQLite storage added to the `defaultStack`
     */
    @objc
    public static func addStorageAndWait() throws -> CSSQLiteStore {
        
        return try CoreStore.defaultStack.addStorageAndWait(SQLiteStore).objc
    }
    
    /**
     Adds a `StorageInterface` to the `defaultStack` and blocks until completion.
     ```
     try CoreStore.addStorageAndWait(InMemoryStore(configuration: "Config1"))
     ```
     
     - parameter storage: the `StorageInterface`
     - returns: the `StorageInterface` added to the `defaultStack`
     */
//    @objc
//    public static func addStorageAndWait(storage: StorageInterface) throws -> StorageInterface {
//        
//        return try self.defaultStack.swift.addStorageAndWait(storage)
//    }
    
    /**
     Creates a `LocalStorageface` of the specified store type with default values and adds it to the `defaultStack`. This method blocks until completion.
     ```
     try CoreStore.addStorageAndWait(SQLiteStore)
     ```
     
     - parameter storeType: the `LocalStorageface` type
     - returns: the local storage added to the `defaultStack`
     */
//    @objc
//    public static func addStorageAndWait<T: LocalStorage where T: DefaultInitializableStore>(storageType: T.Type) throws -> T {
//        
//        return try self.defaultStack.swift.addStorageAndWait(storageType.init())
//    }
    
    /**
     Adds a `LocalStorage` to the `defaultStack` and blocks until completion.
     ```
     try CoreStore.addStorageAndWait(SQLiteStore(configuration: "Config1"))
     ```
     
     - parameter storage: the local storage
     - returns: the local storage added to the `defaultStack`. Note that this may not always be the same instance as the parameter argument if a previous `LocalStorage` was already added at the same URL and with the same configuration.
     */
//    @objc
//    public static func addStorageAndWait<T: LocalStorage>(storage: T) throws -> T {
//        
//        return try self.defaultStack.swift.addStorageAndWait(storage)
//    }
}