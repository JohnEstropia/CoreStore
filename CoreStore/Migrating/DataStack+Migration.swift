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
    
    - parameter fileName: the local filename for the SQLite persistent store in the "Application Support" directory.
    - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
    - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.allBundles()`.
    :return: a `MigrationType` indicating the type of migration required for the store; or `nil` if either inspection of the store failed, or no mapping model was found/inferred. `MigrationType` acts as a `Bool` and evaluates to `false` if no migration is required, and `true` if either a lightweight or custom migration is needed.
    */
    public func needsMigrationForSQLiteStore(fileName fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles() as [NSBundle]) -> MigrationType? {
        
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
    
    - parameter fileURL: the local file URL for the SQLite persistent store.
    - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
    - parameter mappingModelBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.allBundles()`.
    :return: a `MigrationType` indicating the type of migration required for the store; or `nil` if either inspection of the store failed, or no mapping model was found/inferred. `MigrationType` acts as a `Bool` and evaluates to `false` if no migration is required, and `true` if either a lightweight or custom migration is needed.
    */
    public func needsMigrationForSQLiteStore(fileURL fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles() as [NSBundle]) -> MigrationType? {
        
        let metadata: [String : AnyObject]
        do {
            
            metadata = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
                NSSQLiteStoreType,
                URL: fileURL
            )
        }
        catch {
            
            CoreStore.handleError(
                error as NSError,
                "Failed to add SQLite \(typeName(NSPersistentStore)) at \"\(fileURL)\"."
            )
            return nil
        }
        
        let coordinator = self.coordinator;
        let destinationModel = coordinator.managedObjectModel
        if destinationModel.isConfiguration(configuration, compatibleWithStoreMetadata: metadata) {
            
            return .None
        }
        
        guard let sourceModel = NSManagedObjectModel(byMergingModels: [destinationModel], forStoreMetadata: metadata) else {
            
            return nil
        }
        
        if let _ = NSMappingModel(
            fromBundles: mappingModelBundles,
            forSourceModel: sourceModel,
            destinationModel: destinationModel) {
                
                return .Heavyweight
        }
        
        do {
            
            try NSMappingModel.inferredMappingModelForSourceModel(
                sourceModel,
                destinationModel: destinationModel
            )
            
            return .Lightweight
        }
        catch {
            
            return nil
        }
    }
    
    /**
    Migrates an SQLite store with the specified filename to the `DataStack`'s managed object model version. This method does NOT add the migrated store to the data stack.
    
    - parameter fileName: the local filename for the SQLite persistent store in the "Application Support" directory.
    - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
    - parameter sourceBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
    - parameter sourceBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
    */
    public func upgradeSQLiteStoreIfNeeded(fileName fileName: String, configuration: String? = nil, sourceBundles: [NSBundle]? = nil, completion: (MigrationResult) -> Void) -> MigrationType? {
     
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
    
    - parameter fileName: the local filename for the SQLite persistent store in the "Application Support" directory.
    - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil` which indicates the "Default" configuration.
    - parameter sourceBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
    - parameter sourceBundles: an optional array of bundles to search mapping model files from. If not set, defaults to the `NSBundle.mainBundle()`.
    */
    public func upgradeSQLiteStoreIfNeeded(fileURL fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, sourceBundles: [NSBundle]? = nil, completion: (MigrationResult) -> Void) -> MigrationType? {
        
        let metadata: [String: AnyObject]
        do {
            
            metadata = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
                NSSQLiteStoreType,
                URL: fileURL
            )
        }
        catch {
            
            let metadataError = error as NSError
            CoreStore.handleError(
                metadataError,
                "Failed to load SQLite \(typeName(NSPersistentStore)) metadata at \"\(fileURL)\"."
            )
            
            GCDQueue.Main.async {
                
                completion(MigrationResult(metadataError))
            }
            return nil
        }
        
        guard let migrationSteps = self.computeMigrationFromStoreMetadata(metadata, configuration: configuration, sourceBundles: sourceBundles) else {
            
            CoreStore.handleError(
                NSError(coreStoreErrorCode: .MappingModelNotFound),
                "Failed to find migration steps from the store at URL \"\(fileURL)\" to version model \"\(model)\"."
            )
            
            GCDQueue.Main.async {
                
                completion(MigrationResult(.MappingModelNotFound))
            }
            return nil
        }
        
        if migrationSteps.count == 0 {
            
            GCDQueue.Main.async {
                
                completion(MigrationResult(.None))
            }
            return .None
        }
        
        var mergedMigrationType = MigrationType.None
        var migrationResult: MigrationResult?
        
        var operations = [NSOperation]()
        var cancelled = false
        for (sourceModel, destinationModel, mappingModel, migrationType) in migrationSteps {
            
            switch (mergedMigrationType, migrationType) {
                
            case (.None, _), (.Lightweight, .Heavyweight):
                mergedMigrationType = migrationType
                
            default:
                break
            }
            
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
                                mappingModel: mappingModel
                            )
                        }
                        catch {
                            
                            migrationResult = MigrationResult(error as NSError)
                            cancelled = true
                        }
                    }
                }
            )
        }
        
        let migrationOperation = NSBlockOperation()
        migrationOperation.qualityOfService = .Utility
        operations.map { migrationOperation.addDependency($0) }
        migrationOperation.addExecutionBlock { () -> Void in
            
            GCDQueue.Main.async {
                
                completion(migrationResult ?? MigrationResult(mergedMigrationType))
                return
            }
        }
        
        operations.append(migrationOperation)
        
        self.migrationQueue.addOperations(operations, waitUntilFinished: false)
        
        return mergedMigrationType
    }
    
    /**
    Asynchronously adds to the stack an SQLite store from the given SQLite file name. Note that using `addSQLiteStore(...)` instead of `addSQLiteStoreAndWait(...)` implies that the migrations are allowed and expected (thus the asynchronous `completion`.)
    
    - parameter fileName: the local filename for the SQLite persistent store in the "Application Support" directory. A new SQLite file will be created if it does not exist. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
    - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
    - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `PersistentStoreResult` argument indicates the result.
    */
    public func addSQLiteStore(fileName fileName: String, configuration: String? = nil, sourceBundles: [NSBundle]? = nil, completion: (PersistentStoreResult) -> Void) {
        
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
    
    - parameter fileURL: the local file URL for the SQLite persistent store. A new SQLite file will be created if it does not exist. If not specified, defaults to a file URL pointing to a "<Application name>.sqlite" file in the "Application Support" directory. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
    - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
    - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `PersistentStoreResult` argument indicates the result.
    */
    public func addSQLiteStore(fileURL fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, sourceBundles: [NSBundle]? = NSBundle.allBundles(), completion: (PersistentStoreResult) -> Void) {
        
        let coordinator = self.coordinator;
        if let store = coordinator.persistentStoreForURL(fileURL) {
            
            let isExistingStoreAutomigrating = store.options?[NSMigratePersistentStoresAutomaticallyOption] as? Bool == true
            
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
                "Failed to add SQLite \(typeName(NSPersistentStore)) at \"\(fileURL)\" because a different \(typeName(NSPersistentStore)) at that URL already exists."
            )
            
            GCDQueue.Main.async {
                
                completion(PersistentStoreResult(.DifferentPersistentStoreExistsAtURL))
            }
            return
        }
        
        do {
            
            try NSFileManager.defaultManager().createDirectoryAtURL(
                fileURL.URLByDeletingLastPathComponent!,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        catch _ { }
        
        self.upgradeSQLiteStoreIfNeeded(
            fileURL: fileURL,
            configuration: configuration,
            sourceBundles: sourceBundles,
            completion: { (result) -> Void in
                
                if case .Failure(let error) = result
                    where error.domain != NSCocoaErrorDomain || error.code != NSFileReadNoSuchFileError {
                        
                        completion(PersistentStoreResult(error))
                        return
                }
                
                let persistentStoreResult = self.addSQLiteStoreAndWait(
                    fileURL: fileURL,
                    configuration: configuration,
                    automigrating: false,
                    resetStoreOnMigrationFailure: false
                )
                
                completion(persistentStoreResult)
            }
        )
    }
    
    
    // MARK: Private
    
    private func computeMigrationFromStoreMetadata(metadata: [String: AnyObject], configuration: String? = nil, sourceBundles: [NSBundle]? = nil) -> [(sourceModel: NSManagedObjectModel, destinationModel: NSManagedObjectModel, mappingModel: NSMappingModel, migrationType: MigrationType)]? {
        
        let model = self.model
        if model.isConfiguration(configuration, compatibleWithStoreMetadata: metadata) {
            
            return []
        }
        
        let metadataModel = NSManagedObjectModel(byMergingModels: model.mergedModels(), forStoreMetadata: metadata)!
        if let bypassModel = NSMappingModel(
            fromBundles: sourceBundles,
            forSourceModel: metadataModel,
            destinationModel: model) {
                
                return [
                    (
                        sourceModel: metadataModel,
                        destinationModel: model,
                        mappingModel: bypassModel,
                        migrationType: .Heavyweight
                    )
                ]
        }
        
        var initialModel: NSManagedObjectModel?
        if let modelHashes = metadata[NSStoreModelVersionHashesKey] as? [String : NSData],
            let modelVersions = model.modelVersions {
                
                for modelVersion in modelVersions {
                    
                    if let versionModel = model[modelVersion] where modelHashes == versionModel.entityVersionHashesByName {
                        
                        initialModel = versionModel
                        break
                    }
                }
        }
        
        guard var currentVersion = initialModel?.currentModelVersion else {
            
            return nil
        }
        
        let migrationChain = self.migrationChain
        var migrationSteps = [(sourceModel: NSManagedObjectModel, destinationModel: NSManagedObjectModel, mappingModel: NSMappingModel, migrationType: MigrationType)]()
        
        while let nextVersion = migrationChain.nextVersionFrom(currentVersion),
            let sourceModel = model[currentVersion],
            let destinationModel = model[nextVersion] {
                
                if let mappingModel = NSMappingModel(
                    fromBundles: sourceBundles,
                    forSourceModel: sourceModel,
                    destinationModel: destinationModel) {
                        
                        migrationSteps.append(
                            (
                                sourceModel: sourceModel,
                                destinationModel: destinationModel,
                                mappingModel: mappingModel,
                                migrationType: .Heavyweight
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
                                migrationType: .Lightweight
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
    
    private func startMigrationForSQLiteStore(fileURL fileURL: NSURL, sourceModel: NSManagedObjectModel, destinationModel: NSManagedObjectModel, mappingModel: NSMappingModel) throws {
        
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
        
        let migrationManager = NSMigrationManager(
            sourceModel: sourceModel,
            destinationModel: destinationModel
        )
        
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
            
            timer.suspend()
            
            do {
                
                try fileManager.removeItemAtURL(temporaryDirectoryURL)
            }
            catch _ { }
            
            let migrationError = error as NSError
            CoreStore.handleError(
                migrationError,
                "Failed to migrate from version model \"\(migrationManager.sourceModel)\" to version model \"\(migrationManager.destinationModel)\"."
            )
            
            throw error
        }
        
        timer.suspend()
        
        do {
            
            try fileManager.replaceItemAtURL(
                fileURL,
                withItemAtURL: temporaryFileURL,
                backupItemName: nil,
                options: [],
                resultingItemURL: nil
            )
            
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
            
            let replaceError = error as NSError
            CoreStore.handleError(
                replaceError,
                "Failed to save store after migrating from version model \"\(migrationManager.sourceModel)\" to version model \"\(migrationManager.destinationModel)\"."
            )
            
            throw error
        }
    }
}
