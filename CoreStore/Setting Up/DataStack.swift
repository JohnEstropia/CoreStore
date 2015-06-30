//
//  DataStack.swift
//  CoreStore
//
//  Copyright (c) 2014 John Rommel Estropia
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


internal let applicationSupportDirectory = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).first as! NSURL

internal let applicationName = ((NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as? String) ?? "CoreData")

internal let defaultSQLiteStoreURL = applicationSupportDirectory.URLByAppendingPathComponent(applicationName, isDirectory: false).URLByAppendingPathExtension("sqlite")


// MARK: - DataStack

/**
The `DataStack` encapsulates the data model for the Core Data stack. Each `DataStack` can have multiple data stores, usually specified as a "Configuration" in the model editor. Behind the scenes, the DataStack manages its own `NSPersistentStoreCoordinator`, a root `NSManagedObjectContext` for disk saves, and a shared `NSManagedObjectContext` designed as a read-only model interface for `NSManagedObjects`.
*/
public final class DataStack {
    
    // MARK: Public
    
    /**
    Initializes a `DataStack` from an `NSManagedObjectModel`.
    
    :param: modelName the name of the (.xcdatamodeld) model file. If not specified, the application name will be used
    :param: sourceBundle an optional bundle to load models from. If not specified, the main bundle will be used.
    :param: modelVersions the `MigrationChain` that indicates the heirarchy of the model's version names. If not specified, will default to a non-migrating data stack.
    */
    public required init(modelName: String = applicationName, sourceBundle: NSBundle = NSBundle.mainBundle(), modelVersions: MigrationChain = nil) {
        
        let modelFilePath: String! = sourceBundle.pathForResource(
            modelName,
            ofType: "momd"
        )
        CoreStore.assert(modelFilePath != nil, "Could not find a \"momd\" resource from the main bundle.")
        
        let managedObjectModel: NSManagedObjectModel! = NSManagedObjectModel(contentsOfURL: NSURL(fileURLWithPath: modelFilePath)!)
        CoreStore.assert(
            managedObjectModel != nil,
            "Could not create an <\(NSManagedObjectModel.self)> from the resource at path \"\(modelFilePath)\"."
        )
        // TODO: assert existence of all model versions in the migrationChain
        
        self.coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        self.rootSavingContext = NSManagedObjectContext.rootSavingContextForCoordinator(self.coordinator)
        self.mainContext = NSManagedObjectContext.mainContextForRootContext(self.rootSavingContext)
        self.sourceBundle = sourceBundle
        self.modelVersions = modelVersions
        
        var entityNameMapping = [EntityClassNameType: EntityNameType]()
        var entityConfigurationsMapping = [EntityClassNameType: Set<String>]()
        for entityDescription in managedObjectModel.entities as! [NSEntityDescription] {
            
            let managedObjectClassName = entityDescription.managedObjectClassName
            entityConfigurationsMapping[managedObjectClassName] = []
            if let entityName = entityDescription.name {
                
                entityNameMapping[managedObjectClassName] = entityName
            }
        }
        self.entityNameMapping = entityNameMapping
        self.entityConfigurationsMapping = entityConfigurationsMapping
        
        self.rootSavingContext.parentStack = self
    }
    
    /**
    Adds an in-memory store to the stack.
    
    :param: configuration an optional configuration name from the model file. If not specified, defaults to nil.
    :returns: a `PersistentStoreResult` indicating success or failure.
    */
    public func addInMemoryStore(configuration: String? = nil) -> PersistentStoreResult {
        
        let coordinator = self.coordinator;
        var error: NSError?
        
        var store: NSPersistentStore?
        coordinator.performBlockAndWait {
            
            store = coordinator.addPersistentStoreWithType(
                NSInMemoryStoreType,
                configuration: configuration,
                URL: nil,
                options: nil,
                error: &error)
        }
        
        if let store = store {
            
            self.updateMetadataForPersistentStore(store)
            return PersistentStoreResult(store)
        }
        
        if let error = error {
            
            CoreStore.handleError(
                error,
                "Failed to add in-memory <\(NSPersistentStore.self)>.")
            return PersistentStoreResult(error)
        }
        else {
            
            CoreStore.handleError(
                NSError(coreStoreErrorCode: .UnknownError),
                "Failed to add in-memory <\(NSPersistentStore.self)>.")
            return PersistentStoreResult(.UnknownError)
        }
    }
    
