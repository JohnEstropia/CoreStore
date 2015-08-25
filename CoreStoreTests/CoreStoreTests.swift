//
//  CoreStoreTests.swift
//  CoreStoreTests
//
//  Copyright (c) 2014 John Rommel Estropia
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

import UIKit
import XCTest

@testable
import CoreStore

class CoreStoreTests: XCTestCase {
    
    override func setUp() {
        
        super.setUp()
        self.deleteStores()
    }
    
    override func tearDown() {
        
        self.deleteStores()
        super.tearDown()
    }
    
    func testMigrationChains() {
        
        let emptyChain: MigrationChain = nil
        XCTAssertTrue(emptyChain.valid, "emptyChain.valid")
        XCTAssertTrue(emptyChain.empty, "emptyChain.empty")
        
        let normalChain: MigrationChain = "version1"
        XCTAssertTrue(normalChain.valid, "normalChain.valid")
        XCTAssertTrue(normalChain.empty, "normalChain.empty")
        
        let linearChain: MigrationChain = ["version1", "version2", "version3", "version4"]
        XCTAssertTrue(linearChain.valid, "linearChain.valid")
        XCTAssertFalse(linearChain.empty, "linearChain.empty")
        
        let treeChain: MigrationChain = [
            "version1": "version4",
            "version2": "version3",
            "version3": "version4"
        ]
        XCTAssertTrue(treeChain.valid, "treeChain.valid")
        XCTAssertFalse(treeChain.empty, "treeChain.empty")

        // The cases below will trigger assertion failures internally
        
//        let linearLoopChain: MigrationChain = ["version1", "version2", "version1", "version3", "version4"]
//        XCTAssertFalse(linearLoopChain.valid, "linearLoopChain.valid")
//        
//        let treeAmbiguousChain: MigrationChain = [
//            "version1": "version4",
//            "version2": "version3",
//            "version1": "version2",
//            "version3": "version4"
//        ]
//        XCTAssertFalse(treeAmbiguousChain.valid, "treeAmbiguousChain.valid")
    }
    
