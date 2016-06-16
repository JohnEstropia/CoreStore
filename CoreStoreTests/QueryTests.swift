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
                XCTAssertEqual(value, ("nil:TestEntity1:1" as NSString).dataUsingEncoding(NSUTF8StringEncoding))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDate>("testDate"),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, self.dateFormatter.dateFromString("2000-01-01T00:00:00Z"))
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
                OrderBy(.Ascending("testEntityID"))
            ]
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Bool>(.Average("testBoolean")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, true)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int8>(.Average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int16>(.Average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int32>(.Average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int64>(.Average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int>(.Average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Double>(.Average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3.5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Float>(.Average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3.5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSNumber>(.Average("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 3.5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDecimalNumber>(.Average("testDecimal")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, NSDecimalNumber(string: "3.5"))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<String>(.Average("testString")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSString>(.Average("testString")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSData>(.Average("testData")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDate>(.Average("testDate")),
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
                    Select<Bool>(.Count("testBoolean")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, true)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int8>(.Count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int16>(.Count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int32>(.Count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int64>(.Count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int>(.Count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Double>(.Count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Float>(.Count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSNumber>(.Count("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 4)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDecimalNumber>(.Count("testDecimal")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<String>(.Count("testString")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSString>(.Count("testString")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSData>(.Count("testData")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDate>(.Count("testDate")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSManagedObjectID>(.Count("testEntityID")),
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
                    Select<Bool>(.Maximum("testBoolean")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, true)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int8>(.Maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int16>(.Maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int32>(.Maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int64>(.Maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int>(.Maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Double>(.Maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Float>(.Maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSNumber>(.Maximum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 5)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDecimalNumber>(.Maximum("testDecimal")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, NSDecimalNumber(string: "5"))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<String>(.Maximum("testString")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:5")
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSString>(.Maximum("testString")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:5")
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSData>(.Maximum("testData")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, ("nil:TestEntity1:5" as NSString).dataUsingEncoding(NSUTF8StringEncoding))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDate>(.Maximum("testDate")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, self.dateFormatter.dateFromString("2000-01-05T00:00:00Z"))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSManagedObjectID>(.Maximum("testEntityID")),
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
                    Select<Bool>(.Minimum("testBoolean")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, false)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int8>(.Minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int16>(.Minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int32>(.Minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int64>(.Minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int>(.Minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Double>(.Minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Float>(.Minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSNumber>(.Minimum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 2)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDecimalNumber>(.Minimum("testDecimal")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, NSDecimalNumber(string: "2"))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<String>(.Minimum("testString")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:2")
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSString>(.Minimum("testString")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, "nil:TestEntity1:2")
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSData>(.Minimum("testData")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, ("nil:TestEntity1:2" as NSString).dataUsingEncoding(NSUTF8StringEncoding))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDate>(.Minimum("testDate")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, self.dateFormatter.dateFromString("2000-01-02T00:00:00Z"))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSManagedObjectID>(.Minimum("testEntityID")),
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
                    Select<Bool>(.Sum("testBoolean")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, true)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int8>(.Sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int16>(.Sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int32>(.Sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int64>(.Sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int>(.Sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Double>(.Sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Float>(.Sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSNumber>(.Sum("testNumber")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, 14)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDecimalNumber>(.Sum("testDecimal")),
                    queryClauses
                )
                XCTAssertNotNil(value)
                XCTAssertEqual(value, NSDecimalNumber(string: "14"))
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<String>(.Sum("testString")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSString>(.Sum("testString")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSData>(.Sum("testData")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDate>(.Sum("testDate")),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSManagedObjectID>(.Sum("testEntityID")),
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
                    Select<Bool>(.ObjectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int8>(.ObjectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int16>(.ObjectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int32>(.ObjectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int64>(.ObjectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Int>(.ObjectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Double>(.ObjectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<Float>(.ObjectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSNumber>(.ObjectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDecimalNumber>(.ObjectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<String>(.ObjectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSString>(.ObjectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSData>(.ObjectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSDate>(.ObjectID()),
                    queryClauses
                )
                XCTAssertNil(value)
            }
            do {
                
                let value = stack.queryValue(
                    from,
                    Select<NSManagedObjectID>(.ObjectID()),
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
                OrderBy(.Ascending("testEntityID"))
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
                    values!,
                    [
                        [
                            "testBoolean": NSNumber(bool: false),
                            "testNumber": NSNumber(integer: 4),
                            "testDecimal": NSDecimalNumber(string: "4"),
                            "testString": "nil:TestEntity1:4",
                            "testData": ("nil:TestEntity1:4" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!,
                            "testDate": self.dateFormatter.dateFromString("2000-01-04T00:00:00Z")!
                        ],
                        [
                            "testBoolean": NSNumber(bool: true),
                            "testNumber": NSNumber(integer: 5),
                            "testDecimal": NSDecimalNumber(string: "5"),
                            "testString": "nil:TestEntity1:5",
                            "testData": ("nil:TestEntity1:5" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!,
                            "testDate": self.dateFormatter.dateFromString("2000-01-05T00:00:00Z")!
                        ]
                    ]
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
                        .Sum("testBoolean"),
                        .Count("testNumber"),
                        .Maximum("testNumber"),
                        .Minimum("testNumber"),
                        .Average("testDecimal")
                    ),
                    queryClauses
                )
                XCTAssertNotNil(values)
                XCTAssertEqual(
                    values!,
                    [
                        [
                            "sum(testBoolean)": 3,
                            "count(testNumber)": 5,
                            "max(testNumber)": 5,
                            "min(testNumber)": 1,
                            "average(testDecimal)": 3,
                        ]
                    ]
                )
            }
            do {
                
                let values = stack.queryAttributes(
                    from,
                    Select(
                        .Sum("testBoolean", As: "testSum"),
                        .Count("testNumber", As: "testCount"),
                        .Maximum("testNumber", As: "testMaximum"),
                        .Minimum("testNumber", As: "testMinimum"),
                        .Average("testDecimal", As: "testAverage")
                    ),
                    queryClauses
                )
                XCTAssertNotNil(values)
                XCTAssertEqual(
                    values!,
                    [
                        [
                            "testSum": 3,
                            "testCount": 5,
                            "testMaximum": 5,
                            "testMinimum": 1,
                            "testAverage": 3,
                        ]
                    ]
                )
            }
        }
    }
}
