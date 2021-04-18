//
//  SQLiteStore.swift
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
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
 
 - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was depending on CoreStore's default directories prior to 2.0.0, make sure to use the `SQLiteStore.legacy(...)` factory methods to create the `SQLiteStore` instead of using initializers directly.
 */
public final class SQLiteStore: LocalStorage {
    
    /**
     Initializes an SQLite store interface from the given SQLite file URL. When this instance is passed to the `DataStack`'s `addStorage()` methods, a new SQLite file will be created if it does not exist.
     
     - parameter fileURL: the local file URL for the target SQLite persistent store. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
     - parameter migrationMappingProviders: an array of `SchemaMappingProviders` that provides the complete mapping models for custom migrations. All lightweight inferred mappings and/or migration mappings provided by *xcmappingmodel files are automatically used as fallback (as `InferredSchemaMappingProvider`) and may be omitted from the array.
     - parameter localStorageOptions: When the `SQLiteStore` is passed to the `DataStack`'s `addStorage()` methods, tells the `DataStack` how to setup the persistent store. Defaults to `.none`.
     */
    public convenience init(
        fileURL: URL,
        configuration: ModelConfiguration = nil,
        migrationMappingProviders: [SchemaMappingProvider] = [],
        localStorageOptions: LocalStorageOptions = nil
    ) {

        self.init(
            container: .custom(fileURL: fileURL),
            configuration: configuration,
            migrationMappingProviders: migrationMappingProviders,
            localStorageOptions: localStorageOptions
        )
    }
    
    /**
     Initializes an SQLite store interface from the given SQLite file name. When this instance is passed to the `DataStack`'s `addStorage()` methods, a new SQLite file will be created if it does not exist.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was depending on CoreStore's default directories prior to 2.0.0, make sure to use the `SQLiteStore.legacy(...)` factory methods to create the `SQLiteStore` instead of using initializers directly.
     - parameter fileName: the local filename for the SQLite persistent store in the "Application Support/<bundle id>" directory (or the "Caches/<bundle id>" directory on tvOS). Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
     - parameter migrationMappingProviders: an array of `SchemaMappingProviders` that provides the complete mapping models for custom migrations. All lightweight inferred mappings and/or migration mappings provided by *xcmappingmodel files are automatically used as fallback (as `InferredSchemaMappingProvider`) and may be omitted from the array.
     - parameter localStorageOptions: When the `SQLiteStore` is passed to the `DataStack`'s `addStorage()` methods, tells the `DataStack` how to setup the persistent store. Defaults to `.None`.
     */
    public convenience init(
        fileName: String,
        configuration: ModelConfiguration = nil,
        migrationMappingProviders: [SchemaMappingProvider] = [],
        localStorageOptions: LocalStorageOptions = nil
    ) {

        self.init(
            container: .default(fileName: fileName),
            configuration: configuration,
            migrationMappingProviders: migrationMappingProviders,
            localStorageOptions: localStorageOptions
        )
    }

    /**
     Initializes an SQLite store interface with a device-wide shared persistent store using a registered App Group Identifier. This store does not use remote persistent history tracking, and should be used only in the context of App-Extension shared stores.

     - Important: The app will be force-terminated if the `appGroupIdentifier` is not registered for the app.
     - parameter appGroupIdentifier: the App Group identifier registered for this application. The app will be force-terminated if this identifier is not registered for the app.
     - parameter subdirectory: an optional containing directory, or directories separated by the path separator `/`, where the persistent store file will be initialized.
     - parameter fileName: the local filename for the SQLite persistent store.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
     - parameter migrationMappingProviders: an array of `SchemaMappingProviders` that provides the complete mapping models for custom migrations. All lightweight inferred mappings and/or migration mappings provided by *xcmappingmodel files are automatically used as fallback (as `InferredSchemaMappingProvider`) and may be omitted from the array.
     - parameter localStorageOptions: When the `SQLiteStore` is passed to the `DataStack`'s `addStorage()` methods, tells the `DataStack` how to setup the persistent store. Defaults to `.None`.
     */
    public convenience init(
        appGroupIdentifier: String,
        subdirectory: String?,
        fileName: String,
        configuration: ModelConfiguration = nil,
        migrationMappingProviders: [SchemaMappingProvider] = [],
        localStorageOptions: LocalStorageOptions = nil
    ) {

        self.init(
            container: .appGroup(
                appGroupIdentifier: appGroupIdentifier,
                subdirectory: subdirectory,
                fileName: fileName
            ),
            configuration: configuration,
            migrationMappingProviders: migrationMappingProviders,
            localStorageOptions: localStorageOptions
        )
    }
    
    /**
     Initializes an `SQLiteStore` with an all-default settings: a `fileURL` pointing to a "<Application name>.sqlite" file in the "Application Support/<bundle id>" directory (or the "Caches/<bundle id>" directory on tvOS), a `nil` `configuration` pertaining to the "Default" configuration, a `migrationMappingProviders` set to empty, and `localStorageOptions` set to `.AllowProgresiveMigration`.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was depending on CoreStore's default directories prior to 2.0.0, make sure to use the `SQLiteStore.legacy(...)` factory methods to create the `SQLiteStore` instead of using initializers directly.
     */
    public convenience init() {

        self.init(
            container: .default(
                fileName: "\((Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "CoreData").sqlite"
            ),
            configuration: nil,
            migrationMappingProviders: [],
            localStorageOptions: nil
        )
    }
    
