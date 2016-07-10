//
//  CoreStore+Migration.swift
//  CoreStore
//
//  Copyright © 2015 John Rommel Estropia
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
#if USE_FRAMEWORKS
    import GCDKit
#endif


// MARK: - CoreStore

public extension CoreStore {
    
    /**
     Asynchronously adds a `StorageInterface` with default settings to the `defaultStack`. Migrations are also initiated by default.
     ```
     CoreStore.addStorage(
         InMemoryStore.self,
         completion: { result in
             switch result {
             case .Success(let storage): // ...
             case .Failure(let error): // ...
             }
         }
     )
     ```
     
     - parameter storeType: the storage type
     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `SetupResult` argument indicates the result. Note that the `StorageInterface` associated to the `SetupResult.Success` may not always be the same instance as the parameter argument if a previous `StorageInterface` was already added at the same URL and with the same configuration.
     */
    public static func addStorage<T: StorageInterface where T: DefaultInitializableStore>(storeType: T.Type, completion: (SetupResult<T>) -> Void) {
        
        self.defaultStack.addStorage(storeType.init(), completion: completion)
    }

    /**
     Asynchronously adds a `StorageInterface` to the `defaultStack`. Migrations are also initiated by default.
     ```
     CoreStore.addStorage(
         InMemoryStore(configuration: "Config1"),
         completion: { result in
             switch result {
             case .Success(let storage): // ...
             case .Failure(let error): // ...
             }
         }
     )
     ```
     
     - parameter storage: the storage
     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `SetupResult` argument indicates the result. Note that the `StorageInterface` associated to the `SetupResult.Success` may not always be the same instance as the parameter argument if a previous `StorageInterface` was already added at the same URL and with the same configuration.
     */
    public static func addStorage<T: StorageInterface>(storage: T, completion: (SetupResult<T>) -> Void) {
        
        self.defaultStack.addStorage(storage, completion: completion)
    }
    
    /**
     Asynchronously adds a `LocalStorage` with default settings to the `defaultStack`. Migrations are also initiated by default.
     ```
     let migrationProgress = CoreStore.addStorage(
         SQLiteStore.self,
         completion: { result in
             switch result {
             case .Success(let storage): // ...
             case .Failure(let error): // ...
             }
         }
     )
     ```
     
     - parameter storeType: the local storage type
     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `SetupResult` argument indicates the result. Note that the `LocalStorage` associated to the `SetupResult.Success` may not always be the same instance as the parameter argument if a previous `LocalStorage` was already added at the same URL and with the same configuration.
     - returns: an `NSProgress` instance if a migration has started, or `nil` if either no migrations are required or if a failure occured.
     */
    public static func addStorage<T: LocalStorage where T: DefaultInitializableStore>(storeType: T.Type, completion: (SetupResult<T>) -> Void) -> NSProgress? {
        
        return self.defaultStack.addStorage(storeType.init(), completion: completion)
    }

    /**
     Asynchronously adds a `LocalStorage` to the `defaultStack`. Migrations are also initiated by default.
     ```
     let migrationProgress = CoreStore.addStorage(
         SQLiteStore(fileName: "core_data.sqlite", configuration: "Config1"),
         completion: { result in
             switch result {
             case .Success(let storage): // ...
             case .Failure(let error): // ...
             }
         }
     )
     ```
     
     - parameter storage: the local storage
     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `SetupResult` argument indicates the result. Note that the `LocalStorage` associated to the `SetupResult.Success` may not always be the same instance as the parameter argument if a previous `LocalStorage` was already added at the same URL and with the same configuration.
     - returns: an `NSProgress` instance if a migration has started, or `nil` if either no migrations are required or if a failure occured.
     */
    public static func addStorage<T: LocalStorage>(storage: T, completion: (SetupResult<T>) -> Void) -> NSProgress? {
        
        return self.defaultStack.addStorage(storage, completion: completion)
    }
    
