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
import GCDKit

@testable
import CoreStore


//MARK: - TransactionTests

final class TransactionTests: BaseTestCase {
    
    @objc
    dynamic func test_ThatSynchronousTransactions_CanPerformCRUDs() {
        
        self.prepareStack { (stack) in
            
            let testDate = NSDate()
            do {
                
                let createExpectation = self.expectationWithDescription("create")
                stack.beginSynchronous { (transaction) in
                    
                    let object = transaction.create(Into(TestEntity1))
                    object.testEntityID = NSNumber(integer: 1)
                    object.testString = "string1"
                    object.testNumber = 100
                    object.testDate = testDate
                    
                    switch transaction.commitAndWait() {
                        
                    case .Success(let hasChanges):
                        XCTAssertTrue(hasChanges)
                        createExpectation.fulfill()
                        
                    default:
                        XCTFail()
                    }
                }
                self.checkExpectationsImmediately()
                
                XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 1)
                
                let object = stack.fetchOne(From(TestEntity1))
                XCTAssertNotNil(object)
                XCTAssertEqual(object?.testEntityID, NSNumber(integer: 1))
                XCTAssertEqual(object?.testString, "string1")
                XCTAssertEqual(object?.testNumber, 100)
                XCTAssertEqual(object?.testDate, testDate)
            }
            do {
                
                let updateExpectation = self.expectationWithDescription("update")
                stack.beginSynchronous { (transaction) in
                    
                    guard let object = transaction.fetchOne(From(TestEntity1)) else {
                        
                        XCTFail()
                        return
                    }
                    object.testString = "string1_edit"
                    object.testNumber = 200
                    object.testDate = NSDate.distantFuture()
                    
                    switch transaction.commitAndWait() {
                        
                    case .Success(let hasChanges):
                        XCTAssertTrue(hasChanges)
                        updateExpectation.fulfill()
                        
                    default:
                        XCTFail()
                    }
                }
                self.checkExpectationsImmediately()
                
                XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 1)
                
                let object = stack.fetchOne(From(TestEntity1))
                XCTAssertNotNil(object)
                XCTAssertEqual(object?.testEntityID, NSNumber(integer: 1))
                XCTAssertEqual(object?.testString, "string1_edit")
                XCTAssertEqual(object?.testNumber, 200)
                XCTAssertEqual(object?.testDate, NSDate.distantFuture())
            }
            do {
                
                let deleteExpectation = self.expectationWithDescription("delete")
                stack.beginSynchronous { (transaction) in
                    
                    let object = transaction.fetchOne(From(TestEntity1))
                    transaction.delete(object)
                    
                    switch transaction.commitAndWait() {
                        
                    case .Success(let hasChanges):
                        XCTAssertTrue(hasChanges)
                        deleteExpectation.fulfill()
                        
                    default:
                        XCTFail()
                    }
                }
                self.checkExpectationsImmediately()
                
                XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 0)
                
