//
//  DataStack.swift
//  CoreStore
//
//  Copyright © 2014 John Rommel Estropia
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


// MARK: - DataStack

/**
 The `DataStack` encapsulates the data model for the Core Data stack. Each `DataStack` can have multiple data stores, usually specified as a "Configuration" in the model editor. Behind the scenes, the DataStack manages its own `NSPersistentStoreCoordinator`, a root `NSManagedObjectContext` for disk saves, and a shared `NSManagedObjectContext` designed as a read-only model interface for `NSManagedObjects`.
 */
public final class DataStack {
    
    /**
     Initializes a `DataStack` from the model with the specified `modelName` in the specified `bundle`.
     
     - parameter modelName: the name of the (.xcdatamodeld) model file. If not specified, the application name (CFBundleName) will be used if it exists, or "CoreData" if it the bundle name was not set.
     - parameter bundle: an optional bundle to load models from. If not specified, the main bundle will be used.
     - parameter migrationChain: the `MigrationChain` that indicates the sequence of model versions to be used as the order for progressive migrations. If not specified, will default to a non-migrating data stack.
     */
    public convenience init(modelName: String = DataStack.applicationName, bundle: Bundle = Bundle.main, migrationChain: MigrationChain = nil) {
        
        let model = NSManagedObjectModel.fromBundle(
            bundle,
            modelName: modelName,
            modelVersionHints: migrationChain.leafVersions
        )
        self.init(model: model, migrationChain: migrationChain)
    }
    
    /**
     Initializes a `DataStack` from an `NSManagedObjectModel`.
     
     - parameter model: the `NSManagedObjectModel` for the stack
     - parameter migrationChain: the `MigrationChain` that indicates the sequence of model versions to be used as the order for progressive migrations. If not specified, will default to a non-migrating data stack.
     */
    public required init(model: NSManagedObjectModel, migrationChain: MigrationChain = nil) {
        
        CoreStore.assert(
            migrationChain.valid,
            "Invalid migration chain passed to the \(cs_typeName(DataStack.self)). Check that the model versions' order is correct and that no repetitions or ambiguities exist."
        )
        
        self.coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        self.rootSavingContext = NSManagedObjectContext.rootSavingContextForCoordinator(self.coordinator)
        self.mainContext = NSManagedObjectContext.mainContextForRootContext(self.rootSavingContext)
        self.model = model
        self.migrationChain = migrationChain
        
        self.rootSavingContext.parentStack = self
        
        self.mainContext.isDataStackContext = true
    }
    
    /**
     Returns the `DataStack`'s model version. The version string is the same as the name of the version-specific .xcdatamodeld file.
     */
    public var modelVersion: String {
        
        return self.model.currentModelVersion!
    }
    
    /**
     Returns the entity name-to-class type mapping from the `DataStack`'s model.
     */
    public var entityTypesByName: [String: NSManagedObject.Type] {
        
        return self.model.entityTypesMapping()
    }
    
    /**
     Returns the `NSEntityDescription` for the specified `NSManagedObject` subclass.
     */
    public func entityDescription(for type: NSManagedObject.Type) -> NSEntityDescription? {
        
        return NSEntityDescription.entity(
            forEntityName: self.model.entityNameForClass(type),
            in: self.mainContext
        )
    }
    
    /**
     Returns the `NSManagedObjectID` for the specified object URI if it exists in the persistent store.
     */
    public func objectID(forURIRepresentation url: URL) -> NSManagedObjectID? {
        
        return self.coordinator.managedObjectID(forURIRepresentation: url)
    }
    
    /**
     Creates an `SQLiteStore` with default parameters and adds it to the stack. This method blocks until completion.
     ```
     try dataStack.addStorageAndWait()
     ```
     - throws: a `CoreStoreError` value indicating the failure
     - returns: the local SQLite storage added to the stack
     */
    @discardableResult
    public func addStorageAndWait() throws -> SQLiteStore {
        
        return try self.addStorageAndWait(SQLiteStore.self)
    }
    
    /**
     Creates a `StorageInterface` of the specified store type with default values and adds it to the stack. This method blocks until completion.
     ```
     try dataStack.addStorageAndWait(InMemoryStore.self)
     ```
     - parameter storeType: the `StorageInterface` type
     - throws: a `CoreStoreError` value indicating the failure
     - returns: the `StorageInterface` added to the stack
     */
    @discardableResult
    public func addStorageAndWait<T: StorageInterface>(_ storeType: T.Type) throws -> T where T: DefaultInitializableStore {
        
        return try self.addStorageAndWait(storeType.init())
    }
    
