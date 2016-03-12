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

class StorageInterfaceTests: XCTestCase {

    func testDefaultInMemoryStore() {
        
        let store = InMemoryStore()
        expect(store.dynamicType.storeType).to(equal(NSInMemoryStoreType))
        expect(store.configuration).to(beNil())
        expect(store.storeOptions).to(beNil())
    }
    
    func testInMemoryStoreConfiguration() {
        
        let store = InMemoryStore(configuration: "config1")
        expect(store.dynamicType.storeType).to(equal(NSInMemoryStoreType))
        expect(store.configuration).to(equal("config1"))
        expect(store.storeOptions).to(beNil())
    }
    
    func testSQLiteStoreDefaultDirectories() {
        
        #if os(tvOS)
            let systemDirectorySearchPath = NSSearchPathDirectory.CachesDirectory
        #else
            let systemDirectorySearchPath = NSSearchPathDirectory.ApplicationSupportDirectory
        #endif
        
        let defaultSystemDirectory = NSFileManager
            .defaultManager()
            .URLsForDirectory(systemDirectorySearchPath, inDomains: .UserDomainMask).first!
        
        let defaultRootDirectory = defaultSystemDirectory.URLByAppendingPathComponent(
            NSBundle.mainBundle().bundleIdentifier ?? "com.CoreStore.DataStack",
            isDirectory: true
        )
        let applicationName = (NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as? String) ?? "CoreData"
        
        let defaultFileURL = defaultRootDirectory
            .URLByAppendingPathComponent(applicationName, isDirectory: false)
            .URLByAppendingPathExtension("sqlite")
        
        expect(SQLiteStore.defaultRootDirectory).to(equal(defaultRootDirectory))
        expect(SQLiteStore.defaultFileURL).to(equal(defaultFileURL))
    }
    
    func testDefaultSQLiteStore() {
        
        let store = SQLiteStore()
        expect(store.dynamicType.storeType).to(equal(NSSQLiteStoreType))
        expect(store.configuration).to(beNil())
        expect(store.storeOptions).to(equal([NSSQLitePragmasOption: ["journal_mode": "WAL"]] as NSDictionary))
        
        expect(store.fileURL).to(equal(SQLiteStore.defaultFileURL))
        expect(store.mappingModelBundles).to(equal(NSBundle.allBundles()))
        expect(store.resetStoreOnModelMismatch).to(beFalse())
    }
    
    func testSQLiteStoreFileURL() {
        
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory())
            .URLByAppendingPathComponent(NSUUID().UUIDString, isDirectory: false)
            .URLByAppendingPathExtension("db")
        let bundles = [NSBundle(forClass: self.dynamicType)]
        
        let store = SQLiteStore(
            fileURL: fileURL,
            configuration: "config1",
            mappingModelBundles: bundles,
            resetStoreOnModelMismatch: true
        )
        expect(store.dynamicType.storeType).to(equal(NSSQLiteStoreType))
        expect(store.configuration).to(equal("config1"))
        expect(store.storeOptions).to(equal([NSSQLitePragmasOption: ["journal_mode": "WAL"]] as NSDictionary))
        
