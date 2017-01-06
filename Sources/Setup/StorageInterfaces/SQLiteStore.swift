//
//  SQLiteStore.swift
//  CoreStore
//
//  Copyright © 2016 John Rommel Estropia
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

import CoreData


// MARK: - SQLiteStore

/**
 A storage interface that is backed by an SQLite database.
 
 - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was depending on CoreStore's default directories prior to 2.0.0, make sure to use `LegacySQLiteStore` instead of `SQLiteStore`.
 */
public final class SQLiteStore: LocalStorage, DefaultInitializableStore {
    
    /**
     Initializes an SQLite store interface from the given SQLite file URL. When this instance is passed to the `DataStack`'s `addStorage()` methods, a new SQLite file will be created if it does not exist.
     
     - parameter fileURL: the local file URL for the target SQLite persistent store. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
     - parameter mappingModelBundles: a list of `NSBundle`s from which to search mapping models (*.xcmappingmodel) for migration.
     - parameter localStorageOptions: When the `SQLiteStore` is passed to the `DataStack`'s `addStorage()` methods, tells the `DataStack` how to setup the persistent store. Defaults to `.None`.
     */
    public init(fileURL: URL, configuration: String? = nil, mappingModelBundles: [Bundle] = Bundle.allBundles, localStorageOptions: LocalStorageOptions = nil) {
        
        self.fileURL = fileURL
        self.configuration = configuration
        self.mappingModelBundles = mappingModelBundles
        self.localStorageOptions = localStorageOptions
    }
    
    /**
     Initializes an SQLite store interface from the given SQLite file name. When this instance is passed to the `DataStack`'s `addStorage()` methods, a new SQLite file will be created if it does not exist.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was depending on CoreStore's default directories prior to 2.0.0, make sure to use `LegacySQLiteStore` instead of `SQLiteStore`.
     - parameter fileName: the local filename for the SQLite persistent store in the "Application Support/<bundle id>" directory (or the "Caches/<bundle id>" directory on tvOS). Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
     - parameter mappingModelBundles: a list of `NSBundle`s from which to search mapping models (*.xcmappingmodel) for migration
     - parameter localStorageOptions: When the `SQLiteStore` is passed to the `DataStack`'s `addStorage()` methods, tells the `DataStack` how to setup the persistent store. Defaults to `.None`.
     */
    public init(fileName: String, configuration: String? = nil, mappingModelBundles: [Bundle] = Bundle.allBundles, localStorageOptions: LocalStorageOptions = nil) {
        
        self.fileURL = SQLiteStore.defaultRootDirectory
            .appendingPathComponent(fileName, isDirectory: false)
        self.configuration = configuration
        self.mappingModelBundles = mappingModelBundles
        self.localStorageOptions = localStorageOptions
    }
    
    
    // MARK: DefaultInitializableStore
    
    /**
     Initializes an `SQLiteStore` with an all-default settings: a `fileURL` pointing to a "<Application name>.sqlite" file in the "Application Support/<bundle id>" directory (or the "Caches/<bundle id>" directory on tvOS), a `nil` `configuration` pertaining to the "Default" configuration, a `mappingModelBundles` set to search all `NSBundle`s, and `localStorageOptions` set to `.AllowProgresiveMigration`.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was depending on CoreStore's default directories prior to 2.0.0, make sure to use `LegacySQLiteStore` instead of `SQLiteStore`.
     */
    public init() {
        
        self.fileURL = SQLiteStore.defaultFileURL
        self.configuration = nil
        self.mappingModelBundles = Bundle.allBundles
        self.localStorageOptions = nil
    }
    
    
    // MARK: StorageInterface
    
    /**
     The string identifier for the `NSPersistentStore`'s `type` property. For `SQLiteStore`s, this is always set to `NSSQLiteStoreType`.
     */
    public static let storeType = NSSQLiteStoreType
    
    /**
     The configuration name in the model file
     */
    public let configuration: String?
    
    /**
     The options dictionary for the `NSPersistentStore`. For `SQLiteStore`s, this is always set to 
     ```
     [NSSQLitePragmasOption: ["journal_mode": "WAL"]]
     ```
     */
    public let storeOptions: [AnyHashable: Any]? = [NSSQLitePragmasOption: ["journal_mode": "WAL"]]
    
    /**
     Do not call directly. Used by the `DataStack` internally.
     */
    public func didAddToDataStack(_ dataStack: DataStack) {
        
        self.dataStack = dataStack
    }
    
    /**
     Do not call directly. Used by the `DataStack` internally.
     */
    public func didRemoveFromDataStack(_ dataStack: DataStack) {
        
        self.dataStack = nil
    }
    
    
    // MAKR: LocalStorage
    