    func testExample() {
        
        let stack = DataStack(modelName: "Model", bundle: NSBundle(forClass: self.dynamicType))
        CoreStore.defaultStack = stack
        XCTAssert(CoreStore.defaultStack === stack, "CoreStore.defaultStack === stack")
        
        do {
            
            try stack.addSQLiteStoreAndWait(fileName: "ConfigStore1.sqlite", configuration: "Config1", resetStoreOnModelMismatch: true)
        }
        catch let error as NSError {
            
            XCTFail(error.description)
        }
        
        do {
            
            try stack.addSQLiteStoreAndWait(fileName: "ConfigStore2.sqlite", configuration: "Config2", resetStoreOnModelMismatch: true)
        }
        catch let error as NSError {
            
            XCTFail(error.description)
        }
        
        let detachedTransaction = CoreStore.beginDetached()
        
        let createExpectation = self.expectationWithDescription("Entity creation")
        CoreStore.beginAsynchronous { (transaction) -> Void in
        
            let obj1 = transaction.create(Into(TestEntity1))
            obj1.testEntityID = 1
            obj1.testString = "lololol"
            obj1.testNumber = 42
            obj1.testDate = NSDate()
            
            let count = transaction.queryValue(
                From<TestEntity1>(),
                Select<Int>(.Count("testNumber"))
            )
            XCTAssertTrue(count == 0, "count == 0 (actual: \(count))") // counts only objects in store
            
            let obj2 = transaction.create(Into<TestEntity2>())
            obj2.testEntityID = 2
            obj2.testString = "hahaha"
            obj2.testNumber = 100
            obj2.testDate = NSDate()
            
            let obj3 = transaction.create(Into<TestEntity2>("Config2"))
            obj3.testEntityID = 3
            obj3.testString = "hahaha"
            obj3.testNumber = 90
            obj3.testDate = NSDate()
            
            let obj4 = transaction.create(Into(TestEntity2.self, "Config2"))
            obj4.testEntityID = 5
            obj4.testString = "hohoho"
            obj4.testNumber = 80
            obj4.testDate = NSDate()
            
        
            transaction.beginSynchronous { (transaction) -> Void in
                
                let obj4 = transaction.create(Into<TestEntity2>())
                obj4.testEntityID = 4
                obj4.testString = "hehehehe"
                obj4.testNumber = 80
                obj4.testDate = NSDate()
                
                let objs4test = transaction.fetchOne(
                    From<TestEntity2>("Config2"),
                    Where("testEntityID", isEqualTo: 4),
                    Tweak { (fetchRequest) -> Void in
                        
                        fetchRequest.includesPendingChanges = true
                    }
                )
                XCTAssertNotNil(objs4test, "objs4test != nil")
                
                let objs5test = transaction.fetchOne(
                    From(TestEntity2),
                    Where("testEntityID", isEqualTo: 4),
                    Tweak { (fetchRequest) -> Void in
                        
                        fetchRequest.includesPendingChanges = false
                    }
                )
                XCTAssertNil(objs5test, "objs5test == nil")
                
                // Dont commit1
            }
            
            transaction.commit { (result) -> Void in
                
                let objs4test = CoreStore.fetchOne(
                    From(TestEntity2),
                    Where("testEntityID", isEqualTo: 4),
                    Tweak { (fetchRequest) -> Void in
                        
                        fetchRequest.includesPendingChanges = false
                    }
                )
                XCTAssertNil(objs4test, "objs4test == nil")
                
                let objs5test = detachedTransaction.fetchCount(From(TestEntity2))
                XCTAssertTrue(objs5test == 3, "objs5test == 3")
                
                XCTAssertTrue(NSThread.isMainThread(), "NSThread.isMainThread()")
                switch result {
                    
                case .Success(let hasChanges):
                    XCTAssertTrue(hasChanges, "hasChanges == true")
                    createExpectation.fulfill()
                    
                case .Failure(let error):
                    XCTFail(error.description)
                }
            }
        }
        
        let queryExpectation = self.expectationWithDescription("Query creation")
        CoreStore.beginAsynchronous { (transaction) -> Void in
            
            let obj1 = transaction.fetchOne(From(TestEntity1))
            XCTAssertNotNil(obj1, "obj1 != nil")
            
            var orderBy = OrderBy(.Ascending("testEntityID"))
            orderBy += OrderBy(.Descending("testString"))
            let objs2 = transaction.fetchAll(
                From(TestEntity2),
                Where("testNumber", isEqualTo: 100) || Where("%K == %@", "testNumber", 90),
                orderBy,
                Tweak { (fetchRequest) -> Void in
                    
                    fetchRequest.includesPendingChanges = true
                }
            )
            XCTAssertNotNil(objs2, "objs2 != nil")
            XCTAssertTrue(objs2?.count == 2, "objs2?.count == 2")
            
            transaction.commit { (result) -> Void in
                
                let counts = CoreStore.queryAttributes(
                    From(TestEntity2),
                    Select("testString", .Count("testString", As: "count")),
                    GroupBy("testString")
                )
                print(counts)
                
                XCTAssertTrue(NSThread.isMainThread(), "NSThread.isMainThread()")
                switch result {
                    
                case .Success(let hasChanges):
                    XCTAssertFalse(hasChanges, "hasChanges == false")
                    queryExpectation.fulfill()
                    
                case .Failure(let error):
                    XCTFail(error.description)
                }
            }
        }
        
        self.waitForExpectationsWithTimeout(100, handler: nil)
        
        let max1 = CoreStore.queryValue(
            From(TestEntity2),
            Select<Int>(.Maximum("testNumber"))
        )
        XCTAssertTrue(max1 == 100, "max == 100 (actual: \(max1))")
        
        let max2 = CoreStore.queryValue(
            From(TestEntity2),
            Select<NSNumber>(.Maximum("testNumber")),
            Where("%K > %@", "testEntityID", 2)
        )
        XCTAssertTrue(max2 == 90, "max == 90 (actual: \(max2))")
        
        CoreStore.beginSynchronous { (transaction) -> Void in
            
            let numberOfDeletedObjects1 = transaction.deleteAll(From(TestEntity1))
            XCTAssertTrue(numberOfDeletedObjects1 == 1, "numberOfDeletedObjects1 == 1 (actual: \(numberOfDeletedObjects1))")
            
            let numberOfDeletedObjects2 = transaction.deleteAll(
                From(TestEntity2),
                Where("%K > %@", "testEntityID", 2)
            )
            XCTAssertTrue(numberOfDeletedObjects2 == 2, "numberOfDeletedObjects2 == 2 (actual: \(numberOfDeletedObjects2))")
            
            transaction.commit()
        }
        
        CoreStore.beginSynchronous({ (transaction) -> Void in
            
            if let obj = CoreStore.fetchOne(From(TestEntity2)) {
                
                let oldID = obj.testEntityID
                obj.testEntityID = 0
                obj.testEntityID = oldID
            }
            
            transaction.commit()
        })
        
        let objs1 = CoreStore.fetchAll(From(TestEntity1))
        XCTAssertNotNil(objs1, "objs1 != nil")
        XCTAssertTrue(objs1?.count == 0, "objs1?.count == 0")
        
        let objs2 = CoreStore.fetchAll(From(TestEntity2))
        XCTAssertNotNil(objs2, "objs2 != nil")
        XCTAssertTrue(objs2?.count == 1, "objs2?.count == 1")
        
        let detachedExpectation = self.expectationWithDescription("Query creation")
        
        let obj5 = detachedTransaction.create(Into<TestEntity1>("Config1"))
        obj5.testEntityID = 5
        obj5.testString = "hihihi"
        obj5.testNumber = 70
        obj5.testDate = NSDate()
        
        detachedTransaction.commit { (result) -> Void in
            
            XCTAssertTrue(NSThread.isMainThread(), "NSThread.isMainThread()")
            switch result {
                
            case .Success(let hasChanges):
                XCTAssertTrue(hasChanges, "hasChanges == true")
                
                CoreStore.beginSynchronous { (transaction) -> Void in
                    
                    let obj5Copy1 = transaction.edit(obj5)
                    XCTAssertTrue(obj5.objectID == obj5Copy1?.objectID, "obj5.objectID == obj5Copy1?.objectID")
                    XCTAssertFalse(obj5 == obj5Copy1, "obj5 == obj5Copy1")
                    
                    let obj5Copy2 = transaction.edit(Into(TestEntity1), obj5.objectID)
                    XCTAssertTrue(obj5.objectID == obj5Copy2?.objectID, "obj5.objectID == obj5Copy2?.objectID")
                    XCTAssertFalse(obj5 == obj5Copy2, "obj5 == obj5Copy2")
                }
                
                let count: Int? = CoreStore.queryValue(
                    From(TestEntity1),
                    Select(.Count("testNumber"))
                )
                XCTAssertTrue(count == 1, "count == 1 (actual: \(count))")
                
                let obj6 = detachedTransaction.create(Into<TestEntity1>())
                obj6.testEntityID = 6
                obj6.testString = "huehuehue"
                obj6.testNumber = 130
                obj6.testDate = NSDate()
                
                detachedTransaction.commit { (result) -> Void in
                    
                    XCTAssertTrue(NSThread.isMainThread(), "NSThread.isMainThread()")
                    switch result {
                        
                    case .Success(let hasChanges):
                        XCTAssertTrue(hasChanges, "hasChanges == true")
                        
                        let count = CoreStore.queryValue(
                            From(TestEntity1),
                            Select<Int>(.Count("testNumber"))
                        )
                        XCTAssertTrue(count == 2, "count == 2 (actual: \(count))")
                        
                        
                        CoreStore.beginSynchronous { (transaction) -> Void in
                            
                            let obj6 = transaction.edit(obj6)
                            let obj5 = transaction.edit(obj5)
                            transaction.delete(obj5, obj6)
                            
                            transaction.commit()
                        }
                        
                        let count2 = CoreStore.queryValue(
                            From(TestEntity1),
                            Select<Int>(.Count("testNumber"))
                        )
                        XCTAssertTrue(count2 == 0, "count == 0 (actual: \(count2))")
                        
                        detachedExpectation.fulfill()
                        
                    case .Failure(let error):
                        XCTFail(error.description)
                    }
                }
                
            case .Failure(let error):
                XCTFail(error.description)
            }
        }
        
        self.waitForExpectationsWithTimeout(100, handler: nil)
    }
    
    private func deleteStores() {
        
        do {
            
            let fileManager = NSFileManager.defaultManager()
            try fileManager.removeItemAtURL(
                fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).first!
            )
        }
        catch _ { }
    }
}
