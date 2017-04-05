//
//  FetchTests.swift
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


//MARK: - FetchTests

final class FetchTests: BaseTestDataTestCase {
    
    @objc
    dynamic func test_ThatDataStacksAndTransactions_CanFetchOneExisting() {
        
        let configurations: [ModelConfiguration] = ["Config1"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>()
            let fetchClauses: [FetchClause] = [
                OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
            ]
            let object = stack.fetchOne(from, fetchClauses)!
            do {
                
                let existing = stack.fetchExisting(object)
                XCTAssertNotNil(existing)
                XCTAssertEqual(existing!.objectID, object.objectID)
                XCTAssertEqual(existing!.managedObjectContext, stack.mainContext)
            }
            do {
                
                let transaction = stack.beginUnsafe()
                
                let existing1 = transaction.fetchExisting(object)
                XCTAssertNotNil(existing1)
                XCTAssertEqual(existing1!.objectID, object.objectID)
                XCTAssertEqual(existing1!.managedObjectContext, transaction.context)
                
                let existing2 = stack.fetchExisting(existing1!)
                XCTAssertNotNil(existing2)
                XCTAssertEqual(existing2!.objectID, object.objectID)
                XCTAssertEqual(existing2!.managedObjectContext, stack.mainContext)
            }
            do {
                
                let fetchExpectation = self.expectation(description: "fetch")
                
                var existing1: TestEntity1?
                do {
                    
                    try stack.perform(
                        synchronous: { (transaction) in
                            
                            existing1 = transaction.fetchExisting(object)
                            XCTAssertNotNil(existing1)
                            XCTAssertEqual(existing1!.objectID, object.objectID)
                            XCTAssertEqual(existing1!.managedObjectContext, transaction.context)
                            
                            try transaction.cancel()
                        }
                    )
                    XCTFail()
                }
                catch CoreStoreError.userCancelled {
                    
                    fetchExpectation.fulfill()
                }
                catch {
                    
                    XCTFail()
                }
                
                let existing2 = stack.fetchExisting(existing1!)
                XCTAssertNotNil(existing2)
                XCTAssertEqual(existing2!.objectID, object.objectID)
                XCTAssertEqual(existing2!.managedObjectContext, stack.mainContext)
            }
            do {
                
                let fetchExpectation = self.expectation(description: "fetch")
                var existing1: TestEntity1?
                stack.perform(
                    asynchronous: { (transaction) in
                        
                        existing1 = transaction.fetchExisting(object)
                        XCTAssertNotNil(existing1)
                        XCTAssertEqual(existing1!.objectID, object.objectID)
                        XCTAssertEqual(existing1!.managedObjectContext, transaction.context)
                        
                        try transaction.cancel()
                    },
                    success: {
                        
                        XCTFail()
                    },
                    failure: { (error) in
                        
                        XCTAssertEqual(error, CoreStoreError.userCancelled)
                        
                        let existing2 = stack.fetchExisting(existing1!)
                        XCTAssertNotNil(existing2)
                        XCTAssertEqual(existing2!.objectID, object.objectID)
                        XCTAssertEqual(existing2!.managedObjectContext, stack.mainContext)
                        
                        fetchExpectation.fulfill()
                    }
                )
            }
        }
        self.waitAndCheckExpectations()
    }
    