    /**
     Adds a `StorageInterface` to the stack and blocks until completion.
     ```
     try dataStack.addStorageAndWait(InMemoryStore(configuration: "Config1"))
     ```
     - parameter storage: the `StorageInterface`
     - throws: a `CoreStoreError` value indicating the failure
     - returns: the `StorageInterface` added to the stack
     */
    @discardableResult
    public func addStorageAndWait<T: StorageInterface>(_ storage: T) throws -> T {
        
        do {
            
            return try self.coordinator.performSynchronously {
                
                if let _ = self.persistentStoreForStorage(storage) {
                    
                    return storage
                }
                _ = try self.createPersistentStoreFromStorage(
                    storage,
                    finalURL: nil,
                    finalStoreOptions: storage.storeOptions
                )
                return storage
            }
        }
        catch {
            
            let storeError = CoreStoreError(error)
            CoreStore.log(
                storeError,
                "Failed to add \(cs_typeName(storage)) to the stack."
            )
            throw storeError
        }
    }
    
    /**
     Creates a `LocalStorageInterface` of the specified store type with default values and adds it to the stack. This method blocks until completion.
     ```
     try dataStack.addStorageAndWait(SQLiteStore.self)
     ```
     - parameter storeType: the `LocalStorageInterface` type
     - throws: a `CoreStoreError` value indicating the failure
     - returns: the local storage added to the stack
     */
    @discardableResult
    public func addStorageAndWait<T: LocalStorage>(_ storageType: T.Type) throws -> T where T: DefaultInitializableStore {
        
        return try self.addStorageAndWait(storageType.init())
    }
    
    /**
     Adds a `LocalStorage` to the stack and blocks until completion.
     ```
     try dataStack.addStorageAndWait(SQLiteStore(configuration: "Config1"))
     ```
     - parameter storage: the local storage
     - throws: a `CoreStoreError` value indicating the failure
     - returns: the local storage added to the stack. Note that this may not always be the same instance as the parameter argument if a previous `LocalStorage` was already added at the same URL and with the same configuration.
     */
    @discardableResult
    public func addStorageAndWait<T: LocalStorage>(_ storage: T) throws -> T {
        
        return try self.coordinator.performSynchronously {
            
            let fileURL = storage.fileURL
            CoreStore.assert(
                fileURL.isFileURL,
                "The specified store URL for the \"\(cs_typeName(storage))\" is invalid: \"\(fileURL)\""
            )
            
            if let _ = self.persistentStoreForStorage(storage) {
                
                return storage
            }
            
            if let persistentStore = self.coordinator.persistentStore(for: fileURL as URL) {
                
                if let existingStorage = persistentStore.storageInterface as? T,
                    storage.matchesPersistentStore(persistentStore) {
                    
                    return existingStorage
                }
                
                let error = CoreStoreError.differentStorageExistsAtURL(existingPersistentStoreURL: fileURL)
                CoreStore.log(
                    error,
                    "Failed to add \(cs_typeName(storage)) at \"\(fileURL)\" because a different \(cs_typeName(NSPersistentStore.self)) at that URL already exists."
                )
                throw error
            }
            
            do {
                
                var localStorageOptions = storage.localStorageOptions
                localStorageOptions.remove(.recreateStoreOnModelMismatch)
                
                let storeOptions = storage.dictionary(forOptions: localStorageOptions)
                do {
                    
                    try FileManager.default.createDirectory(
                        at: fileURL.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    _ = try self.createPersistentStoreFromStorage(
                        storage,
                        finalURL: fileURL,
                        finalStoreOptions: storeOptions
                    )
                    return storage
                }
                catch let error as NSError where storage.localStorageOptions.contains(.recreateStoreOnModelMismatch) && error.isCoreDataMigrationError {
                    
                    let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
                        ofType: type(of: storage).storeType,
                        at: fileURL,
                        options: storeOptions
                    )
                    try storage.eraseStorageAndWait(
                        metadata: metadata,
                        soureModelHint: self.model[metadata]
                    )
                    _ = try self.createPersistentStoreFromStorage(
                        storage,
                        finalURL: fileURL,
                        finalStoreOptions: storeOptions
                    )
                    return storage
                }
            }
            catch {
                
                let storeError = CoreStoreError(error)
                CoreStore.log(
                    storeError,
                    "Failed to add \(cs_typeName(storage)) to the stack."
                )
                throw storeError
            }
        }
    }
    