    /**
     Initializes an SQLite store interface from the given SQLite file name. When this instance is passed to the `DataStack`'s `addStorage()` methods, a new SQLite file will be created if it does not exist.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was depending on CoreStore's default directories prior to 2.0.0, make sure to use the `SQLiteStore.legacy(...)` factory methods to create the `SQLiteStore` instead of using initializers directly.
     - parameter legacyFileName: the local filename for the SQLite persistent store in the "Application Support" directory (or the "Caches" directory on tvOS). Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
     - parameter migrationMappingProviders: an array of `SchemaMappingProviders` that provides the complete mapping models for custom migrations. All lightweight inferred mappings and/or migration mappings provided by *xcmappingmodel files are automatically used as fallback (as `InferredSchemaMappingProvider`) and may be omitted from the array.
     - parameter localStorageOptions: When the `SQLiteStore` is passed to the `DataStack`'s `addStorage()` methods, tells the `DataStack` how to setup the persistent store. Defaults to `.None`.
     */
    public static func legacy(
        fileName: String,
        configuration: ModelConfiguration = nil,
        migrationMappingProviders: [SchemaMappingProvider] = [],
        localStorageOptions: LocalStorageOptions = nil
    ) -> SQLiteStore {

        return self.init(
            container: .legacy(fileName: fileName),
            configuration: configuration,
            migrationMappingProviders: migrationMappingProviders,
            localStorageOptions: localStorageOptions
        )
    }
    
    /**
     Initializes an `LegacySQLiteStore` with an all-default settings: a `fileURL` pointing to a "<Application name>.sqlite" file in the "Application Support" directory (or the "Caches" directory on tvOS), a `nil` `configuration` pertaining to the "Default" configuration, a `migrationMappingProviders` set to empty, and `localStorageOptions` set to `.AllowProgresiveMigration`.
     
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was depending on CoreStore's default directories prior to 2.0.0, make sure to use the `SQLiteStore.legacy(...)` factory methods to create the `SQLiteStore` instead of using initializers directly.
     */
    public static func legacy() -> SQLiteStore {

        return self.init(
            container: .legacy(
                fileName: "\(DataStack.applicationName).sqlite"
            ),
            configuration: nil,
            migrationMappingProviders: [],
            localStorageOptions: nil
        )
    }
    
    /**
     Queries the file size (in bytes) of the store, or `nil` if the file does not exist yet
     */
    public func fileSize() -> UInt64? {
        
        guard let attribute = try? FileManager.default.attributesOfItem(atPath: self.fileURL.path),
            let sizeAttribute = attribute[.size],
            let fileSize = sizeAttribute as? NSNumber else {
                
                return nil
        }
        return fileSize.uint64Value
    }
    
    
    // MARK: StorageInterface
    
    /**
     The string identifier for the `NSPersistentStore`'s `type` property. For `SQLiteStore`s, this is always set to `NSSQLiteStoreType`.
     */
    public static let storeType = NSSQLiteStoreType
    
    /**
     The configuration name in the model file
     */
    public let configuration: ModelConfiguration
    
    /**
     The options dictionary for the `NSPersistentStore`. For `SQLiteStore`s, this is always set to 
     ```
     [NSSQLitePragmasOption: ["journal_mode": "WAL"]]
     ```
     */
    public let storeOptions: [AnyHashable: Any]? = [
        NSSQLitePragmasOption: ["journal_mode": "WAL"],
        NSBinaryStoreInsecureDecodingCompatibilityOption: true
    ]
    
    /**
     Do not call directly. Used by the `DataStack` internally.
     */
    public func cs_didAddToDataStack(_ dataStack: DataStack) {
        
        self.dataStack = dataStack
    }
    
    /**
     Do not call directly. Used by the `DataStack` internally.
     */
    public func cs_didRemoveFromDataStack(_ dataStack: DataStack) {
        
        self.dataStack = nil
    }
    
    
    // MAKR: LocalStorage
    
    /**
     The `NSURL` that points to the SQLite file
     */
    public private(set) lazy var fileURL: URL = self.container.fileURL
    
    /**
     An array of `SchemaMappingProviders` that provides the complete mapping models for custom migrations.
     */
    public let migrationMappingProviders: [SchemaMappingProvider]
    
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
     Called by the `DataStack` to perform checkpoint operations on the storage. For `SQLiteStore`, this converts the database's WAL journaling mode to DELETE to force a checkpoint.
     */
    public func cs_finalizeStorageAndWait(soureModelHint: NSManagedObjectModel) throws {
        
        _ = try withExtendedLifetime(NSPersistentStoreCoordinator(managedObjectModel: soureModelHint)) { (coordinator: NSPersistentStoreCoordinator) in
            
            var storeOptions = self.storeOptions ?? [:]
            storeOptions[NSSQLitePragmasOption] = ["journal_mode": "DELETE"]
            try coordinator.addPersistentStore(
                ofType: Self.storeType,
                configurationName: self.configuration,
                at: fileURL,
                options: storeOptions
            )
        }
        _ = try? FileManager.default.removeItem(atPath: "\(self.fileURL.path)-shm")
    }
    