    /**
    Adds to the stack an SQLite store from the given SQLite file name.
    
    :param: fileName the local filename for the SQLite persistent store in the "Application Support" directory. A new SQLite file will be created if it does not exist. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
    :param: configuration an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
    :param: automigrating Set to true to configure Core Data auto-migration, or false to disable. If not specified, defaults to true.
    :param: resetStoreOnMigrationFailure Set to true to delete the store on migration failure; or set to false to throw exceptions on failure instead. Typically should only be set to true when debugging, or if the persistent store can be recreated easily. If not specified, defaults to false
    :returns: a `PersistentStoreResult` indicating success or failure.
    */
    public func addSQLiteStoreAndWait(fileName: String, configuration: String? = nil, automigrating: Bool = true, resetStoreOnMigrationFailure: Bool = false) -> PersistentStoreResult {
        
        return self.addSQLiteStoreAndWait(
            fileURL: applicationSupportDirectory.URLByAppendingPathComponent(
                fileName,
                isDirectory: false
            ),
            configuration: configuration,
            automigrating: automigrating,
            resetStoreOnMigrationFailure: resetStoreOnMigrationFailure
        )
    }
    
    /**
    Adds to the stack an SQLite store from the given SQLite file URL.
    
    :param: fileURL the local file URL for the SQLite persistent store. A new SQLite file will be created if it does not exist. If not specified, defaults to a file URL pointing to a "<Application name>.sqlite" file in the "Application Support" directory. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
    :param: configuration an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
    :param: automigrating Set to true to configure Core Data auto-migration, or false to disable. If not specified, defaults to true.
    :param: resetStoreOnMigrationFailure Set to true to delete the store on migration failure; or set to false to throw exceptions on failure instead. Typically should only be set to true when debugging, or if the persistent store can be recreated easily. If not specified, defaults to false.
    :returns: a `PersistentStoreResult` indicating success or failure.
    */
    public func addSQLiteStoreAndWait(fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, automigrating: Bool = true, resetStoreOnMigrationFailure: Bool = false) -> PersistentStoreResult {
        
        let coordinator = self.coordinator;
        if let store = coordinator.persistentStoreForURL(fileURL) {
            
            let isExistingStoreAutomigrating = ((store.options?[NSMigratePersistentStoresAutomaticallyOption] as? Bool) ?? false)
            
            if store.type == NSSQLiteStoreType
                && isExistingStoreAutomigrating == automigrating
                && store.configurationName == (configuration ?? Into.defaultConfigurationName) {
                    
                    return PersistentStoreResult(store)
            }
            
            CoreStore.handleError(
                NSError(coreStoreErrorCode: .DifferentPersistentStoreExistsAtURL),
                "Failed to add SQLite <\(NSPersistentStore.self)> at \"\(fileURL)\" because a different <\(NSPersistentStore.self)> at that URL already exists.")
            
            return PersistentStoreResult(.DifferentPersistentStoreExistsAtURL)
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
                return PersistentStoreResult(directoryError!)
        }
        
        var store: NSPersistentStore?
        var persistentStoreError: NSError?
        coordinator.performBlockAndWait {
            
            store = coordinator.addPersistentStoreWithType(
                NSSQLiteStoreType,
                configuration: configuration,
                URL: fileURL,
                options: [NSSQLitePragmasOption: ["WAL": "journal_mode"],
                    NSInferMappingModelAutomaticallyOption: true,
                    NSMigratePersistentStoresAutomaticallyOption: automigrating],
                error: &persistentStoreError)
        }
        
        if let store = store {
            
            self.updateMetadataForPersistentStore(store)
            return PersistentStoreResult(store)
        }
        
        if let error = persistentStoreError
            where (
                resetStoreOnMigrationFailure
                    && (error.code == NSPersistentStoreIncompatibleVersionHashError
                        || error.code == NSMigrationMissingSourceModelError
                        || error.code == NSMigrationError)
                    && error.domain == NSCocoaErrorDomain
            ) {
                
                fileManager.removeItemAtURL(fileURL, error: nil)
                fileManager.removeItemAtPath(
                    fileURL.path!.stringByAppendingString("-shm"),
                    error: nil)
                fileManager.removeItemAtPath(
                    fileURL.path!.stringByAppendingString("-wal"),
                    error: nil)
                
                var store: NSPersistentStore?
                coordinator.performBlockAndWait {
                    
                    store = coordinator.addPersistentStoreWithType(
                        NSSQLiteStoreType,
                        configuration: configuration,
                        URL: fileURL,
                        options: [NSSQLitePragmasOption: ["WAL": "journal_mode"],
                            NSInferMappingModelAutomaticallyOption: true,
                            NSMigratePersistentStoresAutomaticallyOption: automigrating],
                        error: &persistentStoreError)
                }
                
                if let store = store {
                    
                    self.updateMetadataForPersistentStore(store)
                    return PersistentStoreResult(store)
                }
        }
        
        CoreStore.handleError(
            persistentStoreError ?? NSError(coreStoreErrorCode: .UnknownError),
            "Failed to add SQLite <\(NSPersistentStore.self)> at \"\(fileURL)\".")
        
        return PersistentStoreResult(.UnknownError)
    }
    
    
    // MARK: Internal
    
