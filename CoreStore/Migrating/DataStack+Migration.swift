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
    
    // MARK: Public
    
    /**
    Initializes a `DataStack` from the specified model name and a version-specific model name.
    
    :param: rootModelName the name of the (.xcdatamodeld) model file
    :param: versionModelName the name of the version-specific (.xcdatamodeld) model file
    */
    public convenience init(rootModelName: String, versionModelName: String) {
        
        let modelVersionURL: NSURL! = NSBundle.mainBundle().URLForResource(
            rootModelName.stringByAppendingPathExtension("momd")!.stringByAppendingPathComponent(versionModelName),
            withExtension: "mom"
        )
        CoreStore.assert(modelVersionURL != nil, "Could not find a \"mom\" resource from the main bundle.")
        
        let managedObjectModel: NSManagedObjectModel! = NSManagedObjectModel(contentsOfURL: modelVersionURL)
        CoreStore.assert(managedObjectModel != nil, "Could not create an <\(NSManagedObjectModel.self)> from the resource at URL \"\(modelVersionURL)\".")
        
        self.init(managedObjectModel: managedObjectModel)
    }
    
    /**
    Checks if the store at the specified filename and configuration needs to be migrated to the `DataStack`'s managed object model version.
    
    :param: fileName the local filename for the SQLite persistent store in the "Application Support" directory.
    :param: configuration an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration.
    */
    public func needsMigrationForSQLiteStore(fileName: String, configuration: String? = nil) -> Bool? {
        
        return needsMigrationForSQLiteStore(
            fileURL: applicationSupportDirectory.URLByAppendingPathComponent(
                fileName,
                isDirectory: false
            ),
            configuration: configuration
        )
    }
    
    /**
    Checks if the store at the specified file URL and configuration needs to be migrated to the `DataStack`'s managed object model version.
    
    :param: fileName the local filename for the SQLite persistent store in the "Application Support" directory.
    :param: configuration an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration.
    */
    public func needsMigrationForSQLiteStore(fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil) -> Bool? {
        
        var error: NSError?
        let metadata = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
            NSSQLiteStoreType,
            URL: fileURL,
            error: &error
        )
        if metadata == nil {
            
            CoreStore.handleError(
                error ?? NSError(coreStoreErrorCode: .UnknownError),
                "Failed to add SQLite <\(NSPersistentStore.self)> at \"\(fileURL)\".")
            return nil
        }
        
        return !self.coordinator.managedObjectModel.isConfiguration(
            configuration,
            compatibleWithStoreMetadata: metadata
        )
    }
    
    /**
    EXPERIMENTAL
    */
    public func upgradeSQLiteStoreIfNeeded(fileName: String, configuration: String? = nil, completion: (PersistentStoreResult) -> Void) {
     
        self.upgradeSQLiteStoreIfNeeded(
            fileURL: applicationSupportDirectory.URLByAppendingPathComponent(
                fileName,
                isDirectory: false
            ),
            configuration: configuration,
            completion: completion
        )
    }
    
    /**
    EXPERIMENTAL
    */
    public func upgradeSQLiteStoreIfNeeded(fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, completion: (PersistentStoreResult) -> Void) {
        
        var metadataError: NSError?
        let metadata: [NSObject: AnyObject]! = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
            NSSQLiteStoreType,
            URL: fileURL,
            error: &metadataError
        )
        if metadata == nil {
            
            CoreStore.handleError(
                metadataError ?? NSError(coreStoreErrorCode: .UnknownError),
                "Failed to load SQLite <\(NSPersistentStore.self)> metadata at \"\(fileURL)\".")
            
            GCDQueue.Main.async {
                
                // TODO: inspect valid errors for metadataForPersistentStoreOfType()
                completion(PersistentStoreResult(.PersistentStoreNotFound))
            }
            return
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
                "Failed to add SQLite <\(NSPersistentStore.self)> at \"\(fileURL)\" because a different <\(NSPersistentStore.self)> at that URL already exists.")
            
            GCDQueue.Main.async {
                
                completion(PersistentStoreResult(.DifferentPersistentStoreExistsAtURL))
            }
            return
        }
        
        let managedObjectModel = self.coordinator.managedObjectModel
        let migrationManager = NSMigrationManager(
            sourceModel: NSManagedObjectModel(
                byMergingModels: [managedObjectModel],
                forStoreMetadata: metadata!
            )!,
            destinationModel: managedObjectModel
        )
        
        var mappingModel: NSMappingModel! = NSMappingModel(
            fromBundles: nil, // TODO: parametize
            forSourceModel: migrationManager.sourceModel,
            destinationModel: migrationManager.destinationModel
        )
        var modelError: NSError?
        if mappingModel == nil {
            
            mappingModel = NSMappingModel.inferredMappingModelForSourceModel(
                migrationManager.sourceModel,
                destinationModel: migrationManager.destinationModel,
                error: &modelError
            )
        }
        if mappingModel == nil {
            
            CoreStore.handleError(
                NSError(coreStoreErrorCode: .UnknownError),
                "Failed to load an <\(NSMappingModel.self)> for migration from version model \"\(migrationManager.sourceModel)\" to version model \"\(migrationManager.destinationModel)\".")
            
            GCDQueue.Main.async {
                
                completion(PersistentStoreResult(.MappingModelNotFound))
            }
            return
        }
        
        let temporaryFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)!.URLByAppendingPathComponent(NSProcessInfo().globallyUniqueString)
        
        var migrationError: NSError?
        if !migrationManager.migrateStoreFromURL(
            fileURL,
            type: NSSQLiteStoreType,
            options: nil,
            withMappingModel: mappingModel,
            toDestinationURL: temporaryFileURL,
            destinationType: NSSQLiteStoreType,
            destinationOptions: nil,
            error: &migrationError
            ) {
                
                CoreStore.handleError(
                    migrationError ?? NSError(coreStoreErrorCode: .UnknownError),
                    "Failed to prepare for migration from version model \"\(migrationManager.sourceModel)\" to version model \"\(migrationManager.destinationModel)\".")
                
                GCDQueue.Main.async {
                    
                    completion(PersistentStoreResult(.MigrationFailed))
                }
                return
        }
        
    }
    
    /**
    Asynchronously adds to the stack an SQLite store from the given SQLite file name. Note that using `addSQLiteStore(...)` instead of `addSQLiteStoreAndWait(...)` implies that the migrations are allowed and expected (thus the asynchronous `completion`.)
    
    :param: fileName the local filename for the SQLite persistent store in the "Application Support" directory. A new SQLite file will be created if it does not exist. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
    :param: configuration an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
    :param: completion the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `PersistentStoreResult` argument indicates the result.
    */
    public func addSQLiteStore(fileName: String, configuration: String? = nil, completion: (PersistentStoreResult) -> Void) {
        
        self.addSQLiteStore(
            fileURL: applicationSupportDirectory.URLByAppendingPathComponent(
                fileName,
                isDirectory: false
            ),
            configuration: configuration,
            completion: completion
        )
    }
    
    /**
    Asynchronously adds to the stack an SQLite store from the given SQLite file URL. Note that using `addSQLiteStore(...)` instead of `addSQLiteStoreAndWait(...)` implies that the migrations are allowed and expected (thus the asynchronous `completion`.)
    
    :param: fileURL the local file URL for the SQLite persistent store. A new SQLite file will be created if it does not exist. If not specified, defaults to a file URL pointing to a "<Application name>.sqlite" file in the "Application Support" directory. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
    :param: configuration an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
    :param: completion the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `PersistentStoreResult` argument indicates the result.
    */
    public func addSQLiteStore(fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, completion: (PersistentStoreResult) -> Void) {
        
        var error: NSError?
        let metadata = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
            NSSQLiteStoreType,
            URL: fileURL,
            error: &error
        )
        if metadata == nil {
            
            CoreStore.handleError(
                error ?? NSError(coreStoreErrorCode: .UnknownError),
                "Failed to load SQLite <\(NSPersistentStore.self)> metadata at \"\(fileURL)\".")
            
            GCDQueue.Main.async {
                
                completion(PersistentStoreResult(.UnknownError))
            }
            return
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
                "Failed to add SQLite <\(NSPersistentStore.self)> at \"\(fileURL)\" because a different <\(NSPersistentStore.self)> at that URL already exists.")
            
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
                    "Failed to create directory for SQLite store at \"\(fileURL)\".")
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
                        "Failed to add SQLite <\(NSPersistentStore.self)> at \"\(fileURL)\".")
                    
                    completion(PersistentStoreResult(.UnknownError))
                }
            }
        }
    }
}
