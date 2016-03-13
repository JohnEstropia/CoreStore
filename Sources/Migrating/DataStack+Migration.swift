//
//  DataStack+Migration.swift
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


// MARK: - DataStack

public extension DataStack {
    
    public func addStorage<T: StorageInterface where T: DefaultInitializableStore>(storeType: T.Type, completion: (SetupResult<T>) -> Void) throws -> NSProgress? {
        
        return try self.addStorage(storeType.init(), completion: completion)
    }
    
    public func addStorage<T: StorageInterface>(storage: T, completion: (SetupResult<T>) -> Void) throws -> NSProgress? {
        
        self.coordinator.performBlock {
            
            if let _ = self.persistentStoreForStorage(storage) {
                
                GCDQueue.Main.async {
                    
                    completion(SetupResult(storage))
                }
                return
            }
            
            do {
                
                try self.createPersistentStoreFromStorage(storage, finalURL: nil)
                
                GCDQueue.Main.async {
                    
                    completion(SetupResult(storage))
                }
            }
            catch {
                
                let storeError = error as NSError
                CoreStore.handleError(
                    storeError,
                    "Failed to add \(typeName(storage)) to the stack."
                )
                
                GCDQueue.Main.async {
                    
                    completion(SetupResult(storeError))
                }
            }
        }
        
        return nil
    }
    
    public func addStorage<T: LocalStorage where T: DefaultInitializableStore>(storeType: T.Type, completion: (SetupResult<T>) -> Void) throws -> NSProgress? {
        
        return try self.addStorage(storeType.init(), completion: completion)
    }
    
    /**
     Asynchronously adds to the stack an SQLite store from the given SQLite file URL. Note that using `addSQLiteStore(...)` instead of `addSQLiteStoreAndWait(...)` implies that the migrations are allowed and expected (thus the asynchronous `completion`.)
     
     - parameter fileURL: the local file URL for the SQLite persistent store. A new SQLite file will be created if it does not exist. If not specified, defaults to a file URL pointing to a "<Application name>.sqlite" file in the "Application Support/<bundle id>" directory (or the "Caches/<bundle id>" directory on tvOS). Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
     - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.allBundles()`.
     - parameter resetStoreOnModelMismatch: Set to true to delete the store on model mismatch; or set to false to report failure instead. Typically should only be set to true when debugging, or if the persistent store can be recreated easily. If not specified, defaults to false.
     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `PersistentStoreResult` argument indicates the result. This closure is NOT executed if an error is thrown, but will be executed with a `.Failure` result if an error occurs asynchronously.
     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
     */
    public func addStorage<T: LocalStorage>(storage: T, completion: (SetupResult<T>) -> Void) throws -> NSProgress? {
        
        let fileURL = storage.fileURL
        CoreStore.assert(
            fileURL.fileURL,
            "The specified URL for the \(typeName(storage)) is invalid: \"\(fileURL)\""
        )
        
        return try self.coordinator.performBlockAndWait {
            
            if let _ = self.persistentStoreForStorage(storage) {
                
                GCDQueue.Main.async {
                    
                    completion(SetupResult(storage))
                }
                return nil
            }
            
            if let persistentStore = self.coordinator.persistentStoreForURL(fileURL) {
                
                if let existingStorage = persistentStore.storageInterface as? T
                    where storage.matchesPersistentStore(persistentStore) {
                    
                    GCDQueue.Main.async {
                        
                        completion(SetupResult(existingStorage))
                    }
                    return nil
                }
                
                let error = NSError(coreStoreErrorCode: .DifferentPersistentStoreExistsAtURL)
                CoreStore.handleError(
                    error,
                    "Failed to add \(typeName(storage)) at \"\(fileURL)\" because a different \(typeName(NSPersistentStore)) at that URL already exists."
                )
                throw error
            }
            
            do {
                
                try NSFileManager.defaultManager().createDirectoryAtURL(
                    fileURL.URLByDeletingLastPathComponent!,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                
                let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
                    storage.dynamicType.storeType,
                    URL: fileURL,
                    options: storage.storeOptions
                )
                
                return self.upgradeStorageIfNeeded(
                    storage,
                    metadata: metadata,
                    completion: { (result) -> Void in
                        
                        if case .Failure(let error) = result {
                            
                            if storage.resetStoreOnModelMismatch && error.isCoreDataMigrationError {
                                
                                do {
                                    
                                    try _ = self.model[metadata].flatMap(storage.eraseStorageAndWait)
                                    try self.addStorageAndWait(storage)
                                    
                                    GCDQueue.Main.async {
                                        
                                        completion(SetupResult(storage))
                                    }
                                }
                                catch {
                                    
                                    completion(SetupResult(error as NSError))
                                }
                                return
                            }
                            
                            completion(SetupResult(error))
                            return
                        }
                        
                        do {
                            
                            try self.addStorageAndWait(storage)
                            
                            completion(SetupResult(storage))
                        }
                        catch {
                            
                            completion(SetupResult(error as NSError))
                        }
                    }
                )
            }
            catch let error as NSError
                where error.code == NSFileReadNoSuchFileError && error.domain == NSCocoaErrorDomain {
                    
                    try self.addStorageAndWait(storage)
                    
                    GCDQueue.Main.async {
                        
                        completion(SetupResult(storage))
                    }
                    return nil
            }
            catch {
                
                CoreStore.handleError(
                    error as NSError,
                    "Failed to load SQLite \(typeName(NSPersistentStore)) metadata."
                )
                throw error
            }
        }
    }
    
