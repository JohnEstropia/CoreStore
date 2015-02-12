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
        
        switch stack.addSQLiteStore("Config1Store", configuration: "Config1", resetStoreOnMigrationFailure: true){
            
        case .Failure(let error):
            NSException(
                name: "CoreDataMigrationException",
                reason: error.localizedDescription,
                userInfo: error.userInfo).raise()
            
        default:
            break
        }
        switch stack.addSQLiteStore("Config2Store", configuration: "Config2", resetStoreOnMigrationFailure: true){
            
        case .Failure(let error):
            NSException(
                name: "CoreDataMigrationException",
                reason: error.localizedDescription,
                userInfo: error.userInfo).raise()
            
        default:
            break
        }
        
        HardcoreData.performTransactionAndWait({ (transaction) -> () in
        
            let obj1 = transaction.create(TestEntity1)
            obj1.testEntityID = 1
            obj1.testString = "lololol"
            obj1.testNumber = 42
            obj1.testDate = NSDate()
            
            let obj2 = transaction.create(TestEntity2)
            obj2.testEntityID = 2
            obj2.testString = "hahaha"
            obj2.testNumber = 7
            obj2.testDate = NSDate()
            
            transaction.commitAndWait()
        })
        HardcoreData.performTransactionAndWait({ (transaction) -> () in
            
            let obj1 = transaction.fetchOne(
                TestEntity1.self,
                Where("testEntityID", isEqualTo: 1),
                SortedBy(.Ascending("testEntityID"), .Descending("testString")),
                CustomizeQuery { (fetchRequest) -> Void in
                    
                    fetchRequest.includesPendingChanges = true
                }
            )
            NSLog(">>>>> %@", obj1 ?? "nil")
            
            let objs2 = transaction.fetchAll(
                TestEntity2.self,
                Where("testEntityID", isEqualTo: 2) && Where("testNumber", isEqualTo: 7),
                SortedBy(.Ascending("testEntityID"), .Descending("testString")),
                CustomizeQuery { (fetchRequest) -> () in
                    
                    fetchRequest.includesPendingChanges = true
                }
            )
            NSLog(">>>>> %@", objs2 ?? "nil")
        })
    }
}
