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
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testExample() {
        
        let stack = DataStack()
        HardcoreData.defaultStack = stack
        XCTAssertEqual(HardcoreData.defaultStack, stack, "HardcoreData.defaultStack == stack")
        
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
            
            transaction.commit { (result) -> Void in
                
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
        HardcoreData.performTransaction{ (transaction) -> Void in
            
            let obj1 = transaction.fetchOne(TestEntity1)
            XCTAssertNotNil(obj1, "obj1 != nil")
            
            let objs2 = transaction.fetchAll(
                TestEntity2.self,
                Where("testNumber", isEqualTo: 100) || Where("testNumber", isEqualTo: 90),
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
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
}
