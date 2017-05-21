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

class SetupTests: BaseTestDataTestCase {
    
    @objc
    dynamic func test_ThatDataStacks_ConfigureCorrectly() {
        
        do {
            
            let schemaHistory = SchemaHistory(
                XcodeDataModelSchema.from(
                    modelName: "Model",
                    bundle: Bundle(for: type(of: self))
                )
            )
            let stack = DataStack(schemaHistory: schemaHistory)
            XCTAssertEqual(stack.coordinator.managedObjectModel, schemaHistory.rawModel)
            XCTAssertEqual(stack.rootSavingContext.persistentStoreCoordinator, stack.coordinator)
            XCTAssertNil(stack.rootSavingContext.parent)
            XCTAssertFalse(stack.rootSavingContext.isDataStackContext)
            XCTAssertFalse(stack.rootSavingContext.isTransactionContext)
            XCTAssertEqual(stack.mainContext.parent, stack.rootSavingContext)
            XCTAssertTrue(stack.mainContext.isDataStackContext)
            XCTAssertFalse(stack.mainContext.isTransactionContext)
            XCTAssertEqual(stack.schemaHistory.rawModel, schemaHistory.rawModel)
            XCTAssertTrue(stack.schemaHistory.migrationChain.isValid)
            XCTAssertTrue(stack.schemaHistory.migrationChain.isEmpty)
            XCTAssertTrue(stack.schemaHistory.migrationChain.rootVersions.isEmpty)
            XCTAssertTrue(stack.schemaHistory.migrationChain.leafVersions.isEmpty)
            
            CoreStore.defaultStack = stack
            XCTAssertEqual(CoreStore.defaultStack, stack)
        }
        do {
            
            let migrationChain: MigrationChain = ["version1", "version2", "version3", "Model"]
            
            let stack = self.expectLogger([.logWarning]) {
                
                DataStack(
                    xcodeModelName: "Model",
                    bundle: Bundle(for: type(of: self)),
                    migrationChain: migrationChain
                )
            }
            XCTAssertEqual(stack.modelVersion, "Model")
            XCTAssertEqual(stack.schemaHistory.migrationChain, migrationChain)
            
            CoreStore.defaultStack = stack
            XCTAssertEqual(CoreStore.defaultStack, stack)
        }
    }
    
