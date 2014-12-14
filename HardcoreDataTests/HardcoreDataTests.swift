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
        
        #if DEBUG
            let resetStoreOnMigrationFailure = true
            #else
            let resetStoreOnMigrationFailure = false
        #endif
        
        switch HardcoreData.defaultStack.addSQLiteStore(resetStoreOnMigrationFailure: resetStoreOnMigrationFailure) {
            
        case .Failure(let error):
            NSException(
                name: "CoreDataMigrationException",
                reason: error.localizedDescription,
                userInfo: error.userInfo).raise()
            
        default:
            break
        }
        
        HardcoreData.performTransactionAndWait({ (transaction) -> () in
        
            let obj = transaction.create(TestEntity1)
            obj.testEntityID = 1
            obj.testString = "lololol"
            obj.testNumber = 42
            obj.testDate = NSDate()

            transaction.commitAndWait()
        })
        
        HardcoreData.performTransactionAndWait({ (transaction) -> () in
            
            let obj = transaction.findAll(
                TestEntity1
                    .WHERE("testEntityID", isEqualTo: 1)
                    .SORTEDBY(.Ascending("testEntityID"), .Descending("testString")),
                customizeFetch: { (fetchRequest) -> () in
                    
                    fetchRequest.includesPendingChanges = true
                }
            )
            NSLog("%@", obj ?? [])
        })
    }
}
