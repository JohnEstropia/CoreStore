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

@available(*, deprecated, message: "Call methods directly from the DataStack instead")
extension CoreStore {
    
    /**
     Returns the `CoreStoreDefaults.dataStack`'s model version. The version string is the same as the name of a version-specific .xcdatamodeld file or `CoreStoreSchema`.
     */
    public static var modelVersion: String {
        
        return CoreStoreDefaults.dataStack.modelVersion
    }
    
    /**
     Returns the entity name-to-class type mapping from the `CoreStoreDefaults.dataStack`'s model.
     */
    public static func entityTypesByName(for type: NSManagedObject.Type) -> [EntityName: NSManagedObject.Type] {
        
        return CoreStoreDefaults.dataStack.entityTypesByName(for: type)
    }
    
    /**
     Returns the entity name-to-class type mapping from the `CoreStoreDefaults.dataStack`'s model.
     */
    public static func entityTypesByName(for type: CoreStoreObject.Type) -> [EntityName: CoreStoreObject.Type] {
        
        return CoreStoreDefaults.dataStack.entityTypesByName(for: type)
    }
    
    /**
     Returns the `NSEntityDescription` for the specified `NSManagedObject` subclass from `CoreStoreDefaults.dataStack`'s model.
     */
    public static func entityDescription(for type: NSManagedObject.Type) -> NSEntityDescription? {
        
        return CoreStoreDefaults.dataStack.entityDescription(for: type)
    }
    
    /**
     Returns the `NSEntityDescription` for the specified `CoreStoreObject` subclass from `CoreStoreDefaults.dataStack`'s model.
     */
    public static func entityDescription(for type: CoreStoreObject.Type) -> NSEntityDescription? {
        
        return CoreStoreDefaults.dataStack.entityDescription(for: type)
    }
    
    /**
     Creates an `SQLiteStore` with default parameters and adds it to the `CoreStoreDefaults.dataStack`. This method blocks until completion.
     ```
     try CoreStore.addStorageAndWait()
     ```
     - returns: the local SQLite storage added to the `CoreStoreDefaults.dataStack`
     */
    @discardableResult
    public static func addStorageAndWait() throws -> SQLiteStore {
        
        return try CoreStoreDefaults.dataStack.addStorageAndWait(SQLiteStore())
    }
    
    /**
     Adds a `StorageInterface` to the `CoreStoreDefaults.dataStack` and blocks until completion.
     ```
     try CoreStore.addStorageAndWait(InMemoryStore(configuration: "Config1"))
     ```
     - parameter storage: the `StorageInterface`
     - throws: a `CoreStoreError` value indicating the failure
     - returns: the `StorageInterface` added to the `CoreStoreDefaults.dataStack`
     */
    @discardableResult
    public static func addStorageAndWait<T: StorageInterface>(_ storage: T) throws -> T {
        
        return try CoreStoreDefaults.dataStack.addStorageAndWait(storage)
    }
    
    /**
     Adds a `LocalStorage` to the `CoreStoreDefaults.dataStack` and blocks until completion.
     ```
     try CoreStore.addStorageAndWait(SQLiteStore(configuration: "Config1"))
     ```
     - parameter storage: the local storage
     - throws: a `CoreStoreError` value indicating the failure
     - returns: the local storage added to the `CoreStoreDefaults.dataStack`. Note that this may not always be the same instance as the parameter argument if a previous `LocalStorage` was already added at the same URL and with the same configuration.
     */
    @discardableResult
    public static func addStorageAndWait<T: LocalStorage>(_ storage: T) throws -> T {
        
        return try CoreStoreDefaults.dataStack.addStorageAndWait(storage)
    }
}