                let object = stack.fetchOne(From(TestEntity1))
                XCTAssertNil(object)
            }
        }
    }
    
    @objc
    dynamic func test_ThatSynchronousTransactions_CanPerformCRUDsInCorrectConfiguration() {
        
        self.prepareStack(configurations: [nil, "Config1"]) { (stack) in
            
            let testDate = NSDate()
            do {
                
                let createExpectation = self.expectationWithDescription("create")
                stack.beginSynchronous { (transaction) in
                    
                    let object = transaction.create(Into<TestEntity1>("Config1"))
                    object.testEntityID = NSNumber(integer: 1)
                    object.testString = "string1"
                    object.testNumber = 100
                    object.testDate = testDate
                    
                    switch transaction.commitAndWait() {
                        
                    case .Success(let hasChanges):
                        XCTAssertTrue(hasChanges)
                        createExpectation.fulfill()
                        
                    default:
                        XCTFail()
                    }
                }
                self.checkExpectationsImmediately()
                
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 1)
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                
                let object = stack.fetchOne(From<TestEntity1>("Config1"))
                XCTAssertNotNil(object)
                XCTAssertEqual(object?.testEntityID, NSNumber(integer: 1))
                XCTAssertEqual(object?.testString, "string1")
                XCTAssertEqual(object?.testNumber, 100)
                XCTAssertEqual(object?.testDate, testDate)
            }
            do {
                
                let updateExpectation = self.expectationWithDescription("update")
                stack.beginSynchronous { (transaction) in
                    
                    guard let object = transaction.fetchOne(From<TestEntity1>("Config1")) else {
                        
                        XCTFail()
                        return
                    }
                    object.testString = "string1_edit"
                    object.testNumber = 200
                    object.testDate = NSDate.distantFuture()
                    
                    switch transaction.commitAndWait() {
                        
                    case .Success(let hasChanges):
                        XCTAssertTrue(hasChanges)
                        updateExpectation.fulfill()
                        
                    default:
                        XCTFail()
                    }
                }
                self.checkExpectationsImmediately()
                
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 1)
                XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                
                let object = stack.fetchOne(From<TestEntity1>("Config1"))
                XCTAssertNotNil(object)
                XCTAssertEqual(object?.testEntityID, NSNumber(integer: 1))
                XCTAssertEqual(object?.testString, "string1_edit")
                XCTAssertEqual(object?.testNumber, 200)
                XCTAssertEqual(object?.testDate, NSDate.distantFuture())
            }
            do {
                
                let deleteExpectation = self.expectationWithDescription("delete")
                stack.beginSynchronous { (transaction) in
                    
                    let object = transaction.fetchOne(From<TestEntity1>("Config1"))
                    transaction.delete(object)
                    
                    switch transaction.commitAndWait() {
                        
                    case .Success(let hasChanges):
                        XCTAssertTrue(hasChanges)
                        deleteExpectation.fulfill()
                        
                    default:
                        XCTFail()
                    }
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
                
                let createDiscardExpectation = self.expectationWithDescription("create-discard")
                let loggerExpectations = self.prepareLoggerExpectations([.LogWarning])
                stack.beginSynchronous { (transaction) in
                    
                    let object = transaction.create(Into(TestEntity1))
                    object.testEntityID = NSNumber(integer: 1)
                    object.testString = "string1"
                    object.testNumber = 100
                    object.testDate = NSDate()
                    
                    createDiscardExpectation.fulfill()
                    self.expectLogger(loggerExpectations)
                }
                self.checkExpectationsImmediately()
                
                XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 0)
                
                let object = stack.fetchOne(From(TestEntity1))
                XCTAssertNil(object)
            }
            let testDate = NSDate()
            do {
                
                let createExpectation = self.expectationWithDescription("create")
                stack.beginSynchronous { (transaction) in
                    
                    let object = transaction.create(Into(TestEntity1))
                    object.testEntityID = NSNumber(integer: 1)
                    object.testString = "string1"
                    object.testNumber = 100
                    object.testDate = testDate
                    
                    switch transaction.commitAndWait() {
                        
                    case .Success(true):
                        createExpectation.fulfill()
                        
                    default:
                        XCTFail()
                    }
                }
                self.checkExpectationsImmediately()
            }
            do {
                
                let updateDiscardExpectation = self.expectationWithDescription("update-discard")
                let loggerExpectations = self.prepareLoggerExpectations([.LogWarning])
                stack.beginSynchronous { (transaction) in
                    
                    guard let object = transaction.fetchOne(From(TestEntity1)) else {
                        
                        XCTFail()
                        return
                    }
                    object.testString = "string1_edit"
                    object.testNumber = 200
                    object.testDate = NSDate.distantFuture()
                    
                    updateDiscardExpectation.fulfill()
                    self.expectLogger(loggerExpectations)
                }
                self.checkExpectationsImmediately()
                
                XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 1)
                
                let object = stack.fetchOne(From(TestEntity1))
                XCTAssertNotNil(object)
                XCTAssertEqual(object?.testEntityID, NSNumber(integer: 1))
                XCTAssertEqual(object?.testString, "string1")
                XCTAssertEqual(object?.testNumber, 100)
                XCTAssertEqual(object?.testDate, testDate)
            }
            do {
                
                let deleteDiscardExpectation = self.expectationWithDescription("delete-discard")
                let loggerExpectations = self.prepareLoggerExpectations([.LogWarning])
                stack.beginSynchronous { (transaction) in
                    
                    guard let object = transaction.fetchOne(From(TestEntity1)) else {
                        
                        XCTFail()
                        return
                    }
                    transaction.delete(object)
                    
                    deleteDiscardExpectation.fulfill()
                    self.expectLogger(loggerExpectations)
                }
                self.checkExpectationsImmediately()
                
                XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 1)
                
                let object = stack.fetchOne(From(TestEntity1))
                XCTAssertNotNil(object)
                XCTAssertEqual(object?.testEntityID, NSNumber(integer: 1))
                XCTAssertEqual(object?.testString, "string1")
                XCTAssertEqual(object?.testNumber, 100)
                XCTAssertEqual(object?.testDate, testDate)
            }
        }
    }
    
    @objc
    dynamic func test_ThatAsynchronousTransactions_CanPerformCRUDs() {
        
        self.prepareStack { (stack) in
            
            let testDate = NSDate()
            do {
                
                let createExpectation = self.expectationWithDescription("create")
                stack.beginAsynchronous { (transaction) in
                    
                    let object = transaction.create(Into(TestEntity1))
                    object.testEntityID = NSNumber(integer: 1)
                    object.testString = "string1"
                    object.testNumber = 100
                    object.testDate = testDate
                    
                    transaction.commit { (result) in
                        
                        switch result {
                            
                        case .Success(let hasChanges):
                            XCTAssertTrue(hasChanges)
                            
                            XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 1)
                            
                            let object = stack.fetchOne(From(TestEntity1))
                            XCTAssertNotNil(object)
                            XCTAssertEqual(object?.testEntityID, NSNumber(integer: 1))
                            XCTAssertEqual(object?.testString, "string1")
                            XCTAssertEqual(object?.testNumber, 100)
                            XCTAssertEqual(object?.testDate, testDate)
                            createExpectation.fulfill()
                            
                        default:
                            XCTFail()
                        }
                    }
                }
            }
            do {
                
                let updateExpectation = self.expectationWithDescription("update")
                stack.beginAsynchronous { (transaction) in
                    
                    guard let object = transaction.fetchOne(From(TestEntity1)) else {
                        
                        XCTFail()
                        return
                    }
                    object.testString = "string1_edit"
                    object.testNumber = 200
                    object.testDate = NSDate.distantFuture()
                    
                    transaction.commit { (result) in
                        
                        switch result {
                            
                        case .Success(let hasChanges):
                            XCTAssertTrue(hasChanges)
                            
                            XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 1)
                            
                            let object = stack.fetchOne(From(TestEntity1))
                            XCTAssertNotNil(object)
                            XCTAssertEqual(object?.testEntityID, NSNumber(integer: 1))
                            XCTAssertEqual(object?.testString, "string1_edit")
                            XCTAssertEqual(object?.testNumber, 200)
                            XCTAssertEqual(object?.testDate, NSDate.distantFuture())
                            updateExpectation.fulfill()
                            
                        default:
                            XCTFail()
                        }
                    }
                }
            }
            do {
                
                let deleteExpectation = self.expectationWithDescription("delete")
                stack.beginAsynchronous { (transaction) in
                    
                    let object = transaction.fetchOne(From(TestEntity1))
                    transaction.delete(object)
                    
                    transaction.commit { (result) in
                        
                        switch result {
                            
                        case .Success(let hasChanges):
                            XCTAssertTrue(hasChanges)
                            
                            XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 0)
                            
                            let object = stack.fetchOne(From(TestEntity1))
                            XCTAssertNil(object)
                            deleteExpectation.fulfill()
                            
                        default:
                            XCTFail()
                        }
                    }
                }
            }
        }
        self.waitAndCheckExpectations()
    }
    
    @objc
    dynamic func test_ThatAsynchronousTransactions_CanPerformCRUDsInCorrectConfiguration() {
        
        self.prepareStack(configurations: [nil, "Config1"]) { (stack) in
            
            let testDate = NSDate()
            do {
                
                let createExpectation = self.expectationWithDescription("create")
                stack.beginAsynchronous { (transaction) in
                    
                    let object = transaction.create(Into<TestEntity1>("Config1"))
                    object.testEntityID = NSNumber(integer: 1)
                    object.testString = "string1"
                    object.testNumber = 100
                    object.testDate = testDate
                    
                    transaction.commit { (result) in
                        
                        switch result {
                            
                        case .Success(let hasChanges):
                            XCTAssertTrue(hasChanges)
                            
                            XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 1)
                            XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                            
                            let object = stack.fetchOne(From<TestEntity1>("Config1"))
                            XCTAssertNotNil(object)
                            XCTAssertEqual(object?.testEntityID, NSNumber(integer: 1))
                            XCTAssertEqual(object?.testString, "string1")
                            XCTAssertEqual(object?.testNumber, 100)
                            XCTAssertEqual(object?.testDate, testDate)
                            createExpectation.fulfill()
                            
                        default:
                            XCTFail()
                        }
                    }
                }
            }
            do {
                
                let updateExpectation = self.expectationWithDescription("update")
                stack.beginAsynchronous { (transaction) in
                    
                    guard let object = transaction.fetchOne(From<TestEntity1>("Config1")) else {
                        
                        XCTFail()
                        return
                    }
                    object.testString = "string1_edit"
                    object.testNumber = 200
                    object.testDate = NSDate.distantFuture()
                    
                    transaction.commit { (result) in
                        
                        switch result {
                            
                        case .Success(let hasChanges):
                            XCTAssertTrue(hasChanges)
                            
                            XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 1)
                            XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                            
                            let object = stack.fetchOne(From<TestEntity1>("Config1"))
                            XCTAssertNotNil(object)
                            XCTAssertEqual(object?.testEntityID, NSNumber(integer: 1))
                            XCTAssertEqual(object?.testString, "string1_edit")
                            XCTAssertEqual(object?.testNumber, 200)
                            XCTAssertEqual(object?.testDate, NSDate.distantFuture())
                            updateExpectation.fulfill()
                            
                        default:
                            XCTFail()
                        }
                    }
                }
            }
            do {
                
                let deleteExpectation = self.expectationWithDescription("delete")
                stack.beginAsynchronous { (transaction) in
                    
                    let object = transaction.fetchOne(From<TestEntity1>("Config1"))
                    transaction.delete(object)
                    
                    transaction.commit { (result) in
                        
                        switch result {
                            
                        case .Success(let hasChanges):
                            XCTAssertTrue(hasChanges)
                            
                            XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 0)
                            XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                            
                            deleteExpectation.fulfill()
                            
                        default:
                            XCTFail()
                        }
                    }
                }
            }
        }
        self.waitAndCheckExpectations()
    }
    
    @objc
    dynamic func test_ThatAsynchronousTransactions_CanDiscardUncommittedChanges() {
        
        self.prepareStack { (stack) in
            
            do {
                
                let createDiscardExpectation = self.expectationWithDescription("create-discard")
                let loggerExpectations = self.prepareLoggerExpectations([.LogWarning])
                stack.beginAsynchronous { (transaction) in
                    
                    let object = transaction.create(Into(TestEntity1))
                    object.testEntityID = NSNumber(integer: 1)
                    object.testString = "string1"
                    object.testNumber = 100
                    object.testDate = NSDate()
                    
                    createDiscardExpectation.fulfill()
                    self.expectLogger(loggerExpectations)
                }
            }
            let testDate = NSDate()
            do {
                
                let createExpectation = self.expectationWithDescription("create")
                stack.beginAsynchronous { (transaction) in
                    
                    XCTAssertEqual(transaction.fetchCount(From(TestEntity1)), 0)
                    XCTAssertNil(transaction.fetchOne(From(TestEntity1)))
                    
                    let object = transaction.create(Into(TestEntity1))
                    object.testEntityID = NSNumber(integer: 1)
                    object.testString = "string1"
                    object.testNumber = 100
                    object.testDate = testDate
                    
                    transaction.commit { (result) in
                        
                        switch result {
                            
                        case .Success(true):
                            createExpectation.fulfill()
                            
                        default:
                            XCTFail()
                        }
                    }
                }
            }
            do {
                
                let updateDiscardExpectation = self.expectationWithDescription("update-discard")
                let loggerExpectations = self.prepareLoggerExpectations([.LogWarning])
                stack.beginAsynchronous { (transaction) in
                    
                    guard let object = transaction.fetchOne(From(TestEntity1)) else {
                        
                        XCTFail()
                        return
                    }
                    object.testString = "string1_edit"
                    object.testNumber = 200
                    object.testDate = NSDate.distantFuture()
                    
                    updateDiscardExpectation.fulfill()
                    self.expectLogger(loggerExpectations)
                }
            }
            do {
                
                let deleteDiscardExpectation = self.expectationWithDescription("delete-discard")
                let loggerExpectations = self.prepareLoggerExpectations([.LogWarning])
                stack.beginAsynchronous { (transaction) in
                    
                    XCTAssertEqual(transaction.fetchCount(From(TestEntity1)), 1)
                    
                    guard let object = transaction.fetchOne(From(TestEntity1)) else {
                        
                        XCTFail()
                        return
                    }
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object.testEntityID, NSNumber(integer: 1))
                    XCTAssertEqual(object.testString, "string1")
                    XCTAssertEqual(object.testNumber, 100)
                    XCTAssertEqual(object.testDate, testDate)
                    
                    transaction.delete(object)
                    
                    GCDQueue.Main.async {
                        
                        XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 1)
                        
                        let object = stack.fetchOne(From(TestEntity1))
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testEntityID, NSNumber(integer: 1))
                        XCTAssertEqual(object?.testString, "string1")
                        XCTAssertEqual(object?.testNumber, 100)
                        XCTAssertEqual(object?.testDate, testDate)
                        deleteDiscardExpectation.fulfill()
                    }
                    self.expectLogger(loggerExpectations)
                }
            }
        }
        self.waitAndCheckExpectations()
    }
    
    @objc
    dynamic func test_ThatUnsafeTransactions_CanPerformCRUDs() {
        
        self.prepareStack { (stack) in
            
            let transaction = stack.beginUnsafe()
            
            let testDate = NSDate()
            do {
                
                let object = transaction.create(Into(TestEntity1))
                object.testEntityID = NSNumber(integer: 1)
                object.testString = "string1"
                object.testNumber = 100
                object.testDate = testDate
                
                switch transaction.commitAndWait() {
                    
                case .Success(let hasChanges):
                    XCTAssertTrue(hasChanges)
                    XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 1)
                    
                    let object = stack.fetchOne(From(TestEntity1))
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testEntityID, NSNumber(integer: 1))
                    XCTAssertEqual(object?.testString, "string1")
                    XCTAssertEqual(object?.testNumber, 100)
                    XCTAssertEqual(object?.testDate, testDate)
                    
                default:
                    XCTFail()
                }
            }
            do {
                
                guard let object = transaction.fetchOne(From(TestEntity1)) else {
                    
                    XCTFail()
                    return
                }
                object.testString = "string1_edit"
                object.testNumber = 200
                object.testDate = NSDate.distantFuture()
                
                switch transaction.commitAndWait() {
                    
                case .Success(let hasChanges):
                    XCTAssertTrue(hasChanges)
                    XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 1)
                    
                    let object = stack.fetchOne(From(TestEntity1))
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testEntityID, NSNumber(integer: 1))
                    XCTAssertEqual(object?.testString, "string1_edit")
                    XCTAssertEqual(object?.testNumber, 200)
                    XCTAssertEqual(object?.testDate, NSDate.distantFuture())
                    
                default:
                    XCTFail()
                }
            }
            do {
                
                let object = transaction.fetchOne(From(TestEntity1))
                transaction.delete(object)
                
                switch transaction.commitAndWait() {
                    
                case .Success(let hasChanges):
                    XCTAssertTrue(hasChanges)
                    
                    XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 0)
                    XCTAssertNil(stack.fetchOne(From(TestEntity1)))
                    
                default:
                    XCTFail()
                }
            }
        }
    }
    
    @objc
    dynamic func test_ThatUnsafeTransactions_CanPerformCRUDsInCorrectConfiguration() {
        
        self.prepareStack(configurations: [nil, "Config1"]) { (stack) in
            
            let transaction = stack.beginUnsafe()
            
            let testDate = NSDate()
            do {
                
                let object = transaction.create(Into<TestEntity1>("Config1"))
                object.testEntityID = NSNumber(integer: 1)
                object.testString = "string1"
                object.testNumber = 100
                object.testDate = testDate
                
                switch transaction.commitAndWait() {
                    
                case .Success(let hasChanges):
                    XCTAssertTrue(hasChanges)
                    XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 1)
                    XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                    
                    let object = stack.fetchOne(From<TestEntity1>("Config1"))
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testEntityID, NSNumber(integer: 1))
                    XCTAssertEqual(object?.testString, "string1")
                    XCTAssertEqual(object?.testNumber, 100)
                    XCTAssertEqual(object?.testDate, testDate)
                    
                default:
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
                object.testDate = NSDate.distantFuture()
                
                switch transaction.commitAndWait() {
                    
                case .Success(let hasChanges):
                    XCTAssertTrue(hasChanges)
                    XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 1)
                    XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                    
                    let object = stack.fetchOne(From<TestEntity1>("Config1"))
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testEntityID, NSNumber(integer: 1))
                    XCTAssertEqual(object?.testString, "string1_edit")
                    XCTAssertEqual(object?.testNumber, 200)
                    XCTAssertEqual(object?.testDate, NSDate.distantFuture())
                    
                default:
                    XCTFail()
                }
            }
            do {
                
                let object = transaction.fetchOne(From<TestEntity1>("Config1"))
                transaction.delete(object)
                
                switch transaction.commitAndWait() {
                    
                case .Success(let hasChanges):
                    XCTAssertTrue(hasChanges)
                    
                    XCTAssertEqual(stack.fetchCount(From<TestEntity1>("Config1")), 0)
                    XCTAssertEqual(stack.fetchCount(From<TestEntity1>(nil)), 0)
                    
                default:
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
                
                let object = transaction.create(Into(TestEntity1))
                object.testEntityID = NSNumber(integer: 1)
                object.testString = "string1"
                object.testNumber = 100
                object.testDate = NSDate()
                
                transaction.rollback()
                
                XCTAssertEqual(transaction.fetchCount(From(TestEntity1)), 0)
                XCTAssertNil(transaction.fetchOne(From(TestEntity1)))
                
                XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 0)
                XCTAssertNil(stack.fetchOne(From(TestEntity1)))
            }
            
            let testDate = NSDate()
            do {
                
                let object = transaction.create(Into(TestEntity1))
                object.testEntityID = NSNumber(integer: 1)
                object.testString = "string1"
                object.testNumber = 100
                object.testDate = testDate
                
                switch transaction.commitAndWait() {
                    
                case .Success(true):
                    break
                    
                default:
                    XCTFail()
                }
            }
            
            do {
                
                guard let object = transaction.fetchOne(From(TestEntity1)) else {
                    
                    XCTFail()
                    return
                }
                object.testString = "string1_edit"
                object.testNumber = 200
                object.testDate = NSDate.distantFuture()
                
                transaction.rollback()
                
                XCTAssertEqual(transaction.fetchCount(From(TestEntity1)), 1)
                if let object = transaction.fetchOne(From(TestEntity1)) {
                    
                    XCTAssertEqual(object.testEntityID, NSNumber(integer: 1))
                    XCTAssertEqual(object.testString, "string1")
                    XCTAssertEqual(object.testNumber, 100)
                    XCTAssertEqual(object.testDate, testDate)
                }
                else {
                    
                    XCTFail()
                }
                
                XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 1)
                if let object = stack.fetchOne(From(TestEntity1)) {
                    
                    XCTAssertEqual(object.testEntityID, NSNumber(integer: 1))
                    XCTAssertEqual(object.testString, "string1")
                    XCTAssertEqual(object.testNumber, 100)
                    XCTAssertEqual(object.testDate, testDate)
                }
                else {
                    
                    XCTFail()
                }
            }
            
            do {
                
                guard let object = transaction.fetchOne(From(TestEntity1)) else {
                    
                    XCTFail()
                    return
                }
                transaction.delete(object)
                
                transaction.rollback()
                
                XCTAssertEqual(transaction.fetchCount(From(TestEntity1)), 1)
                if let object = transaction.fetchOne(From(TestEntity1)) {
                    
                    XCTAssertEqual(object.testEntityID, NSNumber(integer: 1))
                    XCTAssertEqual(object.testString, "string1")
                    XCTAssertEqual(object.testNumber, 100)
                    XCTAssertEqual(object.testDate, testDate)
                }
                else {
                    
                    XCTFail()
                }
                
                XCTAssertEqual(stack.fetchCount(From(TestEntity1)), 1)
                if let object = stack.fetchOne(From(TestEntity1)) {
                    
                    XCTAssertEqual(object.testEntityID, NSNumber(integer: 1))
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
