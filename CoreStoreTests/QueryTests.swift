//
//  QueryTests.swift
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


// MARK: - QueryTests

class QueryTests: BaseTestDataTestCase {
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryAttributeValue() {
        
        let configurations: [String?] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where("testEntityID", isEqualTo: 101)
            ]
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Bool>("testBoolean"),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, true)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int8>("testNumber"),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int16>("testNumber"),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int32>("testNumber"),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int64>("testNumber"),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int>("testNumber"),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Double>("testNumber"),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Float>("testNumber"),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSNumber>("testNumber"),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDecimalNumber>("testDecimal"),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, NSDecimalNumber(string: "1"))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<String>("testString"),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:1")
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSString>("testString"),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:1")
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSData>("testData"),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Data?, "nil:TestEntity1:1".data(using: .utf8))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDate>("testDate"),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Date?, self.dateFormatter.date(from: "2000-01-01T00:00:00Z"))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSManagedObjectID>("testDate"),
                    queryClauses
                )
                XCTAssertNil(value)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryAverageValue() {
        
        let configurations: [String?] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where("%K > %@", "testNumber", 1),
                OrderBy(.ascending("testEntityID"))
            ]
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Bool>(.average("testBoolean")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, true)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int8>(.average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int16>(.average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int32>(.average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int64>(.average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int>(.average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Double>(.average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3.5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Float>(.average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3.5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSNumber>(.average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3.5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDecimalNumber>(.average("testDecimal")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, NSDecimalNumber(string: "3.5"))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<String>(.average("testString")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSString>(.average("testString")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSData>(.average("testData")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDate>(.average("testDate")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSManagedObjectID>("testEntityID"),
                    queryClauses
                )
                XCTAssertNil(value)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryCountValue() {
        
        let configurations: [String?] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where("%K > %@", "testNumber", 1)
            ]
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Bool>(.count("testBoolean")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, true)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int8>(.count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int16>(.count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int32>(.count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int64>(.count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int>(.count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Double>(.count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Float>(.count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSNumber>(.count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDecimalNumber>(.count("testDecimal")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<String>(.count("testString")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSString>(.count("testString")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSData>(.count("testData")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDate>(.count("testDate")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSManagedObjectID>(.count("testEntityID")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryMaximumValue() {
        
        let configurations: [String?] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where("%K > %@", "testNumber", 1)
            ]
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Bool>(.maximum("testBoolean")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, true)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int8>(.maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int16>(.maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int32>(.maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int64>(.maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int>(.maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Double>(.maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Float>(.maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSNumber>(.maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDecimalNumber>(.maximum("testDecimal")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, NSDecimalNumber(string: "5"))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<String>(.maximum("testString")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:5")
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSString>(.maximum("testString")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:5")
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSData>(.maximum("testData")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Data?, "nil:TestEntity1:5".data(using: .utf8))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDate>(.maximum("testDate")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Date?, self.dateFormatter.date(from: "2000-01-05T00:00:00Z"))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSManagedObjectID>(.maximum("testEntityID")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryMinimumValue() {
        
        let configurations: [String?] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where("%K > %@", "testNumber", 1)
            ]
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Bool>(.minimum("testBoolean")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, false)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int8>(.minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int16>(.minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int32>(.minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int64>(.minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int>(.minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Double>(.minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Float>(.minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSNumber>(.minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDecimalNumber>(.minimum("testDecimal")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, NSDecimalNumber(string: "2"))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<String>(.minimum("testString")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:2")
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSString>(.minimum("testString")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:2")
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSData>(.minimum("testData")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Data?, "nil:TestEntity1:2".data(using: .utf8))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDate>(.minimum("testDate")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Date?, self.dateFormatter.date(from: "2000-01-02T00:00:00Z"))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSManagedObjectID>(.minimum("testEntityID")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQuerySumValue() {
        
        let configurations: [String?] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where("%K > %@", "testNumber", 1)
            ]
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Bool>(.sum("testBoolean")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, true)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int8>(.sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int16>(.sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int32>(.sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int64>(.sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int>(.sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Double>(.sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Float>(.sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSNumber>(.sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDecimalNumber>(.sum("testDecimal")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, NSDecimalNumber(string: "14"))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<String>(.sum("testString")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSString>(.sum("testString")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSData>(.sum("testData")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDate>(.sum("testDate")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSManagedObjectID>(.sum("testEntityID")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryObjectIDValue() {
        
        let configurations: [String?] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where("%K > %@", "testNumber", 1)
            ]
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Bool>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int8>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int16>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int32>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int64>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Double>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Float>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSNumber>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDecimalNumber>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<String>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSString>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSData>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDate>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSManagedObjectID>(.objectID()),
                    queryClauses
                )
                XCTAssertNotNil(value)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryAttributes() {
        
        let configurations: [String?] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where("%K > %@", "testNumber", 3),
                OrderBy(.ascending("testEntityID"))
            ]
            do {
                
                let values = stack.queryAttributes(
                    from,
                    Select(
                        "testBoolean",
                        "testNumber",
                        "testDecimal",
                        "testString",
                        "testData",
                        "testDate",
                        "testNil"
                    ),
                    queryClauses
                )
                XCTAssertNotNil(values)
                XCTAssertEqual(
                    values as Any as! [NSDictionary],
                    [
                        [
                            "testBoolean": NSNumber(value: false),
                            "testNumber": NSNumber(value: 4),
                            "testDecimal": NSDecimalNumber(string: "4"),
                            "testString": "nil:TestEntity1:4",
                            "testData": ("nil:TestEntity1:4" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                            "testDate": self.dateFormatter.date(from: "2000-01-04T00:00:00Z")!
                        ],
                        [
                            "testBoolean": NSNumber(value: true),
                            "testNumber": NSNumber(value: 5),
                            "testDecimal": NSDecimalNumber(string: "5"),
                            "testString": "nil:TestEntity1:5",
                            "testData": ("nil:TestEntity1:5" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                            "testDate": self.dateFormatter.date(from: "2000-01-05T00:00:00Z")!
                        ]
                    ] as [NSDictionary]
                )
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryAggregates() {
        
        let configurations: [String?] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = []
            do {
                
                let values = stack.queryAttributes(
                    from,
                    Select(
                        .sum("testBoolean"),
                        .count("testNumber"),
                        .maximum("testNumber"),
                        .minimum("testNumber"),
                        .average("testDecimal")
                    ),
                    queryClauses
                )
                XCTAssertNotNil(values)
                XCTAssertEqual(
                    values as Any as! [NSDictionary],
                    [
                        [
                            "sum(testBoolean)": 3,
                            "count(testNumber)": 5,
                            "max(testNumber)": 5,
                            "min(testNumber)": 1,
                            "average(testDecimal)": 3,
                        ]
                    ] as [NSDictionary]
                )
            }
            do {
                
                let values = stack.queryAttributes(
                    from,
                    Select(
                        .sum("testBoolean", as: "testSum"),
                        .count("testNumber", as: "testCount"),
                        .maximum("testNumber", as: "testMaximum"),
                        .minimum("testNumber", as: "testMinimum"),
                        .average("testDecimal", as: "testAverage")
                    ),
                    queryClauses
                )
                XCTAssertNotNil(values)
                XCTAssertEqual(
                    values as Any as! [NSDictionary],
                    [
                        [
                            "testSum": 3,
                            "testCount": 5,
                            "testMaximum": 5,
                            "testMinimum": 1,
                            "testAverage": 3,
                        ]
                    ] as [NSDictionary]
                )
            }
        }
    }
}
