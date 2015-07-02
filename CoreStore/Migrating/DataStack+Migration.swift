//
//  DataStack+Migration.swift
//  CoreStore
//
//  Copyright (c) 2015 John Rommel Estropia
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
import GCDKit


// MARK: - DataStack

public extension DataStack {
    
    /**
    Checks if the store with the specified filename and configuration needs to be migrated to the `DataStack`'s managed object model version.
    
    :param: fileName the local filename for the SQLite persistent store in the "Application Support" directory.
    :param: configuration an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
    :param: mappingModelBundles an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.allBundles()`.
    :return: a `MigrationType` indicating the type of migration required for the store; or `nil` if either inspection of the store failed, or no mapping model was found/inferred. `MigrationType` acts as a `Bool` and evaluates to `false` if no migration is required, and `true` if either a lightweight or custom migration is needed.
    */
    public func needsMigrationForSQLiteStore(fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles() as! [NSBundle]) -> MigrationType? {
        
        return needsMigrationForSQLiteStore(
            fileURL: applicationSupportDirectory.URLByAppendingPathComponent(
                fileName,
                isDirectory: false
            ),
            configuration: configuration,
            mappingModelBundles: mappingModelBundles
        )
    }
    
    /**
    Checks if the store at the specified file URL and configuration needs to be migrated to the `DataStack`'s managed object model version.
    
    :param: fileURL the local file URL for the SQLite persistent store.
    :param: configuration an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
    :param: mappingModelBundles an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.allBundles()`.
    :return: a `MigrationType` indicating the type of migration required for the store; or `nil` if either inspection of the store failed, or no mapping model was found/inferred. `MigrationType` acts as a `Bool` and evaluates to `false` if no migration is required, and `true` if either a lightweight or custom migration is needed.
    */
    public func needsMigrationForSQLiteStore(fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles() as! [NSBundle]) -> MigrationType? {
        
        var error: NSError?
        let metadata: [NSObject : AnyObject]! = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
            NSSQLiteStoreType,
            URL: fileURL,
            error: &error
        )
        if metadata == nil {
            
            CoreStore.handleError(
                error ?? NSError(coreStoreErrorCode: .UnknownError),
                "Failed to add SQLite <\(NSPersistentStore.self)> at \"\(fileURL)\"."
            )
            return nil
        }
        
        let coordinator = self.coordinator;
        let destinationModel = coordinator.managedObjectModel
        if destinationModel.isConfiguration(
            configuration,
            compatibleWithStoreMetadata: metadata) {
               
                return .None
        }
        
        let sourceModel = NSManagedObjectModel(
            byMergingModels: [destinationModel],
            forStoreMetadata: metadata
        )!
        
        if NSMappingModel(
            fromBundles: mappingModelBundles,
            forSourceModel: sourceModel,
            destinationModel: destinationModel) != nil {
                
                return .Heavyweight
        }
        
        if NSMappingModel.inferredMappingModelForSourceModel(
            sourceModel,
            destinationModel: destinationModel,
            error: nil) != nil {
                
                return .Lightweight
        }
        