    /**
     Asynchronously adds a `CloudStorage` to the `defaultStack`. Migrations are also initiated by default.
     ```
     guard let storage = ICloudStore(
         ubiquitousContentName: "MyAppCloudData",
         ubiquitousContentTransactionLogsSubdirectory: "logs/config1",
         ubiquitousContainerID: "iCloud.com.mycompany.myapp.containername",
         ubiquitousPeerToken: "9614d658014f4151a95d8048fb717cf0",
         configuration: "Config1",
         cloudStorageOptions: .RecreateLocalStoreOnModelMismatch
     ) else {
         // iCloud is not available on the device
         return
     }
     let migrationProgress = dataStack.addStorage(
         storage,
         completion: { result in
             switch result {
             case .Success(let storage): // ...
             case .Failure(let error): // ...
             }
         }
     )
     ```
     
     - parameter storage: the cloud storage
     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `SetupResult` argument indicates the result. Note that the `CloudStorage` associated to the `SetupResult.Success` may not always be the same instance as the parameter argument if a previous `CloudStorage` was already added at the same URL and with the same configuration.
     */
    public static func addStorage<T: CloudStorage>(storage: T, completion: (SetupResult<T>) -> Void) {
        
        self.defaultStack.addStorage(storage, completion: completion)
    }

    /**
     Migrates a local storage to match the `defaultStack`'s managed object model version. This method does NOT add the migrated store to the data stack.

     - parameter storage: the local storage
     - parameter completion: the closure to be executed on the main queue when the migration completes, either due to success or failure. The closure's `MigrationResult` argument indicates the result. This closure is NOT executed if an error is thrown, but will be executed with a `.Failure` result if an error occurs asynchronously.
     - throws: a `CoreStoreError` value indicating the failure
     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
     */
    public static func upgradeStorageIfNeeded<T: LocalStorage>(storage: T, completion: (MigrationResult) -> Void) throws -> NSProgress? {
        
        return try self.defaultStack.upgradeStorageIfNeeded(storage, completion: completion)
    }
    
    /**
     Checks the migration steps required for the storage to match the `defaultStack`'s managed object model version.
     
     - parameter storage: the local storage
     - throws: a `CoreStoreError` value indicating the failure
     - returns: a `MigrationType` array indicating the migration steps required for the store, or an empty array if the file does not exist yet. Otherwise, an error is thrown if either inspection of the store failed, or if no mapping model was found/inferred.
     */
    @warn_unused_result
    public static func requiredMigrationsForStorage<T: LocalStorage>(storage: T) throws -> [MigrationType] {
        
        return try self.defaultStack.requiredMigrationsForStorage(storage)
    }
    
    
    // MARK: Deprecated
    
