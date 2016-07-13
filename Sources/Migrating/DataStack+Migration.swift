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
    
    /**
     Asynchronously adds a `StorageInterface` with default settings to the stack. Migrations are also initiated by default.
     ```
     dataStack.addStorage(
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
    public func addStorage<T: StorageInterface where T: DefaultInitializableStore>(storeType: T.Type, completion: (SetupResult<T>) -> Void) {
        
        self.addStorage(storeType.init(), completion: completion)
    }
    
    /**
     Asynchronously adds a `StorageInterface` to the stack. Migrations are also initiated by default.
     ```
     dataStack.addStorage(
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
    public func addStorage<T: StorageInterface>(storage: T, completion: (SetupResult<T>) -> Void) {
        
        self.coordinator.performAsynchronously {
            
            if let _ = self.persistentStoreForStorage(storage) {
                
                GCDQueue.Main.async {
                    
                    completion(SetupResult(storage))
                }
                return
            }
            
            do {
                
                try self.createPersistentStoreFromStorage(
                    storage,
                    finalURL: nil,
                    finalStoreOptions: storage.storeOptions
                )
                
                GCDQueue.Main.async {
                    
                    completion(SetupResult(storage))
                }
            }
            catch {
                
                let storeError = CoreStoreError(error)
                CoreStore.log(
                    storeError,
                    "Failed to add \(cs_typeName(storage)) to the stack."
                )
                GCDQueue.Main.async {
                    
                    completion(SetupResult(storeError))
                }
            }
        }
    }
    
    /**
     Asynchronously adds a `LocalStorage` with default settings to the stack. Migrations are also initiated by default.
     ```
     let migrationProgress = dataStack.addStorage(
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
    public func addStorage<T: LocalStorage where T: DefaultInitializableStore>(storeType: T.Type, completion: (SetupResult<T>) -> Void) -> NSProgress? {
        
        return self.addStorage(storeType.init(), completion: completion)
    }
    
    /**
     Asynchronously adds a `LocalStorage` to the stack. Migrations are also initiated by default.
     ```
     let migrationProgress = dataStack.addStorage(
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
    public func addStorage<T: LocalStorage>(storage: T, completion: (SetupResult<T>) -> Void) -> NSProgress? {
        
        let fileURL = storage.fileURL
        CoreStore.assert(
            fileURL.fileURL,
            "The specified URL for the \(cs_typeName(storage)) is invalid: \"\(fileURL)\""
        )
        
        return self.coordinator.performSynchronously {
            
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
                
                let error = CoreStoreError.DifferentStorageExistsAtURL(existingPersistentStoreURL: fileURL)
                CoreStore.log(
                    error,
                    "Failed to add \(cs_typeName(storage)) at \"\(fileURL)\" because a different \(cs_typeName(NSPersistentStore)) at that URL already exists."
                )
                GCDQueue.Main.async {
                    
                    completion(SetupResult(error))
                }
                return nil
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
                        
                        if case .Failure(.InternalError(let error)) = result {
                            
                            if storage.localStorageOptions.contains(.RecreateStoreOnModelMismatch) && error.isCoreDataMigrationError {
                                
                                do {
                                    
                                    try _ = self.model[metadata].flatMap(storage.eraseStorageAndWait)
                                    try self.addStorageAndWait(storage)
                                    
                                    GCDQueue.Main.async {
                                        
                                        completion(SetupResult(storage))
                                    }
                                }
                                catch {
                                    
                                    completion(SetupResult(error))
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
                            
                            completion(SetupResult(error))
                        }
                    }
                )
            }
            catch let error as NSError
                where error.code == NSFileReadNoSuchFileError && error.domain == NSCocoaErrorDomain {
                    
                    do {
                        
                        try self.addStorageAndWait(storage)
                        
                        GCDQueue.Main.async {
                            
                            completion(SetupResult(storage))
                        }
                    }
                    catch {
                        
                        GCDQueue.Main.async {
                            
                            completion(SetupResult(error))
                        }
                    }
                    return nil
            }
            catch {
                
                let storeError = CoreStoreError(error)
                CoreStore.log(
                    storeError,
                    "Failed to load SQLite \(cs_typeName(NSPersistentStore)) metadata."
                )
                GCDQueue.Main.async {
                    
                    completion(SetupResult(storeError))
                }
                return nil
            }
        }
    }
    
    /**
     Asynchronously adds a `CloudStorage` to the stack. Migrations are also initiated by default.
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
     dataStack.addStorage(
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
    public func addStorage<T: CloudStorage>(storage: T, completion: (SetupResult<T>) -> Void)  {
        
        let cacheFileURL = storage.cacheFileURL
        self.coordinator.performSynchronously {
            
            if let _ = self.persistentStoreForStorage(storage) {
                
                GCDQueue.Main.async {
                    
                    completion(SetupResult(storage))
                }
                return
            }
            
            if let persistentStore = self.coordinator.persistentStoreForURL(cacheFileURL) {
                
                if let existingStorage = persistentStore.storageInterface as? T
                    where storage.matchesPersistentStore(persistentStore) {
                    
                    GCDQueue.Main.async {
                        
                        completion(SetupResult(existingStorage))
                    }
                    return
                }
                
                let error = CoreStoreError.DifferentStorageExistsAtURL(existingPersistentStoreURL: cacheFileURL)
                CoreStore.log(
                    error,
                    "Failed to add \(cs_typeName(storage)) at \"\(cacheFileURL)\" because a different \(cs_typeName(NSPersistentStore)) at that URL already exists."
                )
                GCDQueue.Main.async {
                    
                    completion(SetupResult(error))
                }
                return
            }
            
            do {
                
                var cloudStorageOptions = storage.cloudStorageOptions
                cloudStorageOptions.remove(.RecreateLocalStoreOnModelMismatch)
                
                let storeOptions = storage.storeOptionsForOptions(cloudStorageOptions)
                do {
                    
                    try NSFileManager.defaultManager().createDirectoryAtURL(
                        cacheFileURL.URLByDeletingLastPathComponent!,
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    try self.createPersistentStoreFromStorage(
                        storage,
                        finalURL: cacheFileURL,
                        finalStoreOptions: storeOptions
                    )
                    GCDQueue.Main.async {
                        
                        completion(SetupResult(storage))
                    }
                }
                catch let error as NSError where storage.cloudStorageOptions.contains(.RecreateLocalStoreOnModelMismatch) && error.isCoreDataMigrationError {
                    
                    let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
                        storage.dynamicType.storeType,
                        URL: cacheFileURL,
                        options: storeOptions
                    )
                    try _ = self.model[metadata].flatMap(storage.eraseStorageAndWait)
                    
                    try self.createPersistentStoreFromStorage(
                        storage,
                        finalURL: cacheFileURL,
                        finalStoreOptions: storeOptions
                    )
                }
            }
            catch let error as NSError
                where error.code == NSFileReadNoSuchFileError && error.domain == NSCocoaErrorDomain {
                    
                    do {
                        
                        try self.addStorageAndWait(storage)
                        
                        GCDQueue.Main.async {
                            
                            completion(SetupResult(storage))
                        }
                    }
                    catch {
                        
                        GCDQueue.Main.async {
                            
                            completion(SetupResult(error))
                        }
                    }
            }
            catch {
                
                let storeError = CoreStoreError(error)
                CoreStore.log(
                    storeError,
                    "Failed to load \(cs_typeName(NSPersistentStore)) metadata."
                )
                GCDQueue.Main.async {
                    
                    completion(SetupResult(storeError))
                }
            }
        }
    }
    
    /**
     Migrates a local storage to match the `DataStack`'s managed object model version. This method does NOT add the migrated store to the data stack.
     
     - parameter storage: the local storage
     - parameter completion: the closure to be executed on the main queue when the migration completes, either due to success or failure. The closure's `MigrationResult` argument indicates the result.
     - throws: a `CoreStoreError` value indicating the failure
     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
     */
    public func upgradeStorageIfNeeded<T: LocalStorage>(storage: T, completion: (MigrationResult) -> Void) throws -> NSProgress? {
        
        return try self.coordinator.performSynchronously {
            
            let fileURL = storage.fileURL
            do {
                
                CoreStore.assert(
                    self.persistentStoreForStorage(storage) == nil,
                    "Attempted to migrate an already added \(cs_typeName(storage)) at URL \"\(fileURL)\""
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
                
                let metadataError = CoreStoreError(error)
                CoreStore.log(
                    metadataError,
                    "Failed to load \(cs_typeName(storage)) metadata from URL \"\(fileURL)\"."
                )
                throw metadataError
            }
        }
    }
    
    /**
     Checks the migration steps required for the storage to match the `DataStack`'s managed object model version.
     
     - parameter storage: the local storage
     - throws: a `CoreStoreError` value indicating the failure
     - returns: a `MigrationType` array indicating the migration steps required for the store, or an empty array if the file does not exist yet. Otherwise, an error is thrown if either inspection of the store failed, or if no mapping model was found/inferred.
     */
    @warn_unused_result
    public func requiredMigrationsForStorage<T: LocalStorage>(storage: T) throws -> [MigrationType] {
        
        return try self.coordinator.performSynchronously {
            
            let fileURL = storage.fileURL
            
            CoreStore.assert(
                self.persistentStoreForStorage(storage) == nil,
                "Attempted to query required migrations for an already added \(cs_typeName(storage)) at URL \"\(fileURL)\""
            )
            do {
                
                let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
                    storage.dynamicType.storeType,
                    URL: fileURL,
                    options: storage.storeOptions
                )
                
                guard let migrationSteps = self.computeMigrationFromStorage(storage, metadata: metadata) else {
                    
                    let error = CoreStoreError.MappingModelNotFound(
                        localStoreURL: fileURL,
                        targetModel: self.model,
                        targetModelVersion: self.modelVersion
                    )
                    CoreStore.log(
                        error,
                        "Failed to find migration steps from the \(cs_typeName(storage)) at URL \"\(fileURL)\" to version model \"\(self.modelVersion)\"."
                    )
                    throw error
                }
                
                if migrationSteps.count > 1 && storage.localStorageOptions.contains(.PreventProgressiveMigration) {
                    
                    let error = CoreStoreError.ProgressiveMigrationRequired(localStoreURL: fileURL)
                    CoreStore.log(
                        error,
                        "Failed to find migration mapping from the \(cs_typeName(storage)) at URL \"\(fileURL)\" to version model \"\(self.modelVersion)\" without requiring progessive migrations."
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
                
                let metadataError = CoreStoreError(error)
                CoreStore.log(
                    metadataError,
                    "Failed to load \(cs_typeName(storage)) metadata from URL \"\(fileURL)\"."
                )
                throw metadataError
            }
        }
    }
    
    
    // MARK: Private
    
    private func upgradeStorageIfNeeded<T: LocalStorage>(storage: T, metadata: [String: AnyObject], completion: (MigrationResult) -> Void) -> NSProgress? {
        
        guard let migrationSteps = self.computeMigrationFromStorage(storage, metadata: metadata) else {
            
            let error = CoreStoreError.MappingModelNotFound(
                localStoreURL: storage.fileURL,
                targetModel: self.model,
                targetModelVersion: self.modelVersion
            )
            CoreStore.log(
                error,
                "Failed to find migration steps from \(cs_typeName(storage)) at URL \"\(storage.fileURL)\" to version model \"\(self.model)\"."
            )
            
            GCDQueue.Main.async {
                
                completion(MigrationResult(error))
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
        else if numberOfMigrations > 1 && storage.localStorageOptions.contains(.PreventProgressiveMigration) {
            
            let error = CoreStoreError.ProgressiveMigrationRequired(localStoreURL: storage.fileURL)
            CoreStore.log(
                error,
                "Failed to find migration mapping from the \(cs_typeName(storage)) at URL \"\(storage.fileURL)\" to version model \"\(self.modelVersion)\" without requiring progessive migrations."
            )
            GCDQueue.Main.async {
                
                completion(MigrationResult(error))
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
                    
                    cs_autoreleasepool {
                        
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
                            
                            migrationResult = MigrationResult(error)
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
        #if USE_FRAMEWORKS
            
            migrationOperation.qualityOfService = .Utility
        #else
            
            if #available(iOS 8.0, *) {
                
                migrationOperation.qualityOfService = .Utility
            }
        #endif
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
    
    private func computeMigrationFromStorage<T: LocalStorage>(storage: T, metadata: [String: AnyObject]) -> [(sourceModel: NSManagedObjectModel, destinationModel: NSManagedObjectModel, mappingModel: NSMappingModel, migrationType: MigrationType)]? {
        
        let model = self.model
        if model.isConfiguration(storage.configuration, compatibleWithStoreMetadata: metadata) {
            
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
                    fromBundles: storage.mappingModelBundles,
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
            let migrationError = CoreStoreError(error)
            CoreStore.log(
                migrationError,
                "Failed to migrate from version model \"\(sourceVersion)\" to version model \"\(destinationVersion)\"."
            )
            
            throw migrationError
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
            let fileError = CoreStoreError(error)
            CoreStore.log(
                fileError,
                "Failed to save store after migrating from version model \"\(sourceVersion)\" to version model \"\(destinationVersion)\"."
            )
            
            throw fileError
        }
    }
    
    
    // MARK: Deprecated
    
    /**
     Deprecated. Use `addStorage(_:completion:)` by passing a `InMemoryStore` instance.
     */
    @available(*, deprecated=2.0.0, message="Use addStorage(_:completion:) by passing a InMemoryStore instance.")
    public func addInMemoryStore(configuration configuration: String? = nil, completion: (PersistentStoreResult) -> Void) {
        
        self.addStorage(
            InMemoryStore(configuration: configuration),
            completion: { result in
                
                switch result {
                    
                case .Success(let storage):
                    completion(PersistentStoreResult(self.persistentStoreForStorage(storage)!))
                    
                case .Failure(let error):
                    completion(PersistentStoreResult(error as NSError))
                }
            }
        )
    }
    
    /**
     Deprecated. Use `addStorage(_:completion:)` by passing a `LegacySQLiteStore` instance.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was using this method prior to 2.0.0, make sure to use `LegacySQLiteStore`.
     */
    @available(*, deprecated=2.0.0, message="Use addStorage(_:completion:) by passing a LegacySQLiteStore instance. Warning: The default SQLite file location for the LegacySQLiteStore and SQLiteStore are different. If the app was using this method prior to 2.0.0, make sure to use LegacySQLiteStore.")
    public func addSQLiteStore(fileName fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle]? = nil, resetStoreOnModelMismatch: Bool = false, completion: (PersistentStoreResult) -> Void) throws -> NSProgress? {
        
        return self.addStorage(
            LegacySQLiteStore(
                fileName: fileName,
                configuration: configuration,
                mappingModelBundles: mappingModelBundles ?? NSBundle.allBundles(),
                localStorageOptions: resetStoreOnModelMismatch ? .RecreateStoreOnModelMismatch : .None
            ),
            completion: { result in
                
                switch result {
                    
                case .Success(let storage):
                    completion(PersistentStoreResult(self.persistentStoreForStorage(storage)!))
                    
                case .Failure(let error):
                    completion(PersistentStoreResult(error as NSError))
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
        
        return self.addStorage(
            LegacySQLiteStore(
                fileURL: fileURL,
                configuration: configuration,
                mappingModelBundles: mappingModelBundles ?? NSBundle.allBundles(),
                localStorageOptions: resetStoreOnModelMismatch ? .RecreateStoreOnModelMismatch : .None
            ),
            completion: { result in
                
                switch result {
                    
                case .Success(let storage):
                    completion(PersistentStoreResult(self.persistentStoreForStorage(storage)!))
                    
                case .Failure(let error):
                    completion(PersistentStoreResult(error as NSError))
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
