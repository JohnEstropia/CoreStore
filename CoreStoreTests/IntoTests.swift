//
//  IntoTests.swift
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


//MARK: - IntoTests

final class IntoTests: XCTestCase {
    
    @objc
    dynamic func test_ThatIntoClauseConstants_AreCorrect() {
        
        XCTAssertEqual(DataStack.defaultConfigurationName, "PF_DEFAULT_CONFIGURATION_NAME")
    }
    
    @objc
    dynamic func test_ThatIntoClauses_ConfigureCorrectly() {
        
        do {
            
            let into = Into<NSManagedObject>()
            XCTAssert(into.entityClass === NSManagedObject.self)
            XCTAssertNil(into.configuration)
            XCTAssertTrue(into.inferStoreIfPossible)
        }
        do {
            
            let into = Into<TestEntity1>()
            XCTAssert(into.entityClass === TestEntity1.self)
            XCTAssertNil(into.configuration)
            XCTAssertTrue(into.inferStoreIfPossible)
        }
        do {
            
            let into = Into(TestEntity1.self)
            XCTAssert(into.entityClass === TestEntity1.self)
            XCTAssertNil(into.configuration)
            XCTAssertTrue(into.inferStoreIfPossible)
        }
        do {
            
            let into = Into<TestEntity1>("Config1")
            XCTAssert(into.entityClass === TestEntity1.self)
            XCTAssertEqual(into.configuration, "Config1")
            XCTAssertFalse(into.inferStoreIfPossible)
        }
        do {
            
            let into = Into(TestEntity1.self, "Config1")
            XCTAssert(into.entityClass === TestEntity1.self)
            XCTAssertEqual(into.configuration, "Config1")
            XCTAssertFalse(into.inferStoreIfPossible)
        }
    }
    
    @objc
    dynamic func test_ThatIntoClauses_AreEquatable() {
        
        do {
            
            let into = Into<NSManagedObject>()
            XCTAssertEqual(into, Into<NSManagedObject>())
            XCTAssertEqual(into, Into(NSManagedObject.self))
            XCTAssertNotEqual(into, Into<NSManagedObject>(TestEntity1.self))
            XCTAssertNotEqual(into, Into<NSManagedObject>("Config1"))
        }
        do {
            
            let into = Into<TestEntity1>()
            XCTAssertEqual(into, Into<TestEntity1>())
            XCTAssertEqual(into, Into(TestEntity1.self))
            XCTAssertNotEqual(into, Into<TestEntity1>("Config1"))
        }
        do {
            
            let into = Into(TestEntity1.self)
            XCTAssert(into == Into<TestEntity1>())
            XCTAssertEqual(into, Into(TestEntity1.self))
            XCTAssertFalse(into == Into<TestEntity1>("Config1"))
        }
        do {
            
            let into = Into<TestEntity1>("Config1")
            XCTAssertEqual(into, Into(TestEntity1.self, "Config1"))
            XCTAssertNotEqual(into, Into<TestEntity1>("Config2"))
        }
        do {
            
            let into = Into(TestEntity1.self, "Config1")
            XCTAssertEqual(into, Into(TestEntity1.self, "Config1"))
            XCTAssertEqual(into, Into<TestEntity1>("Config1"))
            XCTAssertNotEqual(into, Into<TestEntity1>("Config2"))
        }
        do {
            
            let into = Into(TestEntity1.self, "Config1")
            XCTAssertEqual(into, Into<TestEntity1>("Config1"))
            XCTAssertEqual(into, Into(TestEntity1.self, "Config1"))
            XCTAssertNotEqual(into, Into<TestEntity1>("Config2"))
        }
    }
    
    @objc
    dynamic func test_ThatIntoClauses_BridgeCorrectly() {
        
        do {
            
            let into = Into<NSManagedObject>()
            let objcInto = into.bridgeToObjectiveC
            XCTAssertEqual(into, objcInto.bridgeToSwift)
        }
    }
}