    @objc
    dynamic func test_ThatInMemoryStores_SetupCorrectly() {
        
        let stack = DataStack(
            xcodeModelName: "Model",
            bundle: Bundle(for: type(of: self))
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
            xcodeModelName: "Model",
            bundle: Bundle(for: type(of: self))
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
                localStorageOptions: .recreateStoreOnModelMismatch
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
                localStorageOptions: .recreateStoreOnModelMismatch
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
    dynamic func test_ThatSQLiteStores_DeleteFilesCorrectly() {
        
        let fileManager = FileManager.default
        let sqliteStore = SQLiteStore()
        func createStore() throws -> [String: Any] {
            
            do {
                
                let stack = DataStack(
                    xcodeModelName: "Model",
                    bundle: Bundle(for: type(of: self))
                )
                try! stack.addStorageAndWait(sqliteStore)
                self.prepareTestDataForStack(stack)
            }
            XCTAssertTrue(fileManager.fileExists(atPath: sqliteStore.fileURL.path))
            XCTAssertTrue(fileManager.fileExists(atPath: sqliteStore.fileURL.path.appending("-shm")))
            
            return try NSPersistentStoreCoordinator.metadataForPersistentStore(
                ofType: type(of: sqliteStore).storeType,
                at: sqliteStore.fileURL,
                options: sqliteStore.storeOptions
            )
        }
        do {
            
            let metadata = try createStore()
            let stack = DataStack(
                xcodeModelName: "Model",
                bundle: Bundle(for: type(of: self))
            )
            try sqliteStore.cs_eraseStorageAndWait(
                metadata: metadata,
                soureModelHint: stack.schemaHistory.schema(for: metadata)?.rawModel()
            )
            XCTAssertFalse(fileManager.fileExists(atPath: sqliteStore.fileURL.path))
            XCTAssertFalse(fileManager.fileExists(atPath: sqliteStore.fileURL.path.appending("-wal")))
            XCTAssertFalse(fileManager.fileExists(atPath: sqliteStore.fileURL.path.appending("-shm")))
        }
        catch {
            
            XCTFail()
        }
        do {
            
            let metadata = try createStore()
            try sqliteStore.cs_eraseStorageAndWait(metadata: metadata, soureModelHint: nil)
            XCTAssertFalse(fileManager.fileExists(atPath: sqliteStore.fileURL.path))
            XCTAssertFalse(fileManager.fileExists(atPath: sqliteStore.fileURL.path.appending("-wal")))
            XCTAssertFalse(fileManager.fileExists(atPath: sqliteStore.fileURL.path.appending("-shm")))
        }
        catch {
            
            XCTFail()
        }
    }
    
    @objc
    dynamic func test_ThatLegacySQLiteStores_SetupCorrectly() {
        
        let stack = DataStack(
            xcodeModelName: "Model",
            bundle: Bundle(for: type(of: self))
        )
        do {
            
            let sqliteStore = SQLiteStore.legacy()
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
            
            let sqliteStore = SQLiteStore.legacy(
                fileName: "ConfigStore1.sqlite",
                configuration: "Config1",
                localStorageOptions: .recreateStoreOnModelMismatch
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
            
            let sqliteStore = SQLiteStore.legacy(
                fileName: "ConfigStore2.sqlite",
                configuration: "Config2",
                localStorageOptions: .recreateStoreOnModelMismatch
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
    dynamic func test_ThatLegacySQLiteStores_DeleteFilesCorrectly() {
        
        let fileManager = FileManager.default
        let sqliteStore = SQLiteStore.legacy()
        func createStore() throws -> [String: Any] {
            
            do {
                
                let stack = DataStack(
                    xcodeModelName: "Model",
                    bundle: Bundle(for: type(of: self))
                )
                try! stack.addStorageAndWait(sqliteStore)
                self.prepareTestDataForStack(stack)
            }
            XCTAssertTrue(fileManager.fileExists(atPath: sqliteStore.fileURL.path))
            XCTAssertTrue(fileManager.fileExists(atPath: sqliteStore.fileURL.path.appending("-shm")))
            
            return try NSPersistentStoreCoordinator.metadataForPersistentStore(
                ofType: type(of: sqliteStore).storeType,
                at: sqliteStore.fileURL,
                options: sqliteStore.storeOptions
            )
        }
        do {
            
            let metadata = try createStore()
            let stack = DataStack(
                xcodeModelName: "Model",
                bundle: Bundle(for: type(of: self))
            )
            try sqliteStore.cs_eraseStorageAndWait(
                metadata: metadata,
                soureModelHint: stack.schemaHistory.schema(for: metadata)?.rawModel()
            )
            XCTAssertFalse(fileManager.fileExists(atPath: sqliteStore.fileURL.path))
            XCTAssertFalse(fileManager.fileExists(atPath: sqliteStore.fileURL.path.appending("-wal")))
            XCTAssertFalse(fileManager.fileExists(atPath: sqliteStore.fileURL.path.appending("-shm")))
        }
        catch {
            
            XCTFail()
        }
        do {
            
            let metadata = try createStore()
            try sqliteStore.cs_eraseStorageAndWait(metadata: metadata, soureModelHint: nil)
            XCTAssertFalse(fileManager.fileExists(atPath: sqliteStore.fileURL.path))
            XCTAssertFalse(fileManager.fileExists(atPath: sqliteStore.fileURL.path.appending("-wal")))
            XCTAssertFalse(fileManager.fileExists(atPath: sqliteStore.fileURL.path.appending("-shm")))
        }
        catch {
            
            XCTFail()
        }
    }
}
