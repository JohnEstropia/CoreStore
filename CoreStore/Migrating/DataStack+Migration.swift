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
     Asynchronously adds an in-memory store to the stack.
     
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`.
     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `PersistentStoreResult` argument indicates the result.
     */
    public func addInMemoryStore(configuration configuration: String? = nil, completion: (PersistentStoreResult) -> Void) {
        
        self.coordinator.performAsynchronously {
            
            do {
                
                let store = try self.coordinator.addPersistentStoreWithType(
                    NSInMemoryStoreType,
                    configuration: configuration,
                    URL: nil,
                    options: nil
                )
                self.updateMetadataForPersistentStore(store)
                
                GCDQueue.Main.async {
                    
                    completion(PersistentStoreResult(store))
                }
            }
            catch {
                
                let storeError = error as NSError
                CoreStore.handleError(
                    storeError,
                    "Failed to add in-memory \(typeName(NSPersistentStore)) to the stack."
                )
                
                GCDQueue.Main.async {
                    
                    completion(PersistentStoreResult(storeError))
                }
            }
        }
    }
    
    /**
     Asynchronously adds to the stack an SQLite store from the given SQLite file name. Note that using `addSQLiteStore(...)` instead of `addSQLiteStoreAndWait(...)` implies that the migrations are allowed and expected (thus the asynchronous `completion`.)
     
     - parameter fileName: the local filename for the SQLite persistent store in the "Application Support" directory (or the "Caches" directory on tvOS). A new SQLite file will be created if it does not exist. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
     - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.allBundles()`.
     - parameter resetStoreOnModelMismatch: Set to true to delete the store on model mismatch; or set to false to report failure instead. Typically should only be set to true when debugging, or if the persistent store can be recreated easily. If not specified, defaults to false.
     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `PersistentStoreResult` argument indicates the result. This closure is NOT executed if an error is thrown, but will be executed with a `.Failure` result if an error occurs asynchronously.
     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
     */
    public func addSQLiteStore(fileName fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle]? = nil, resetStoreOnModelMismatch: Bool = false, completion: (PersistentStoreResult) -> Void) throws -> NSProgress? {
        
        return try self.addSQLiteStore(
            fileURL: defaultDirectory.URLByAppendingPathComponent(
                fileName,
                isDirectory: false
            ),
            configuration: configuration,
            mappingModelBundles: mappingModelBundles,
            resetStoreOnModelMismatch: resetStoreOnModelMismatch,
            completion: completion
        )
    }
    
    /**
     Asynchronously adds to the stack an SQLite store from the given SQLite file URL. Note that using `addSQLiteStore(...)` instead of `addSQLiteStoreAndWait(...)` implies that the migrations are allowed and expected (thus the asynchronous `completion`.)
     
     - parameter fileURL: the local file URL for the SQLite persistent store. A new SQLite file will be created if it does not exist. If not specified, defaults to a file URL pointing to a "<Application name>.sqlite" file in the "Application Support" directory (or the "Caches" directory on tvOS). Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
     - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.allBundles()`.
     - parameter resetStoreOnModelMismatch: Set to true to delete the store on model mismatch; or set to false to report failure instead. Typically should only be set to true when debugging, or if the persistent store can be recreated easily. If not specified, defaults to false.
     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `PersistentStoreResult` argument indicates the result. This closure is NOT executed if an error is thrown, but will be executed with a `.Failure` result if an error occurs asynchronously.
     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
     */
    public func addSQLiteStore(fileURL fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, mappingModelBundles: [NSBundle]? = NSBundle.allBundles(), resetStoreOnModelMismatch: Bool = false, completion: (PersistentStoreResult) -> Void) throws -> NSProgress? {
        
        CoreStore.assert(
            fileURL.fileURL,
            "The specified file URL for the SQLite store is invalid: \"\(fileURL)\""
        )
        
        let coordinator = self.coordinator;
        if let store = coordinator.persistentStoreForURL(fileURL) {
            
            guard store.type == NSSQLiteStoreType
                && store.configurationName == (configuration ?? Into.defaultConfigurationName) else {
                    
                    let error = NSError(coreStoreErrorCode: .DifferentPersistentStoreExistsAtURL)
                    CoreStore.handleError(
                        error,
                        "Failed to add SQLite \(typeName(NSPersistentStore)) at \"\(fileURL)\" because a different \(typeName(NSPersistentStore)) at that URL already exists."
                    )
                    throw error
            }
            
            GCDQueue.Main.async {
                
                completion(PersistentStoreResult(store))
            }
            return nil
        }
        
        let fileManager = NSFileManager.defaultManager()
        _ = try? fileManager.createDirectoryAtURL(
            fileURL.URLByDeletingLastPathComponent!,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        do {
            
            let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
                NSSQLiteStoreType,
                URL: fileURL,
                options: self.optionsForSQLiteStore()
            )
            
            return self.upgradeSQLiteStoreIfNeeded(
                fileURL: fileURL,
                metadata: metadata,
                configuration: configuration,
                mappingModelBundles: mappingModelBundles,
                completion: { (result) -> Void in
                    
                    if case .Failure(let error) = result {
                        
                        if resetStoreOnModelMismatch && error.isCoreDataMigrationError {
                            
                            fileManager.removeSQLiteStoreAtURL(fileURL)
                            do {
                                
                                let store = try self.addSQLiteStoreAndWait(
                                    fileURL: fileURL,
                                    configuration: configuration,
                                    resetStoreOnModelMismatch: false
                                )
                                
                                GCDQueue.Main.async {
                                    
                                    completion(PersistentStoreResult(store))
                                }
                            }
                            catch {
                                
                                completion(PersistentStoreResult(error as NSError))
                            }
                            return
                        }
                        
                        completion(PersistentStoreResult(error))
                        return
                    }
                    
                    do {
                        
                        let store = try self.addSQLiteStoreAndWait(
                            fileURL: fileURL,
                            configuration: configuration,
                            resetStoreOnModelMismatch: false
                        )
                        
                        completion(PersistentStoreResult(store))
                    }
                    catch {
                        
                        completion(PersistentStoreResult(error as NSError))
                    }
                }
            )
        }
        catch let error as NSError
            where error.code == NSFileReadNoSuchFileError && error.domain == NSCocoaErrorDomain {
                
                let store = try self.addSQLiteStoreAndWait(
                    fileURL: fileURL,
                    configuration: configuration,
                    resetStoreOnModelMismatch: false
                )
                
                GCDQueue.Main.async {
                    
                    completion(PersistentStoreResult(store))
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
    
    /**
     Migrates an SQLite store with the specified filename to the `DataStack`'s managed object model version WITHOUT adding the migrated store to the data stack.
     
     - parameter fileName: the local filename for the SQLite persistent store in the "Application Support" directory (or the "Caches" directory on tvOS).
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
     - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
     - parameter sourceBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
     */
    public func upgradeSQLiteStoreIfNeeded(fileName fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle]? = nil, completion: (MigrationResult) -> Void) throws -> NSProgress? {
        
        return try self.upgradeSQLiteStoreIfNeeded(
            fileURL: defaultDirectory.URLByAppendingPathComponent(
                fileName,
                isDirectory: false
            ),
            configuration: configuration,
            mappingModelBundles: mappingModelBundles,
            completion: completion
        )
    }
    
    /**
     Migrates an SQLite store at the specified file URL and configuration name to the `DataStack`'s managed object model version. This method does NOT add the migrated store to the data stack.
     
     - parameter fileName: the local filename for the SQLite persistent store in the "Application Support" directory (or the "Caches" directory on tvOS).
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
     - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
     - parameter sourceBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
     */
    public func upgradeSQLiteStoreIfNeeded(fileURL fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, mappingModelBundles: [NSBundle]? = nil, completion: (MigrationResult) -> Void) throws -> NSProgress? {
        
        let metadata: [String: AnyObject]
        do {
            
            metadata = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
                NSSQLiteStoreType,
                URL: fileURL,
                options: self.optionsForSQLiteStore()
            )
        }
        catch {
            
            CoreStore.handleError(
                error as NSError,
                "Failed to load SQLite \(typeName(NSPersistentStore)) metadata."
            )
            throw error
        }
        
        return self.upgradeSQLiteStoreIfNeeded(
            fileURL: fileURL,
            metadata: metadata,
            configuration: configuration,
            mappingModelBundles: mappingModelBundles,
            completion: completion
        )
    }
    
    /**
     Checks for the required migrations needed for the store with the specified filename and configuration to be migrated to the `DataStack`'s managed object model version. This method throws an error if the store does not exist, if inspection of the store failed, or no mapping model was found/inferred.
     
     - parameter fileName: the local filename for the SQLite persistent store in the "Application Support" directory (or the "Caches" directory on tvOS).
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
     - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.allBundles()`.
     :return: an array of `MigrationType`s indicating the chain of migrations required for the store; or `nil` if either inspection of the store failed, or no mapping model was found/inferred. `MigrationType` acts as a `Bool` and evaluates to `false` if no migration is required, and `true` if either a lightweight or custom migration is needed.
     */
    @warn_unused_result
    public func requiredMigrationsForSQLiteStore(fileName fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles() as [NSBundle]) throws -> [MigrationType] {
        
        return try requiredMigrationsForSQLiteStore(
            fileURL: defaultDirectory.URLByAppendingPathComponent(
                fileName,
                isDirectory: false
            ),
            configuration: configuration,
            mappingModelBundles: mappingModelBundles
        )
    }
    
    /**
     Checks if the store at the specified file URL and configuration needs to be migrated to the `DataStack`'s managed object model version.
     
     - parameter fileURL: the local file URL for the SQLite persistent store.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
     - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.allBundles()`.
     :return: a `MigrationType` indicating the type of migration required for the store; or `nil` if either inspection of the store failed, or no mapping model was found/inferred. `MigrationType` acts as a `Bool` and evaluates to `false` if no migration is required, and `true` if either a lightweight or custom migration is needed.
     */
    @warn_unused_result
    public func requiredMigrationsForSQLiteStore(fileURL fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles() as [NSBundle]) throws -> [MigrationType] {
        
        let metadata: [String : AnyObject]
        do {
            
            metadata = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
                NSSQLiteStoreType,
                URL: fileURL,
                options: self.optionsForSQLiteStore()
            )
        }
        catch {
            
            CoreStore.handleError(
                error as NSError,
                "Failed to load SQLite \(typeName(NSPersistentStore)) metadata."
            )
            throw error
        }
        
        guard let migrationSteps = self.computeMigrationFromStoreMetadata(metadata, configuration: configuration, mappingModelBundles: mappingModelBundles) else {
            
            let error = NSError(coreStoreErrorCode: .MappingModelNotFound)
            CoreStore.handleError(
                error,
                "Failed to find migration steps from the store at URL \"\(fileURL)\" to version model \"\(self.modelVersion)\"."
            )
            throw error
        }
        
        return migrationSteps.map { $0.migrationType }
    }
    
    
    // MARK: Private
    
    private func upgradeSQLiteStoreIfNeeded(fileURL fileURL: NSURL, metadata: [String: AnyObject], configuration: String?, mappingModelBundles: [NSBundle]?, completion: (MigrationResult) -> Void) -> NSProgress? {
        
        guard let migrationSteps = self.computeMigrationFromStoreMetadata(metadata, configuration: configuration, mappingModelBundles: mappingModelBundles) else {
            
            CoreStore.handleError(
                NSError(coreStoreErrorCode: .MappingModelNotFound),
                "Failed to find migration steps from the store at URL \"\(fileURL)\" to version model \"\(model)\"."
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
        
        // todo nsprogress crashing sometimes
        for (sourceModel, destinationModel, mappingModel, _) in migrationSteps {
            
            progress.becomeCurrentWithPendingUnitCount(1)
            
            let childProgress = NSProgress(parent: progress, userInfo: nil)
            childProgress.totalUnitCount = 100
            
            operations.append(
                NSBlockOperation { [weak self] in
                    
                    guard let strongSelf = self where !cancelled else {
                        
                        return
                    }
                    
                    autoreleasepool {
                        
                        do {
                            
                            try strongSelf.startMigrationForSQLiteStore(
                                fileURL: fileURL,
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
                        
                        withExtendedLifetime(childProgress) { (_: NSProgress) -> Void in }
                        return
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
    
    private func computeMigrationFromStoreMetadata(metadata: [String: AnyObject], configuration: String? = nil, mappingModelBundles: [NSBundle]? = nil) -> [(sourceModel: NSManagedObjectModel, destinationModel: NSManagedObjectModel, mappingModel: NSMappingModel, migrationType: MigrationType)]? {
        
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
    
    private func startMigrationForSQLiteStore(fileURL fileURL: NSURL, sourceModel: NSManagedObjectModel, destinationModel: NSManagedObjectModel, mappingModel: NSMappingModel, progress: NSProgress) throws {
        
        autoreleasepool {
            
            let journalUpdatingCoordinator = NSPersistentStoreCoordinator(managedObjectModel: sourceModel)
            let store = try! journalUpdatingCoordinator.addPersistentStoreWithType(
                NSSQLiteStoreType,
                configuration: nil,
                URL: fileURL,
                options: [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
            )
            try! journalUpdatingCoordinator.removePersistentStore(store)
        }
        
        let migrationManager = MigrationManager(
            sourceModel: sourceModel,
            destinationModel: destinationModel,
            progress: progress
        )
        
        let temporaryDirectoryURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).URLByAppendingPathComponent(NSProcessInfo().globallyUniqueString)
        
        let fileManager = NSFileManager.defaultManager()
        try! fileManager.createDirectoryAtURL(
            temporaryDirectoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        let temporaryFileURL = temporaryDirectoryURL.URLByAppendingPathComponent(fileURL.lastPathComponent!, isDirectory: false)
        
        do {
            
            try migrationManager.migrateStoreFromURL(
                fileURL,
                type: NSSQLiteStoreType,
                options: nil,
                withMappingModel: mappingModel,
                toDestinationURL: temporaryFileURL,
                destinationType: NSSQLiteStoreType,
                destinationOptions: nil
            )
        }
        catch {
            
            do {
                
                try fileManager.removeItemAtURL(temporaryDirectoryURL)
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
            
            do {
                
                try fileManager.removeItemAtPath(fileURL.path! + "-shm")
            }
            catch _ { }
        }
        catch {
            
            do {
                
                try fileManager.removeItemAtURL(temporaryDirectoryURL)
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
}
