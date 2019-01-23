//
//  FetchTests.swift
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
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
                OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
            ]
            let object = try stack.fetchOne(from, fetchClauses)!
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
                    success: { _ in
                        
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
                OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
            ]
            let objects = try stack.fetchAll(from, fetchClauses)
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
                    success: { _ in
                
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
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNil(objectID)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil)
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNil(objectID)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchOne(from, fetchClauses)
                    }
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchObjectID(from, fetchClauses)
                    }
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchOne(from, fetchClauses)
                    }
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchObjectID(from, fetchClauses)
                    }
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
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNil(objectID)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil)
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNil(objectID)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "Config1:TestEntity1:2")
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "Config1:TestEntity1:3")
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNil(objectID)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config2")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchOne(from, fetchClauses)
                    }
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchObjectID(from, fetchClauses)
                    }
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchOne(from, fetchClauses)
                    }
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchObjectID(from, fetchClauses)
                    }
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
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNil(objectID)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil, "Config2")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNil(objectID)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1", "Config2")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "Config1:TestEntity1:2")
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNotNil(object)
                    XCTAssertEqual(object?.testString, "Config1:TestEntity1:3")
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
                    XCTAssertNotNil(objectID)
                    XCTAssertEqual(objectID, object?.objectID)
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let object = try stack.fetchOne(from, fetchClauses)
                    XCTAssertNil(object)
                    
                    let objectID = try stack.fetchObjectID(from, fetchClauses)
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
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 3)
                    XCTAssertEqual(
                        objects.map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:2",
                            "nil:TestEntity1:3",
                            "nil:TestEntity1:4"
                        ]
                    )
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 3)
                    XCTAssertEqual(
                        objectIDs,
                        objects.map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 3)
                    XCTAssertEqual(
                        objects.map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:4",
                            "nil:TestEntity1:3",
                            "nil:TestEntity1:2"
                        ]
                    )
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 3)
                    XCTAssertEqual(
                        objectIDs,
                        objects.map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 0)
                    
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil)
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 3)
                    XCTAssertEqual(
                        objects.map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:2",
                            "nil:TestEntity1:3",
                            "nil:TestEntity1:4"
                        ]
                    )
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 3)
                    XCTAssertEqual(
                        objectIDs,
                        objects.map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 3)
                    XCTAssertEqual(
                        objects.map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:4",
                            "nil:TestEntity1:3",
                            "nil:TestEntity1:2"
                        ]
                    )
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 3)
                    XCTAssertEqual(
                        objectIDs,
                        objects.map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 0)
                    
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchAll(from, fetchClauses)
                    }
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchObjectIDs(from, fetchClauses)
                    }
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>(#keyPath(TestEntity1.testNumber), isEqualTo: 0),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchAll(from, fetchClauses)
                    }
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchObjectIDs(from, fetchClauses)
                    }
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>(#keyPath(TestEntity1.testNumber), isEqualTo: nil),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchAll(from, fetchClauses)
                    }
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchObjectIDs(from, fetchClauses)
                    }
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
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 3)
                    
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 3)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 3)
                    
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 3)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 0)
                    
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil)
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 2)
                    XCTAssertEqual(
                        objects.map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:4",
                            "nil:TestEntity1:5"
                        ]
                    )
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 2)
                    XCTAssertEqual(
                        objectIDs,
                        objects.map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 2)
                    XCTAssertEqual(
                        objects.map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:2",
                            "nil:TestEntity1:1"
                        ]
                    )
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 2)
                    XCTAssertEqual(
                        objectIDs,
                        objects.map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 0)
                    
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 2)
                    XCTAssertEqual(
                        objects.map { $0.testString ?? "" },
                        [
                            "Config1:TestEntity1:4",
                            "Config1:TestEntity1:5"
                        ]
                    )
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 2)
                    XCTAssertEqual(
                        objectIDs,
                        objects.map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 2)
                    XCTAssertEqual(
                        objects.map { $0.testString ?? "" },
                        [
                            "Config1:TestEntity1:2",
                            "Config1:TestEntity1:1"
                        ]
                    )
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 2)
                    XCTAssertEqual(
                        objectIDs,
                        objects.map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 0)
                    
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config2")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchAll(from, fetchClauses)
                    }
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchObjectIDs(from, fetchClauses)
                    }
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchAll(from, fetchClauses)
                    }
                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchObjectIDs(from, fetchClauses)
                    }
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
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 3)
                    
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 3)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 3)
                    
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 3)
                    
                    // configuration ambiguous, no other behavior should be relied on
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 0)
                    
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil, "Config2")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 2)
                    XCTAssertEqual(
                        objects.map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:4",
                            "nil:TestEntity1:5"
                        ]
                    )
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 2)
                    XCTAssertEqual(
                        objectIDs,
                        objects.map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 2)
                    XCTAssertEqual(
                        objects.map { $0.testString ?? "" },
                        [
                            "nil:TestEntity1:2",
                            "nil:TestEntity1:1"
                        ]
                    )
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 2)
                    XCTAssertEqual(
                        objectIDs,
                        objects.map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 0)
                    
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1", "Config2")
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 2)
                    XCTAssertEqual(
                        objects.map { $0.testString ?? "" },
                        [
                            "Config1:TestEntity1:4",
                            "Config1:TestEntity1:5"
                        ]
                    )
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 2)
                    XCTAssertEqual(
                        objectIDs,
                        objects.map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 2)
                    XCTAssertEqual(
                        objects.map { $0.testString ?? "" },
                        [
                            "Config1:TestEntity1:2",
                            "Config1:TestEntity1:1"
                        ]
                    )
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 2)
                    XCTAssertEqual(
                        objectIDs,
                        objects.map { $0.objectID }
                    )
                }
                do {
                    
                    let fetchClauses: [FetchClause] = [
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    ]
                    let objects = try stack.fetchAll(from, fetchClauses)
                    XCTAssertEqual(objects.count, 0)
                    
                    let objectIDs = try stack.fetchObjectIDs(from, fetchClauses)
                    XCTAssertEqual(objectIDs.count, 0)
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
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
                    XCTAssertEqual(count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil)
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
                    XCTAssertEqual(count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                do {

                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchCount(
                            from,
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                    }
                }
                do {

                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchCount(
                            from,
                            Where<TestEntity1>(#keyPath(TestEntity1.testNumber), isEqualTo: 0),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        )
                    }
                }
                do {

                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchCount(
                            from,
                            Where<TestEntity1>(#keyPath(TestEntity1.testNumber), isEqualTo: nil),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        )
                    }
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
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
                    XCTAssertEqual(count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil)
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
                    XCTAssertEqual(count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
                    XCTAssertEqual(count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config2")
                do {

                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchCount(
                            from,
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                    }
                }
                do {

                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchCount(
                            from,
                            Where<TestEntity1>(#keyPath(TestEntity1.testNumber), isEqualTo: 0),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        )
                    }
                }
                do {

                    self.expectError(code: .persistentStoreNotFound) {
                        
                        try stack.fetchCount(
                            from,
                            Where<TestEntity1>(#keyPath(TestEntity1.testNumber), isEqualTo: nil),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        )
                    }
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
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 3)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
                    XCTAssertEqual(count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>(nil, "Config2")
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
                    XCTAssertEqual(count, 0)
                }
            }
            do {
                
                let from = From<TestEntity1>("Config1", "Config2")
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                        OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                        Tweak { $0.fetchLimit = 3 }
                    )
                    XCTAssertEqual(count, 2)
                }
                do {
                    
                    let count = try stack.fetchCount(
                        from,
                        Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                        OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                    )
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
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
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
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
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
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchOne(from, fetchClauses)
                        }
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchObjectID(from, fetchClauses)
                        }
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchOne(from, fetchClauses)
                        }
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchObjectID(from, fetchClauses)
                        }
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
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testNumber, 2) // configuration ambiguous
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testNumber, 3) // configuration
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
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
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
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
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "Config1:TestEntity1:2")
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "Config1:TestEntity1:3")
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
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
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchOne(from, fetchClauses)
                        }
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchObjectID(from, fetchClauses)
                        }
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchOne(from, fetchClauses)
                        }
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchObjectID(from, fetchClauses)
                        }
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
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testNumber, 2) // configuration is ambiguous
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testNumber, 3) // configuration is ambiguous
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
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
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:3")
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
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
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "Config1:TestEntity1:2")
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNotNil(object)
                        XCTAssertEqual(object?.testString, "Config1:TestEntity1:3")
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
                        XCTAssertNotNil(objectID)
                        XCTAssertEqual(objectID, object?.objectID)
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let object = try transaction.fetchOne(from, fetchClauses)
                        XCTAssertNil(object)
                        
                        let objectID = try transaction.fetchObjectID(from, fetchClauses)
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
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 3)
                        XCTAssertEqual(
                            objects.map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:2",
                                "nil:TestEntity1:3",
                                "nil:TestEntity1:4"
                            ]
                        )
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 3)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 3)
                        XCTAssertEqual(
                            objects.map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:4",
                                "nil:TestEntity1:3",
                                "nil:TestEntity1:2"
                            ]
                        )
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 3)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 0)
                        
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil)
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 3)
                        XCTAssertEqual(
                            objects.map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:2",
                                "nil:TestEntity1:3",
                                "nil:TestEntity1:4"
                            ]
                        )
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 3)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 3)
                        XCTAssertEqual(
                            objects.map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:4",
                                "nil:TestEntity1:3",
                                "nil:TestEntity1:2"
                            ]
                        )
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 3)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 0)
                        
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config1")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchAll(from, fetchClauses)
                        }
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchObjectIDs(from, fetchClauses)
                        }
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>(#keyPath(TestEntity1.testNumber), isEqualTo: 0),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchAll(from, fetchClauses)
                        }
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchObjectIDs(from, fetchClauses)
                        }
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>(#keyPath(TestEntity1.testNumber), isEqualTo: nil),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchAll(from, fetchClauses)
                        }
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchObjectIDs(from, fetchClauses)
                        }
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
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 3)
                        XCTAssertEqual(
                            Set(objects.map { $0.testNumber!.intValue }),
                            [4, 5] as Set<Int>
                        ) // configuration is ambiguous
                        
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 3)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 3)
                        XCTAssertEqual(
                            Set(objects.map { $0.testNumber!.intValue }),
                            [1, 2] as Set<Int>
                        ) // configuration is ambiguous
                        
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 3)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 0)
                        
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil)
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 2)
                        XCTAssertEqual(
                            objects.map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:4",
                                "nil:TestEntity1:5"
                            ]
                        )
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 2)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 2)
                        XCTAssertEqual(
                            objects.map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:2",
                                "nil:TestEntity1:1"
                            ]
                        )
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 2)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 0)
                        
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config1")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 2)
                        XCTAssertEqual(
                            objects.map { $0.testString ?? "" },
                            [
                                "Config1:TestEntity1:4",
                                "Config1:TestEntity1:5"
                            ]
                        )
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 2)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 2)
                        XCTAssertEqual(
                            objects.map { $0.testString ?? "" },
                            [
                                "Config1:TestEntity1:2",
                                "Config1:TestEntity1:1"
                            ]
                        )
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 2)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 0)
                        
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config2")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchAll(from, fetchClauses)
                        }
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchObjectIDs(from, fetchClauses)
                        }
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchAll(from, fetchClauses)
                        }
                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchObjectIDs(from, fetchClauses)
                        }
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
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 3)
                        XCTAssertEqual(
                            Set(objects.map { $0.testNumber!.intValue }),
                            [4, 5] as Set<Int>
                        ) // configuration is ambiguous
                        
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 3)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 3)
                        XCTAssertEqual(
                            Set(objects.map { $0.testNumber!.intValue }),
                            [1, 2] as Set<Int>
                        ) // configuration is ambiguous
                        
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 3)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 0)
                        
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil, "Config2")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 2)
                        XCTAssertEqual(
                            objects.map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:4",
                                "nil:TestEntity1:5"
                            ]
                        )
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 2)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 2)
                        XCTAssertEqual(
                            objects.map { $0.testString ?? "" },
                            [
                                "nil:TestEntity1:2",
                                "nil:TestEntity1:1"
                            ]
                        )
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 2)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 0)
                        
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config1", "Config2")
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 2)
                        XCTAssertEqual(
                            objects.map { $0.testString ?? "" },
                            [
                                "Config1:TestEntity1:4",
                                "Config1:TestEntity1:5"
                            ]
                        )
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 2)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 2)
                        XCTAssertEqual(
                            objects.map { $0.testString ?? "" },
                            [
                                "Config1:TestEntity1:2",
                                "Config1:TestEntity1:1"
                            ]
                        )
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 2)
                        XCTAssertEqual(
                            objectIDs,
                            objects.map { $0.objectID }
                        )
                    }
                    do {
                        
                        let fetchClauses: [FetchClause] = [
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        ]
                        let objects = try transaction.fetchAll(from, fetchClauses)
                        XCTAssertEqual(objects.count, 0)
                        
                        let objectIDs = try transaction.fetchObjectIDs(from, fetchClauses)
                        XCTAssertEqual(objectIDs.count, 0)
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
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
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
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertNotNil(count)
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
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

                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchCount(
                                from,
                                Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                                OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                            )
                        }
                    }
                    do {

                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchCount(
                                from,
                                Where<TestEntity1>(#keyPath(TestEntity1.testNumber), isEqualTo: 0),
                                OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                            )
                        }
                    }
                    do {

                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchCount(
                                from,
                                Where<TestEntity1>(#keyPath(TestEntity1.testNumber), isEqualTo: nil),
                                OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                            )
                        }
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
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                        XCTAssertEqual(count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil)
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                        XCTAssertEqual(count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config1")
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                        XCTAssertEqual(count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config2")
                    do {

                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchCount(
                                from,
                                Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 4),
                                OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                            )
                        }
                    }
                    do {

                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchCount(
                                from,
                                Where<TestEntity1>(#keyPath(TestEntity1.testNumber), isEqualTo: 0),
                                OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                            )
                        }
                    }
                    do {

                        self.expectError(code: .persistentStoreNotFound) {
                            
                            try transaction.fetchCount(
                                from,
                                Where<TestEntity1>(#keyPath(TestEntity1.testNumber), isEqualTo: nil),
                                OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID)))
                            )
                        }
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
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertEqual(count, 3)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                        XCTAssertEqual(count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>(nil, "Config2")
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                        XCTAssertEqual(count, 0)
                    }
                    try transaction.cancel()
                }
            )
            _ = try? stack.perform(
                synchronous: { (transaction) in
                    
                    let from = From<TestEntity1>("Config1", "Config2")
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K < %@", #keyPath(TestEntity1.testNumber), 3),
                            OrderBy<TestEntity1>(.descending(#keyPath(TestEntity1.testEntityID))),
                            Tweak { $0.fetchLimit = 3 }
                        )
                        XCTAssertEqual(count, 2)
                    }
                    do {
                        
                        let count = try transaction.fetchCount(
                            from,
                            Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 5),
                            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
                        )
                        XCTAssertEqual(count, 0)
                    }
                    try transaction.cancel()
                }
            )
        }
    }
}
