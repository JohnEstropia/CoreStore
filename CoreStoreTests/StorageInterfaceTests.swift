//
//  StorageInterfaceTests.swift
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

import XCTest

@testable
import CoreStore


//MARK: - StorageInterfaceTests

final class StorageInterfaceTests: XCTestCase {
    
    @objc
    dynamic func test_ThatDefaultInMemoryStores_ConfigureCorrectly() {
        
        let store = InMemoryStore()
        XCTAssertEqual(type(of: store).storeType, NSInMemoryStoreType)
        XCTAssertNil(store.configuration)
        XCTAssertNil(store.storeOptions)
    }
    
    @objc
    dynamic func test_ThatCustomInMemoryStores_ConfigureCorrectly() {
        
        let store = InMemoryStore(configuration: "config1")
        XCTAssertEqual(type(of: store).storeType, NSInMemoryStoreType)
        XCTAssertEqual(store.configuration, "config1")
        XCTAssertNil(store.storeOptions)
    }
    
    @objc
    dynamic func test_ThatSQLiteStoreDefaultDirectories_AreCorrect() {
        
        #if os(tvOS)
            let systemDirectorySearchPath = FileManager.SearchPathDirectory.cachesDirectory
        #else
            let systemDirectorySearchPath = FileManager.SearchPathDirectory.applicationSupportDirectory
        #endif
        
        let defaultSystemDirectory = FileManager.default
            .urls(for: systemDirectorySearchPath, in: .userDomainMask).first!
        
        let defaultRootDirectory = defaultSystemDirectory.appendingPathComponent(
            Bundle.main.bundleIdentifier ?? "com.CoreStore.DataStack",
            isDirectory: true
        )
        let applicationName = (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "CoreData"
        
        let defaultFileURL = defaultRootDirectory
            .appendingPathComponent(applicationName, isDirectory: false)
            .appendingPathExtension("sqlite")
        
        XCTAssertEqual(SQLiteStore.defaultRootDirectory, defaultRootDirectory)
        XCTAssertEqual(SQLiteStore.defaultFileURL, defaultFileURL)
    }
    
    @objc
    dynamic func test_ThatDefaultSQLiteStores_ConfigureCorrectly() {
        
        let store = SQLiteStore()
        XCTAssertEqual(type(of: store).storeType, NSSQLiteStoreType)
        XCTAssertNil(store.configuration)
        XCTAssertEqual(store.storeOptions as NSDictionary?, [NSSQLitePragmasOption: ["journal_mode": "WAL"]] as NSDictionary)
        
        XCTAssertEqual(store.fileURL, SQLiteStore.defaultFileURL)
        XCTAssertTrue(store.migrationMappingProviders.isEmpty)
        XCTAssertEqual(store.localStorageOptions, .none)
    }
    
    @objc
    dynamic func test_ThatFileURLSQLiteStores_ConfigureCorrectly() {
        
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(NSUUID().uuidString, isDirectory: false)!
            .appendingPathExtension("db")
        let mappingProvider = XcodeSchemaMappingProvider(
            from: "V1", to: "V2",
            mappingModelBundle: Bundle(for: type(of: self))
        )
        
        let store = SQLiteStore(
            fileURL: fileURL,
            configuration: "config1",
            migrationMappingProviders: [mappingProvider],
            localStorageOptions: .recreateStoreOnModelMismatch
        )
        XCTAssertEqual(type(of: store).storeType, NSSQLiteStoreType)
        XCTAssertEqual(store.configuration, "config1")
        XCTAssertEqual(store.storeOptions as NSDictionary?, [NSSQLitePragmasOption: ["journal_mode": "WAL"]] as NSDictionary)
        
        XCTAssertEqual(store.fileURL, fileURL)
        XCTAssertEqual(store.migrationMappingProviders as! [XcodeSchemaMappingProvider], [mappingProvider])
        XCTAssertEqual(store.localStorageOptions, [.recreateStoreOnModelMismatch])
    }
    
    @objc
    dynamic func test_ThatFileNameSQLiteStores_ConfigureCorrectly() {
        
        let fileName = UUID().uuidString + ".db"
        let mappingProvider = XcodeSchemaMappingProvider(
            from: "V1", to: "V2",
            mappingModelBundle: Bundle(for: type(of: self))
        )
        let store = SQLiteStore(
            fileName: fileName,
            configuration: "config1",
            migrationMappingProviders: [mappingProvider],
            localStorageOptions: .recreateStoreOnModelMismatch
        )
        XCTAssertEqual(type(of: store).storeType, NSSQLiteStoreType)
        XCTAssertEqual(store.configuration, "config1")
        XCTAssertEqual(store.storeOptions as NSDictionary?, [NSSQLitePragmasOption: ["journal_mode": "WAL"]] as NSDictionary)
        
        XCTAssertEqual(store.fileURL.deletingLastPathComponent(), SQLiteStore.defaultRootDirectory)
        XCTAssertEqual(store.fileURL.lastPathComponent, fileName)
        XCTAssertEqual(store.migrationMappingProviders as! [XcodeSchemaMappingProvider], [mappingProvider])
        XCTAssertEqual(store.localStorageOptions, [.recreateStoreOnModelMismatch])
    }
    
    @objc
    dynamic func test_ThatLegacySQLiteStoreDefaultDirectories_AreCorrect() {
        
        #if os(tvOS)
            let systemDirectorySearchPath = FileManager.SearchPathDirectory.cachesDirectory
        #else
            let systemDirectorySearchPath = FileManager.SearchPathDirectory.applicationSupportDirectory
        #endif
        
        let legacyDefaultRootDirectory = FileManager.default.urls(
            for: systemDirectorySearchPath,
            in: .userDomainMask).first!
        
        let legacyDefaultFileURL = legacyDefaultRootDirectory
            .appendingPathComponent(DataStack.applicationName, isDirectory: false)
            .appendingPathExtension("sqlite")
        
        XCTAssertEqual(SQLiteStore.legacyDefaultRootDirectory, legacyDefaultRootDirectory)
        XCTAssertEqual(SQLiteStore.legacyDefaultFileURL, legacyDefaultFileURL)
    }
    
    @objc
    dynamic func test_ThatDefaultLegacySQLiteStores_ConfigureCorrectly() {
        
        let store = SQLiteStore.legacy()
        XCTAssertEqual(type(of: store).storeType, NSSQLiteStoreType)
        XCTAssertNil(store.configuration)
        XCTAssertEqual(store.storeOptions as NSDictionary?, [NSSQLitePragmasOption: ["journal_mode": "WAL"]] as NSDictionary)
        
        XCTAssertEqual(store.fileURL, SQLiteStore.legacyDefaultFileURL)
        XCTAssertTrue(store.migrationMappingProviders.isEmpty)
        XCTAssertEqual(store.localStorageOptions, .none)
    }
    
    @objc
    dynamic func test_ThatFileNameLegacySQLiteStores_ConfigureCorrectly() {
        
        let fileName = UUID().uuidString + ".db"
        let mappingProvider = XcodeSchemaMappingProvider(
            from: "V1", to: "V2",
            mappingModelBundle: Bundle(for: type(of: self))
        )
        let store = SQLiteStore.legacy(
            fileName: fileName,
            configuration: "config1",
            migrationMappingProviders: [mappingProvider],
            localStorageOptions: .recreateStoreOnModelMismatch
        )
        XCTAssertEqual(type(of: store).storeType, NSSQLiteStoreType)
        XCTAssertEqual(store.configuration, "config1")
        XCTAssertEqual(store.storeOptions as NSDictionary?, [NSSQLitePragmasOption: ["journal_mode": "WAL"]] as NSDictionary)
        
        XCTAssertEqual(store.fileURL.deletingLastPathComponent(), SQLiteStore.legacyDefaultRootDirectory)
        XCTAssertEqual(store.fileURL.lastPathComponent, fileName)
        XCTAssertEqual(store.migrationMappingProviders as! [XcodeSchemaMappingProvider], [mappingProvider])
        XCTAssertEqual(store.localStorageOptions, [.recreateStoreOnModelMismatch])
    }
}
