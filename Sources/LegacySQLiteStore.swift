//
//  LegacySQLiteStore.swift
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

import Foundation
import CoreData


// MARK: - LegacySQLiteStore

/**
 A storage interface backed by an SQLite database that was created before CoreStore 2.0.0.
 */
@available(*, obsoleted: 3.1, message: "`LegacySQLiteStore` previous users should now use `SQLiteStore`'s new SQLiteStore.legacy(fileName:configuration:migrationMappingProviders:localStorageOptions:) or SQLiteStore.legacy() methods to create an `SQLiteStore` with legacy paths.")
public final class LegacySQLiteStore: LocalStorage {
    
    @available(*, obsoleted: 3.1, message: "Use `SQLiteStore`'s new SQLiteStore.init(fileURL:configuration:migrationMappingProviders:localStorageOptions:) initializer.")
    public init(fileURL: URL, configuration: ModelConfiguration = nil, mappingModelBundles: [Bundle] = Bundle.allBundles, localStorageOptions: LocalStorageOptions = nil) {
        
        fatalError()
    }
    
    @available(*, obsoleted: 3.1, message: "Use `SQLiteStore`'s new SQLiteStore.legacy(fileName:configuration:migrationMappingProviders:localStorageOptions:) factory method.")
    public init(fileName: String, configuration: ModelConfiguration = nil, mappingModelBundles: [Bundle] = Bundle.allBundles, localStorageOptions: LocalStorageOptions = nil) {
        
        fatalError()
    }
    
    @available(*, obsoleted: 3.1, message: "Use `SQLiteStore`'s new SQLiteStore.legacy(...) factory method.")
    public init() {
        
        fatalError()
    }
    
    
    // MARK: StorageInterface
    
    public static let storeType = NSSQLiteStoreType
    
    public func dictionary(forOptions options: LocalStorageOptions) -> [AnyHashable: Any]? {
        
        fatalError()
    }
    
    public let configuration: ModelConfiguration
    
    public let storeOptions: [AnyHashable: Any]? = [NSSQLitePragmasOption: ["journal_mode": "WAL"]]
    
    public func cs_didAddToDataStack(_ dataStack: DataStack) {
        
        fatalError()
    }
    
    public func cs_didRemoveFromDataStack(_ dataStack: DataStack) {
        
        fatalError()
    }
    
    
    // MAKR: LocalStorage
    
    public let fileURL: URL
    
    public let migrationMappingProviders: [SchemaMappingProvider]
    
    public var localStorageOptions: LocalStorageOptions
    
    public func cs_finalizeStorageAndWait(soureModelHint: NSManagedObjectModel) throws {
        
        fatalError()
    }
    
    public func cs_eraseStorageAndWait(metadata: [String: Any], soureModelHint: NSManagedObjectModel?) throws {
        
        fatalError()
    }
    
    
    // MARK: Private
    
    private weak var dataStack: DataStack?
}
