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
    
    public static func addStorage<T: StorageInterface where T: DefaultInitializableStore>(storeType: T.Type, completion: (SetupResult<T>) -> Void) throws -> NSProgress? {
        
        return try self.defaultStack.addStorage(storeType.init(), completion: completion)
    }
    
    public static func addStorage<T: StorageInterface>(storage: T, completion: (SetupResult<T>) -> Void) throws -> NSProgress? {
        
        return try self.defaultStack.addStorage(storage, completion: completion)
    }
    
    public static func addStorage<T: LocalStorage where T: DefaultInitializableStore>(storeType: T.Type, completion: (SetupResult<T>) -> Void) throws -> NSProgress? {
        
        return try self.defaultStack.addStorage(storeType.init(), completion: completion)
    }
    
    public static func addStorage<T: LocalStorage>(storage: T, completion: (SetupResult<T>) -> Void) throws -> NSProgress? {
        
        return try self.defaultStack.addStorage(storage, completion: completion)
    }
    
    public static func upgradeStorageIfNeeded<T: LocalStorage>(storage: T, completion: (MigrationResult) -> Void) throws -> NSProgress? {
        
        return try self.defaultStack.upgradeStorageIfNeeded(storage, completion: completion)
    }
    
    @warn_unused_result
    public static func requiredMigrationsForStorage<T: LocalStorage>(storage: T) throws -> [MigrationType] {
        
        return try self.defaultStack.requiredMigrationsForStorage(storage)
    }
    
    
    // MARK: Internal
    
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
