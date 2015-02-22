//
//  DataStack.swift
//  HardcoreData
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


private let applicationSupportDirectory = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).first as! NSURL

private let applicationName = ((NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as? String) ?? "CoreData")


// MARK: - DataStack

/**
The DataStack encapsulates the data model for the Core Data stack. Each DataStack can have multiple data stores, usually specified as a "Configuration" in the model editor. Behind the scenes, the DataStack manages its own NSPersistentStoreCoordinator, a root NSManagedObjectContext for disk saves, and a shared NSManagedObjectContext acting as a model interface for NSManagedObjects.
*/
public class DataStack {
    
    // MARK: Public
    
    /**
    Initializes a DataStack from merged model in the app bundle.
    */
    public convenience init() {
        
        self.init(managedObjectModel: NSManagedObjectModel.mergedModelFromBundles(NSBundle.allBundles())!)
    }
    
    /**
    Initializes a DataStack from the specified model name.

    :param: modelName the name of the (.xcdatamodeld) model file.
    */
    public convenience init(modelName: String) {
        
        let modelFilePath = NSBundle.mainBundle().pathForResource(modelName, ofType: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: NSURL(fileURLWithPath: modelFilePath)!)!
        
        self.init(managedObjectModel: managedObjectModel)
    }
    
    /**
    Initializes a DataStack from an NSManagedObjectModel.
    
    :param: modelName the name of the "momd" (or xcdatamodeld) file.
    */
    public required init(managedObjectModel: NSManagedObjectModel) {
        
        self.coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        self.rootSavingContext = NSManagedObjectContext.rootSavingContextForCoordinator(self.coordinator)
        self.mainContext = NSManagedObjectContext.mainContextForRootContext(self.rootSavingContext)
        self.transactionQueue = .createSerial("com.hardcoredata.datastack.transactionqueue")
        self.entityNameMapping = (managedObjectModel.entities as! [NSEntityDescription]).reduce([EntityClassNameType: EntityNameType]()) { (var mapping, entityDescription) in
            
            if let entityName = entityDescription.name {
                
                mapping[entityDescription.managedObjectClassName] = entityName
            }
            return mapping
        }
        
        println(self.entityNameMapping)
        
        self.rootSavingContext.parentStack = self
    }
    
    /**
    Adds an in-memory store to the stack.
    
    :param: configuration an optional configuration name from the model file. If not specified, defaults to nil.
    :returns: a PersistentStoreResult indicating success or failure.
    */
    public func addInMemoryStore(configuration: String? = nil) -> PersistentStoreResult {
        
        let coordinator = self.coordinator;
        var persistentStoreError: NSError?
        
        var store: NSPersistentStore?
        coordinator.performSynchronously {
            
            store = coordinator.addPersistentStoreWithType(
                NSInMemoryStoreType,
                configuration: configuration,
                URL: nil,
                options: nil,
                error: &persistentStoreError)
        }
        
        if let store = store {
            
            return PersistentStoreResult(store)
        }
        
        if let error = persistentStoreError {
            
            HardcoreData.handleError(
                error,
                "Failed to add in-memory NSPersistentStore.")
            return PersistentStoreResult(error)
        }
        else {
            
            HardcoreData.handleError(
                NSError(hardcoreDataErrorCode: .UnknownError),
                "Failed to add in-memory NSPersistentStore.")
        }
        return PersistentStoreResult(.UnknownError)
    }
    