    /**
     Adds a `CloudStorage` to the stack and blocks until completion.
     ```
     guard let storage = ICloudStore(
         ubiquitousContentName: "MyAppCloudData",
         ubiquitousContentTransactionLogsSubdirectory: "logs/config1",
         ubiquitousContainerID: "iCloud.com.mycompany.myapp.containername",
         ubiquitousPeerToken: "9614d658014f4151a95d8048fb717cf0",
         configuration: "Config1",
         cloudStorageOptions: .recreateLocalStoreOnModelMismatch
     ) else {
         // iCloud is not available on the device
         return
     }
     try dataStack.addStorageAndWait(storage)
     ```
     - parameter storage: the local storage
     - throws: a `CoreStoreError` value indicating the failure
     - returns: the cloud storage added to the stack. Note that this may not always be the same instance as the parameter argument if a previous `CloudStorage` was already added at the same URL and with the same configuration.
     */
    @discardableResult
    public func addStorageAndWait<T: CloudStorage>(_ storage: T) throws -> T {
        
        return try self.coordinator.performSynchronously {
            
            if let _ = self.persistentStoreForStorage(storage) {
                
                return storage
            }
            
            let cacheFileURL = storage.cacheFileURL
            if let persistentStore = self.coordinator.persistentStore(for: cacheFileURL as URL) {
                
                if let existingStorage = persistentStore.storageInterface as? T,
                    storage.matchesPersistentStore(persistentStore) {
                    
                    return existingStorage
                }
                
                let error = CoreStoreError.differentStorageExistsAtURL(existingPersistentStoreURL: cacheFileURL)
                CoreStore.log(
                    error,
                    "Failed to add \(cs_typeName(storage)) at \"\(cacheFileURL)\" because a different \(cs_typeName(NSPersistentStore.self)) at that URL already exists."
                )
                throw error
            }
            
            do {
                
                var cloudStorageOptions = storage.cloudStorageOptions
                cloudStorageOptions.remove(.recreateLocalStoreOnModelMismatch)
                
                let storeOptions = storage.dictionary(forOptions: cloudStorageOptions)
                do {
                    
                    try FileManager.default.createDirectory(
                        at: cacheFileURL.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    _ = try self.createPersistentStoreFromStorage(
                        storage,
                        finalURL: cacheFileURL,
                        finalStoreOptions: storeOptions
                    )
                    return storage
                }
                catch let error as NSError where storage.cloudStorageOptions.contains(.recreateLocalStoreOnModelMismatch) && error.isCoreDataMigrationError {
                    
                    let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
                        ofType: type(of: storage).storeType,
                        at: cacheFileURL,
                        options: storeOptions
                    )
                    _ = try self.model[metadata].flatMap(storage.eraseStorageAndWait)
                    _ = try self.createPersistentStoreFromStorage(
                        storage,
                        finalURL: cacheFileURL,
                        finalStoreOptions: storeOptions
                    )
                    return storage
                }
            }
            catch {
                
                let storeError = CoreStoreError(error)
                CoreStore.log(
                    storeError,
                    "Failed to add \(cs_typeName(storage)) to the stack."
                )
                throw storeError
            }
        }
    }
    
    
    // MARK: Internal
    