    @objc
    dynamic func test_ThatDataStacksAndTransactions_CanFetchAllExisting() {
        
        let configurations: [ModelConfiguration] = ["Config1"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>()
            let fetchClauses: [FetchClause] = [
                OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
            ]
            let objects = stack.fetchAll(from, fetchClauses)!
            do {
                
                let existing = stack.fetchExisting(objects)
                XCTAssertEqual(
                    existing.map { $0.objectID },
                    objects.map { $0.objectID }
                )
                for object in existing {
                    
                    XCTAssertEqual(object.managedObjectContext, stack.mainContext)
                }
            }
            do {
                
                let transaction = stack.beginUnsafe()
                
                let existing1 = transaction.fetchExisting(objects)
                XCTAssertEqual(
                    existing1.map { $0.objectID },
                    objects.map { $0.objectID }
                )
                for object in existing1 {
                    
                    XCTAssertEqual(object.managedObjectContext, transaction.context)
                }
                
                let existing2 = stack.fetchExisting(existing1)
                XCTAssertEqual(
                    existing2.map { $0.objectID },
                    objects.map { $0.objectID }
                )
                for object in existing2 {
                    
                    XCTAssertEqual(object.managedObjectContext, stack.mainContext)
                }
            }
            do {
                
                let fetchExpectation = self.expectation(description: "fetch")
                
                var existing1 = [TestEntity1]()
                do {
                    
                    try stack.perform(
                        synchronous: { (transaction) in
                            
                            existing1 = transaction.fetchExisting(objects)
                            XCTAssertEqual(
                                existing1.map { $0.objectID },
                                objects.map { $0.objectID }
                            )
                            for object in existing1 {
                                
                                XCTAssertEqual(object.managedObjectContext, transaction.context)
                            }
                            
                            try transaction.cancel()
                        }
                    )
                    XCTFail()
                }
                catch CoreStoreError.userCancelled {
                    
                    fetchExpectation.fulfill()
                }
                catch {
                    
                    XCTFail()
                }
                let existing2 = stack.fetchExisting(existing1)
                XCTAssertEqual(
                    existing2.map { $0.objectID },
                    objects.map { $0.objectID }
                )
                for object in existing2 {
                    
                    XCTAssertEqual(object.managedObjectContext, stack.mainContext)
                }
            }
            do {
                
                let fetchExpectation = self.expectation(description: "fetch")
                var existing1 = [TestEntity1]()
                stack.perform(
                    asynchronous: { (transaction) in
                        
                        existing1 = transaction.fetchExisting(objects)
                        XCTAssertEqual(
                            existing1.map { $0.objectID },
                            objects.map { $0.objectID }
                        )
                        for object in existing1 {
                            
                            XCTAssertEqual(object.managedObjectContext, transaction.context)
                        }
                        try transaction.cancel()
                    },
                    success: {
                
                        XCTFail()
                    },
                    failure: { (error) in
                
                        XCTAssertEqual(error, CoreStoreError.userCancelled)
                        
                        let existing2 = stack.fetchExisting(existing1)
                        XCTAssertEqual(
                            existing2.map { $0.objectID },
                            objects.map { $0.objectID }
                        )
                        for object in existing2 {
                            
                            XCTAssertEqual(object.managedObjectContext, stack.mainContext)
                        }
                        fetchExpectation.fulfill()
                    }
                )
            }
        }
        self.waitAndCheckExpectations()
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchOneFromDefaultConfiguration() {
        
        let configurations: [ModelConfiguration] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            do {
                
                let from = From<TestEntity1>()
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNil(objectID)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil)
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNil(objectID)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = self.expectLogger([.logWarning]) {
                        
                        stack.fetchOne(from, fetchClauses)
                    }
                    XCTAssertNil(object)
                    
                    let objectID = self.expectLogger([.logWarning]) {
                        
                        stack.fetchObjectID(from, fetchClauses)
                    }
                    XCTAssertNil(objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = self.expectLogger([.logWarning]) {
                        
                        stack.fetchOne(from, fetchClauses)
                    }
                    XCTAssertNil(object)
                    
                    let objectID = self.expectLogger([.logWarning]) {
                        
                        stack.fetchObjectID(from, fetchClauses)
                    }
                    XCTAssertNil(objectID)
                }
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchOneFromSingleConfiguration() {
        
        let configurations: [ModelConfiguration] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            do {
                
                let from = From<TestEntity1>()
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNil(objectID)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil)
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNil(objectID)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "Config1:TestEntity1:2")
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "Config1:TestEntity1:3")
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNil(objectID)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config2")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = self.expectLogger([.logWarning]) {
                        
                        stack.fetchOne(from, fetchClauses)
                    }
                    XCTAssertNil(object)
                    