    /**
    Adds to the stack an SQLite store from the given SQLite file name.
    
    :param: fileName the local filename for the SQLite persistent store in the "Application Support" directory. A new SQLite file will be created if it does not exist.
    :param: configuration an optional configuration name from the model file. If not specified, defaults to nil.
    :param: automigrating Set to true to configure Core Data auto-migration, or false to disable. If not specified, defaults to true.
    :param: resetStoreOnMigrationFailure Set to true to delete the store on migration failure; or set to false to throw exceptions on failure instead. Typically should only be set to true when debugging, or if the persistent store can be recreated easily. If not specified, defaults to false
    :returns: a PersistentStoreResult indicating success or failure.
    */
    public func addSQLiteStore(fileName: String, configuration: String? = nil, automigrating: Bool = true, resetStoreOnMigrationFailure: Bool = false) -> PersistentStoreResult {
        
        return self.addSQLiteStore(
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
    
    :param: fileURL the local file URL for the SQLite persistent store. A new SQLite file will be created if it does not exist. If not specified, defaults to a file URL pointing to a "<Application name>.sqlite" file in the "Application Support" directory.
    :param: configuration an optional configuration name from the model file. If not specified, defaults to nil.
    :param: automigrating Set to true to configure Core Data auto-migration, or false to disable. If not specified, defaults to true.
    :param: resetStoreOnMigrationFailure Set to true to delete the store on migration failure; or set to false to throw exceptions on failure instead. Typically should only be set to true when debugging, or if the persistent store can be recreated easily. If not specified, defaults to false.
    :returns: a PersistentStoreResult indicating success or failure.
    */
    public func addSQLiteStore(fileURL: NSURL = applicationSupportDirectory.URLByAppendingPathComponent(applicationName, isDirectory: true).URLByAppendingPathExtension("sqlite"), configuration: String? = nil, automigrating: Bool = true, resetStoreOnMigrationFailure: Bool = false) -> PersistentStoreResult {
        
        let coordinator = self.coordinator;
        if let store = coordinator.persistentStoreForURL(fileURL) {
            
            let isExistingStoreAutomigrating = ((store.options?[NSMigratePersistentStoresAutomaticallyOption] as? Bool) ?? false)
            
            if store.type == NSSQLiteStoreType
                && isExistingStoreAutomigrating == automigrating {
                    
                    return PersistentStoreResult(store)
            }
            
            HardcoreData.handleError(
                NSError(hardcoreDataErrorCode: .DifferentPersistentStoreExistsAtURL),
                "Failed to add SQLite NSPersistentStore at \"\(fileURL)\" because a different NSPersistentStore at that URL already exists.")
            return PersistentStoreResult(.DifferentPersistentStoreExistsAtURL)
        }
        
        let fileManager = NSFileManager.defaultManager()
        var directoryError: NSError?
        if !fileManager.createDirectoryAtURL(
            fileURL.URLByDeletingLastPathComponent!,
            withIntermediateDirectories: true,
            attributes: nil,
            error: &directoryError) {
                
                HardcoreData.handleError(
                    directoryError!,
                    "Failed to create directory for SQLite store at \"\(fileURL)\".")
                return PersistentStoreResult(directoryError!)
        }
        
        var store: NSPersistentStore?
        var persistentStoreError: NSError?
        coordinator.performSynchronously {
            
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
            
            return PersistentStoreResult(store)
        }
        
        if let error = persistentStoreError {
            
            if resetStoreOnMigrationFailure
                && (error.code == NSPersistentStoreIncompatibleVersionHashError
                    || error.code == NSMigrationMissingSourceModelError)
                && error.domain == NSCocoaErrorDomain {
                    
                    fileManager.removeItemAtURL(fileURL, error: nil)
                    fileManager.removeItemAtPath(
                        fileURL.path!.stringByAppendingString("-shm"),
                        error: nil)
                    fileManager.removeItemAtPath(
                        fileURL.path!.stringByAppendingString("-wal"),
                        error: nil)
                    
                    var store: NSPersistentStore?
                    coordinator.performSynchronously {
                        
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
                        
                        return PersistentStoreResult(store)
                    }
            }
        }
        
        if let error = persistentStoreError {
            
            HardcoreData.handleError(
                error,
                "Failed to add SQLite NSPersistentStore at \"\(fileURL)\".")
            return PersistentStoreResult(error)
        }
        else {
            
            HardcoreData.handleError(
                NSError(hardcoreDataErrorCode: .UnknownError),
                "Failed to add SQLite NSPersistentStore at \"\(fileURL)\".")
        }
        return PersistentStoreResult(.UnknownError)
    }
    
    
    // MARK: Internal
    
    internal let mainContext: NSManagedObjectContext
    internal let transactionQueue: GCDQueue;
    
    internal func entityNameForEntityClass(entityClass: NSManagedObject.Type) -> String? {
        
        return self.entityNameMapping[NSStringFromClass(entityClass)]
    }
    
    
    // MARK: Private
    
    private typealias EntityClassNameType = String
    private typealias EntityNameType = String
    
    private let coordinator: NSPersistentStoreCoordinator
    private let rootSavingContext: NSManagedObjectContext
    private let entityNameMapping: [EntityClassNameType: EntityNameType]
}