    /**
     The `NSURL` that points to the SQLite file
     */
    public let fileURL: URL
    
    /**
     The `NSBundle`s from which to search mapping models for migrations
     */
    public let mappingModelBundles: [Bundle]
    
    /**
     Options that tell the `DataStack` how to setup the persistent store
     */
    public var localStorageOptions: LocalStorageOptions
    
    /**
     The options dictionary for the specified `LocalStorageOptions`
     */
    public func dictionary(forOptions options: LocalStorageOptions) -> [AnyHashable: Any]? {
        
        if options == .none {
            
            return self.storeOptions
        }
        
        var storeOptions = self.storeOptions ?? [:]
        if options.contains(.allowSynchronousLightweightMigration) {
            
            storeOptions[NSMigratePersistentStoresAutomaticallyOption] = true
            storeOptions[NSInferMappingModelAutomaticallyOption] = true
        }
        return storeOptions
    }
    
    /**
     Called by the `DataStack` to perform actual deletion of the store file from disk. Do not call directly! The `sourceModel` argument is a hint for the existing store's model version. For `SQLiteStore`, this converts the database's WAL journaling mode to DELETE before deleting the file.
     */
    public func eraseStorageAndWait(metadata: [String: Any], soureModelHint: NSManagedObjectModel?) throws {
        
        // TODO: check if attached to persistent store
        
        func deleteFiles(storeURL: URL, extraFiles: [String] = []) throws {
            
            let fileManager = FileManager.default
            let extraFiles: [String] = [
                storeURL.path.appending("-wal"),
                storeURL.path.appending("-shm")
            ]
            do {
                
                let trashURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!)
                    .appendingPathComponent(Bundle.main.bundleIdentifier ?? "com.CoreStore.DataStack", isDirectory: true)
                    .appendingPathComponent("trash", isDirectory: true)
                try fileManager.createDirectory(
                    at: trashURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                
                let temporaryFileURL = trashURL.appendingPathComponent(UUID().uuidString, isDirectory: false)
                try fileManager.moveItem(at: storeURL, to: temporaryFileURL)
                
                let extraTemporaryFiles = extraFiles.map { (extraFile) -> String in
                    
                    let temporaryFile = trashURL.appendingPathComponent(UUID().uuidString, isDirectory: false).path
                    if let _ = try? fileManager.moveItem(atPath: extraFile, toPath: temporaryFile) {
                        
                        return temporaryFile
                    }
                    return extraFile
                }
                DispatchQueue.global(qos: .background).async {
                    
                    _ = try? fileManager.removeItem(at: temporaryFileURL)
                    extraTemporaryFiles.forEach({ _ = try? fileManager.removeItem(atPath: $0) })
                }
            }
            catch {
                
                try fileManager.removeItem(at: storeURL)
                extraFiles.forEach({ _ = try? fileManager.removeItem(atPath: $0) })
            }
        }
        
        let fileURL = self.fileURL
        try autoreleasepool {
            
            if let soureModel = soureModelHint ?? NSManagedObjectModel.mergedModel(from: nil, forStoreMetadata: metadata) {
                
                let journalUpdatingCoordinator = NSPersistentStoreCoordinator(managedObjectModel: soureModel)
                let store = try journalUpdatingCoordinator.addPersistentStore(
                    ofType: type(of: self).storeType,
                    configurationName: self.configuration,
                    at: fileURL,
                    options: [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
                )
                try journalUpdatingCoordinator.remove(store)
            }
            try deleteFiles(storeURL: fileURL)
        }
    }
    
    
    // MARK: Internal
    
    internal static let defaultRootDirectory: URL = {
        
        #if os(tvOS)
            let systemDirectorySearchPath = FileManager.SearchPathDirectory.cachesDirectory
        #else
            let systemDirectorySearchPath = FileManager.SearchPathDirectory.applicationSupportDirectory
        #endif
        
        let defaultSystemDirectory = FileManager.default.urls(
                for: systemDirectorySearchPath,
                in: .userDomainMask).first!
        
        return defaultSystemDirectory.appendingPathComponent(
            Bundle.main.bundleIdentifier ?? "com.CoreStore.DataStack",
            isDirectory: true
        )
    }()
    
    internal static let defaultFileURL = SQLiteStore.defaultRootDirectory
        .appendingPathComponent(
            (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "CoreData",
            isDirectory: false
        )
        .appendingPathExtension("sqlite")
    
    
    // MARK: Private
    
    private weak var dataStack: DataStack?
}
