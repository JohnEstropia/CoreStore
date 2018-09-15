//
//  CoreStore+Setup.swift
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

import Foundation
import CoreData


// MARK: - CoreStore

public extension CoreStore {
    
    /**
     Returns the `defaultStack`'s model version. The version string is the same as the name of a version-specific .xcdatamodeld file or `CoreStoreSchema`.
     */
    public static var modelVersion: String {
        
        return self.defaultStack.modelVersion
    }
    
    /**
     Returns the entity name-to-class type mapping from the `defaultStack`'s model.
     */
    public static func entityTypesByName(for type: NSManagedObject.Type) -> [EntityName: NSManagedObject.Type] {
        
        return self.defaultStack.entityTypesByName(for: type)
    }
    
    /**
     Returns the entity name-to-class type mapping from the `defaultStack`'s model.
     */
    public static func entityTypesByName(for type: CoreStoreObject.Type) -> [EntityName: CoreStoreObject.Type] {
        
        return self.defaultStack.entityTypesByName(for: type)
    }
    
    /**
     Returns the `NSEntityDescription` for the specified `NSManagedObject` subclass from `defaultStack`'s model.
     */
    public static func entityDescription(for type: NSManagedObject.Type) -> NSEntityDescription? {
        
        return self.defaultStack.entityDescription(for: type)
    }
    
    /**
     Returns the `NSEntityDescription` for the specified `CoreStoreObject` subclass from `defaultStack`'s model.
     */
    public static func entityDescription(for type: CoreStoreObject.Type) -> NSEntityDescription? {
        
        return self.defaultStack.entityDescription(for: type)
    }
    
    /**
     Creates an `SQLiteStore` with default parameters and adds it to the `defaultStack`. This method blocks until completion.
     ```
     try CoreStore.addStorageAndWait()
     ```
     - returns: the local SQLite storage added to the `defaultStack`
     */
    @discardableResult
    public static func addStorageAndWait() throws -> SQLiteStore {
        
        return try self.defaultStack.addStorageAndWait(SQLiteStore())
    }
    
    /**
     Adds a `StorageInterface` to the `defaultStack` and blocks until completion.
     ```
     try CoreStore.addStorageAndWait(InMemoryStore(configuration: "Config1"))
     ```
     - parameter storage: the `StorageInterface`
     - throws: a `CoreStoreError` value indicating the failure
     - returns: the `StorageInterface` added to the `defaultStack`
     */
    @discardableResult
    public static func addStorageAndWait<T: StorageInterface>(_ storage: T) throws -> T {
        
        return try self.defaultStack.addStorageAndWait(storage)
    }
    
    /**
     Adds a `LocalStorage` to the `defaultStack` and blocks until completion.
     ```
     try CoreStore.addStorageAndWait(SQLiteStore(configuration: "Config1"))
     ```
     - parameter storage: the local storage
     - throws: a `CoreStoreError` value indicating the failure
     - returns: the local storage added to the `defaultStack`. Note that this may not always be the same instance as the parameter argument if a previous `LocalStorage` was already added at the same URL and with the same configuration.
     */
    @discardableResult
    public static func addStorageAndWait<T: LocalStorage>(_ storage: T) throws -> T {
        
        return try self.defaultStack.addStorageAndWait(storage)
    }
    
    /**
     Adds a `CloudStorage` to the `defaultStack` and blocks until completion.
     ```
     guard let storage = ICloudStore(
         ubiquitousContentName: "MyAppCloudData",
         ubiquitousContentTransactionLogsSubdirectory: "logs/config1",
         ubiquitousContainerID: "iCloud.com.mycompany.myapp.containername",
         ubiquitousPeerToken: "9614d658014f4151a95d8048fb717cf0",
         configuration: "Config1",
         cloudStorageOptions: .recreateLocalStoreOnModelMismatch
     ) else {
         // iCloud is not available on the device
         return
     }
     try CoreStore.addStorageAndWait(storage)
     ```
     - parameter storage: the local storage
     - throws: a `CoreStoreError` value indicating the failure
     - returns: the cloud storage added to the stack. Note that this may not always be the same instance as the parameter argument if a previous `CloudStorage` was already added at the same URL and with the same configuration.
     */
    @discardableResult
    public static func addStorageAndWait<T: CloudStorage>(_ storage: T) throws -> T {
        
        return try self.defaultStack.addStorageAndWait(storage)
    }
    
    
    // MARK: Deprecated
    
    @available(*, deprecated, message: "Use the new CoreStore.entityTypesByName(for:) method passing `NSManagedObject.self` as argument.")
    public static var entityTypesByName: [EntityName: NSManagedObject.Type] {
        
        return self.defaultStack.entityTypesByName
    }
    
    
    // MARK: Obsolete
    
    @available(*, obsoleted: 3.1, renamed: "entityDescription(for:)")
    public static func entityDescriptionForType(_ type: NSManagedObject.Type) -> NSEntityDescription? {
        
        return self.entityDescription(for: type)
    }
}
