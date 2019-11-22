//
//  QueryTests.swift
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


// MARK: - QueryTests

class QueryTests: BaseTestDataTestCase {
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryAttributeValue() {
        
        let configurations: [ModelConfiguration] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where<TestEntity1>(#keyPath(TestEntity1.testEntityID), isEqualTo: 101)
            ]
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Bool>(#keyPath(TestEntity1.testBoolean)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, true)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int8>(#keyPath(TestEntity1.testNumber)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int16>(#keyPath(TestEntity1.testNumber)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int32>(#keyPath(TestEntity1.testNumber)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int64>(#keyPath(TestEntity1.testNumber)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int>(#keyPath(TestEntity1.testNumber)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Double>(#keyPath(TestEntity1.testNumber)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Float>(#keyPath(TestEntity1.testNumber)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSNumber>(#keyPath(TestEntity1.testNumber)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 1)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSDecimalNumber>(#keyPath(TestEntity1.testDecimal)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, NSDecimalNumber(string: "1"))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, String>(#keyPath(TestEntity1.testString)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:1")
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSString>(#keyPath(TestEntity1.testString)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:1")
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Data>(#keyPath(TestEntity1.testData)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Data?, "nil:TestEntity1:1".data(using: .utf8))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSData>(#keyPath(TestEntity1.testData)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Data?, "nil:TestEntity1:1".data(using: .utf8))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Date>(#keyPath(TestEntity1.testDate)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Date?, self.dateFormatter.date(from: "2000-01-01T00:00:00Z"))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSDate>(#keyPath(TestEntity1.testDate)),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Date?, self.dateFormatter.date(from: "2000-01-01T00:00:00Z"))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSManagedObjectID>(#keyPath(TestEntity1.testDate)),
                    queryClauses
                )
                XCTAssertNil(value)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryAverageValue() {
        
        let configurations: [ModelConfiguration] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1),
                OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
            ]
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Bool>(.average(#keyPath(TestEntity1.testBoolean))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, true)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int8>(.average(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int16>(.average(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int32>(.average(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int64>(.average(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int>(.average(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Double>(.average(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3.5)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Float>(.average(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3.5)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSNumber>(.average(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3.5)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSDecimalNumber>(.average(#keyPath(TestEntity1.testDecimal))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, NSDecimalNumber(string: "3.5"))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, String>(.average(#keyPath(TestEntity1.testString))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSString>(.average(#keyPath(TestEntity1.testString))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Data>(.average(#keyPath(TestEntity1.testData))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSData>(.average(#keyPath(TestEntity1.testData))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Date>(.average(#keyPath(TestEntity1.testDate))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSDate>(.average(#keyPath(TestEntity1.testDate))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSManagedObjectID>(#keyPath(TestEntity1.testEntityID)),
                    queryClauses
                )
                XCTAssertNil(value)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryCountValue() {
        
        let configurations: [ModelConfiguration] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1)
            ]
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Bool>(.count(#keyPath(TestEntity1.testBoolean))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, true)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int8>(.count(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int16>(.count(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int32>(.count(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int64>(.count(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int>(.count(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Double>(.count(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Float>(.count(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSNumber>(.count(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSDecimalNumber>(.count(#keyPath(TestEntity1.testDecimal))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, String>(.count(#keyPath(TestEntity1.testString))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSString>(.count(#keyPath(TestEntity1.testString))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Data>(.count(#keyPath(TestEntity1.testData))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSData>(.count(#keyPath(TestEntity1.testData))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Date>(.count(#keyPath(TestEntity1.testDate))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSDate>(.count(#keyPath(TestEntity1.testDate))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSManagedObjectID>(.count(#keyPath(TestEntity1.testEntityID))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryMaximumValue() {
        
        let configurations: [ModelConfiguration] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1)
            ]
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Bool>(.maximum(#keyPath(TestEntity1.testBoolean))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, true)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int8>(.maximum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int16>(.maximum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int32>(.maximum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int64>(.maximum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int>(.maximum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Double>(.maximum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Float>(.maximum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSNumber>(.maximum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSDecimalNumber>(.maximum(#keyPath(TestEntity1.testDecimal))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, NSDecimalNumber(string: "5"))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, String>(.maximum(#keyPath(TestEntity1.testString))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:5")
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSString>(.maximum(#keyPath(TestEntity1.testString))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:5")
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Data>(.maximum(#keyPath(TestEntity1.testData))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Data?, "nil:TestEntity1:5".data(using: .utf8))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSData>(.maximum(#keyPath(TestEntity1.testData))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Data?, "nil:TestEntity1:5".data(using: .utf8))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Date>(.maximum(#keyPath(TestEntity1.testDate))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Date?, self.dateFormatter.date(from: "2000-01-05T00:00:00Z"))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSDate>(.maximum(#keyPath(TestEntity1.testDate))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Date?, self.dateFormatter.date(from: "2000-01-05T00:00:00Z"))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSManagedObjectID>(.maximum(#keyPath(TestEntity1.testEntityID))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryMinimumValue() {
        
        let configurations: [ModelConfiguration] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1)
            ]
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Bool>(.minimum(#keyPath(TestEntity1.testBoolean))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, false)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int8>(.minimum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int16>(.minimum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int32>(.minimum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int64>(.minimum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int>(.minimum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Double>(.minimum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Float>(.minimum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSNumber>(.minimum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSDecimalNumber>(.minimum(#keyPath(TestEntity1.testDecimal))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, NSDecimalNumber(string: "2"))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, String>(.minimum(#keyPath(TestEntity1.testString))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:2")
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSString>(.minimum(#keyPath(TestEntity1.testString))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:2")
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Data>(.minimum(#keyPath(TestEntity1.testData))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Data?, "nil:TestEntity1:2".data(using: .utf8))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSData>(.minimum(#keyPath(TestEntity1.testData))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Data?, "nil:TestEntity1:2".data(using: .utf8))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Date>(.minimum(#keyPath(TestEntity1.testDate))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Date?, self.dateFormatter.date(from: "2000-01-02T00:00:00Z"))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSDate>(.minimum(#keyPath(TestEntity1.testDate))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value as Date?, self.dateFormatter.date(from: "2000-01-02T00:00:00Z"))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSManagedObjectID>(.minimum(#keyPath(TestEntity1.testEntityID))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQuerySumValue() {
        
        let configurations: [ModelConfiguration] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1)
            ]
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Bool>(.sum(#keyPath(TestEntity1.testBoolean))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, true)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int8>(.sum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int16>(.sum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int32>(.sum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int64>(.sum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int>(.sum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Double>(.sum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Float>(.sum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSNumber>(.sum(#keyPath(TestEntity1.testNumber))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSDecimalNumber>(.sum(#keyPath(TestEntity1.testDecimal))),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, NSDecimalNumber(string: "14"))
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, String>(.sum(#keyPath(TestEntity1.testString))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSString>(.sum(#keyPath(TestEntity1.testString))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Data>(.sum(#keyPath(TestEntity1.testData))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSData>(.sum(#keyPath(TestEntity1.testData))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Date>(.sum(#keyPath(TestEntity1.testDate))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSDate>(.sum(#keyPath(TestEntity1.testDate))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSManagedObjectID>(.sum(#keyPath(TestEntity1.testEntityID))),
                    queryClauses
                )
                XCTAssertNil(value)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryObjectIDValue() {
        
        let configurations: [ModelConfiguration] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 1)
            ]
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Bool>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int8>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int16>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int32>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int64>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Int>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Double>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Float>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSNumber>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSDecimalNumber>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, String>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSString>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Data>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSData>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, Date>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSDate>(.objectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = try stack.queryValue(
                    from,
                    Select<TestEntity1, NSManagedObjectID>(.objectID()),
                    queryClauses
                )
                XCTAssertNotNil(value)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryAttributes() {
        
        let configurations: [ModelConfiguration] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = [
                Where<TestEntity1>("%K > %@", #keyPath(TestEntity1.testNumber), 3),
                OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
            ]
            do {
                
                let values = try stack.queryAttributes(
                    from,
                    Select<TestEntity1, NSDictionary>(
                        #keyPath(TestEntity1.testBoolean),
                        #keyPath(TestEntity1.testNumber),
                        #keyPath(TestEntity1.testDecimal),
                        #keyPath(TestEntity1.testString),
                        #keyPath(TestEntity1.testData),
                        #keyPath(TestEntity1.testDate),
                        #keyPath(TestEntity1.testNil)
                    ),
                    queryClauses
                )
                XCTAssertNotNil(values)
                XCTAssertEqual(
                    values as Any as! [NSDictionary],
                    [
                        [
                            #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                            #keyPath(TestEntity1.testNumber): NSNumber(value: 4),
                            #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "4"),
                            #keyPath(TestEntity1.testString): "nil:TestEntity1:4",
                            #keyPath(TestEntity1.testData): ("nil:TestEntity1:4" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                            #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-04T00:00:00Z")!
                        ],
                        [
                            #keyPath(TestEntity1.testBoolean): NSNumber(value: true),
                            #keyPath(TestEntity1.testNumber): NSNumber(value: 5),
                            #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "5"),
                            #keyPath(TestEntity1.testString): "nil:TestEntity1:5",
                            #keyPath(TestEntity1.testData): ("nil:TestEntity1:5" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                            #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-05T00:00:00Z")!
                        ]
                    ] as [NSDictionary]
                )
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanQueryAggregates() {
        
        let configurations: [ModelConfiguration] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareTestDataForStack(stack, configurations: configurations)
            
            let from = From<TestEntity1>(configurations)
            let queryClauses: [QueryClause] = []
            do {
                
                let values = try stack.queryAttributes(
                    from,
                    Select<TestEntity1, NSDictionary>(
                        .sum(#keyPath(TestEntity1.testBoolean)),
                        .count(#keyPath(TestEntity1.testNumber)),
                        .maximum(#keyPath(TestEntity1.testNumber)),
                        .minimum(#keyPath(TestEntity1.testNumber)),
                        .average(#keyPath(TestEntity1.testDecimal))
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
                
                let values = try stack.queryAttributes(
                    from,
                    Select(
                        .sum(#keyPath(TestEntity1.testBoolean), as: "testSum"),
                        .count(#keyPath(TestEntity1.testNumber), as: "testCount"),
                        .maximum(#keyPath(TestEntity1.testNumber), as: "testMaximum"),
                        .minimum(#keyPath(TestEntity1.testNumber), as: "testMinimum"),
                        .average(#keyPath(TestEntity1.testDecimal), as: "testAverage")
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