    /**
     Migrates an SQLite store at the specified file URL and configuration name to the `DataStack`'s managed object model version. This method does NOT add the migrated store to the data stack.
     
     - parameter fileName: the local filename for the SQLite persistent store in the "Application Support/<bundle id>" directory (or the "Caches/<bundle id>" directory on tvOS).
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
     - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
     - parameter sourceBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
     */
    public func upgradeStorageIfNeeded<T: LocalStorage>(storage: T, completion: (MigrationResult) -> Void) throws -> NSProgress? {
        
        return try self.coordinator.performBlockAndWait {
            
            let fileURL = storage.fileURL
            do {
                
                CoreStore.assert(
                    self.persistentStoreForStorage(storage) == nil,
                    "Attempted to migrate an already added \(typeName(storage)) at URL \"\(fileURL)\""
                )
                
                let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
                    storage.dynamicType.storeType,
                    URL: fileURL,
                    options: storage.storeOptions
                )
                return self.upgradeStorageIfNeeded(
                    storage,
                    metadata: metadata,
                    completion: completion
                )
            }
            catch {
                
                CoreStore.handleError(
                    error as NSError,
                    "Failed to load \(typeName(storage)) metadata from URL \"\(fileURL)\"."
                )
                throw error
            }
        }
    }
    
    
    /**
     Checks if the storage needs to be migrated to the `DataStack`'s managed object model version.
     
     - parameter fileURL: the local file URL for the SQLite persistent store.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
     - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.allBundles()`.
     :return: a `MigrationType` indicating the type of migration required for the store; or `nil` if either inspection of the store failed, or no mapping model was found/inferred. `MigrationType` acts as a `Bool` and evaluates to `false` if no migration is required, and `true` if either a lightweight or custom migration is needed.
     */
    @warn_unused_result
    public func requiredMigrationsForStorage<T: LocalStorage>(storage: T) throws -> [MigrationType] {
        
        return try self.coordinator.performBlockAndWait {
            
            let fileURL = storage.fileURL
            
            CoreStore.assert(
                self.persistentStoreForStorage(storage) == nil,
                "Attempted to query required migrations for an already added \(typeName(storage)) at URL \"\(fileURL)\""
            )
            do {
                
                let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
                    storage.dynamicType.storeType,
                    URL: fileURL,
                    options: storage.storeOptions
                )
                
                guard let migrationSteps = self.computeMigrationFromStorageMetadata(metadata, configuration: storage.configuration, mappingModelBundles: storage.mappingModelBundles) else {
                    
                    let error = NSError(coreStoreErrorCode: .MappingModelNotFound)
                    CoreStore.handleError(
                        error,
                        "Failed to find migration steps from the \(typeName(storage)) at URL \"\(fileURL)\" to version model \"\(self.modelVersion)\"."
                    )
                    throw error
                }
                
                return migrationSteps.map { $0.migrationType }
            }
            catch let error as NSError
                where error.code == NSFileReadNoSuchFileError && error.domain == NSCocoaErrorDomain {
                    
                    return []
            }
            catch {
                
                CoreStore.handleError(
                    error as NSError,
                    "Failed to load \(typeName(storage)) metadata from URL \"\(fileURL)\"."
                )
                throw error
            }
        }
    }
    
    
    // MARK: Private
    
    private func upgradeStorageIfNeeded<T: LocalStorage>(storage: T, metadata: [String: AnyObject], completion: (MigrationResult) -> Void) -> NSProgress? {
        
        guard let migrationSteps = self.computeMigrationFromStorageMetadata(metadata, configuration: storage.configuration, mappingModelBundles: storage.mappingModelBundles) else {
            
            CoreStore.handleError(
                NSError(coreStoreErrorCode: .MappingModelNotFound),
                "Failed to find migration steps from \(typeName(storage)) at URL \"\(storage.fileURL )\" to version model \"\(model)\"."
            )
            
            GCDQueue.Main.async {
                
                completion(MigrationResult(.MappingModelNotFound))
            }
            return nil
        }
        
        let numberOfMigrations: Int64 = Int64(migrationSteps.count)
        if numberOfMigrations == 0 {
            
            GCDQueue.Main.async {
                
                completion(MigrationResult([]))
                return
            }
            return nil
        }
        
        let migrationTypes = migrationSteps.map { $0.migrationType }
        var migrationResult: MigrationResult?
        var operations = [NSOperation]()
        var cancelled = false
        
        let progress = NSProgress(parent: nil, userInfo: nil)
        progress.totalUnitCount = numberOfMigrations
        
        for (sourceModel, destinationModel, mappingModel, _) in migrationSteps {
            
            progress.becomeCurrentWithPendingUnitCount(1)
            
            let childProgress = NSProgress(parent: progress, userInfo: nil)
            childProgress.totalUnitCount = 100
            
            operations.append(
                NSBlockOperation { [weak self] in
                    
                    guard let `self` = self where !cancelled else {
                        
                        return
                    }
                    
                    autoreleasepool {
                        
                        do {
                            
                            try self.startMigrationForStorage(
                                storage,
                                sourceModel: sourceModel,
                                destinationModel: destinationModel,
                                mappingModel: mappingModel,
                                progress: childProgress
                            )
                        }
                        catch {
                            
                            migrationResult = MigrationResult(error as NSError)
                            cancelled = true
                        }
                    }
                    
                    GCDQueue.Main.async {
                        
                        _ = withExtendedLifetime(childProgress) { (_: NSProgress) -> Void in }
                    }
                }
            )
            
            progress.resignCurrent()
        }
        
        let migrationOperation = NSBlockOperation()
        migrationOperation.qualityOfService = .Utility
        operations.forEach { migrationOperation.addDependency($0) }
        migrationOperation.addExecutionBlock { () -> Void in
            
            GCDQueue.Main.async {
                
                progress.setProgressHandler(nil)
                completion(migrationResult ?? MigrationResult(migrationTypes))
                return
            }
        }
        
        operations.append(migrationOperation)
        
        self.migrationQueue.addOperations(operations, waitUntilFinished: false)
        
        return progress
    }
    
    private func computeMigrationFromStorageMetadata(metadata: [String: AnyObject], configuration: String?, mappingModelBundles: [NSBundle]) -> [(sourceModel: NSManagedObjectModel, destinationModel: NSManagedObjectModel, mappingModel: NSMappingModel, migrationType: MigrationType)]? {
        
        let model = self.model
        if model.isConfiguration(configuration, compatibleWithStoreMetadata: metadata) {
            
            return []
        }
        
        guard let initialModel = model[metadata],
            var currentVersion = initialModel.currentModelVersion else {
                
                return nil
        }
        
        let migrationChain: MigrationChain = self.migrationChain.empty
            ? [currentVersion: model.currentModelVersion!]
            : self.migrationChain
        
        var migrationSteps = [(sourceModel: NSManagedObjectModel, destinationModel: NSManagedObjectModel, mappingModel: NSMappingModel, migrationType: MigrationType)]()
        
        while let nextVersion = migrationChain.nextVersionFrom(currentVersion),
            let sourceModel = model[currentVersion],
            let destinationModel = model[nextVersion] where sourceModel != model {
                
                if let mappingModel = NSMappingModel(
                    fromBundles: mappingModelBundles,
                    forSourceModel: sourceModel,
                    destinationModel: destinationModel) {
                        
                        migrationSteps.append(
                            (
                                sourceModel: sourceModel,
                                destinationModel: destinationModel,
                                mappingModel: mappingModel,
                                migrationType: .Heavyweight(
                                    sourceVersion: currentVersion,
                                    destinationVersion: nextVersion
                                )
                            )
                        )
                }
                else {
                    
                    do {
                        
                        let mappingModel = try NSMappingModel.inferredMappingModelForSourceModel(
                            sourceModel,
                            destinationModel: destinationModel
                        )
                        
                        migrationSteps.append(
                            (
                                sourceModel: sourceModel,
                                destinationModel: destinationModel,
                                mappingModel: mappingModel,
                                migrationType: .Lightweight(
                                    sourceVersion: currentVersion,
                                    destinationVersion: nextVersion
                                )
                            )
                        )
                    }
                    catch {
                        
                        return nil
                    }
                }
                currentVersion = nextVersion
        }
        
        if migrationSteps.last?.destinationModel == model {
            
            return migrationSteps
        }
        
        return nil
    }
    
    private func startMigrationForStorage<T: LocalStorage>(storage: T, sourceModel: NSManagedObjectModel, destinationModel: NSManagedObjectModel, mappingModel: NSMappingModel, progress: NSProgress) throws {
        
        let fileURL = storage.fileURL
        
        let temporaryDirectoryURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .URLByAppendingPathComponent(NSBundle.mainBundle().bundleIdentifier ?? "com.CoreStore.DataStack")
            .URLByAppendingPathComponent(NSProcessInfo().globallyUniqueString)
        
        let fileManager = NSFileManager.defaultManager()
        try! fileManager.createDirectoryAtURL(
            temporaryDirectoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        let temporaryFileURL = temporaryDirectoryURL.URLByAppendingPathComponent(
            fileURL.lastPathComponent!,
            isDirectory: false
        )
        
        let migrationManager = MigrationManager(
            sourceModel: sourceModel,
            destinationModel: destinationModel,
            progress: progress
        )
        
        do {
            
            try migrationManager.migrateStoreFromURL(
                fileURL,
                type: storage.dynamicType.storeType,
                options: nil,
                withMappingModel: mappingModel,
                toDestinationURL: temporaryFileURL,
                destinationType: storage.dynamicType.storeType,
                destinationOptions: nil
            )
        }
        catch {
            
            do {
                
                try fileManager.removeItemAtURL(temporaryFileURL)
            }
            catch _ { }
            
            let sourceVersion = migrationManager.sourceModel.currentModelVersion ?? "???"
            let destinationVersion = migrationManager.destinationModel.currentModelVersion ?? "???"
            CoreStore.handleError(
                error as NSError,
                "Failed to migrate from version model \"\(sourceVersion)\" to version model \"\(destinationVersion)\"."
            )
            
            throw error
        }
        
        do {
            
            try fileManager.replaceItemAtURL(
                fileURL,
                withItemAtURL: temporaryFileURL,
                backupItemName: nil,
                options: [],
                resultingItemURL: nil
            )
            
            progress.completedUnitCount = progress.totalUnitCount
        }
        catch {
            
            do {
                
                try fileManager.removeItemAtURL(temporaryFileURL)
            }
            catch _ { }
            
            let sourceVersion = migrationManager.sourceModel.currentModelVersion ?? "???"
            let destinationVersion = migrationManager.destinationModel.currentModelVersion ?? "???"
            CoreStore.handleError(
                error as NSError,
                "Failed to save store after migrating from version model \"\(sourceVersion)\" to version model \"\(destinationVersion)\"."
            )
            
            throw error
        }
    }
    
    
    // MARK: Deprecated
    
    /**
     Deprecated. Use `addStorage(_:completion:)` by passing a `InMemoryStore` instance.
     */
    @available(*, deprecated=2.0.0, message="Use addStorage(_:completion:) by passing a InMemoryStore instance.")
    public func addInMemoryStore(configuration configuration: String? = nil, completion: (PersistentStoreResult) -> Void) {
        
        do {
         
            try self.addStorage(
                InMemoryStore(configuration: configuration),
                completion: { result in
                    
                    switch result {
                        
                    case .Success(let storage):
                        completion(PersistentStoreResult(self.persistentStoreForStorage(storage)!))
                        
                    case .Failure(let error):
                        completion(PersistentStoreResult(error))
                    }
                }
            )
        }
        catch {
            
            completion(PersistentStoreResult(error as NSError))
        }
    }
    
    /**
     Deprecated. Use `addStorage(_:completion:)` by passing a `LegacySQLiteStore` instance.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was using this method prior to 2.0.0, make sure to use `LegacySQLiteStore`.
     */
    @available(*, deprecated=2.0.0, message="Use addStorage(_:completion:) by passing a LegacySQLiteStore instance. Warning: The default SQLite file location for the LegacySQLiteStore and SQLiteStore are different. If the app was using this method prior to 2.0.0, make sure to use LegacySQLiteStore.")
    public func addSQLiteStore(fileName fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle]? = nil, resetStoreOnModelMismatch: Bool = false, completion: (PersistentStoreResult) -> Void) throws -> NSProgress? {
        
        return try self.addStorage(
            LegacySQLiteStore(
                fileName: fileName,
                configuration: configuration,
                mappingModelBundles: mappingModelBundles ?? NSBundle.allBundles(),
                resetStoreOnModelMismatch: resetStoreOnModelMismatch
            ),
            completion: { result in
                
                switch result {
                    
                case .Success(let storage):
                    completion(PersistentStoreResult(self.persistentStoreForStorage(storage)!))
                    
                case .Failure(let error):
                    completion(PersistentStoreResult(error))
                }
            }
        )
    }
    
    /**
     Deprecated. Use `addSQLiteStore(_:completion:)` by passing a `LegacySQLiteStore` instance.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was using this method prior to 2.0.0, make sure to use `LegacySQLiteStore`.
     */
    @available(*, deprecated=2.0.0, message="Use addSQLiteStore(_:completion:) by passing a LegacySQLiteStore instance. Warning: The default SQLite file location for the LegacySQLiteStore and SQLiteStore are different. If the app was using this method prior to 2.0.0, make sure to use LegacySQLiteStore.")
    public func addSQLiteStore(fileURL fileURL: NSURL = LegacySQLiteStore.defaultFileURL, configuration: String? = nil, mappingModelBundles: [NSBundle]? = NSBundle.allBundles(), resetStoreOnModelMismatch: Bool = false, completion: (PersistentStoreResult) -> Void) throws -> NSProgress? {
        
        return try self.addStorage(
            LegacySQLiteStore(
                fileURL: fileURL,
                configuration: configuration,
                mappingModelBundles: mappingModelBundles ?? NSBundle.allBundles(),
                resetStoreOnModelMismatch: resetStoreOnModelMismatch
            ),
            completion: { result in
                
                switch result {
                    
                case .Success(let storage):
                    completion(PersistentStoreResult(self.persistentStoreForStorage(storage)!))
                    
                case .Failure(let error):
                    completion(PersistentStoreResult(error))
                }
            }
        )
    }
    
    /**
     Deprecated. Use `upgradeStorageIfNeeded(_:completion:)` by passing a `LegacySQLiteStore` instance.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was using this method prior to 2.0.0, make sure to use `LegacySQLiteStore`.
     */
    @available(*, deprecated=2.0.0, message="Use upgradeStorageIfNeeded(_:completion:) by passing a LegacySQLiteStore instance. Warning: The default SQLite file location for the LegacySQLiteStore and SQLiteStore are different. If the app was using this method prior to 2.0.0, make sure to use LegacySQLiteStore.")
    public func upgradeSQLiteStoreIfNeeded(fileName fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles(), completion: (MigrationResult) -> Void) throws -> NSProgress? {
        
        return try self.upgradeStorageIfNeeded(
            LegacySQLiteStore(
                fileName: fileName,
                configuration: configuration,
                mappingModelBundles: mappingModelBundles
            ),
            completion: completion
        )
    }
    
    /**
     Deprecated. Use `upgradeStorageIfNeeded(_:completion:)` by passing a `LegacySQLiteStore` instance.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was using this method prior to 2.0.0, make sure to use `LegacySQLiteStore`.
     */
    @available(*, deprecated=2.0.0, message="Use upgradeStorageIfNeeded(_:completion:) by passing a LegacySQLiteStore instance. Warning: The default SQLite file location for the LegacySQLiteStore and SQLiteStore are different. If the app was using this method prior to 2.0.0, make sure to use LegacySQLiteStore.")
    public func upgradeSQLiteStoreIfNeeded(fileURL fileURL: NSURL = LegacySQLiteStore.defaultFileURL, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles(), completion: (MigrationResult) -> Void) throws -> NSProgress? {
        
        return try self.upgradeStorageIfNeeded(
            LegacySQLiteStore(
                fileURL: fileURL,
                configuration: configuration,
                mappingModelBundles: mappingModelBundles
            ),
            completion: completion
        )
    }
    
    /**
     Deprecated. Use `requiredMigrationsForStorage(_:)` by passing a `LegacySQLiteStore` instance.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was using this method prior to 2.0.0, make sure to use `LegacySQLiteStore`.
     */
    @available(*, deprecated=2.0.0, message="Use requiredMigrationsForStorage(_:) by passing a LegacySQLiteStore instance. Warning: The default SQLite file location for the LegacySQLiteStore and SQLiteStore are different. If the app was using this method prior to 2.0.0, make sure to use LegacySQLiteStore.")
    @warn_unused_result
    public func requiredMigrationsForSQLiteStore(fileName fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles() as [NSBundle]) throws -> [MigrationType] {
        
        return try self.requiredMigrationsForStorage(
            LegacySQLiteStore(
                fileName: fileName,
                configuration: configuration,
                mappingModelBundles: mappingModelBundles
            )
        )
    }
    
    /**
     Deprecated. Use `requiredMigrationsForStorage(_:)` by passing a `LegacySQLiteStore` instance.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was using this method prior to 2.0.0, make sure to use `LegacySQLiteStore`.
     */
    @available(*, deprecated=2.0.0, message="Use requiredMigrationsForStorage(_:) by passing a LegacySQLiteStore instance. Warning: The default SQLite file location for the LegacySQLiteStore and SQLiteStore are different. If the app was using this method prior to 2.0.0, make sure to use LegacySQLiteStore.")
    @warn_unused_result
    public func requiredMigrationsForSQLiteStore(fileURL fileURL: NSURL = LegacySQLiteStore.defaultFileURL, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles() as [NSBundle]) throws -> [MigrationType] {
        
        return try self.requiredMigrationsForStorage(
            LegacySQLiteStore(
                fileURL: fileURL,
                configuration: configuration,
                mappingModelBundles: mappingModelBundles
            )
        )
    }
}