        expect(store.fileURL).to(equal(fileURL))
        expect(store.mappingModelBundles).to(equal(bundles))
        expect(store.resetStoreOnModelMismatch).to(beTrue())
    }
    
    func testSQLiteStoreFileName() {
        
        let fileName = NSUUID().UUIDString + ".db"
        let bundles = [NSBundle(forClass: self.dynamicType)]
        
        let store = SQLiteStore(
            fileName: fileName,
            configuration: "config1",
            mappingModelBundles: bundles,
            resetStoreOnModelMismatch: true
        )
        expect(store.dynamicType.storeType).to(equal(NSSQLiteStoreType))
        expect(store.configuration).to(equal("config1"))
        expect(store.storeOptions).to(equal([NSSQLitePragmasOption: ["journal_mode": "WAL"]] as NSDictionary))
        
        expect(store.fileURL.URLByDeletingLastPathComponent).to(equal(SQLiteStore.defaultRootDirectory))
        expect(store.fileURL.lastPathComponent).to(equal(fileName))
        expect(store.mappingModelBundles).to(equal(bundles))
        expect(store.resetStoreOnModelMismatch).to(beTrue())
    }
    
    func testLegacySQLiteStoreDefaultDirectories() {
        
        #if os(tvOS)
            let systemDirectorySearchPath = NSSearchPathDirectory.CachesDirectory
        #else
            let systemDirectorySearchPath = NSSearchPathDirectory.ApplicationSupportDirectory
        #endif
        
        let legacyDefaultRootDirectory = NSFileManager.defaultManager().URLsForDirectory(
            systemDirectorySearchPath,
            inDomains: .UserDomainMask
            ).first!
        
        let legacyDefaultFileURL = legacyDefaultRootDirectory
            .URLByAppendingPathComponent(DataStack.applicationName, isDirectory: false)
            .URLByAppendingPathExtension("sqlite")
        
        expect(LegacySQLiteStore.legacyDefaultRootDirectory).to(equal(legacyDefaultRootDirectory))
        expect(LegacySQLiteStore.legacyDefaultFileURL).to(equal(legacyDefaultFileURL))
    }
    
    func testDefaultLegacySQLiteStore() {
        
        let store = LegacySQLiteStore()
        expect(store.dynamicType.storeType).to(equal(NSSQLiteStoreType))
        expect(store.configuration).to(beNil())
        expect(store.storeOptions).to(equal([NSSQLitePragmasOption: ["journal_mode": "WAL"]] as NSDictionary))
        
        expect(store.fileURL).to(equal(LegacySQLiteStore.legacyDefaultFileURL))
        expect(store.mappingModelBundles).to(equal(NSBundle.allBundles()))
        expect(store.resetStoreOnModelMismatch).to(beFalse())
    }
    
    func testLegacySQLiteStoreFileURL() {
        
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory())
            .URLByAppendingPathComponent(NSUUID().UUIDString, isDirectory: false)
            .URLByAppendingPathExtension("db")
        let bundles = [NSBundle(forClass: self.dynamicType)]
        
        let store = LegacySQLiteStore(
            fileURL: fileURL,
            configuration: "config1",
            mappingModelBundles: bundles,
            resetStoreOnModelMismatch: true
        )
        expect(store.dynamicType.storeType).to(equal(NSSQLiteStoreType))
        expect(store.configuration).to(equal("config1"))
        expect(store.storeOptions).to(equal([NSSQLitePragmasOption: ["journal_mode": "WAL"]] as NSDictionary))
        
        expect(store.fileURL).to(equal(fileURL))
        expect(store.mappingModelBundles).to(equal(bundles))
        expect(store.resetStoreOnModelMismatch).to(beTrue())
    }
    
    func testLegacySQLiteStoreFileName() {
        
        let fileName = NSUUID().UUIDString + ".db"
        let bundles = [NSBundle(forClass: self.dynamicType)]
        
        let store = LegacySQLiteStore(
            fileName: fileName,
            configuration: "config1",
            mappingModelBundles: bundles,
            resetStoreOnModelMismatch: true
        )
        expect(store.dynamicType.storeType).to(equal(NSSQLiteStoreType))
        expect(store.configuration).to(equal("config1"))
        expect(store.storeOptions).to(equal([NSSQLitePragmasOption: ["journal_mode": "WAL"]] as NSDictionary))
        
        expect(store.fileURL.URLByDeletingLastPathComponent).to(equal(LegacySQLiteStore.legacyDefaultRootDirectory))
        expect(store.fileURL.lastPathComponent).to(equal(fileName))
        expect(store.mappingModelBundles).to(equal(bundles))
        expect(store.resetStoreOnModelMismatch).to(beTrue())
    }
}
