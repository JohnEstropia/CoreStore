//
//  CSSQLiteStore.swift
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
import CoreData


// MARK: - CSSQLiteStore

/**
 The `CSSQLiteStore` serves as the Objective-C bridging type for `SQLiteStore`.
 
 - SeeAlso: `SQLiteStore`
 */
@objc
public final class CSSQLiteStore: NSObject, CSLocalStorage, CoreStoreObjectiveCType {
    
    /**
     Initializes an SQLite store interface from the given SQLite file URL. When this instance is passed to the `CSDataStack`'s `-addStorage*:` methods, a new SQLite file will be created if it does not exist.
     
     - Important: Initializing `CSSQLiteStore`s with custom migration mapping models is currently not supported. Create an `SQLiteStore` instance from Swift code and bridge the instance to Objective-C using its `SQLiteStore.bridgeToObjectiveC` property.
     - parameter fileURL: the local file URL for the target SQLite persistent store. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileURL` explicitly for each of them.
     - parameter localStorageOptions: When the `CSSQLiteStore` is passed to the `CSDataStack`'s `addStorage()` methods, tells the `CSDataStack` how to setup the persistent store. Defaults to `CSLocalStorageOptionsNone`.
     */
    @objc
    public convenience init(fileURL: URL, configuration: ModelConfiguration, localStorageOptions: Int) {
        
        self.init(
            SQLiteStore(
                fileURL: fileURL,
                configuration: configuration,
                localStorageOptions: LocalStorageOptions(rawValue: localStorageOptions)
            )
        )
    }
    
    /**
     Initializes an SQLite store interface from the given SQLite file name. When this instance is passed to the `CSDataStack`'s `-addStorage*:` methods, a new SQLite file will be created if it does not exist.
     
     - Important: Initializing `CSSQLiteStore`s with custom migration mapping models is currently not supported. Create an `SQLiteStore` instance from Swift code and bridge the instance to Objective-C using its `SQLiteStore.bridgeToObjectiveC` property.
     - parameter fileName: the local filename for the SQLite persistent store in the "Application Support/<bundle id>" directory (or the "Caches/<bundle id>" directory on tvOS). Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `fileName` explicitly for each of them.
     - parameter localStorageOptions: When the `CSSQLiteStore` is passed to the `CSDataStack`'s `addStorage()` methods, tells the `CSDataStack` how to setup the persistent store. Defaults to `[CSLocalStorageOptions none]`.
     */
    @objc
    public convenience init(fileName: String, configuration: ModelConfiguration, localStorageOptions: Int) {
        
        self.init(
            SQLiteStore(
                fileName: fileName,
                configuration: configuration,
                localStorageOptions: LocalStorageOptions(rawValue: localStorageOptions)
            )
        )
    }
    
    /**
     Initializes an `CSSQLiteStore` with an all-default settings: a `fileURL` pointing to a "<Application name>.sqlite" file in the "Application Support/<bundle id>" directory (or the "Caches/<bundle id>" directory on tvOS), a `nil` `configuration` pertaining to the "Default" configuration, and `localStorageOptions` set to `[CSLocalStorageOptions none]`.
     
     - Important: Initializing `CSSQLiteStore`s with custom migration mapping models is currently not supported. Create an `SQLiteStore` instance from Swift code and bridge the instance to Objective-C using its `SQLiteStore.bridgeToObjectiveC` property.
     */
    @objc
    public convenience override init() {
        
        self.init(SQLiteStore())
    }
    
    
    // MAKR: CSLocalStorage
    
    /**
     The `NSURL` that points to the SQLite file
     */
    @objc
    public var fileURL: URL {
     
        return self.bridgeToSwift.fileURL as URL
    }
    
    /**
     An array of `SchemaMappingProvider`s that provides the complete mapping models for custom migrations. This is currently only supported for Swift code.
     */
    @objc
    public var migrationMappingProviders: [Any] {
    
        return self.bridgeToSwift.migrationMappingProviders
    }
    
    /**
     Options that tell the `CSDataStack` how to setup the persistent store
     */
    @objc
    public var localStorageOptions: Int {
        
        return self.bridgeToSwift.localStorageOptions.rawValue
    }
    
    
    // MARK: CSStorageInterface
    
    /**
     The string identifier for the `NSPersistentStore`'s `type` property. For `CSSQLiteStore`s, this is always set to `NSSQLiteStoreType`.
     */
    @objc
    public static let storeType = NSSQLiteStoreType
    
    /**
     The configuration name in the model file
     */
    public var configuration: ModelConfiguration {
        
        return self.bridgeToSwift.configuration
    }
    
    /**
     The options dictionary for the `NSPersistentStore`. For `CSSQLiteStore`s, this is always set to
     ```
     [NSSQLitePragmasOption: ["journal_mode": "WAL"]]
     ```
     */
    @objc
    public var storeOptions: [AnyHashable: Any]? {
        
        return self.bridgeToSwift.storeOptions
    }
    
    /**
     Called by the `CSDataStack` to perform actual deletion of the store file from disk. Do not call directly! The `sourceModel` argument is a hint for the existing store's model version. For `CSSQLiteStore`, this converts the database's WAL journaling mode to DELETE before deleting the file.
     */
    @objc
    public func cs_eraseStorageAndWait(metadata: NSDictionary, soureModelHint: NSManagedObjectModel?, error: NSErrorPointer) -> Bool {
        
        return bridge(error) {
            
            try self.bridgeToSwift.cs_eraseStorageAndWait(metadata: metadata as! [String: Any], soureModelHint: soureModelHint)
        }
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return ObjectIdentifier(self.bridgeToSwift).hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let object = object as? CSSQLiteStore else {
            
            return false
        }
        return self.bridgeToSwift === object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: type(of: self)))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: SQLiteStore
    
    public required init(_ swiftValue: SQLiteStore) {
        
        self.bridgeToSwift = swiftValue
        super.init()
    }
    
    
    // MARK: Obsoleted
    
    @available(*, obsoleted: 3.1, message: "The `mappingModelBundles` argument of this method is ignored. Use the new -[CSSQLiteStore initWithFileURL:configuration:localStorageOptions:]) initializer instead.")
    @objc
    public convenience init(fileURL: URL, configuration: ModelConfiguration, mappingModelBundles: [Bundle]?, localStorageOptions: Int) {
        
        fatalError()
    }
    
    @available(*, obsoleted: 3.1, message: "The `mappingModelBundles` argument of this method is ignored. Use the new -[CSSQLiteStore initWithFileName:configuration:localStorageOptions:]) initializer instead.")
    @objc
    public convenience init(fileName: String, configuration: ModelConfiguration, mappingModelBundles: [Bundle]?, localStorageOptions: Int) {
        
        fatalError()
    }
}


// MARK: - SQLiteStore

extension SQLiteStore: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSSQLiteStore {
        
        return CSSQLiteStore(self)
    }
}
