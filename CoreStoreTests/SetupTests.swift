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
    
    @objc
    dynamic func test_ThatDataStacks_ConfigureCorrectly() {
        
        do {
            
            let model = NSManagedObjectModel.mergedModelFromBundles([NSBundle(forClass: self.dynamicType)])!
            
            let stack = DataStack(model: model, migrationChain: nil)
            XCTAssertEqual(stack.coordinator.managedObjectModel, model)
            XCTAssertEqual(stack.rootSavingContext.persistentStoreCoordinator, stack.coordinator)
            XCTAssertNil(stack.rootSavingContext.parentContext)
            XCTAssertEqual(stack.mainContext.parentContext, stack.rootSavingContext)
            XCTAssertEqual(stack.model, model)
            XCTAssertTrue(stack.migrationChain.valid)
            XCTAssertTrue(stack.migrationChain.empty)
            XCTAssertTrue(stack.migrationChain.rootVersions.isEmpty)
            XCTAssertTrue(stack.migrationChain.leafVersions.isEmpty)
            
            CoreStore.defaultStack = stack
            XCTAssertEqual(CoreStore.defaultStack, stack)
        }
        do {
            
            let migrationChain: MigrationChain = ["version1", "version2", "version3"]
            
            let stack = self.expectLogger([.LogWarning]) {
                
                DataStack(
                    modelName: "Model",
                    bundle: NSBundle(forClass: self.dynamicType),
                    migrationChain: migrationChain
                )
            }
            XCTAssertEqual(stack.modelVersion, "Model")
            XCTAssertEqual(stack.migrationChain, migrationChain)
            
            CoreStore.defaultStack = stack
            XCTAssertEqual(CoreStore.defaultStack, stack)
        }
    }
    
    @objc
    dynamic func test_ThatInMemoryStores_SetupCorrectly() {
        
        let stack = DataStack(
            modelName: "Model",
            bundle: NSBundle(forClass: self.dynamicType)
        )
        do {
            
            let inMemoryStore = InMemoryStore()
            do {
                
                try stack.addStorageAndWait(inMemoryStore)
            }
            catch let error as NSError {
                
                XCTFail(error.description)
            }
            let persistentStore = stack.persistentStoreForStorage(inMemoryStore)
            XCTAssertNotNil(persistentStore)
        }
        do {
            
            let inMemoryStore = InMemoryStore(
                configuration: "Config1"
            )
            do {
                
                try stack.addStorageAndWait(inMemoryStore)
            }
            catch let error as NSError {
                
                XCTFail(error.description)
            }
            let persistentStore = stack.persistentStoreForStorage(inMemoryStore)
            XCTAssertNotNil(persistentStore)
        }
        do {
            
            let inMemoryStore = InMemoryStore(
                configuration: "Config2"
            )
            do {
                
                try stack.addStorageAndWait(inMemoryStore)
            }
            catch let error as NSError {
                
                XCTFail(error.description)
            }
            let persistentStore = stack.persistentStoreForStorage(inMemoryStore)
            XCTAssertNotNil(persistentStore)
        }
    }
    
    @objc
    dynamic func test_ThatSQLiteStores_SetupCorrectly() {
        
        let stack = DataStack(
            modelName: "Model",
            bundle: NSBundle(forClass: self.dynamicType)
        )
        do {
            
            let sqliteStore = SQLiteStore()
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
    
    @objc
    dynamic func test_ThatLegacySQLiteStores_SetupCorrectly() {
        
        let stack = DataStack(
            modelName: "Model",
            bundle: NSBundle(forClass: self.dynamicType)
        )
        do {
            
            let sqliteStore = SQLiteStore()
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
