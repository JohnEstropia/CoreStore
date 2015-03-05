//
//  HardcoreDataTests.swift
//  HardcoreDataTests
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
import HardcoreData

class HardcoreDataTests: XCTestCase {
    
    override func setUp() {
        
        super.setUp()
        self.deleteStores()
    }
    
    override func tearDown() {
        
        self.deleteStores()
        super.tearDown()
    }
    
    func testExample() {
        
        let stack = DataStack()
        HardcoreData.defaultStack = stack
        XCTAssert(HardcoreData.defaultStack === stack, "HardcoreData.defaultStack === stack")
        
        switch stack.addSQLiteStore("Config1Store.sqlite", configuration: "Config1", resetStoreOnMigrationFailure: true){
            
        case .Failure(let error):
            XCTFail(error.description)
            
        default:
            break
        }
        
        switch stack.addSQLiteStore("Config2Store.sqlite", configuration: "Config2", resetStoreOnMigrationFailure: true){
            
        case .Failure(let error):
            XCTFail(error.description)
            
        default:
            break
        }
        
        let createExpectation = self.expectationWithDescription("Entity creation")
        HardcoreData.performTransaction { (transaction) -> Void in
        
            let obj1 = transaction.create(TestEntity1)
            obj1.testEntityID = 1
            obj1.testString = "lololol"
            obj1.testNumber = 42
            obj1.testDate = NSDate()
            
            let count = transaction.queryAggregate(
                TestEntity1.self,
                function: .Count("testNumber")
            )
            XCTAssertTrue(count == 0, "count == 0 (actual: \(count))") // counts only objects in store
            
            let obj2 = transaction.create(TestEntity2)
            obj2.testEntityID = 2
            obj2.testString = "hahaha"
            obj2.testNumber = 100
            obj2.testDate = NSDate()
            
            let obj3 = transaction.create(TestEntity2)
            obj3.testEntityID = 3
            obj3.testString = "hohoho"
            obj3.testNumber = 90
            obj3.testDate = NSDate()
            
        
            transaction.performTransactionAndWait { (transaction) -> Void in
                
                let obj4 = transaction.create(TestEntity2)
                obj4.testEntityID = 4
                obj4.testString = "hehehehe"
                obj4.testNumber = 80
                obj4.testDate = NSDate()
                
                let objs4test = transaction.fetchOne(
                    TestEntity2.self,
                    Where("testEntityID", isEqualTo: 4),
                    CustomizeQuery { (fetchRequest) -> Void in
                        
                        fetchRequest.includesPendingChanges = true
                    }
                )
                XCTAssertNotNil(objs4test, "objs4test != nil")
                // Dont commit1
            }
            
            transaction.commit { (result) -> Void in
                
                let objs4test = HardcoreData.fetchOne(
                    TestEntity2.self,
                    Where("testEntityID", isEqualTo: 4)
                )
                XCTAssertNil(objs4test, "objs4test == nil")
                
                XCTAssertTrue(NSThread.isMainThread(), "NSThread.isMainThread()")
                switch result {
                    
                case .Success(let hasChanges):
                    createExpectation.fulfill()
                    
                case .Failure(let error):
                    XCTFail(error.description)
                }
            }
        }
        
        let queryExpectation = self.expectationWithDescription("Query creation")
        HardcoreData.performTransaction { (transaction) -> Void in
            
            let obj1 = transaction.fetchOne(TestEntity1)
            XCTAssertNotNil(obj1, "obj1 != nil")
            
            let objs2 = transaction.fetchAll(
                TestEntity2.self,
                Where("testNumber", isEqualTo: 100) || Where("%K == %@", "testNumber", 90),
                SortedBy(.Ascending("testEntityID"), .Descending("testString")),
                CustomizeQuery { (fetchRequest) -> Void in
                    
                    fetchRequest.includesPendingChanges = true
                }
            )
            XCTAssertNotNil(objs2, "objs2 != nil")
            XCTAssertTrue(objs2?.count == 2, "objs2?.count == 2")
            
            transaction.commit { (result) -> Void in
                
                XCTAssertTrue(NSThread.isMainThread(), "NSThread.isMainThread()")
                switch result {
                    
                case .Success(let hasChanges):
                    queryExpectation.fulfill()
                    
                case .Failure(let error):
                    XCTFail(error.description)
                }
            }
        }
        
        self.waitForExpectationsWithTimeout(100, handler: nil)
        
        let max1 = HardcoreData.queryAggregate(
            TestEntity2.self,
            function: .Maximum("testNumber")
        )
        XCTAssertTrue(max1 == 100, "max == 100 (actual: \(max1))")
        
        let max2 = HardcoreData.queryAggregate(
            TestEntity2.self,
            function: .Maximum("testNumber"),
            Where("%K > %@", "testEntityID", 2)
        )
        XCTAssertTrue(max2 == 90, "max == 90 (actual: \(max2))")
        
        HardcoreData.performTransactionAndWait { (transaction) -> Void in
            
            let numberOfDeletedObjects1 = transaction.deleteAll(TestEntity1)
            XCTAssertTrue(numberOfDeletedObjects1 == 1, "numberOfDeletedObjects1 == 1 (actual: \(numberOfDeletedObjects1))")
            
            let numberOfDeletedObjects2 = transaction.deleteAll(
                TestEntity2.self,
                Where("%K > %@", "testEntityID", 2)
            )
            XCTAssertTrue(numberOfDeletedObjects2 == 1, "numberOfDeletedObjects2 == 1 (actual: \(numberOfDeletedObjects2))")
            
            transaction.commitAndWait()
        }
        
        let objs1 = HardcoreData.fetchAll(TestEntity1)
        XCTAssertNotNil(objs1, "objs1 != nil")
        XCTAssertTrue(objs1?.count == 0, "objs1?.count == 0")
        
        let objs2 = HardcoreData.fetchAll(TestEntity2)
        XCTAssertNotNil(objs2, "objs2 != nil")
        XCTAssertTrue(objs2?.count == 1, "objs2?.count == 1")
    }
    
    private func deleteStores() {
        
        NSFileManager.defaultManager().removeItemAtURL(
            NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).first as! NSURL,
            error: nil
        )
    }
}
