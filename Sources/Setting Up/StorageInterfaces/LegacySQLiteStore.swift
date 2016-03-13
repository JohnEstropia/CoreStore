//
//  LegacySQLiteStore.swift
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

import Foundation


// MARK: - LegacySQLiteStore

/**
 A storage interface backed by an SQLite database that was created before CoreStore 2.0.0.
 - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was depending on CoreStore's default directories prior to 2.0.0, make sure to use `LegacySQLiteStore` instead of `SQLiteStore`.
 */
public final class LegacySQLiteStore: SQLiteStore {
    
    /**
     Initializes an SQLite store interface from the given SQLite file URL. When this instance is passed to the `DataStack`'s `addStorage()` methods, a new SQLite file will be created if it does not exist.
     
     - parameter fileURL: the local file URL for the target SQLite persistent store. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
     - parameter mappingModelBundles: a list of `NSBundle`s from which to search mapping models for migration.
     - parameter resetStoreOnModelMismatch: When the `LegacySQLiteStore` is passed to the `DataStack`'s `addStorage()` methods, a `true` value tells the `DataStack` to delete the store on model mismatch; a `false` value lets exceptions be thrown on failure instead. Typically should only be set to true when debugging, or if the persistent store can be recreated easily. If not specified, defaults to `false`.
     */
    public required init(fileURL: NSURL, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles(), resetStoreOnModelMismatch: Bool = false) {
        
        super.init(
            fileURL: fileURL,
            configuration: configuration,
            mappingModelBundles: mappingModelBundles,
            resetStoreOnModelMismatch: resetStoreOnModelMismatch
        )
    }
    
    /**
     Initializes an SQLite store interface from the given SQLite file name. When this instance is passed to the `DataStack`'s `addStorage()` methods, a new SQLite file will be created if it does not exist.
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was depending on CoreStore's default directories prior to 2.0.0, make sure to use `LegacySQLiteStore` instead of `SQLiteStore`.
     
     - parameter fileName: the local filename for the SQLite persistent store in the "Application Support" directory (or the "Caches" directory on tvOS). Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
     - parameter mappingModelBundles: a list of `NSBundle`s from which to search mapping models for migration.
     - parameter resetStoreOnModelMismatch: When the `LegacySQLiteStore` is passed to the `DataStack`'s `addStorage()` methods, a true value tells the `DataStack` to delete the store on model mismatch; a false value lets exceptions be thrown on failure instead. Typically should only be set to true when debugging, or if the persistent store can be recreated easily. If not specified, defaults to false.
     */
    public required init(fileName: String, configuration: String? = nil, mappingModelBundles: [NSBundle] = NSBundle.allBundles(), resetStoreOnModelMismatch: Bool = false) {
        
        super.init(
            fileURL: LegacySQLiteStore.defaultRootDirectory.URLByAppendingPathComponent(
                fileName,
                isDirectory: false
            ),
            configuration: configuration,
            mappingModelBundles: mappingModelBundles,
            resetStoreOnModelMismatch: resetStoreOnModelMismatch
        )
    }
    
    
    // MARK: SQLiteStore
    
    internal override class var defaultRootDirectory: NSURL {
        
        #if os(tvOS)
            let systemDirectorySearchPath = NSSearchPathDirectory.CachesDirectory
        #else
            let systemDirectorySearchPath = NSSearchPathDirectory.ApplicationSupportDirectory
        #endif
        
        return NSFileManager.defaultManager().URLsForDirectory(
            systemDirectorySearchPath,
            inDomains: .UserDomainMask
            ).first!
    }
    
    internal override class var defaultFileURL: NSURL {
        
        return LegacySQLiteStore.defaultRootDirectory
            .URLByAppendingPathComponent(DataStack.applicationName, isDirectory: false)
            .URLByAppendingPathExtension("sqlite")
    }
    
    
    // MARK: DefaultInitializableStore
    
    /**
     Initializes an `LegacySQLiteStore` with an all-default settings: a `fileURL` pointing to a "<Application name>.sqlite" file in the "Application Support" directory (or the "Caches" directory on tvOS), a `nil` `configuration` pertaining to the "Default" configuration, a `mappingModelBundles` set to search all `NSBundle`s, and `resetStoreOnModelMismatch` disabled.
     - Warning: The default SQLite file location for the `LegacySQLiteStore` and `SQLiteStore` are different. If the app was depending on CoreStore's default directories prior to 2.0.0, make sure to use `LegacySQLiteStore` instead of `SQLiteStore`.
     */
    public required init() {
        
        super.init(fileURL: LegacySQLiteStore.defaultFileURL)
    }
}
