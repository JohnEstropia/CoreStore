//
//  SetupTests.swift
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

@testable
import CoreStore


// MARK: - SetupTests

class SetupTests: BaseTestCase {
    
    func testInMemoryStores() {
        
        let stack = DataStack(
            modelName: "Model",
            bundle: NSBundle(forClass: self.dynamicType)
        )
        CoreStore.defaultStack = stack
        XCTAssertEqual(CoreStore.defaultStack, stack)
        XCTAssertEqual(stack.modelVersion, "Model")
        XCTAssert(stack.migrationChain.valid)
        XCTAssert(stack.migrationChain.empty)
        XCTAssert(stack.migrationChain.rootVersions.isEmpty)
        XCTAssert(stack.migrationChain.leafVersions.isEmpty)
        
        do {
            
            let sqliteStore = SQLiteStore()
            XCTAssertEqual(sqliteStore.fileURL, SQLiteStore.defaultFileURL)
            XCTAssertEqual(sqliteStore.configuration, nil)
            XCTAssertEqual(sqliteStore.mappingModelBundles, NSBundle.allBundles())
            XCTAssertEqual(sqliteStore.localStorageOptions, LocalStorageOptions.None)
            
            do {
                
                try stack.addStorageAndWait(sqliteStore)
            }
            catch let error as NSError {
                
                XCTFail(error.description)
            }
            let persistentStore = stack.persistentStoreForStorage(sqliteStore)
            XCTAssertNotNil(persistentStore)
            XCTAssert(sqliteStore.matchesPersistentStore(persistentStore!))
        }
        
        do {
            
            let sqliteStore = SQLiteStore(
                fileName: "ConfigStore1.sqlite",
                configuration: "Config1",
                localStorageOptions: .RecreateStoreOnModelMismatch
            )
            XCTAssertEqual(sqliteStore.fileURL, SQLiteStore.defaultRootDirectory
                .URLByAppendingPathComponent("ConfigStore1.sqlite", isDirectory: false))
            XCTAssertEqual(sqliteStore.configuration, "Config1")
            XCTAssertEqual(sqliteStore.mappingModelBundles, NSBundle.allBundles())
            XCTAssertEqual(sqliteStore.localStorageOptions, LocalStorageOptions.RecreateStoreOnModelMismatch)
            
            do {
                
                try stack.addStorageAndWait(sqliteStore)
            }
            catch let error as NSError {
                
                XCTFail(error.description)
            }
            let persistentStore = stack.persistentStoreForStorage(sqliteStore)
            XCTAssertNotNil(persistentStore)
            XCTAssert(sqliteStore.matchesPersistentStore(persistentStore!))
        }
        
        do {
            
            let sqliteStore = SQLiteStore(
                fileName: "ConfigStore2.sqlite",
                configuration: "Config2",
                localStorageOptions: .RecreateStoreOnModelMismatch
            )
            XCTAssertEqual(sqliteStore.fileURL, SQLiteStore.defaultRootDirectory
                .URLByAppendingPathComponent("ConfigStore2.sqlite", isDirectory: false))
            XCTAssertEqual(sqliteStore.configuration, "Config2")
            XCTAssertEqual(sqliteStore.mappingModelBundles, NSBundle.allBundles())
            XCTAssertEqual(sqliteStore.localStorageOptions, LocalStorageOptions.RecreateStoreOnModelMismatch)
            
            do {
                
                try stack.addStorageAndWait(sqliteStore)
            }
            catch let error as NSError {
                
                XCTFail(error.description)
            }
            let persistentStore = stack.persistentStoreForStorage(sqliteStore)
            XCTAssertNotNil(persistentStore)
            XCTAssert(sqliteStore.matchesPersistentStore(persistentStore!))
        }
    }
    
    func testSQLiteStores() {
        
        let stack = DataStack(
            modelName: "Model",
            bundle: NSBundle(forClass: self.dynamicType)
        )
        CoreStore.defaultStack = stack
        XCTAssertEqual(CoreStore.defaultStack, stack)
        XCTAssertEqual(stack.modelVersion, "Model")
        XCTAssert(stack.migrationChain.valid)
        XCTAssert(stack.migrationChain.empty)
        XCTAssert(stack.migrationChain.rootVersions.isEmpty)
        XCTAssert(stack.migrationChain.leafVersions.isEmpty)
        
        do {
            
            let sqliteStore = SQLiteStore()
            XCTAssertEqual(sqliteStore.fileURL, SQLiteStore.defaultFileURL)
            XCTAssertEqual(sqliteStore.configuration, nil)
            XCTAssertEqual(sqliteStore.mappingModelBundles, NSBundle.allBundles())
            XCTAssertEqual(sqliteStore.localStorageOptions, LocalStorageOptions.None)
            
            do {
                
                try stack.addStorageAndWait(sqliteStore)
            }
            catch let error as NSError {
                
                XCTFail(error.description)
            }
            let persistentStore = stack.persistentStoreForStorage(sqliteStore)
            XCTAssertNotNil(persistentStore)
            XCTAssert(sqliteStore.matchesPersistentStore(persistentStore!))
        }
        
        do {
            
            let sqliteStore = SQLiteStore(
                fileName: "ConfigStore1.sqlite",
                configuration: "Config1",
                localStorageOptions: .RecreateStoreOnModelMismatch
            )
            XCTAssertEqual(sqliteStore.fileURL, SQLiteStore.defaultRootDirectory
                .URLByAppendingPathComponent("ConfigStore1.sqlite", isDirectory: false))
            XCTAssertEqual(sqliteStore.configuration, "Config1")
            XCTAssertEqual(sqliteStore.mappingModelBundles, NSBundle.allBundles())
            XCTAssertEqual(sqliteStore.localStorageOptions, LocalStorageOptions.RecreateStoreOnModelMismatch)
            
            do {
                
                try stack.addStorageAndWait(sqliteStore)
            }
            catch let error as NSError {
                
                XCTFail(error.description)
            }
            let persistentStore = stack.persistentStoreForStorage(sqliteStore)
            XCTAssertNotNil(persistentStore)
            XCTAssert(sqliteStore.matchesPersistentStore(persistentStore!))
        }
        
        do {
            
            let sqliteStore = SQLiteStore(
                fileName: "ConfigStore2.sqlite",
                configuration: "Config2",
                localStorageOptions: .RecreateStoreOnModelMismatch
            )
            XCTAssertEqual(sqliteStore.fileURL, SQLiteStore.defaultRootDirectory
                .URLByAppendingPathComponent("ConfigStore2.sqlite", isDirectory: false))
            XCTAssertEqual(sqliteStore.configuration, "Config2")
            XCTAssertEqual(sqliteStore.mappingModelBundles, NSBundle.allBundles())
            XCTAssertEqual(sqliteStore.localStorageOptions, LocalStorageOptions.RecreateStoreOnModelMismatch)
            
            do {
                
                try stack.addStorageAndWait(sqliteStore)
            }
            catch let error as NSError {
                
                XCTFail(error.description)
            }
            let persistentStore = stack.persistentStoreForStorage(sqliteStore)
            XCTAssertNotNil(persistentStore)
            XCTAssert(sqliteStore.matchesPersistentStore(persistentStore!))
        }
    }
}
