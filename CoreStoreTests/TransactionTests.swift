//
//  TransactionTests.swift
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


//MARK: - TransactionTests

final class TransactionTests: BaseTestCase {
    
    @objc
    dynamic func test_ThatSynchronousTransactions_CanPerformCRUDs() {
        
        self.prepareStack { (stack) in
            
            let testDate = Date()
            do {
                
                let createExpectation = self.expectation(description: "create")
                let hasChanges: Bool = try! stack.perform(
                    synchronous: { (transaction) in
                    
                        defer {
                            
                            createExpectation.fulfill()
                        }
                        XCTAssertEqual(transaction.context, transaction.unsafeContext())
                        XCTAssertTrue(transaction.context.isTransactionContext)
                        XCTAssertFalse(transaction.context.isDataStackContext)
                        
                        let object = transaction.create(Into<TestEntity1>())
                        XCTAssertEqual(object.fetchSource()?.unsafeContext(), transaction.context)
                        XCTAssertEqual(object.querySource()?.unsafeContext(), transaction.context)
                        
                        object.testEntityID = NSNumber(value: 1)
                        object.testString = "string1"
                        object.testNumber = 100
                        object.testDate = testDate
                        
                        return transaction.hasChanges
                    },
                    waitForAllObservers: true
                )
                self.checkExpectationsImmediately()
                XCTAssertTrue(hasChanges)
                
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 1)
                
                let object = stack.fetchOne(From<TestEntity1>())
                XCTAssertNotNil(object)
                XCTAssertEqual(object?.fetchSource()?.unsafeContext(), stack.mainContext)
                XCTAssertEqual(object?.querySource()?.unsafeContext(), stack.mainContext)

                XCTAssertEqual(object?.testEntityID, NSNumber(value: 1))
                XCTAssertEqual(object?.testString, "string1")
                XCTAssertEqual(object?.testNumber, 100)
                XCTAssertEqual(object?.testDate, testDate)
            }
            do {
                
                let updateExpectation = self.expectation(description: "update")
                let hasChanges: Bool = try! stack.perform(
                    synchronous: { (transaction) in
                        
                        defer {
                            
                            updateExpectation.fulfill()
                        }
                        guard let object = transaction.fetchOne(From<TestEntity1>()) else {
                            // TODO: convert fetch methods to throwing methods
                            XCTFail() 
                            try transaction.cancel()
                        }
                        object.testString = "string1_edit"
                        object.testNumber = 200
                        object.testDate = Date.distantFuture
                        
                        return transaction.hasChanges
                    },
                    waitForAllObservers: true
                )
                self.checkExpectationsImmediately()
                XCTAssertTrue(hasChanges)
                
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 1)
                
                let object = stack.fetchOne(From<TestEntity1>())
                XCTAssertNotNil(object)
                XCTAssertEqual(object?.testEntityID, NSNumber(value: 1))
                XCTAssertEqual(object?.testString, "string1_edit")
                XCTAssertEqual(object?.testNumber, 200)
                XCTAssertEqual(object?.testDate, Date.distantFuture)
            }
            do {
                
                let deleteExpectation = self.expectation(description: "delete")
                do {
                    
                    let hasChanges: Bool = try stack.perform(
                        synchronous: { (transaction) in
                            
                            defer {
                                
                                deleteExpectation.fulfill()
                            }
                            let object = transaction.fetchOne(From<TestEntity1>())
                            transaction.delete(object)
                            return transaction.hasChanges
                        }
                    )
                    XCTAssertTrue(hasChanges)
                }
                catch {
                    
                    XCTFail()
                }
                self.checkExpectationsImmediately()
                
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 0)
                