    /**
     Called by the `DataStack` to perform actual deletion of the store file from disk. Do not call directly! The `sourceModel` argument is a hint for the existing store's model version. For `SQLiteStore`, this converts the database's WAL journaling mode to DELETE before deleting the file.
     */
    public func cs_eraseStorageAndWait(metadata: [String: Any], soureModelHint: NSManagedObjectModel?) throws {
        
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
                var storeOptions = self.storeOptions ?? [:]
                storeOptions[NSSQLitePragmasOption] = ["journal_mode": "DELETE"]
                let store = try journalUpdatingCoordinator.addPersistentStore(
                    ofType: Self.storeType,
                    configurationName: self.configuration,
                    at: fileURL,
                    options: storeOptions
                )
                try journalUpdatingCoordinator.remove(store)
            }
            try deleteFiles(storeURL: fileURL)
        }
    }
    
    
    // MARK: Internal
    
    internal static let defaultRootDirectory: URL = Internals.with {
        
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
    }
    
    internal static let legacyDefaultRootDirectory: URL = Internals.with {
        
        #if os(tvOS)
            let systemDirectorySearchPath = FileManager.SearchPathDirectory.cachesDirectory
        #else
            let systemDirectorySearchPath = FileManager.SearchPathDirectory.applicationSupportDirectory
        #endif
        
        return FileManager.default.urls(
            for: systemDirectorySearchPath,
            in: .userDomainMask).first!
    }

    @available(*, deprecated, message: "Used only in Unit Tests")
    internal static let defaultFileURL = SQLiteStore.defaultRootDirectory
        .appendingPathComponent(
            (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "CoreData",
            isDirectory: false
        )
        .appendingPathExtension("sqlite")

    @available(*, deprecated, message: "Used only in Unit Tests")
    internal static let legacyDefaultFileURL = Internals.with {
        
        return SQLiteStore.legacyDefaultRootDirectory
        .appendingPathComponent(DataStack.applicationName, isDirectory: false)
        .appendingPathExtension("sqlite")
    }
    
    
    // MARK: Private
    
    private weak var dataStack: DataStack?
    private let container: Container

    private init(
        container: Container,
        configuration: ModelConfiguration = nil,
        migrationMappingProviders: [SchemaMappingProvider] = [],
        localStorageOptions: LocalStorageOptions = nil
    ) {

        self.container = container
        self.configuration = configuration
        self.migrationMappingProviders = migrationMappingProviders
        self.localStorageOptions = localStorageOptions
    }


    // MARK: - Container

    internal enum Container: Equatable {

        // MARK: Internal

        /**
         A container for device-wide shared persistent store using a registered Application Group Identifier.

         - Important: The app will be force-terminated if the `appGroupIdentifier` is not registered for the app.
         */
        case appGroup(
                appGroupIdentifier: String,
                subdirectory: String?,
                fileName: String
             )

        /**
         A local filename for the SQLite persistent store saved into the "Application Support/<bundle id>" directory (or on tvOS, the "Caches/<bundle id>" directory). Use this only for apps that used CoreStore's default directories prior to CoreStore v8.0.0 and after CoreStore v2.0.0. For apps with no bundle identifiers (ex: command line tools), the "<bundle id>" will be `com.CoreStore.DataStack`
         */
        case `default`(fileName: String)

        /**
         A local filename for the SQLite persistent store saved into the "Application Support" directory (or on tvOS, the "Caches" directory). Use this only for apps that used CoreStore's default directories prior to CoreStore v2.0.0.
         */
        case legacy(fileName: String)

        /**
         A custom location specifying the URL of the SQLite persistent store file itself
         */
        case custom(fileURL: URL)


        var fileURL: URL {

            switch self {

            case .appGroup(let appGroupIdentifier, let subdirectory, let fileName):
                let containerURL = FileManager.default.containerURL(
                    forSecurityApplicationGroupIdentifier: appGroupIdentifier
                )!
                if let subdirectory = subdirectory {

                    return containerURL
                        .appendingPathComponent(subdirectory, isDirectory: true)
                        .appendingPathComponent(fileName, isDirectory: false)
                }
                else {

                    return containerURL
                        .appendingPathComponent(fileName, isDirectory: false)
                }

            case .default(let fileName):
                return SQLiteStore.defaultRootDirectory
                    .appendingPathComponent(fileName, isDirectory: false)

            case .legacy(let fileName):
                return SQLiteStore.legacyDefaultRootDirectory
                    .appendingPathComponent(fileName, isDirectory: false)

            case .custom(let fileURL):
                return fileURL
            }
        }
    }
}