                    let objectID = self.expectLogger([.logWarning]) {
                        
                        stack.fetchObjectID(from, fetchClauses)
                    }
                    XCTAssertNil(objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = self.expectLogger([.logWarning]) {
                        
                        stack.fetchOne(from, fetchClauses)
                    }
                    XCTAssertNil(object)
                    
                    let objectID = self.expectLogger([.logWarning]) {
                        
                        stack.fetchObjectID(from, fetchClauses)
                    }
                    XCTAssertNil(objectID)
                }
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchOneFromMultipleConfigurations() {
        
        let configurations: [ModelConfiguration] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            do {
                
                let from = From<TestEntity1>(nil, "Config1")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNil(objectID)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil, "Config2")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNil(objectID)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1", "Config2")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "Config1:TestEntity1:2")
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "Config1:TestEntity1:3")
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNil(objectID)
                }
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchAllFromDefaultConfiguration() {
        
        let configurations: [ModelConfiguration] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            do {
                
                let from = From<TestEntity1>()
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 3)
                    XCTAssertEqual(
                        (objects ?? []).map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:2",
                            "nil:TestEntity1:3",
                            "nil:TestEntity1:4"
                        ]
                    )
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 3)
                    XCTAssertEqual(
                        (objectIDs ?? []),
                        (objects ?? []).map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 3)
                    XCTAssertEqual(
                        (objects ?? []).map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:4",
                            "nil:TestEntity1:3",
                            "nil:TestEntity1:2"
                        ]
                    )
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 3)
                    XCTAssertEqual(
                        (objectIDs ?? []),
                        (objects ?? []).map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 0)
                    
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil)
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 3)
                    XCTAssertEqual(
                        (objects ?? []).map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:2",
                            "nil:TestEntity1:3",
                            "nil:TestEntity1:4"
                        ]
                    )
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 3)
                    XCTAssertEqual(
                        (objectIDs ?? []),
                        (objects ?? []).map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 3)
                    XCTAssertEqual(
                        (objects ?? []).map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:4",
                            "nil:TestEntity1:3",
                            "nil:TestEntity1:2"
                        ]
                    )
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 3)
                    XCTAssertEqual(
                        (objectIDs ?? []),
                        (objects ?? []).map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 0)
                    
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = self.expectLogger([.logWarning]) {
                        
                        stack.fetchAll(from, fetchClauses)
                    }
                    XCTAssertNil(objects)
                    
                    let objectIDs = self.expectLogger([.logWarning]) {
                        
                        stack.fetchObjectIDs(from, fetchClauses)
                    }
                    XCTAssertNil(objectIDs)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where(#keyPath(TestEntity1.testNumber), isEqualTo: 0),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = self.expectLogger([.logWarning]) {
                        
                        stack.fetchAll(from, fetchClauses)
                    }
                    XCTAssertNil(objects)
                    
                    let objectIDs = self.expectLogger([.logWarning]) {
                        
                        stack.fetchObjectIDs(from, fetchClauses)
                    }
                    XCTAssertNil(objectIDs)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where(#keyPath(TestEntity1.testNumber), isEqualTo: nil),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = self.expectLogger([.logWarning]) {
                        
                        stack.fetchAll(from, fetchClauses)
                    }
                    XCTAssertNil(objects)
                    
                    let objectIDs = self.expectLogger([.logWarning]) {
                        
                        stack.fetchObjectIDs(from, fetchClauses)
                    }
                    XCTAssertNil(objectIDs)
                }
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchAllFromSingleConfiguration() {
        
        let configurations: [ModelConfiguration] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            do {
                
                let from = From<TestEntity1>()
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 3)
                    
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 3)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 3)
                    
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 3)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 0)
                    
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil)
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 2)
                    XCTAssertEqual(
                        (objects ?? []).map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:4",
                            "nil:TestEntity1:5"
                        ]
                    )
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 2)
                    XCTAssertEqual(
                        (objectIDs ?? []),
                        (objects ?? []).map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 2)
                    XCTAssertEqual(
                        (objects ?? []).map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:2",
                            "nil:TestEntity1:1"
                        ]
                    )
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 2)
                    XCTAssertEqual(
                        (objectIDs ?? []),
                        (objects ?? []).map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 0)
                    
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 2)
                    XCTAssertEqual(
                        (objects ?? []).map { $0.testString ?? "" },
                        [
                            "Config1:TestEntity1:4",
                            "Config1:TestEntity1:5"
                        ]
                    )
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 2)
                    XCTAssertEqual(
                        (objectIDs ?? []),
                        (objects ?? []).map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 2)
                    XCTAssertEqual(
                        (objects ?? []).map { $0.testString ?? "" },
                        [
                            "Config1:TestEntity1:2",
                            "Config1:TestEntity1:1"
                        ]
                    )
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 2)
                    XCTAssertEqual(
                        (objectIDs ?? []),
                        (objects ?? []).map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 0)
                    
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config2")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = self.expectLogger([.logWarning]) {
                        
                        stack.fetchAll(from, fetchClauses)
                    }
                    XCTAssertNil(objects)
                    
                    let objectIDs = self.expectLogger([.logWarning]) {
                        
                        stack.fetchObjectIDs(from, fetchClauses)
                    }
                    XCTAssertNil(objectIDs)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = self.expectLogger([.logWarning]) {
                        
                        stack.fetchAll(from, fetchClauses)
                    }
                    XCTAssertNil(objects)
                    
                    let objectIDs = self.expectLogger([.logWarning]) {
                        
                        stack.fetchObjectIDs(from, fetchClauses)
                    }
                    XCTAssertNil(objectIDs)
                }
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchAllFromMultipleConfigurations() {
        
        let configurations: [ModelConfiguration] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            do {
                
                let from = From<TestEntity1>(nil, "Config1")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 3)
                    
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 3)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 3)
                    
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 3)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 0)
                    
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil, "Config2")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 2)
                    XCTAssertEqual(
                        (objects ?? []).map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:4",
                            "nil:TestEntity1:5"
                        ]
                    )
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 2)
                    XCTAssertEqual(
                        (objectIDs ?? []),
                        (objects ?? []).map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 2)
                    XCTAssertEqual(
                        (objects ?? []).map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:2",
                            "nil:TestEntity1:1"
                        ]
                    )
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 2)
                    XCTAssertEqual(
                        (objectIDs ?? []),
                        (objects ?? []).map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 0)
                    
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1", "Config2")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 2)
                    XCTAssertEqual(
                        (objects ?? []).map { $0.testString ?? "" },
                        [
                            "Config1:TestEntity1:4",
                            "Config1:TestEntity1:5"
                        ]
                    )
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 2)
                    XCTAssertEqual(
                        (objectIDs ?? []),
                        (objects ?? []).map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 2)
                    XCTAssertEqual(
                        (objects ?? []).map { $0.testString ?? "" },
                        [
                            "Config1:TestEntity1:2",
                            "Config1:TestEntity1:1"
                        ]
                    )
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 2)
                    XCTAssertEqual(
                        (objectIDs ?? []),
                        (objects ?? []).map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = stack.fetchAll(from, fetchClauses)
                    XCTAssertNotNil(objects)
                    XCTAssertEqual(objects?.count, 0)
                    
                    let objectIDs = stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertNotNil(objectIDs)
                    XCTAssertEqual(objectIDs?.count, 0)
                }
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchCountFromDefaultConfiguration() {
        
        let configurations: [ModelConfiguration] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            do {
                
                let from = From<TestEntity1>()
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil)
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                do {
                    
                    let count = self.expectLogger([.logWarning]) {
                        
                        stack.fetchCount(
                            from,
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                    }
                    XCTAssertNil(count)
                }
                do {
                    
                    let count = self.expectLogger([.logWarning]) {
                        
                        stack.fetchCount(
                            from,
                            Where(#keyPath(TestEntity1.testNumber), isEqualTo: 0),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        )
                    }
                    XCTAssertNil(count)
                }
                do {
                    
                    let count = self.expectLogger([.logWarning]) {
                        
                        stack.fetchCount(
                            from,
                            Where(#keyPath(TestEntity1.testNumber), isEqualTo: nil),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        )
                    }
                    XCTAssertNil(count)
                }
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchCountFromSingleConfiguration() {
        
        let configurations: [ModelConfiguration] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            do {
                
                let from = From<TestEntity1>()
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil)
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config2")
                do {
                    
                    let count = self.expectLogger([.logWarning]) {
                        
                        stack.fetchCount(
                            from,
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                    }
                    XCTAssertNil(count)
                }
                do {
                    
                    let count = self.expectLogger([.logWarning]) {
                        
                        stack.fetchCount(
                            from,
                            Where(#keyPath(TestEntity1.testNumber), isEqualTo: 0),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        )
                    }
                    XCTAssertNil(count)
                }
                do {
                    
                    let count = self.expectLogger([.logWarning]) {
                        
                        stack.fetchCount(
                            from,
                            Where(#keyPath(TestEntity1.testNumber), isEqualTo: nil),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        )
                    }
                    XCTAssertNil(count)
                }
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchCountFromMultipleConfigurations() {
        
        let configurations: [ModelConfiguration] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            do {
                
                let from = From<TestEntity1>(nil, "Config1")
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil, "Config2")
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1", "Config2")
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = stack.fetchCount(
                        from,
                        Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
                    XCTAssertNotNil(count)
                    XCTAssertEqual(count, 0)
                }
            }
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchOneFromDefaultConfiguration() {
        
        let configurations: [ModelConfiguration] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            _ = try? stack.perform(
                synchronous: { (transaction) in
                
                    let from = From<TestEntity1>()
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNil(objectID)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil)
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNil(objectID)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config1")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchOne(from, fetchClauses)
                        }
                        XCTAssertNil(object)
                        
                        let objectID = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchObjectID(from, fetchClauses)
                        }
                        XCTAssertNil(objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchOne(from, fetchClauses)
                        }
                        XCTAssertNil(object)
                        
                        let objectID = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchObjectID(from, fetchClauses)
                        }
                        XCTAssertNil(objectID)
                    }
                    try transaction.cancel()
                }
            )
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchOneFromSingleConfiguration() {
        
        let configurations: [ModelConfiguration] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>()
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testNumber, 2) // configuration ambiguous
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testNumber, 3) // configuration
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNil(objectID)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil)
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNil(objectID)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config1")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "Config1:TestEntity1:2")
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "Config1:TestEntity1:3")
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNil(objectID)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config2")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchOne(from, fetchClauses)
                        }
                        XCTAssertNil(object)
                        
                        let objectID = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchObjectID(from, fetchClauses)
                        }
                        XCTAssertNil(objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchOne(from, fetchClauses)
                        }
                        XCTAssertNil(object)
                        
                        let objectID = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchObjectID(from, fetchClauses)
                        }
                        XCTAssertNil(objectID)
                    }
                    try transaction.cancel()
                }
            )
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchOneFromMultipleConfigurations() {
        
        let configurations: [ModelConfiguration] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil, "Config1")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testNumber, 2) // configuration is ambiguous
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testNumber, 3) // configuration is ambiguous
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNil(objectID)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil, "Config2")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNil(objectID)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config1", "Config2")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "Config1:TestEntity1:2")
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "Config1:TestEntity1:3")
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNil(objectID)
                    }
                    try transaction.cancel()
                }
            )
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchAllFromDefaultConfiguration() {
        
        let configurations: [ModelConfiguration] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>()
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 3)
                        XCTAssertEqual(
                            (objects ?? []).map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:2",
                                "nil:TestEntity1:3",
                                "nil:TestEntity1:4"
                            ]
                        )
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 3)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 3)
                        XCTAssertEqual(
                            (objects ?? []).map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:4",
                                "nil:TestEntity1:3",
                                "nil:TestEntity1:2"
                            ]
                        )
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 3)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 0)
                        
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil)
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 3)
                        XCTAssertEqual(
                            (objects ?? []).map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:2",
                                "nil:TestEntity1:3",
                                "nil:TestEntity1:4"
                            ]
                        )
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 3)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 3)
                        XCTAssertEqual(
                            (objects ?? []).map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:4",
                                "nil:TestEntity1:3",
                                "nil:TestEntity1:2"
                            ]
                        )
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 3)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 0)
                        
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config1")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchAll(from, fetchClauses)
                        }
                        XCTAssertNil(objects)
                        
                        let objectIDs = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchObjectIDs(from, fetchClauses)
                        }
                        XCTAssertNil(objectIDs)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where(#keyPath(TestEntity1.testNumber), isEqualTo: 0),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchAll(from, fetchClauses)
                        }
                        XCTAssertNil(objects)
                        
                        let objectIDs = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchObjectIDs(from, fetchClauses)
                        }
                        XCTAssertNil(objectIDs)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where(#keyPath(TestEntity1.testNumber), isEqualTo: nil),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchAll(from, fetchClauses)
                        }
                        XCTAssertNil(objects)
                        
                        let objectIDs = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchObjectIDs(from, fetchClauses)
                        }
                        XCTAssertNil(objectIDs)
                    }
                    try transaction.cancel()
                }
            )
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchAllFromSingleConfiguration() {
        
        let configurations: [ModelConfiguration] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>()
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 3)
                        XCTAssertEqual(
                            Set((objects ?? []).map { $0.testNumber!.intValue }),
                            [4, 5] as Set<Int>
                        ) // configuration is ambiguous
                        
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 3)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 3)
                        XCTAssertEqual(
                            Set((objects ?? []).map { $0.testNumber!.intValue }),
                            [1, 2] as Set<Int>
                        ) // configuration is ambiguous
                        
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 3)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 0)
                        
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil)
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 2)
                        XCTAssertEqual(
                            (objects ?? []).map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:4",
                                "nil:TestEntity1:5"
                            ]
                        )
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 2)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 2)
                        XCTAssertEqual(
                            (objects ?? []).map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:2",
                                "nil:TestEntity1:1"
                            ]
                        )
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 2)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 0)
                        
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config1")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 2)
                        XCTAssertEqual(
                            (objects ?? []).map { $0.testString ?? "" },
                            [
                                "Config1:TestEntity1:4",
                                "Config1:TestEntity1:5"
                            ]
                        )
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 2)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 2)
                        XCTAssertEqual(
                            (objects ?? []).map { $0.testString ?? "" },
                            [
                                "Config1:TestEntity1:2",
                                "Config1:TestEntity1:1"
                            ]
                        )
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 2)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 0)
                        
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config2")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchAll(from, fetchClauses)
                        }
                        XCTAssertNil(objects)
                        
                        let objectIDs = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchObjectIDs(from, fetchClauses)
                        }
                        XCTAssertNil(objectIDs)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchAll(from, fetchClauses)
                        }
                        XCTAssertNil(objects)
                        
                        let objectIDs = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchObjectIDs(from, fetchClauses)
                        }
                        XCTAssertNil(objectIDs)
                    }
                    try transaction.cancel()
                }
            )
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchAllFromMultipleConfigurations() {
        
        let configurations: [ModelConfiguration] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil, "Config1")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 3)
                        XCTAssertEqual(
                            Set((objects ?? []).map { $0.testNumber!.intValue }),
                            [4, 5] as Set<Int>
                        ) // configuration is ambiguous
                        
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 3)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 3)
                        XCTAssertEqual(
                            Set((objects ?? []).map { $0.testNumber!.intValue }),
                            [1, 2] as Set<Int>
                        ) // configuration is ambiguous
                        
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 3)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 0)
                        
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil, "Config2")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 2)
                        XCTAssertEqual(
                            (objects ?? []).map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:4",
                                "nil:TestEntity1:5"
                            ]
                        )
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 2)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 2)
                        XCTAssertEqual(
                            (objects ?? []).map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:2",
                                "nil:TestEntity1:1"
                            ]
                        )
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 2)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 0)
                        
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config1", "Config2")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 2)
                        XCTAssertEqual(
                            (objects ?? []).map { $0.testString ?? "" },
                            [
                                "Config1:TestEntity1:4",
                                "Config1:TestEntity1:5"
                            ]
                        )
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 2)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 2)
                        XCTAssertEqual(
                            (objects ?? []).map { $0.testString ?? "" },
                            [
                                "Config1:TestEntity1:2",
                                "Config1:TestEntity1:1"
                            ]
                        )
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 2)
                        XCTAssertEqual(
                            (objectIDs ?? []),
                            (objects ?? []).map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = transaction.fetchAll(from, fetchClauses)
                        XCTAssertNotNil(objects)
                        XCTAssertEqual(objects?.count, 0)
                        
                        let objectIDs = transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertNotNil(objectIDs)
                        XCTAssertEqual(objectIDs?.count, 0)
                    }
                    try transaction.cancel()
                }
            )
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchCountFromDefaultConfiguration() {
        
        let configurations: [ModelConfiguration] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>()
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil)
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config1")
                    do {
                        
                        let count = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchCount(
                                from,
                                Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                                OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                            )
                        }
                        XCTAssertNil(count)
                    }
                    do {
                        
                        let count = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchCount(
                                from,
                                Where(#keyPath(TestEntity1.testNumber), isEqualTo: 0),
                                OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                            )
                        }
                        XCTAssertNil(count)
                    }
                    do {
                        
                        let count = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchCount(
                                from,
                                Where(#keyPath(TestEntity1.testNumber), isEqualTo: nil),
                                OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                            )
                        }
                        XCTAssertNil(count)
                    }
                    try transaction.cancel()
                }
            )
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchCountFromSingleConfiguration() {
        
        let configurations: [ModelConfiguration] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>()
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil)
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config1")
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config2")
                    do {
                        
                        let count = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchCount(
                                from,
                                Where("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                                OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                            )
                        }
                        XCTAssertNil(count)
                    }
                    do {
                        
                        let count = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchCount(
                                from,
                                Where(#keyPath(TestEntity1.testNumber), isEqualTo: 0),
                                OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                            )
                        }
                        XCTAssertNil(count)
                    }
                    do {
                        
                        let count = self.expectLogger([.logWarning]) {
                            
                            transaction.fetchCount(
                                from,
                                Where(#keyPath(TestEntity1.testNumber), isEqualTo: nil),
                                OrderBy(.descending(#keyPath(TestEntity1.testEntityID)))
                            )
                        }
                        XCTAssertNil(count)
                    }
                    try transaction.cancel()
                }
            )
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchCountFromMultipleConfigurations() {
        
        let configurations: [ModelConfiguration] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil, "Config1")
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil, "Config2")
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config1", "Config2")
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = transaction.fetchCount(
                            from,
                            Where("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 0)
                    }
                    try transaction.cancel()
                }
            )
        }
    }
}