    internal static let applicationName = (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "CoreData"
    
    internal let coordinator: NSPersistentStoreCoordinator
    internal let rootSavingContext: NSManagedObjectContext
    internal let mainContext: NSManagedObjectContext
    internal let model: NSManagedObjectModel
    internal let migrationChain: MigrationChain
    internal let childTransactionQueue = DispatchQueue.serial("com.coreStore.dataStack.childTransactionQueue")
    internal let storeMetadataUpdateQueue = DispatchQueue.concurrent("com.coreStore.persistentStoreBarrierQueue")
    internal let migrationQueue: OperationQueue = {
        
        let migrationQueue = OperationQueue()
        migrationQueue.maxConcurrentOperationCount = 1
        migrationQueue.name = "com.coreStore.migrationOperationQueue"
        migrationQueue.qualityOfService = .utility
        migrationQueue.underlyingQueue = DispatchQueue.serial("com.coreStore.migrationQueue", qos: .userInitiated)
        return migrationQueue
    }()
    
    internal func persistentStoreForStorage(_ storage: StorageInterface) -> NSPersistentStore? {
        
        return self.coordinator.persistentStores
            .filter { $0.storageInterface === storage }
            .first
    }
    
    internal func entityNameForEntityClass(_ entityClass: AnyClass) -> String? {
        
        return self.model.entityNameForClass(entityClass)
    }
    
    internal func persistentStoresForEntityClass(_ entityClass: AnyClass) -> [NSPersistentStore]? {
        
        var returnValue: [NSPersistentStore]? = nil
        self.storeMetadataUpdateQueue.sync(flags: .barrier) {
            
            returnValue = self.entityConfigurationsMapping[NSStringFromClass(entityClass)]?.map {
                
                return self.configurationStoreMapping[$0]!
            } ?? []
        }
        return returnValue
    }
    
    internal func persistentStoreForEntityClass(_ entityClass: AnyClass, configuration: String?, inferStoreIfPossible: Bool) -> (store: NSPersistentStore?, isAmbiguous: Bool) {
        
        return self.storeMetadataUpdateQueue.sync(flags: .barrier) { () -> (store: NSPersistentStore?, isAmbiguous: Bool) in
            
            let configurationsForEntity = self.entityConfigurationsMapping[NSStringFromClass(entityClass)] ?? []
            if let configuration = configuration {
                
                if configurationsForEntity.contains(configuration) {
                    
                    return (store: self.configurationStoreMapping[configuration], isAmbiguous: false)
                }
                else if !inferStoreIfPossible {
                    
                    return (store: nil, isAmbiguous: false)
                }
            }
            
            switch configurationsForEntity.count {
                
            case 0:
                return (store: nil, isAmbiguous: false)
                
            case 1 where inferStoreIfPossible:
                return (store: self.configurationStoreMapping[configurationsForEntity.first!], isAmbiguous: false)
                
            default:
                return (store: nil, isAmbiguous: true)
            }
        }
    }
    
    internal func createPersistentStoreFromStorage(_ storage: StorageInterface, finalURL: URL?, finalStoreOptions: [AnyHashable: Any]?) throws -> NSPersistentStore {
        
        let persistentStore = try self.coordinator.addPersistentStore(
            ofType: type(of: storage).storeType,
            configurationName: storage.configuration,
            at: finalURL,
            options: finalStoreOptions
        )
        persistentStore.storageInterface = storage
        
        self.storeMetadataUpdateQueue.async(flags: .barrier) {
            
            let configurationName = persistentStore.configurationName
            self.configurationStoreMapping[configurationName] = persistentStore
            for entityDescription in (self.coordinator.managedObjectModel.entities(forConfigurationName: configurationName) ?? []) {
                
                let managedObjectClassName = entityDescription.managedObjectClassName!
                CoreStore.assert(
                    NSClassFromString(managedObjectClassName) != nil,
                    "The class \(cs_typeName(managedObjectClassName)) for the entity \(cs_typeName(entityDescription.name)) does not exist. Check if the subclass type and module name are properly configured."
                )
                
                if self.entityConfigurationsMapping[managedObjectClassName] == nil {
                    
                    self.entityConfigurationsMapping[managedObjectClassName] = []
                }
                self.entityConfigurationsMapping[managedObjectClassName]?.insert(configurationName)
            }
        }
        storage.didAddToDataStack(self)
        return persistentStore
    }
    
    
    // MARK: Private
    
    private var configurationStoreMapping = [String: NSPersistentStore]()
    private var entityConfigurationsMapping = [String: Set<String>]()
    
    deinit {
        
        let coordinator = self.coordinator
        coordinator.performAsynchronously {
            
            withExtendedLifetime(coordinator) { coordinator in
                
                coordinator.persistentStores.forEach {
                    
                    _ = try? coordinator.remove($0)
                }
            }
        }
    }
    
    
    // MARK: Deprecated
    
    @available(*, deprecated: 3.0.0, renamed: "entityDescription(for:)")
    public func entityDescriptionForType(_ type: NSManagedObject.Type) -> NSEntityDescription? {
        
        return self.entityDescription(for: type)
    }
    
    @available(*, deprecated: 3.0.0, renamed: "objectID(forURIRepresentation:)")
    public func objectIDForURIRepresentation(_ url: URL) -> NSManagedObjectID? {
        
        return self.objectID(forURIRepresentation: url)
    }
}


// MARK: - DataStack: Equatable

public func == (lhs: DataStack, rhs: DataStack) -> Bool {
    
    return lhs === rhs
}

extension DataStack: Equatable {}
