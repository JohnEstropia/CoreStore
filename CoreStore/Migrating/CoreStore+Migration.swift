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
     Asynchronously adds to the `defaultStack` an SQLite store from the given SQLite file name. Note that using `addSQLiteStore(...)` instead of `addSQLiteStoreAndWait(...)` implies that the migrations are allowed and expected (thus the asynchronous `completion`.)
     
     - parameter fileName: the local filename for the SQLite persistent store in the "Application Support" directory (or the "Caches" directory on tvOS). A new SQLite file will be created if it does not exist. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
     - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.allBundles()`.
     - parameter resetStoreOnModelMismatch: Set to true to delete the store on model mismatch; or set to false to report failure instead. Typically should only be set to true when debugging, or if the persistent store can be recreated easily. If not specified, defaults to false.
     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `PersistentStoreResult` argument indicates the result. This closure is NOT executed if an error is thrown, but will be executed with a `.Failure` result if an error occurs asynchronously.
     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
     */
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
     Asynchronously adds to the `defaultStack` an SQLite store from the given SQLite file URL. Note that using `addSQLiteStore(...)` instead of `addSQLiteStoreAndWait(...)` implies that the migrations are allowed and expected (thus the asynchronous `completion`.)
     
     - parameter fileURL: the local file URL for the SQLite persistent store. A new SQLite file will be created if it does not exist. If not specified, defaults to a file URL pointing to a "<Application name>.sqlite" file in the "Application Support" directory (or the "Caches" directory on tvOS). Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
     - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.allBundles()`.
     - parameter resetStoreOnModelMismatch: Set to true to delete the store on model mismatch; or set to false to report failure instead. Typically should only be set to true when debugging, or if the persistent store can be recreated easily. If not specified, defaults to false.
     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `PersistentStoreResult` argument indicates the result. This closure is NOT executed if an error is thrown, but will be executed with a `.Failure` result if an error occurs asynchronously.
     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
     */
    public static func addSQLiteStore(fileURL fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, mappingModelBundles: [NSBundle]? = NSBundle.allBundles(), resetStoreOnModelMismatch: Bool = false, completion: (PersistentStoreResult) -> Void) throws -> NSProgress? {
        
        return try self.defaultStack.addSQLiteStore(
            fileURL: fileURL,
            configuration: configuration,
            mappingModelBundles: mappingModelBundles,
            resetStoreOnModelMismatch: resetStoreOnModelMismatch,
            completion: completion
        )
    }
    
    /**
     Using the `defaultStack`, migrates an SQLite store with the specified filename to the `DataStack`'s managed object model version WITHOUT adding the migrated store to the data stack.
     
     - parameter fileName: the local filename for the SQLite persistent store in the "Application Support" directory (or the "Caches" directory on tvOS).
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
     - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
     - parameter sourceBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
     */
    public static func upgradeSQLiteStoreIfNeeded(fileName fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle]? = nil, completion: (MigrationResult) -> Void) throws -> NSProgress? {
        
        return try self.defaultStack.upgradeSQLiteStoreIfNeeded(
            fileName: fileName,
            configuration: configuration,
            mappingModelBundles: mappingModelBundles,
            completion: completion
        )
    }
    
    /**
     Using the `defaultStack`, migrates an SQLite store at the specified file URL and configuration name to the `DataStack`'s managed object model version. This method does NOT add the migrated store to the data stack.
     
     - parameter fileName: the local filename for the SQLite persistent store in the "Application Support" directory (or the "Caches" directory on tvOS).
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
     - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
     - parameter sourceBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
     */
    public static func upgradeSQLiteStoreIfNeeded(fileURL fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, mappingModelBundles: [NSBundle]? = nil, completion: (MigrationResult) -> Void) throws -> NSProgress? {
        
        return try self.defaultStack.upgradeSQLiteStoreIfNeeded(
            fileURL: fileURL,
            configuration: configuration,
            mappingModelBundles: mappingModelBundles,
            completion: completion
        )
    }
    
    /**
     Using the `defaultStack`, checks for the required migrations needed for the store with the specified filename and configuration to be migrated to the `DataStack`'s managed object model version. This method throws an error if the store does not exist, if inspection of the store failed, or no mapping model was found/inferred.
     
     - parameter fileName: the local filename for the SQLite persistent store in the "Application Support" directory (or the "Caches" directory on tvOS).
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
     - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.allBundles()`.
     :return: an array of `MigrationType`s indicating the chain of migrations required for the store; or `nil` if either inspection of the store failed, or no mapping model was found/inferred. `MigrationType` acts as a `Bool` and evaluates to `false` if no migration is required, and `true` if either a lightweight or custom migration is needed.
     */
    @warn_unused_result
    public static func requiredMigrationsForSQLiteStore(fileName fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles() as [NSBundle]) throws -> [MigrationType] {
        
        return try self.defaultStack.requiredMigrationsForSQLiteStore(
            fileName: fileName,
            configuration: configuration,
            mappingModelBundles: mappingModelBundles
        )
    }
    
    /**
     Using the `defaultStack`, checks if the store at the specified file URL and configuration needs to be migrated to the `DataStack`'s managed object model version.
     
     - parameter fileURL: the local file URL for the SQLite persistent store.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
     - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.allBundles()`.
     :return: a `MigrationType` indicating the type of migration required for the store; or `nil` if either inspection of the store failed, or no mapping model was found/inferred. `MigrationType` acts as a `Bool` and evaluates to `false` if no migration is required, and `true` if either a lightweight or custom migration is needed.
     */
    @warn_unused_result
    public static func requiredMigrationsForSQLiteStore(fileURL fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles() as [NSBundle]) throws -> [MigrationType] {
        
        return try self.defaultStack.requiredMigrationsForSQLiteStore(
            fileURL: fileURL,
            configuration: configuration,
            mappingModelBundles: mappingModelBundles
        )
    }
}