    /**
     Deprecated. Use `addSQLiteStore(_:completion:)` by passing a `LegacySQLiteStore` instance.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was using this method prior to 2.0.0, make sure to use `LegacySQLiteStore`.
     */
    @available(*, deprecated=2.0.0, message="Use addSQLiteStore(_:completion:) by passing a LegacySQLiteStore instance. Warning: The default SQLite file location for the LegacySQLiteStore and SQLiteStore are different. If the app was using this method prior to 2.0.0, make sure to use LegacySQLiteStore.")
    public static func addSQLiteStore(fileName fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle]? = nil, resetStoreOnModelMismatch: Bool = false, completion: (PersistentStoreResult) -> Void) throws -> NSProgress? {
        
        return try self.defaultStack.addSQLiteStore(
            fileName: fileName,
            configuration: configuration,
            mappingModelBundles: mappingModelBundles,
            resetStoreOnModelMismatch: resetStoreOnModelMismatch,
            completion: completion
        )
    }
    
    /**
     Deprecated. Use `addSQLiteStore(_:completion:)` by passing a `LegacySQLiteStore` instance.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was using this method prior to 2.0.0, make sure to use `LegacySQLiteStore`.
     */
    @available(*, deprecated=2.0.0, message="Use addSQLiteStore(_:completion:) by passing a LegacySQLiteStore instance. Warning: The default SQLite file location for the LegacySQLiteStore and SQLiteStore are different. If the app was using this method prior to 2.0.0, make sure to use LegacySQLiteStore.")
    public static func addSQLiteStore(fileURL fileURL: NSURL = LegacySQLiteStore.defaultFileURL, configuration: String? = nil, mappingModelBundles: [NSBundle]? = NSBundle.allBundles(), resetStoreOnModelMismatch: Bool = false, completion: (PersistentStoreResult) -> Void) throws -> NSProgress? {
        
        return try self.defaultStack.addSQLiteStore(
            fileURL: fileURL,
            configuration: configuration,
            mappingModelBundles: mappingModelBundles,
            resetStoreOnModelMismatch: resetStoreOnModelMismatch,
            completion: completion
        )
    }
    
    /**
     Deprecated. Use `upgradeStorageIfNeeded(_:completion:)` by passing a `LegacySQLiteStore` instance.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was using this method prior to 2.0.0, make sure to use `LegacySQLiteStore`.
     */
    @available(*, deprecated=2.0.0, message="Use upgradeStorageIfNeeded(_:completion:) by passing a LegacySQLiteStore instance. Warning: The default SQLite file location for the LegacySQLiteStore and SQLiteStore are different. If the app was using this method prior to 2.0.0, make sure to use LegacySQLiteStore.")
    public static func upgradeSQLiteStoreIfNeeded(fileName fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle]? = nil, completion: (MigrationResult) -> Void) throws -> NSProgress? {
        
        return try self.defaultStack.upgradeSQLiteStoreIfNeeded(
            fileName: fileName,
            configuration: configuration,
            mappingModelBundles: mappingModelBundles ?? NSBundle.allBundles(),
            completion: completion
        )
    }
    
    /**
     Deprecated. Use `upgradeStorageIfNeeded(_:completion:)` by passing a `LegacySQLiteStore` instance.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was using this method prior to 2.0.0, make sure to use `LegacySQLiteStore`.
     */
    @available(*, deprecated=2.0.0, message="Use upgradeStorageIfNeeded(_:completion:) by passing a LegacySQLiteStore instance. Warning: The default SQLite file location for the LegacySQLiteStore and SQLiteStore are different. If the app was using this method prior to 2.0.0, make sure to use LegacySQLiteStore.")
    public static func upgradeSQLiteStoreIfNeeded(fileURL fileURL: NSURL = LegacySQLiteStore.defaultFileURL, configuration: String? = nil, mappingModelBundles: [NSBundle]? = nil, completion: (MigrationResult) -> Void) throws -> NSProgress? {
        
        return try self.defaultStack.upgradeSQLiteStoreIfNeeded(
            fileURL: fileURL,
            configuration: configuration,
            mappingModelBundles: mappingModelBundles ?? NSBundle.allBundles(),
            completion: completion
        )
    }
    
    /**
     Deprecated. Use `requiredMigrationsForStorage(_:)` by passing a `LegacySQLiteStore` instance.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was using this method prior to 2.0.0, make sure to use `LegacySQLiteStore`.
     */
    @available(*, deprecated=2.0.0, message="Use requiredMigrationsForStorage(_:) by passing a LegacySQLiteStore instance. Warning: The default SQLite file location for the LegacySQLiteStore and SQLiteStore are different. If the app was using this method prior to 2.0.0, make sure to use LegacySQLiteStore.")
    @warn_unused_result
    public static func requiredMigrationsForSQLiteStore(fileName fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles() as [NSBundle]) throws -> [MigrationType] {
        
        return try self.defaultStack.requiredMigrationsForSQLiteStore(
            fileName: fileName,
            configuration: configuration,
            mappingModelBundles: mappingModelBundles
        )
    }
    
    /**
     Deprecated. Use `requiredMigrationsForStorage(_:)` by passing a `LegacySQLiteStore` instance.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was using this method prior to 2.0.0, make sure to use `LegacySQLiteStore`.
     */
    @available(*, deprecated=2.0.0, message="Use requiredMigrationsForStorage(_:) by passing a LegacySQLiteStore instance. Warning: The default SQLite file location for the LegacySQLiteStore and SQLiteStore are different. If the app was using this method prior to 2.0.0, make sure to use LegacySQLiteStore.")
    @warn_unused_result
    public static func requiredMigrationsForSQLiteStore(fileURL fileURL: NSURL = LegacySQLiteStore.defaultFileURL, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles() as [NSBundle]) throws -> [MigrationType] {
        
        return try self.defaultStack.requiredMigrationsForSQLiteStore(
            fileURL: fileURL,
            configuration: configuration,
            mappingModelBundles: mappingModelBundles
        )
    }
}