                let object = stack.fetchOne(From<TestEntity1>())
                XCTAssertNil(object)
            }
        }
    }
    
    @objc
    dynamic func test_ThatSynchronousTransactions_CanPerformCRUDsInCorrectConfiguration() {
        
        self.prepareStack(configurations: [nil, "Config1"]) { (stack) in
            
            let testDate = Date()
            do {
                
                let createExpectation = self.expectation(description: "create")
                do {
                    
                    let hasChanges: Bool = try stack.perform(
                        synchronous: { (transaction) in
                            
                            defer {
                                
                                createExpectation.fulfill()
                            }
                            let object = transaction.create(Into<TestEntity1>("Config1"))
                            object.testEntityID = NSNumber(value: 1)
                            object.testString = "string1"
                            object.testNumber = 100
                            object.testDate = testDate
                            
                            return transaction.hasChanges
                        }
                    )
                    XCTAssertTrue(hasChanges)
                }
                catch {
                 
                    XCTFail()
                }
                self.checkExpectationsImmediately()
                
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 1)
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                
                let object = stack.fetchOne(From<TestEntity1>("Config1"))
                XCTAssertNotNil(object)
                XCTAssertEqual(object?.testEntityID, NSNumber(value: 1))
                XCTAssertEqual(object?.testString, "string1")
                XCTAssertEqual(object?.testNumber, 100)
                XCTAssertEqual(object?.testDate, testDate)
            }
            do {
                
                let updateExpectation = self.expectation(description: "update")
                do {
                    
                    let hasChanges: Bool = try stack.perform(
                        synchronous: { (transaction) in
                            
                            defer {
                                
                                updateExpectation.fulfill()
                            }
                            guard let object = transaction.fetchOne(From<TestEntity1>("Config1")) else {
                                
                                XCTFail()
                                try transaction.cancel()
                            }
                            object.testString = "string1_edit"
                            object.testNumber = 200
                            object.testDate = Date.distantFuture
                            
                            return transaction.hasChanges
                        }
                    )
                    XCTAssertTrue(hasChanges)
                }
                catch {
                    
                    XCTFail()
                }
                self.checkExpectationsImmediately()
                
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 1)
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                
                let object = stack.fetchOne(From<TestEntity1>("Config1"))
                XCTAssertNotNil(object)
                XCTAssertEqual(object?.testEntityID, NSNumber(value: 1))
                XCTAssertEqual(object?.testString, "string1_edit")
                XCTAssertEqual(object?.testNumber, 200)
                XCTAssertEqual(object?.testDate, Date.distantFuture)
            }
            do {
                
                let deleteExpectation = self.expectation(description: "delete")
                do {
                    
                    let hasChanges: Bool = try stack.perform(
                        synchronous: { (transaction) in
                            
                            defer {
                                
                                deleteExpectation.fulfill()
                            }
                            let object = transaction.fetchOne(From<TestEntity1>("Config1"))
                            transaction.delete(object)
                            
                            return transaction.hasChanges
                        }
                    )
                    XCTAssertTrue(hasChanges)
                }
                catch {
                    
                    XCTFail()
                }
                self.checkExpectationsImmediately()
                
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 0)
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
            }
        }
    }
    
    @objc
    dynamic func test_ThatSynchronousTransactions_CanDiscardUncommittedChanges() {
        
        self.prepareStack { (stack) in
            
            do {
                
                let createDiscardExpectation = self.expectation(description: "create-discard")
                _ = try? stack.perform(
                    synchronous: { (transaction) in
                        
                        defer {
                            
                            createDiscardExpectation.fulfill()
                        }
                        let object = transaction.create(Into<TestEntity1>())
                        object.testEntityID = NSNumber(value: 1)
                        object.testString = "string1"
                        object.testNumber = 100
                        object.testDate = Date()
                        
                        try transaction.cancel()
                    }
                )
                self.checkExpectationsImmediately()
                
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 0)
                
                let object = stack.fetchOne(From<TestEntity1>())
                XCTAssertNil(object)
            }
            let testDate = Date()
            do {
                
                let createExpectation = self.expectation(description: "create")
                let dataPrepared: Void? = try? stack.perform(
                    synchronous: { (transaction) in
                        
                        let object = transaction.create(Into<TestEntity1>())
                        object.testEntityID = NSNumber(value: 1)
                        object.testString = "string1"
                        object.testNumber = 100
                        object.testDate = testDate
                    }
                )
                if dataPrepared != nil {
                    
                    createExpectation.fulfill()
                }
                self.checkExpectationsImmediately()
            }
            do {
                
                let updateDiscardExpectation = self.expectation(description: "update-discard")
                _ = try? stack.perform(
                    synchronous: { (transaction) in
                        
                        defer {
                            
                            updateDiscardExpectation.fulfill()
                        }
                        guard let object = transaction.fetchOne(From<TestEntity1>()) else {
                            
                            XCTFail()
                            try transaction.cancel()
                        }
                        object.testString = "string1_edit"
                        object.testNumber = 200
                        object.testDate = Date.distantFuture
                        
                        try transaction.cancel()
                    }
                )
                self.checkExpectationsImmediately()
                
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 1)
                
                let object = stack.fetchOne(From<TestEntity1>())
                XCTAssertNotNil(object)
                XCTAssertEqual(object?.testEntityID, NSNumber(value: 1))
                XCTAssertEqual(object?.testString, "string1")
                XCTAssertEqual(object?.testNumber, 100)
                XCTAssertEqual(object?.testDate, testDate)
            }
            do {
                
                let deleteDiscardExpectation = self.expectation(description: "delete-discard")
                _ = try? stack.perform(
                    synchronous: { (transaction) in
                        
                        defer {
                            
                            deleteDiscardExpectation.fulfill()
                        }
                        guard let object = transaction.fetchOne(From<TestEntity1>()) else {
                            
                            XCTFail()
                            try transaction.cancel()
                        }
                        transaction.delete(object)
                        
                        try transaction.cancel()
                    }
                )
                self.checkExpectationsImmediately()
                
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 1)
                
                let object = stack.fetchOne(From<TestEntity1>())
                XCTAssertNotNil(object)
                XCTAssertEqual(object?.testEntityID, NSNumber(value: 1))
                XCTAssertEqual(object?.testString, "string1")
                XCTAssertEqual(object?.testNumber, 100)
                XCTAssertEqual(object?.testDate, testDate)
            }
        }
    }
    
    
    @available(OSX 10.12, *)
    @objc
    dynamic func test_ThatSynchronousTransactions_CanCommitWithoutWaitingForMerges() {
        
        self.prepareStack { (stack) in
            
            let observer = TestListObserver()
            let monitor = stack.monitorList(
                From<TestEntity1>(),
                OrderBy(.ascending("testEntityID"))
            )
            monitor.addObserver(observer)
            
            XCTAssertFalse(monitor.hasObjects())
            
            var events = 0
            let willChangeExpectation = self.expectation(
                forNotification: "listMonitorWillChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 0)
                    XCTAssertTrue(note.userInfo?.isEmpty != false)
                    defer {
                        
                        events += 1
                    }
                    return events == 0
                }
            )
            let didInsertObjectExpectation = self.expectation(
                forNotification: "listMonitor:didInsertObject:toIndexPath:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 1)
                    
                    let userInfo = note.userInfo
                    XCTAssertNotNil(userInfo)
                    XCTAssertEqual(
                        Set(((userInfo as? [String: AnyObject]) ?? [:]).keys),
                        ["indexPath", "object"]
                    )
                    
                    let indexPath = userInfo?["indexPath"] as? NSIndexPath
                    XCTAssertEqual(indexPath?.index(atPosition: 0), 0)
                    XCTAssertEqual(indexPath?.index(atPosition: 1), 0)
                    
                    let object = userInfo?["object"] as? TestEntity1
                    XCTAssertEqual(object?.testBoolean, NSNumber(value: true))
                    XCTAssertEqual(object?.testNumber, NSNumber(value: 1))
                    XCTAssertEqual(object?.testDecimal, NSDecimalNumber(string: "1"))
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:1")
                    defer {
                        
                        events += 1
                    }
                    return events == 1
                }
            )
            let didChangeExpectation = self.expectation(
                forNotification: "listMonitorDidChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertTrue(note.userInfo?.isEmpty != false)
                    defer {
                        
                        events += 1
                    }
                    return events == 2
                }
            )
            let saveExpectation = self.expectation(description: "save")
            do {
                
                let hasChanges: Bool = try stack.perform(
                    synchronous: { (transaction) in
                        
                        let object = transaction.create(Into<TestEntity1>())
                        object.testBoolean = NSNumber(value: true)
                        object.testNumber = NSNumber(value: 1)
                        object.testDecimal = NSDecimalNumber(string: "1")
                        object.testString = "nil:TestEntity1:1"
                        
                        return transaction.hasChanges
                    },
                    waitForAllObservers: false
                )
                XCTAssertTrue(hasChanges)
                saveExpectation.fulfill()
            }
            catch {
                
                XCTFail()
            }
            XCTAssertEqual(events, 0)
            XCTAssertEqual(monitor.numberOfObjects(), 0)
            self.waitAndCheckExpectations()
        }
    }
    
    
    @objc
    dynamic func test_ThatAsynchronousTransactions_CanPerformCRUDs() {
        
        self.prepareStack { (stack) in
            
            let testDate = Date()
            do {
                
                let createExpectation = self.expectation(description: "create")
                stack.perform(
                    asynchronous: { (transaction) -> Bool in
                        
                        XCTAssertEqual(transaction.context, transaction.unsafeContext())
                        XCTAssertTrue(transaction.context.isTransactionContext)
                        XCTAssertFalse(transaction.context.isDataStackContext)
                        
                        let object = transaction.create(Into<TestEntity1>())
                        XCTAssertEqual(object.fetchSource()?.unsafeContext(), transaction.context)
                        XCTAssertEqual(object.querySource()?.unsafeContext(), transaction.context)
                        
                        object.testEntityID = NSNumber(value: 1)
                        object.testString = "string1"
                        object.testNumber = 100
                        object.testDate = testDate
                        
                        return transaction.hasChanges
                    },
                    success: { (hasChanges) in
                        
                        XCTAssertTrue(hasChanges)
                        
                        XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 1)
                        
                        let object = stack.fetchOne(From<TestEntity1>())
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.fetchSource()?.unsafeContext(), stack.mainContext)
                        XCTAssertEqual(object?.querySource()?.unsafeContext(), stack.mainContext)
                        
                        XCTAssertEqual(object?.testEntityID, NSNumber(value: 1))
                        XCTAssertEqual(object?.testString, "string1")
                        XCTAssertEqual(object?.testNumber, 100)
                        XCTAssertEqual(object?.testDate, testDate)
                        createExpectation.fulfill()
                    },
                    failure: { _ in
                        
                        XCTFail()
                    }
                )
            }
            do {
                
                let updateExpectation = self.expectation(description: "update")
                stack.perform(
                    asynchronous: { (transaction) -> Bool in
                        
                        guard let object = transaction.fetchOne(From<TestEntity1>()) else {
                            
                            XCTFail()
                            try transaction.cancel()
                        }
                        object.testString = "string1_edit"
                        object.testNumber = 200
                        object.testDate = Date.distantFuture
                        
                        return transaction.hasChanges
                    },
                    success: { (hasChanges) in
                        
                        XCTAssertTrue(hasChanges)
                        
                        XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 1)
                        
                        let object = stack.fetchOne(From<TestEntity1>())
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testEntityID, NSNumber(value: 1))
                        XCTAssertEqual(object?.testString, "string1_edit")
                        XCTAssertEqual(object?.testNumber, 200)
                        XCTAssertEqual(object?.testDate, Date.distantFuture)
                        updateExpectation.fulfill()
                    },
                    failure: { _ in
                        
                        XCTFail()
                    }
                )
            }
            do {
                
                let deleteExpectation = self.expectation(description: "delete")
                stack.perform(
                    asynchronous: { (transaction) -> Bool in
                        
                        let object = transaction.fetchOne(From<TestEntity1>())
                        transaction.delete(object)
                        
                        return transaction.hasChanges
                    },
                    success: { (hasChanges) in
                        
                        XCTAssertTrue(hasChanges)
                        
                        XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 0)
                        
                        let object = stack.fetchOne(From<TestEntity1>())
                        XCTAssertNil(object)
                        deleteExpectation.fulfill()
                    },
                    failure: { _ in
                        
                        XCTFail()
                    }
                )
            }
        }
        self.waitAndCheckExpectations()
    }
    
    @objc
    dynamic func test_ThatAsynchronousTransactions_CanPerformCRUDsInCorrectConfiguration() {
        
        self.prepareStack(configurations: [nil, "Config1"]) { (stack) in
            
            let testDate = Date()
            do {
                
                let createExpectation = self.expectation(description: "create")
                stack.perform(
                    asynchronous: { (transaction) -> Bool in
                        
                        let object = transaction.create(Into<TestEntity1>("Config1"))
                        object.testEntityID = NSNumber(value: 1)
                        object.testString = "string1"
                        object.testNumber = 100
                        object.testDate = testDate
                        
                        return transaction.hasChanges
                    },
                    success: { (hasChanges) in
                        
                        XCTAssertTrue(hasChanges)
                        
                        XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 1)
                        XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                        
                        let object = stack.fetchOne(From<TestEntity1>("Config1"))
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testEntityID, NSNumber(value: 1))
                        XCTAssertEqual(object?.testString, "string1")
                        XCTAssertEqual(object?.testNumber, 100)
                        XCTAssertEqual(object?.testDate, testDate)
                        createExpectation.fulfill()
                    },
                    failure: { _ in
                        
                        XCTFail()
                    }
                )
            }
            do {
                
                let updateExpectation = self.expectation(description: "update")
                stack.perform(
                    asynchronous: { (transaction) -> Bool in
                        
                        guard let object = transaction.fetchOne(From<TestEntity1>("Config1")) else {
                            
                            XCTFail()
                            try transaction.cancel()
                        }
                        object.testString = "string1_edit"
                        object.testNumber = 200
                        object.testDate = Date.distantFuture
                        
                        return transaction.hasChanges
                    },
                    success: { (hasChanges) in
                        
                        XCTAssertTrue(hasChanges)
                        
                        XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 1)
                        XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                        
                        let object = stack.fetchOne(From<TestEntity1>("Config1"))
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testEntityID, NSNumber(value: 1))
                        XCTAssertEqual(object?.testString, "string1_edit")
                        XCTAssertEqual(object?.testNumber, 200)
                        XCTAssertEqual(object?.testDate, Date.distantFuture)
                        updateExpectation.fulfill()
                    },
                    failure: { _ in
                        
                        XCTFail()
                    }
                )
            }
            do {
                
                let deleteExpectation = self.expectation(description: "delete")
                stack.perform(
                    asynchronous: { (transaction) -> Bool in
                        
                        let object = transaction.fetchOne(From<TestEntity1>("Config1"))
                        transaction.delete(object)
                        
                        return transaction.hasChanges
                    },
                    success: { (hasChanges) in
                        
                        XCTAssertTrue(hasChanges)
                        
                        XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 0)
                        XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                        
                        deleteExpectation.fulfill()
                    },
                    failure: { _ in
                        
                        XCTFail()
                    }
                )
            }
        }
        self.waitAndCheckExpectations()
    }
    
    @objc
    dynamic func test_ThatAsynchronousTransactions_CanDiscardUncommittedChanges() {
        
        self.prepareStack { (stack) in
            
            do {
                
                let createDiscardExpectation = self.expectation(description: "create-discard")
                stack.perform(
                    asynchronous: { (transaction) -> Void in
                        
                        let object = transaction.create(Into<TestEntity1>())
                        object.testEntityID = NSNumber(value: 1)
                        object.testString = "string1"
                        object.testNumber = 100
                        object.testDate = Date()
                        
                        createDiscardExpectation.fulfill()
                        try transaction.cancel()
                    },
                    success: {
                        
                        XCTFail()
                    },
                    failure: { (error) in
                        
                        XCTAssertEqual(error, CoreStoreError.userCancelled)
                    }
                )
            }
            let testDate = Date()
            do {
                
                let createExpectation = self.expectation(description: "create")
                stack.perform(
                    asynchronous: { (transaction) -> Bool in
                        
                        XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 0)
                        XCTAssertNil(transaction.fetchOne(From<TestEntity1>()))
                        
                        let object = transaction.create(Into<TestEntity1>())
                        object.testEntityID = NSNumber(value: 1)
                        object.testString = "string1"
                        object.testNumber = 100
                        object.testDate = testDate
                        
                        return transaction.hasChanges
                    },
                    success: { (hasChanges) in
                        
                        XCTAssertTrue(hasChanges)
                        createExpectation.fulfill()
                    },
                    failure: { _ in
                        
                        XCTFail()
                    }
                )
            }
            do {
                
                let updateDiscardExpectation = self.expectation(description: "update-discard")
                stack.perform(
                    asynchronous: { (transaction) -> Void in
                        
                        guard let object = transaction.fetchOne(From<TestEntity1>()) else {
                            
                            XCTFail()
                            return
                        }
                        object.testString = "string1_edit"
                        object.testNumber = 200
                        object.testDate = Date.distantFuture
                        
                        updateDiscardExpectation.fulfill()
                        
                        try transaction.cancel()
                    },
                    success: {
                        
                        XCTFail()
                    },
                    failure: { (error) in
                        
                        XCTAssertEqual(error, CoreStoreError.userCancelled)
                    }
                )
            }
            do {
                
                let deleteDiscardExpectation = self.expectation(description: "delete-discard")
                stack.perform(
                    asynchronous: { (transaction) -> Void in
                        
                        XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 1)
                        
                        guard let object = transaction.fetchOne(From<TestEntity1>()) else {
                            
                            XCTFail()
                            try transaction.cancel()
                        }
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object.testEntityID, NSNumber(value: 1))
                        XCTAssertEqual(object.testString, "string1")
                        XCTAssertEqual(object.testNumber, 100)
                        XCTAssertEqual(object.testDate, testDate)
                        
                        transaction.delete(object)
                        
                        try transaction.cancel()
                    },
                    success: {
                        
                        XCTFail()
                    },
                    failure: { (error) in
                        
                        XCTAssertEqual(error, CoreStoreError.userCancelled)
                        XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 1)
                        
                        let object = stack.fetchOne(From<TestEntity1>())
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testEntityID, NSNumber(value: 1))
                        XCTAssertEqual(object?.testString, "string1")
                        XCTAssertEqual(object?.testNumber, 100)
                        XCTAssertEqual(object?.testDate, testDate)
                        deleteDiscardExpectation.fulfill()
                    }
                )
            }
        }
        self.waitAndCheckExpectations()
    }
    
    @objc
    dynamic func test_ThatUnsafeTransactions_CanPerformCRUDs() {
        
        self.prepareStack { (stack) in
            
            let transaction = stack.beginUnsafe()
            XCTAssertEqual(transaction.context, transaction.unsafeContext())
            XCTAssertTrue(transaction.context.isTransactionContext)
            XCTAssertFalse(transaction.context.isDataStackContext)
            
            let testDate = Date()
            do {
                
                let object = transaction.create(Into<TestEntity1>())
                XCTAssertEqual(object.fetchSource()?.unsafeContext(), transaction.context)
                XCTAssertEqual(object.querySource()?.unsafeContext(), transaction.context)
                
                object.testEntityID = NSNumber(value: 1)
                object.testString = "string1"
                object.testNumber = 100
                object.testDate = testDate
                
                do {
                    
                    XCTAssertTrue(transaction.hasChanges)
                    try transaction.commitAndWait()
                    
                    XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 1)
                    
                    let object = stack.fetchOne(From<TestEntity1>())
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.fetchSource()?.unsafeContext(), stack.mainContext)
                    XCTAssertEqual(object?.querySource()?.unsafeContext(), stack.mainContext)
                    
                    XCTAssertEqual(object?.testEntityID, NSNumber(value: 1))
                    XCTAssertEqual(object?.testString, "string1")
                    XCTAssertEqual(object?.testNumber, 100)
                    XCTAssertEqual(object?.testDate, testDate)
                }
                catch {
                    
                    XCTFail()
                }
            }
            do {
                
                guard let object = transaction.fetchOne(From<TestEntity1>()) else {
                    
                    XCTFail()
                    return
                }
                object.testString = "string1_edit"
                object.testNumber = 200
                object.testDate = Date.distantFuture
                
                do {
                    
                    XCTAssertTrue(transaction.hasChanges)
                    try transaction.commitAndWait()
                    
                    XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 1)
                    
                    let object = stack.fetchOne(From<TestEntity1>())
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testEntityID, NSNumber(value: 1))
                    XCTAssertEqual(object?.testString, "string1_edit")
                    XCTAssertEqual(object?.testNumber, 200)
                    XCTAssertEqual(object?.testDate, Date.distantFuture)
                }
                catch {
                    
                    XCTFail()
                }
            }
            do {
                
                let object = transaction.fetchOne(From<TestEntity1>())
                transaction.delete(object)
                
                do {
                    
                    XCTAssertTrue(transaction.hasChanges)
                    try transaction.commitAndWait()
                    
                    XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 0)
                    XCTAssertNil(stack.fetchOne(From<TestEntity1>()))
                }
                catch {
                    
                    XCTFail()
                }
            }
        }
    }
    
    @objc
    dynamic func test_ThatUnsafeTransactions_CanPerformCRUDsInCorrectConfiguration() {
        
        self.prepareStack(configurations: [nil, "Config1"]) { (stack) in
            
            let transaction = stack.beginUnsafe()
            
            let testDate = Date()
            do {
                
                let object = transaction.create(Into<TestEntity1>("Config1"))
                object.testEntityID = NSNumber(value: 1)
                object.testString = "string1"
                object.testNumber = 100
                object.testDate = testDate
                
                do {
                    
                    XCTAssertTrue(transaction.hasChanges)
                    try transaction.commitAndWait()
                    
                    XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 1)
                    XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                    
                    let object = stack.fetchOne(From<TestEntity1>("Config1"))
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testEntityID, NSNumber(value: 1))
                    XCTAssertEqual(object?.testString, "string1")
                    XCTAssertEqual(object?.testNumber, 100)
                    XCTAssertEqual(object?.testDate, testDate)
                }
                catch {
                    
                    XCTFail()
                }
            }
            do {
                
                guard let object = transaction.fetchOne(From<TestEntity1>("Config1")) else {
                    
                    XCTFail()
                    return
                }
                object.testString = "string1_edit"
                object.testNumber = 200
                object.testDate = Date.distantFuture
                
                do {
                    
                    XCTAssertTrue(transaction.hasChanges)
                    try transaction.commitAndWait()
                    
                    XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 1)
                    XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                    
                    let object = stack.fetchOne(From<TestEntity1>("Config1"))
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testEntityID, NSNumber(value: 1))
                    XCTAssertEqual(object?.testString, "string1_edit")
                    XCTAssertEqual(object?.testNumber, 200)
                    XCTAssertEqual(object?.testDate, Date.distantFuture)
                }
                catch {
                    
                    XCTFail()
                }
            }
            do {
                
                let object = transaction.fetchOne(From<TestEntity1>("Config1"))
                transaction.delete(object)
                
                do {
                    
                    XCTAssertTrue(transaction.hasChanges)
                    try transaction.commitAndWait()
                    
                    XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 0)
                    XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                }
                catch {
                    
                    XCTFail()
                }
            }
        }
    }
    
    @objc
    dynamic func test_ThatUnsafeTransactions_CanRollbackChanges() {
        
        self.prepareStack { (stack) in
            
            let transaction = stack.beginUnsafe(supportsUndo: true)
            do {
                
                let object = transaction.create(Into<TestEntity1>())
                object.testEntityID = NSNumber(value: 1)
                object.testString = "string1"
                object.testNumber = 100
                object.testDate = Date()
                
                transaction.rollback()
                
                XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 0)
                XCTAssertNil(transaction.fetchOne(From<TestEntity1>()))
                
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 0)
                XCTAssertNil(stack.fetchOne(From<TestEntity1>()))
            }
            
            let testDate = Date()
            do {
                
                let object = transaction.create(Into<TestEntity1>())
                object.testEntityID = NSNumber(value: 1)
                object.testString = "string1"
                object.testNumber = 100
                object.testDate = testDate
                
                do {
                    
                    XCTAssertTrue(transaction.hasChanges)
                    try transaction.commitAndWait()
                }
                catch {
                    
                    XCTFail()
                }
            }
            
            do {
                
                guard let object = transaction.fetchOne(From<TestEntity1>()) else {
                    
                    XCTFail()
                    return
                }
                object.testString = "string1_edit"
                object.testNumber = 200
                object.testDate = Date.distantFuture
                
                transaction.rollback()
                
                XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 1)
                if let object = transaction.fetchOne(From<TestEntity1>()) {
                    
                    XCTAssertEqual(object.testEntityID, NSNumber(value: 1))
                    XCTAssertEqual(object.testString, "string1")
                    XCTAssertEqual(object.testNumber, 100)
                    XCTAssertEqual(object.testDate, testDate)
                }
                else {
                    
                    XCTFail()
                }
                
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 1)
                if let object = stack.fetchOne(From<TestEntity1>()) {
                    
                    XCTAssertEqual(object.testEntityID, NSNumber(value: 1))
                    XCTAssertEqual(object.testString, "string1")
                    XCTAssertEqual(object.testNumber, 100)
                    XCTAssertEqual(object.testDate, testDate)
                }
                else {
                    
                    XCTFail()
                }
            }
            
            do {
                
                guard let object = transaction.fetchOne(From<TestEntity1>()) else {
                    
                    XCTFail()
                    return
                }
                transaction.delete(object)
                
                transaction.rollback()
                
                XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 1)
                if let object = transaction.fetchOne(From<TestEntity1>()) {
                    
                    XCTAssertEqual(object.testEntityID, NSNumber(value: 1))
                    XCTAssertEqual(object.testString, "string1")
                    XCTAssertEqual(object.testNumber, 100)
                    XCTAssertEqual(object.testDate, testDate)
                }
                else {
                    
                    XCTFail()
                }
                
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 1)
                if let object = stack.fetchOne(From<TestEntity1>()) {
                    
                    XCTAssertEqual(object.testEntityID, NSNumber(value: 1))
                    XCTAssertEqual(object.testString, "string1")
                    XCTAssertEqual(object.testNumber, 100)
                    XCTAssertEqual(object.testDate, testDate)
                }
                else {
                    
                    XCTFail()
                }
            }
        }
    }
}