        return nil
    }
    
    /**
    Migrates an SQLite store with the specified filename to the `DataStack`'s managed object model version. This method does NOT add the migrated store to the data stack.
    
    :param: fileName the local filename for the SQLite persistent store in the "Application Support" directory.
    :param: configuration an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
    :param: sourceBundles an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
    :param: sourceBundles an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
    */
    public func upgradeSQLiteStoreIfNeeded(fileName: String, configuration: String? = nil, sourceBundles: [NSBundle]? = nil, completion: (MigrationResult) -> Void) -> MigrationType? {
     
        return self.upgradeSQLiteStoreIfNeeded(
            fileURL: applicationSupportDirectory.URLByAppendingPathComponent(
                fileName,
                isDirectory: false
            ),
            configuration: configuration,
            sourceBundles: sourceBundles,
            completion: completion
        )
    }
    
    /**
    Migrates an SQLite store at the specified file URL and configuration name to the `DataStack`'s managed object model version. This method does NOT add the migrated store to the data stack.
    
    :param: fileName the local filename for the SQLite persistent store in the "Application Support" directory.
    :param: configuration an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
    :param: sourceBundles an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
    :param: sourceBundles an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
    */
    public func upgradeSQLiteStoreIfNeeded(fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, sourceBundles: [NSBundle]? = nil, completion: (MigrationResult) -> Void) -> MigrationType? {
        
        var metadataError: NSError?
        let metadata: [NSObject: AnyObject]! = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
            NSSQLiteStoreType,
            URL: fileURL,
            error: &metadataError
        )
        if metadata == nil {
            
            let error = metadataError ?? NSError(coreStoreErrorCode: .UnknownError)
            CoreStore.handleError(
                error,
                "Failed to load SQLite <\(NSPersistentStore.self)> metadata at \"\(fileURL)\"."
            )
            
            GCDQueue.Main.async {
                
                completion(MigrationResult(error))
            }
            return nil
        }
        
        let coordinator = self.coordinator;
        let destinationModel = coordinator.managedObjectModel
        if destinationModel.isConfiguration(
            configuration,
            compatibleWithStoreMetadata: metadata) {
                
                GCDQueue.Main.async {
                    
                    completion(MigrationResult(.None))
                }
                return .None
        }
        
        let sourceModel = NSManagedObjectModel(
            byMergingModels: [destinationModel],
            forStoreMetadata: metadata
        )!
        
        if let mappingModel = NSMappingModel(
            fromBundles: sourceBundles,
            forSourceModel: sourceModel,
            destinationModel: destinationModel) {
                
                self.startMigrationForSQLiteStore(
                    fileURL,
                    sourceModel: sourceModel,
                    destinationModel: destinationModel,
                    mappingModel: mappingModel,
                    migrationType: .Heavyweight,
                    completion: completion
                )
                return .Heavyweight
        }
        
        if let mappingModel = NSMappingModel.inferredMappingModelForSourceModel(
            sourceModel,
            destinationModel: destinationModel,
            error: nil) {
                
                self.startMigrationForSQLiteStore(
                    fileURL,
                    sourceModel: sourceModel,
                    destinationModel: destinationModel,
                    mappingModel: mappingModel,
                    migrationType: .Lightweight,
                    completion: completion
                )
                return .Lightweight
        }
        
        CoreStore.handleError(
            NSError(coreStoreErrorCode: .UnknownError),
            "Failed to load an <\(NSMappingModel.self)> for migration from version model \"\(sourceModel)\" to version model \"\(destinationModel)\"."
        )
        
        GCDQueue.Main.async {
            
            completion(MigrationResult(.MappingModelNotFound))
        }
        return nil
    }
    
    /**
    Asynchronously adds to the stack an SQLite store from the given SQLite file name. Note that using `addSQLiteStore(...)` instead of `addSQLiteStoreAndWait(...)` implies that the migrations are allowed and expected (thus the asynchronous `completion`.)
    
    :param: fileName the local filename for the SQLite persistent store in the "Application Support" directory. A new SQLite file will be created if it does not exist. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
    :param: configuration an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
    :param: completion the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `PersistentStoreResult` argument indicates the result.
    */
    public func addSQLiteStore(fileName: String, configuration: String? = nil, sourceBundles: [NSBundle]? = nil, completion: (PersistentStoreResult) -> Void) {
        
        self.addSQLiteStore(
            fileURL: applicationSupportDirectory.URLByAppendingPathComponent(
                fileName,
                isDirectory: false
            ),
            configuration: configuration,
            sourceBundles: sourceBundles,
            completion: completion
        )
    }
    
    /**
    Asynchronously adds to the stack an SQLite store from the given SQLite file URL. Note that using `addSQLiteStore(...)` instead of `addSQLiteStoreAndWait(...)` implies that the migrations are allowed and expected (thus the asynchronous `completion`.)
    
    :param: fileURL the local file URL for the SQLite persistent store. A new SQLite file will be created if it does not exist. If not specified, defaults to a file URL pointing to a "<Application name>.sqlite" file in the "Application Support" directory. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
    :param: configuration an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
    :param: completion the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `PersistentStoreResult` argument indicates the result.
    */
    public func addSQLiteStore(fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, sourceBundles: [NSBundle]? = nil, completion: (PersistentStoreResult) -> Void) {
        
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            
            var error: NSError?
            let metadata = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
                NSSQLiteStoreType,
                URL: fileURL,
                error: &error
            )
            if metadata == nil {
                
                CoreStore.handleError(
                    error ?? NSError(coreStoreErrorCode: .UnknownError),
                    "Failed to load SQLite <\(NSPersistentStore.self)> metadata at \"\(fileURL)\"."
                )
                
                GCDQueue.Main.async {
                    
                    completion(PersistentStoreResult(.UnknownError))
                }
                return
            }
        }
        
        let coordinator = self.coordinator;
        if let store = coordinator.persistentStoreForURL(fileURL) {
            
            let isExistingStoreAutomigrating = ((store.options?[NSMigratePersistentStoresAutomaticallyOption] as? Bool) ?? false)
            
            if store.type == NSSQLiteStoreType
                && isExistingStoreAutomigrating
                && store.configurationName == (configuration ?? Into.defaultConfigurationName) {
                    
                    GCDQueue.Main.async {
                        
                        completion(PersistentStoreResult(store))
                    }
                    return
            }
            
            CoreStore.handleError(
                NSError(coreStoreErrorCode: .DifferentPersistentStoreExistsAtURL),
                "Failed to add SQLite <\(NSPersistentStore.self)> at \"\(fileURL)\" because a different <\(NSPersistentStore.self)> at that URL already exists."
            )
            
            GCDQueue.Main.async {
                
                completion(PersistentStoreResult(.DifferentPersistentStoreExistsAtURL))
            }
            return
        }
        
        let fileManager = NSFileManager.defaultManager()
        var directoryError: NSError?
        if !fileManager.createDirectoryAtURL(
            fileURL.URLByDeletingLastPathComponent!,
            withIntermediateDirectories: true,
            attributes: nil,
            error: &directoryError) {
                
                CoreStore.handleError(
                    directoryError ?? NSError(coreStoreErrorCode: .UnknownError),
                    "Failed to create directory for SQLite store at \"\(fileURL)\"."
                )
                
                GCDQueue.Main.async {
                    
                    completion(PersistentStoreResult(directoryError!))
                }
                return
        }
        
        coordinator.performBlock {
            
            var persistentStoreError: NSError?
            let store = coordinator.addPersistentStoreWithType(
                NSSQLiteStoreType,
                configuration: configuration,
                URL: fileURL,
                options: [NSSQLitePragmasOption: ["WAL": "journal_mode"],
                    NSInferMappingModelAutomaticallyOption: true,
                    NSMigratePersistentStoresAutomaticallyOption: true],
                error: &persistentStoreError)
            
            if let store = store {
                
                GCDQueue.Main.async {
                    
                    self.updateMetadataForPersistentStore(store)
                    completion(PersistentStoreResult(store))
                }
            }
            else {
                
                GCDQueue.Main.async {
                    
                    CoreStore.handleError(
                        persistentStoreError ?? NSError(coreStoreErrorCode: .UnknownError),
                        "Failed to add SQLite <\(NSPersistentStore.self)> at \"\(fileURL)\"."
                    )
                    
                    completion(PersistentStoreResult(.UnknownError))
                }
            }
        }
    }
    
    
    // MARK: Private
    
    private func startMigrationForSQLiteStore(fileURL: NSURL, sourceModel: NSManagedObjectModel, destinationModel: NSManagedObjectModel, mappingModel: NSMappingModel, migrationType: MigrationType, completion: (MigrationResult) -> Void) {
        
        let migrationManager = NSMigrationManager(
            sourceModel: sourceModel,
            destinationModel: destinationModel
        )
        
        self.migrationQueue.async {
            
            var lastReportedProgress: Float = -1
            let timer = GCDTimer.createSuspended(
                .Main,
                interval: 0.1,
                eventHandler: { (timer) -> Void in
                    
                    let progress = migrationManager.migrationProgress
                    if progress > lastReportedProgress {
                        
                        // TODO: progress
                        CoreStore.log(.Trace, message: "migration progress: \(progress)")
                        lastReportedProgress = progress
                    }
                }
            )
            
            let temporaryFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)!.URLByAppendingPathComponent(NSProcessInfo().globallyUniqueString)
            
            var migrationError: NSError?
            let migrationCompleted = migrationManager.migrateStoreFromURL(
                fileURL,
                type: NSSQLiteStoreType,
                options: nil,
                withMappingModel: mappingModel,
                toDestinationURL: temporaryFileURL,
                destinationType: NSSQLiteStoreType,
                destinationOptions: nil,
                error: &migrationError
            )
            
            timer.suspend()
            
            let fileManager = NSFileManager.defaultManager()
            if !migrationCompleted {
                
                fileManager.removeItemAtURL(temporaryFileURL, error: nil)
                
                let error = migrationError ?? NSError(coreStoreErrorCode: .UnknownError)
                CoreStore.handleError(
                    error,
                    "Failed to migrate from version model \"\(migrationManager.sourceModel)\" to version model \"\(migrationManager.destinationModel)\"."
                )
                
                GCDQueue.Main.async {
                    
                    completion(MigrationResult(error))
                }
                return
            }
            
            var replaceError: NSError?
            if !fileManager.replaceItemAtURL(
                fileURL,
                withItemAtURL: temporaryFileURL,
                backupItemName: nil,
                options: .allZeros,
                resultingItemURL: nil,
                error: &replaceError) {
                    
                    fileManager.removeItemAtURL(temporaryFileURL, error: nil)
                    
                    let error = replaceError ?? NSError(coreStoreErrorCode: .UnknownError)
                    CoreStore.handleError(
                        error,
                        "Failed to save store after migrating from version model \"\(migrationManager.sourceModel)\" to version model \"\(migrationManager.destinationModel)\"."
                    )
                    
                    GCDQueue.Main.async {
                        
                        completion(MigrationResult(error))
                    }
                    return
            }
            
            GCDQueue.Main.async {
                
                completion(MigrationResult(migrationType))
            }
        }
    }
}