    internal let coordinator: NSPersistentStoreCoordinator
    internal let rootSavingContext: NSManagedObjectContext
    internal let mainContext: NSManagedObjectContext
    internal let sourceBundle: NSBundle
    internal let modelVersions: MigrationChain
    internal let childTransactionQueue: GCDQueue = .createSerial("com.corestore.datastack.childtransactionqueue")
    internal let migrationQueue: GCDQueue = .createSerial("com.corestore.datastack.migrationqueue")
    
    internal func entityNameForEntityClass(entityClass: AnyClass) -> String? {
        
        return self.entityNameMapping[NSStringFromClass(entityClass)]
    }
    
    internal func persistentStoresForEntityClass(entityClass: AnyClass) -> [NSPersistentStore]? {
        
        var returnValue: [NSPersistentStore]? = nil
        self.storeMetadataUpdateQueue.barrierSync {
            
            let configurationsForEntity = self.entityConfigurationsMapping[NSStringFromClass(entityClass)] ?? []
            returnValue = map(configurationsForEntity) {
                
                return self.configurationStoreMapping[$0]!
            }
        }
        return returnValue
    }
    
    internal func persistentStoreForEntityClass(entityClass: AnyClass, configuration: String?, inferStoreIfPossible: Bool) -> (store: NSPersistentStore?, isAmbiguous: Bool) {
        
        var returnValue: (store: NSPersistentStore?, isAmbiguous: Bool) = (store: nil, isAmbiguous: false)
        self.storeMetadataUpdateQueue.barrierSync {
            
            let configurationsForEntity = self.entityConfigurationsMapping[NSStringFromClass(entityClass)] ?? []
            if let configuration = configuration {
                
                if configurationsForEntity.contains(configuration) {
                    
                    returnValue = (store: self.configurationStoreMapping[configuration], isAmbiguous: false)
                    return
                }
                else if !inferStoreIfPossible {
                    
                    return
                }
            }
            
            switch configurationsForEntity.count {
                
            case 0:
                return
                
            case 1 where inferStoreIfPossible:
                returnValue = (store: self.configurationStoreMapping[configurationsForEntity.first!], isAmbiguous: false)
                
            default:
                returnValue = (store: nil, isAmbiguous: true)
            }
        }
        return returnValue
    }
    
    internal func updateMetadataForPersistentStore(persistentStore: NSPersistentStore) {
        
        self.storeMetadataUpdateQueue.barrierAsync {
            
            let configurationName = persistentStore.configurationName
            self.configurationStoreMapping[configurationName] = persistentStore
            for entityDescription in (self.coordinator.managedObjectModel.entitiesForConfiguration(configurationName) as? [NSEntityDescription] ?? []) {
                
                self.entityConfigurationsMapping[entityDescription.managedObjectClassName]?.insert(configurationName)
            }
        }
    }
    
    
    // MARK: Private
    
    private typealias EntityClassNameType = String
    private typealias EntityNameType = String
    private typealias ConfigurationNameType = String
    
    private let entityNameMapping: [EntityClassNameType: EntityNameType]
    private let storeMetadataUpdateQueue = GCDQueue.createConcurrent("com.coreStore.persistentStoreBarrierQueue")
    private var configurationStoreMapping = [ConfigurationNameType: NSPersistentStore]()
    private var entityConfigurationsMapping = [EntityClassNameType: Set<String>]()
}
