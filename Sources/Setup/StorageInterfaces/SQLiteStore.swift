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
    public init(fileURL: NSURL, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles(), localStorageOptions: LocalStorageOptions = nil) {
        
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
    public init(fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles(), localStorageOptions: LocalStorageOptions = nil) {
        
        self.fileURL = SQLiteStore.defaultRootDirectory
            .URLByAppendingPathComponent(fileName, isDirectory: false)
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
        self.mappingModelBundles = NSBundle.allBundles()
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
    public let storeOptions: [String: AnyObject]? = [NSSQLitePragmasOption: ["journal_mode": "WAL"]]
    
    /**
     Do not call directly. Used by the `DataStack` internally.
     */
    public func didAddToDataStack(dataStack: DataStack) {
        
        self.dataStack = dataStack
    }
    
    /**
     Do not call directly. Used by the `DataStack` internally.
     */
    public func didRemoveFromDataStack(dataStack: DataStack) {
        
        self.dataStack = nil
    }
    
    
    // MAKR: LocalStorage
    
    /**
     The `NSURL` that points to the SQLite file
     */
    public let fileURL: NSURL
    
    /**
     The `NSBundle`s from which to search mapping models for migrations
     */
    public let mappingModelBundles: [NSBundle]
    
    /**
     Options that tell the `DataStack` how to setup the persistent store
     */
    public var localStorageOptions: LocalStorageOptions
    
    /**
     The options dictionary for the specified `LocalStorageOptions`
     */
    public func storeOptionsForOptions(options: LocalStorageOptions) -> [String: AnyObject]? {
        
        if options == .None {
            
            return self.storeOptions
        }
        
        var storeOptions = self.storeOptions ?? [:]
        if options.contains(.AllowSynchronousLightweightMigration) {
            
            storeOptions[NSMigratePersistentStoresAutomaticallyOption] = true
            storeOptions[NSInferMappingModelAutomaticallyOption] = true
        }
        return storeOptions
    }
    
    /**
     Called by the `DataStack` to perform actual deletion of the store file from disk. Do not call directly! The `sourceModel` argument is a hint for the existing store's model version. For `SQLiteStore`, this converts the database's WAL journaling mode to DELETE before deleting the file.
     */
    public func eraseStorageAndWait(soureModel soureModel: NSManagedObjectModel) throws {
        
        // TODO: check if attached to persistent store
        
        let fileURL = self.fileURL
        try cs_autoreleasepool {
            
            let journalUpdatingCoordinator = NSPersistentStoreCoordinator(managedObjectModel: soureModel)
            let store = try journalUpdatingCoordinator.addPersistentStoreWithType(
                self.dynamicType.storeType,
                configuration: self.configuration,
                URL: fileURL,
                options: [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
            )
            try journalUpdatingCoordinator.removePersistentStore(store)
            try NSFileManager.defaultManager().removeItemAtURL(fileURL)
        }
    }
    
    
    // MARK: Internal
    
    internal static let defaultRootDirectory: NSURL = {
        
        #if os(tvOS)
            let systemDirectorySearchPath = NSSearchPathDirectory.CachesDirectory
        #else
            let systemDirectorySearchPath = NSSearchPathDirectory.ApplicationSupportDirectory
        #endif
        
        let defaultSystemDirectory = NSFileManager
            .defaultManager()
            .URLsForDirectory(systemDirectorySearchPath, inDomains: .UserDomainMask).first!
        
        return defaultSystemDirectory.URLByAppendingPathComponent(
            NSBundle.mainBundle().bundleIdentifier ?? "com.CoreStore.DataStack",
            isDirectory: true
        )
    }()
    
    internal static let defaultFileURL = SQLiteStore.defaultRootDirectory
        .URLByAppendingPathComponent(
            (NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as? String) ?? "CoreData",
            isDirectory: false
        )
        .URLByAppendingPathExtension("sqlite")
    
    
    // MARK: Private
    
    private weak var dataStack: DataStack?
}
