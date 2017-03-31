//
//  ImportTests.swift
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


// MARK: - ImportTests

class ImportTests: BaseTestDataTestCase {
    
    @objc
    dynamic func test_ThatAttributeProtocols_BehaveCorrectly() {
        
        XCTAssertEqual(NSNumber.cs_fromImportableNativeType(NSNumber(value: true))?.boolValue, true)
        XCTAssertEqual(NSNumber.cs_fromImportableNativeType(NSNumber(value: Int16.max))?.int16Value, Int16.max)
        XCTAssertEqual(NSNumber.cs_fromImportableNativeType(NSNumber(value: Int32.max))?.int32Value, Int32.max)
        XCTAssertEqual(NSNumber.cs_fromImportableNativeType(NSNumber(value: Int64.max))?.int64Value, Int64.max)
        XCTAssertEqual(NSNumber.cs_fromImportableNativeType(NSNumber(value: MAXFLOAT))?.floatValue, MAXFLOAT)
        XCTAssertEqual(NSNumber.cs_fromImportableNativeType(NSNumber(value: Double(MAXFLOAT)))?.doubleValue, Double(MAXFLOAT))
        
        XCTAssertEqual(NSDecimalNumber.cs_fromImportableNativeType(NSDecimalNumber(string: "1"))?.boolValue, true)
        XCTAssertEqual(NSDecimalNumber.cs_fromImportableNativeType(NSDecimalNumber(string: Int16.max.description))?.int16Value, Int16.max)
        XCTAssertEqual(NSDecimalNumber.cs_fromImportableNativeType(NSDecimalNumber(string: Int32.max.description))?.int32Value, Int32.max)
        XCTAssertEqual(NSDecimalNumber.cs_fromImportableNativeType(NSDecimalNumber(string: Int64.max.description))?.int64Value, Int64.max)
        XCTAssertEqual(NSDecimalNumber.cs_fromImportableNativeType(NSDecimalNumber(string: MAXFLOAT.description))?.doubleValue, NSDecimalNumber(string: MAXFLOAT.description).doubleValue)
        XCTAssertEqual(NSDecimalNumber.cs_fromImportableNativeType(NSDecimalNumber(string: MAXFLOAT.description))?.floatValue, NSDecimalNumber(string: MAXFLOAT.description).floatValue)
        
        XCTAssertEqual(NSNumber.cs_fromImportableNativeType(NSDecimalNumber(string: "1"))?.boolValue, true)
        XCTAssertEqual(NSNumber.cs_fromImportableNativeType(NSDecimalNumber(string: Int16.max.description))?.int16Value, Int16.max)
        XCTAssertEqual(NSNumber.cs_fromImportableNativeType(NSDecimalNumber(string: Int32.max.description))?.int32Value, Int32.max)
        XCTAssertEqual(NSNumber.cs_fromImportableNativeType(NSDecimalNumber(string: Int64.max.description))?.int64Value, Int64.max)
        XCTAssertEqual(NSNumber.cs_fromImportableNativeType(NSDecimalNumber(string: MAXFLOAT.description))?.doubleValue, NSDecimalNumber(string: MAXFLOAT.description).doubleValue)
        XCTAssertEqual(NSNumber.cs_fromImportableNativeType(NSDecimalNumber(string: MAXFLOAT.description))?.floatValue, NSDecimalNumber(string: MAXFLOAT.description).floatValue)
        
        XCTAssertNil(NSDecimalNumber.cs_fromImportableNativeType(NSNumber(value: true)))
        XCTAssertNil(NSDecimalNumber.cs_fromImportableNativeType(NSNumber(value: Int16.max)))
        XCTAssertNil(NSDecimalNumber.cs_fromImportableNativeType(NSNumber(value: Int32.max)))
        XCTAssertNil(NSDecimalNumber.cs_fromImportableNativeType(NSNumber(value: Int64.max)))
        XCTAssertNil(NSDecimalNumber.cs_fromImportableNativeType(NSNumber(value: MAXFLOAT)))
        XCTAssertNil(NSDecimalNumber.cs_fromImportableNativeType(NSNumber(value: Double(MAXFLOAT))))
        
        XCTAssertEqual(true.cs_toQueryableNativeType(), NSNumber(value: true))
        XCTAssertEqual(Int16.max.cs_toQueryableNativeType(), NSNumber(value: Int16.max))
        XCTAssertEqual(Int32.max.cs_toQueryableNativeType(), NSNumber(value: Int32.max))
        XCTAssertEqual(Int64.max.cs_toQueryableNativeType(), NSNumber(value: Int64.max))
        XCTAssertEqual(MAXFLOAT.cs_toQueryableNativeType(), NSNumber(value: MAXFLOAT))
        XCTAssertEqual(Double(MAXFLOAT).cs_toQueryableNativeType(), NSNumber(value: Double(MAXFLOAT)))
    }
    
    @objc
    dynamic func test_ThatImportObject_CanSkipImport() {
        
        self.prepareStack { (stack) in
            
            do {
                
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        let object = try transaction.importObject(
                            Into<TestEntity1>(),
                            source: [
                                #keyPath(TestEntity1.testBoolean): NSNumber(value: true),
                                #keyPath(TestEntity1.testNumber): NSNumber(value: 1),
                                #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "1"),
                                #keyPath(TestEntity1.testString): "nil:TestEntity1:1",
                                #keyPath(TestEntity1.testData): ("nil:TestEntity1:1" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-01T00:00:00Z")!,
                                "skip_insert": ""
                            ]
                        )
                        XCTAssertNil(object)
                        XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 0)
                    }
                )
            }
            catch {
                
                XCTFail()
            }
            XCTAssertEqual(stack.fetchCount(From<TestEntity1>()), 0)
        }
    }
    
    @objc
    dynamic func test_ThatImportObject_CanThrowError() {
        
        self.prepareStack { (stack) in
            
            do {
                
                let errorExpectation = self.expectation(description: "error")
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        do {
                            
                            _ = try transaction.importObject(
                                Into<TestEntity1>(),
                                source: [
                                    #keyPath(TestEntity1.testBoolean): NSNumber(value: true),
                                    #keyPath(TestEntity1.testNumber): NSNumber(value: 1),
                                    #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "1"),
                                    #keyPath(TestEntity1.testString): "nil:TestEntity1:1",
                                    #keyPath(TestEntity1.testData): ("nil:TestEntity1:1" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                    #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-01T00:00:00Z")!,
                                    "throw_on_insert": ""
                                ]
                            )
                            XCTFail()
                        }
                        catch _ as TestInsertError {
                            
                            errorExpectation.fulfill()
                            XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 1)
                            
                            let object = transaction.fetchOne(From<TestEntity1>())
                            XCTAssertNotNil(object)
                            XCTAssertNil(object?.testEntityID)
                            XCTAssertNil(object?.testBoolean)
                            XCTAssertNil(object?.testNumber)
                            XCTAssertNil(object?.testDecimal)
                            XCTAssertNil(object?.testString)
                            XCTAssertNil(object?.testData)
                            XCTAssertNil(object?.testDate)
                        }
                    }
                )
                self.checkExpectationsImmediately()
            }
            catch {
                
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatImportObject_CanImportCorrectly() {
        
        self.prepareStack { (stack) in
            
            do {
                
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        let object = try transaction.importObject(
                            Into<TestEntity1>(),
                            source: [
                                #keyPath(TestEntity1.testBoolean): NSNumber(value: true),
                                #keyPath(TestEntity1.testNumber): NSNumber(value: 1),
                                #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "1"),
                                #keyPath(TestEntity1.testString): "nil:TestEntity1:1",
                                #keyPath(TestEntity1.testData): ("nil:TestEntity1:1" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-01T00:00:00Z")!
                            ]
                        )
                        XCTAssertNotNil(object)
                        XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 1)
                        XCTAssertNil(object?.testEntityID)
                        XCTAssertEqual(object?.testBoolean, NSNumber(value: true))
                        XCTAssertEqual(object?.testNumber, NSNumber(value: 1))
                        XCTAssertEqual(object?.testDecimal, NSDecimalNumber(string: "1"))
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:1")
                        XCTAssertEqual(object?.testData, ("nil:TestEntity1:1" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                        XCTAssertEqual(object?.testDate, self.dateFormatter.date(from: "2000-01-01T00:00:00Z")!)
                        
                        try transaction.importObject(
                            object!,
                            source: [
                                #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                                #keyPath(TestEntity1.testNumber): NSNumber(value: 2),
                                #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "2"),
                                #keyPath(TestEntity1.testString): "nil:TestEntity1:2",
                                #keyPath(TestEntity1.testData): ("nil:TestEntity1:2" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-02T00:00:00Z")!
                            ]
                        )
                        XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 1)
                        XCTAssertNil(object?.testEntityID)
                        XCTAssertEqual(object?.testBoolean, NSNumber(value: false))
                        XCTAssertEqual(object?.testNumber, NSNumber(value: 2))
                        XCTAssertEqual(object?.testDecimal, NSDecimalNumber(string: "2"))
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:2")
                        XCTAssertEqual(object?.testData, ("nil:TestEntity1:2" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                        XCTAssertEqual(object?.testDate, self.dateFormatter.date(from: "2000-01-02T00:00:00Z")!)
                    }
                )
            }
            catch {
                
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatImportObjects_CanSkipImport() {
        
        self.prepareStack { (stack) in
            
            do {
                
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        let sourceArray: [TestEntity1.ImportSource] = [
                            [
                                #keyPath(TestEntity1.testBoolean): NSNumber(value: true),
                                #keyPath(TestEntity1.testNumber): NSNumber(value: 1),
                                #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "1"),
                                #keyPath(TestEntity1.testString): "nil:TestEntity1:1",
                                #keyPath(TestEntity1.testData): ("nil:TestEntity1:1" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-01T00:00:00Z")!,
                                "skip_insert": ""
                            ],
                            [
                                #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                                #keyPath(TestEntity1.testNumber): NSNumber(value: 2),
                                #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "2"),
                                #keyPath(TestEntity1.testString): "nil:TestEntity1:2",
                                #keyPath(TestEntity1.testData): ("nil:TestEntity1:2" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-02T00:00:00Z")!
                            ]
                        ]
                        let objects = try transaction.importObjects(
                            Into<TestEntity1>(),
                            sourceArray: sourceArray
                        )
                        XCTAssertEqual(objects.count, 1)
                        XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 1)
                        
                        let object = objects[0]
                        let dictionary = sourceArray[1]
                        XCTAssertNil(object.testEntityID)
                        XCTAssertEqual(object.testBoolean, dictionary[(#keyPath(TestEntity1.testBoolean))] as? NSNumber)
                        XCTAssertEqual(object.testNumber, dictionary[(#keyPath(TestEntity1.testNumber))] as? NSNumber)
                        XCTAssertEqual(object.testDecimal, dictionary[(#keyPath(TestEntity1.testDecimal))] as? NSDecimalNumber)
                        XCTAssertEqual(object.testString, dictionary[(#keyPath(TestEntity1.testString))] as? String)
                        XCTAssertEqual(object.testData, dictionary[(#keyPath(TestEntity1.testData))] as? Data)
                        XCTAssertEqual(object.testDate, dictionary[(#keyPath(TestEntity1.testDate))] as? Date)
                    }
                )
            }
            catch {
                
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatImportObjects_CanThrowError() {
        
        self.prepareStack { (stack) in
            
            do {
                
                let errorExpectation = self.expectation(description: "error")
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        do {
                            
                            let sourceArray: [TestEntity1.ImportSource] = [
                                [
                                    #keyPath(TestEntity1.testBoolean): NSNumber(value: true),
                                    #keyPath(TestEntity1.testNumber): NSNumber(value: 1),
                                    #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "1"),
                                    #keyPath(TestEntity1.testString): "nil:TestEntity1:1",
                                    #keyPath(TestEntity1.testData): ("nil:TestEntity1:1" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                    #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-01T00:00:00Z")!,
                                    "throw_on_insert": ""
                                ],
                                [
                                    #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                                    #keyPath(TestEntity1.testNumber): NSNumber(value: 2),
                                    #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "2"),
                                    #keyPath(TestEntity1.testString): "nil:TestEntity1:2",
                                    #keyPath(TestEntity1.testData): ("nil:TestEntity1:2" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                    #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-02T00:00:00Z")!
                                ]
                            ]
                            let _ = try transaction.importObjects(
                                Into<TestEntity1>(),
                                sourceArray: sourceArray
                            )
                            XCTFail()
                        }
                        catch _ as TestInsertError {
                            
                            errorExpectation.fulfill()
                            XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 1)
                            
                            let object = transaction.fetchOne(From<TestEntity1>())
                            XCTAssertNotNil(object)
                            XCTAssertNil(object?.testEntityID)
                            XCTAssertNil(object?.testBoolean)
                            XCTAssertNil(object?.testNumber)
                            XCTAssertNil(object?.testDecimal)
                            XCTAssertNil(object?.testString)
                            XCTAssertNil(object?.testData)
                            XCTAssertNil(object?.testDate)
                        }
                    }
                )
                self.checkExpectationsImmediately()
            }
            catch {
                
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatImportObjects_CanImportCorrectly() {
        
        self.prepareStack { (stack) in
            
            do {
                
                try stack.perform(
                    synchronous: { (transaction) in
                
                        let sourceArray: [TestEntity1.ImportSource] = [
                            [
                                #keyPath(TestEntity1.testBoolean): NSNumber(value: true),
                                #keyPath(TestEntity1.testNumber): NSNumber(value: 1),
                                #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "1"),
                                #keyPath(TestEntity1.testString): "nil:TestEntity1:1",
                                #keyPath(TestEntity1.testData): ("nil:TestEntity1:1" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-01T00:00:00Z")!
                            ],
                            [
                                #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                                #keyPath(TestEntity1.testNumber): NSNumber(value: 2),
                                #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "2"),
                                #keyPath(TestEntity1.testString): "nil:TestEntity1:2",
                                #keyPath(TestEntity1.testData): ("nil:TestEntity1:2" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-02T00:00:00Z")!
                            ]
                        ]
                        let objects = try transaction.importObjects(
                            Into<TestEntity1>(),
                            sourceArray: sourceArray
                        )
                        XCTAssertEqual(objects.count, sourceArray.count)
                        XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 2)
                        
                        for i in 0 ..< sourceArray.count {
                            
                            let object = objects[i]
                            let dictionary = sourceArray[i]
                            
                            XCTAssertNil(object.testEntityID)
                            XCTAssertEqual(object.testBoolean, dictionary[(#keyPath(TestEntity1.testBoolean))] as? NSNumber)
                            XCTAssertEqual(object.testNumber, dictionary[(#keyPath(TestEntity1.testNumber))] as? NSNumber)
                            XCTAssertEqual(object.testDecimal, dictionary[(#keyPath(TestEntity1.testDecimal))] as? NSDecimalNumber)
                            XCTAssertEqual(object.testString, dictionary[(#keyPath(TestEntity1.testString))] as? String)
                            XCTAssertEqual(object.testData, dictionary[(#keyPath(TestEntity1.testData))] as? Data)
                            XCTAssertEqual(object.testDate, dictionary[(#keyPath(TestEntity1.testDate))] as? Date)
                        }
                    }
                )
            }
            catch {
                
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatImportUniqueObject_CanSkipImport() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            do {
                
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        do {
                            
                            let object = try transaction.importUniqueObject(
                                Into<TestEntity1>(),
                                source: [
                                    #keyPath(TestEntity1.testEntityID): NSNumber(value: 106),
                                    #keyPath(TestEntity1.testBoolean): NSNumber(value: true),
                                    #keyPath(TestEntity1.testNumber): NSNumber(value: 6),
                                    #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "6"),
                                    #keyPath(TestEntity1.testString): "nil:TestEntity1:6",
                                    #keyPath(TestEntity1.testData): ("nil:TestEntity1:6" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                    #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-06T00:00:00Z")!,
                                    "skip_insert": ""
                                ]
                            )
                            XCTAssertNil(object)
                            XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 5)
                        }
                        do {
                            
                            let object = try transaction.importUniqueObject(
                                Into<TestEntity1>(),
                                source: [
                                    #keyPath(TestEntity1.testEntityID): NSNumber(value: 105),
                                    #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                                    #keyPath(TestEntity1.testNumber): NSNumber(value: 6),
                                    #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "6"),
                                    #keyPath(TestEntity1.testString): "nil:TestEntity1:6",
                                    #keyPath(TestEntity1.testData): ("nil:TestEntity1:6" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                    #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-06T00:00:00Z")!,
                                    "skip_update": ""
                                ]
                            )
                            XCTAssertNil(object)
                            XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 5)
                            
                            let existingObjects = transaction.fetchAll(From<TestEntity1>(), Where(#keyPath(TestEntity1.testEntityID), isEqualTo: 105))
                            XCTAssertNotNil(existingObjects)
                            XCTAssertEqual(existingObjects?.count, 1)
                            
                            let existingObject = existingObjects?[0]
                            XCTAssertEqual(existingObject?.testEntityID, NSNumber(value: 105))
                            XCTAssertEqual(existingObject?.testBoolean, NSNumber(value: true))
                            XCTAssertEqual(existingObject?.testNumber, NSNumber(value: 5))
                            XCTAssertEqual(existingObject?.testDecimal, NSDecimalNumber(string: "5"))
                            XCTAssertEqual(existingObject?.testString, "nil:TestEntity1:5")
                            XCTAssertEqual(existingObject?.testData, ("nil:TestEntity1:5" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                            XCTAssertEqual(existingObject?.testDate, self.dateFormatter.date(from: "2000-01-05T00:00:00Z")!)
                        }
                    }
                )
            }
            catch {
                
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatImportUniqueObjects_ImportsLastOfImportSourcesWithSameIDs() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            do {
                
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        let sourceArray: [TestEntity1.ImportSource] = [
                            [
                                #keyPath(TestEntity1.testEntityID): NSNumber(value: 106),
                                #keyPath(TestEntity1.testBoolean): NSNumber(value: true),
                                #keyPath(TestEntity1.testNumber): NSNumber(value: 6),
                                #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "6"),
                                #keyPath(TestEntity1.testString): "nil:TestEntity1:6",
                                #keyPath(TestEntity1.testData): ("nil:TestEntity1:6" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-06T00:00:00Z")!
                            ],
                            [
                                #keyPath(TestEntity1.testEntityID): NSNumber(value: 106),
                                #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                                #keyPath(TestEntity1.testNumber): NSNumber(value: 7),
                                #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "7"),
                                #keyPath(TestEntity1.testString): "nil:TestEntity1:7",
                                #keyPath(TestEntity1.testData): ("nil:TestEntity1:7" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-07T00:00:00Z")!
                            ]
                        ]
                        let objects = try transaction.importUniqueObjects(
                            Into<TestEntity1>(),
                            sourceArray: sourceArray
                        )
                        
                        XCTAssertEqual(objects.count, 1)
                        XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 6)
                        
                        let object = objects[0]
                        let dictionary = sourceArray[1]
                        XCTAssertEqual(object.testEntityID, dictionary[(#keyPath(TestEntity1.testEntityID))] as? NSNumber)
                        XCTAssertEqual(object.testBoolean, dictionary[(#keyPath(TestEntity1.testBoolean))] as? NSNumber)
                        XCTAssertEqual(object.testNumber, dictionary[(#keyPath(TestEntity1.testNumber))] as? NSNumber)
                        XCTAssertEqual(object.testDecimal, dictionary[(#keyPath(TestEntity1.testDecimal))] as? NSDecimalNumber)
                        XCTAssertEqual(object.testString, dictionary[(#keyPath(TestEntity1.testString))] as? String)
                        XCTAssertEqual(object.testData, dictionary[(#keyPath(TestEntity1.testData))] as? Data)
                        XCTAssertEqual(object.testDate, dictionary[(#keyPath(TestEntity1.testDate))] as? Date)
                    }
                )
            }
            catch {
                
                XCTFail()
            }
        }
    }

    @objc
    dynamic func test_ThatImportUniqueObjects_MaintainsOrderOfInputSourceArray() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            do {
             
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        let sourceArray: [TestEntity1.ImportSource] = [
                            [
                                #keyPath(TestEntity1.testEntityID): NSNumber(value: 106),
                                #keyPath(TestEntity1.testBoolean): NSNumber(value: true),
                                #keyPath(TestEntity1.testNumber): NSNumber(value: 6),
                                #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "6"),
                                #keyPath(TestEntity1.testString): "nil:TestEntity1:6",
                                #keyPath(TestEntity1.testData): ("nil:TestEntity1:6" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-06T00:00:00Z")!
                            ],
                            [
                                #keyPath(TestEntity1.testEntityID): NSNumber(value: 107),
                                #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                                #keyPath(TestEntity1.testNumber): NSNumber(value: 7),
                                #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "7"),
                                #keyPath(TestEntity1.testString): "nil:TestEntity1:7",
                                #keyPath(TestEntity1.testData): ("nil:TestEntity1:7" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-07T00:00:00Z")!
                            ]
                        ]
                        
                        let objects = try transaction.importUniqueObjects(
                            Into<TestEntity1>(),
                            sourceArray: sourceArray
                        )
                        
                        XCTAssertEqual(objects.count, 2)
                        
                        zip(objects, sourceArray)
                            .forEach { object, dictionary in
                                XCTAssertEqual(object.testEntityID, dictionary[(#keyPath(TestEntity1.testEntityID))] as? NSNumber)
                                XCTAssertEqual(object.testBoolean, dictionary[(#keyPath(TestEntity1.testBoolean))] as? NSNumber)
                                XCTAssertEqual(object.testNumber, dictionary[(#keyPath(TestEntity1.testNumber))] as? NSNumber)
                                XCTAssertEqual(object.testDecimal, dictionary[(#keyPath(TestEntity1.testDecimal))] as? NSDecimalNumber)
                                XCTAssertEqual(object.testString, dictionary[(#keyPath(TestEntity1.testString))] as? String)
                                XCTAssertEqual(object.testData, dictionary[(#keyPath(TestEntity1.testData))] as? Data)
                                XCTAssertEqual(object.testDate, dictionary[(#keyPath(TestEntity1.testDate))] as? Date)
                        }
                    }
                )
            }
            catch {
                
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatImportUniqueObject_CanThrowError() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            do {
                
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        let errorExpectation = self.expectation(description: "error")
                        do {
                            
                            let _ = try transaction.importUniqueObject(
                                Into<TestEntity1>(),
                                source: [
                                    #keyPath(TestEntity1.testEntityID): NSNumber(value: 106),
                                    #keyPath(TestEntity1.testBoolean): NSNumber(value: true),
                                    #keyPath(TestEntity1.testNumber): NSNumber(value: 6),
                                    #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "6"),
                                    #keyPath(TestEntity1.testString): "nil:TestEntity1:6",
                                    #keyPath(TestEntity1.testData): ("nil:TestEntity1:6" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                    #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-06T00:00:00Z")!,
                                    "throw_on_insert": ""
                                ]
                            )
                            XCTFail()
                        }
                        catch _ as TestInsertError {
                            
                            errorExpectation.fulfill()
                            XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 6)
                            
                            let object = transaction.fetchOne(From<TestEntity1>(), Where(#keyPath(TestEntity1.testEntityID), isEqualTo: 106))
                            XCTAssertNotNil(object)
                            XCTAssertEqual(object?.testEntityID, NSNumber(value: 106))
                            XCTAssertNil(object?.testBoolean)
                            XCTAssertNil(object?.testNumber)
                            XCTAssertNil(object?.testDecimal)
                            XCTAssertNil(object?.testString)
                            XCTAssertNil(object?.testData)
                            XCTAssertNil(object?.testDate)
                        }
                        self.checkExpectationsImmediately()
                    }
                )
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        let errorExpectation = self.expectation(description: "error")
                        do {
                            
                            let _ = try transaction.importUniqueObject(
                                Into<TestEntity1>(),
                                source: [
                                    #keyPath(TestEntity1.testEntityID): NSNumber(value: 105),
                                    #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                                    #keyPath(TestEntity1.testNumber): NSNumber(value: 6),
                                    #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "6"),
                                    #keyPath(TestEntity1.testString): "nil:TestEntity1:6",
                                    #keyPath(TestEntity1.testData): ("nil:TestEntity1:6" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                    #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-06T00:00:00Z")!,
                                    "throw_on_update": ""
                                ]
                            )
                            XCTFail()
                        }
                        catch _ as TestUpdateError {
                            
                            errorExpectation.fulfill()
                            XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 6)
                            
                            let existingObjects = transaction.fetchAll(From<TestEntity1>(), Where(#keyPath(TestEntity1.testEntityID), isEqualTo: 105))
                            XCTAssertNotNil(existingObjects)
                            XCTAssertEqual(existingObjects?.count, 1)
                            
                            let existingObject = existingObjects?[0]
                            XCTAssertNotNil(existingObject)
                            XCTAssertEqual(existingObject?.testEntityID, NSNumber(value: 105))
                            XCTAssertEqual(existingObject?.testBoolean, NSNumber(value: true))
                            XCTAssertEqual(existingObject?.testNumber, NSNumber(value: 5))
                            XCTAssertEqual(existingObject?.testDecimal, NSDecimalNumber(string: "5"))
                            XCTAssertEqual(existingObject?.testString, "nil:TestEntity1:5")
                            XCTAssertEqual(existingObject?.testData, ("nil:TestEntity1:5" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                            XCTAssertEqual(existingObject?.testDate, self.dateFormatter.date(from: "2000-01-05T00:00:00Z")!)
                        }
                        self.checkExpectationsImmediately()
                    }
                )
            }
            catch {
                
                XCTFail()
            }
        }
    }

    @objc
    dynamic func test_ThatImportUniqueObject_CanImportCorrectly() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            do {
                
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        do {
                            
                            let object = try transaction.importUniqueObject(
                                Into<TestEntity1>(),
                                source: [
                                    #keyPath(TestEntity1.testEntityID): NSNumber(value: 106),
                                    #keyPath(TestEntity1.testBoolean): NSNumber(value: true),
                                    #keyPath(TestEntity1.testNumber): NSNumber(value: 6),
                                    #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "6"),
                                    #keyPath(TestEntity1.testString): "nil:TestEntity1:6",
                                    #keyPath(TestEntity1.testData): ("nil:TestEntity1:6" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                    #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-06T00:00:00Z")!
                                ]
                            )
                            XCTAssertNotNil(object)
                            XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 6)
                            
                            XCTAssertEqual(object?.testEntityID, NSNumber(value: 106))
                            XCTAssertEqual(object?.testBoolean, NSNumber(value: true))
                            XCTAssertEqual(object?.testNumber, NSNumber(value: 6))
                            XCTAssertEqual(object?.testDecimal, NSDecimalNumber(string: "6"))
                            XCTAssertEqual(object?.testString, "nil:TestEntity1:6")
                            XCTAssertEqual(object?.testData, ("nil:TestEntity1:6" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                            XCTAssertEqual(object?.testDate, self.dateFormatter.date(from: "2000-01-06T00:00:00Z")!)
                        }
                        do {
                            
                            let object = try transaction.importUniqueObject(
                                Into<TestEntity1>(),
                                source: [
                                    #keyPath(TestEntity1.testEntityID): NSNumber(value: 106),
                                    #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                                    #keyPath(TestEntity1.testNumber): NSNumber(value: 7),
                                    #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "7"),
                                    #keyPath(TestEntity1.testString): "nil:TestEntity1:7",
                                    #keyPath(TestEntity1.testData): ("nil:TestEntity1:7" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                    #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-07T00:00:00Z")!,
                                    ]
                            )
                            XCTAssertNotNil(object)
                            XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 6)
                            
                            XCTAssertEqual(object?.testEntityID, NSNumber(value: 106))
                            XCTAssertEqual(object?.testBoolean, NSNumber(value: false))
                            XCTAssertEqual(object?.testNumber, NSNumber(value: 7))
                            XCTAssertEqual(object?.testDecimal, NSDecimalNumber(string: "7"))
                            XCTAssertEqual(object?.testString, "nil:TestEntity1:7")
                            XCTAssertEqual(object?.testData, ("nil:TestEntity1:7" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                            XCTAssertEqual(object?.testDate, self.dateFormatter.date(from: "2000-01-07T00:00:00Z")!)
                            
                            let existingObjects = transaction.fetchAll(From<TestEntity1>(), Where(#keyPath(TestEntity1.testEntityID), isEqualTo: 106))
                            XCTAssertNotNil(existingObjects)
                            XCTAssertEqual(existingObjects?.count, 1)
                            
                            let existingObject = existingObjects?[0]
                            XCTAssertEqual(existingObject, object)
                        }
                    }
                )
            }
            catch {
                
                XCTFail()
            }
        }
    }

    @objc
    dynamic func test_ThatImportUniqueObjects_CanSkipImport() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            do {
                
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        let sourceArray: [TestEntity1.ImportSource] = [
                            [
                                #keyPath(TestEntity1.testEntityID): NSNumber(value: 106),
                                #keyPath(TestEntity1.testBoolean): NSNumber(value: true),
                                #keyPath(TestEntity1.testNumber): NSNumber(value: 6),
                                #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "6"),
                                #keyPath(TestEntity1.testString): "nil:TestEntity1:6",
                                #keyPath(TestEntity1.testData): ("nil:TestEntity1:6" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-06T00:00:00Z")!,
                                "skip_insert": ""
                            ],
                            [
                                #keyPath(TestEntity1.testEntityID): NSNumber(value: 107),
                                #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                                #keyPath(TestEntity1.testNumber): NSNumber(value: 7),
                                #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "7"),
                                #keyPath(TestEntity1.testString): "nil:TestEntity1:7",
                                #keyPath(TestEntity1.testData): ("nil:TestEntity1:7" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-07T00:00:00Z")!
                            ]
                        ]
                        let objects = try transaction.importUniqueObjects(
                            Into<TestEntity1>(),
                            sourceArray: sourceArray
                        )
                        XCTAssertEqual(objects.count, 1)
                        XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 6)
                        
                        let object = objects[0]
                        let dictionary = sourceArray[1]
                        XCTAssertEqual(object.testEntityID, dictionary[(#keyPath(TestEntity1.testEntityID))] as? NSNumber)
                        XCTAssertEqual(object.testBoolean, dictionary[(#keyPath(TestEntity1.testBoolean))] as? NSNumber)
                        XCTAssertEqual(object.testNumber, dictionary[(#keyPath(TestEntity1.testNumber))] as? NSNumber)
                        XCTAssertEqual(object.testDecimal, dictionary[(#keyPath(TestEntity1.testDecimal))] as? NSDecimalNumber)
                        XCTAssertEqual(object.testString, dictionary[(#keyPath(TestEntity1.testString))] as? String)
                        XCTAssertEqual(object.testData, dictionary[(#keyPath(TestEntity1.testData))] as? Data)
                        XCTAssertEqual(object.testDate, dictionary[(#keyPath(TestEntity1.testDate))] as? Date)
                    }
                )
            }
            catch {
                
                XCTFail()
            }
        }
    }

    @objc
    dynamic func test_ThatImportUniqueObjects_CanThrowError() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            do {
                
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        let errorExpectation = self.expectation(description: "error")
                        do {
                            
                            let sourceArray: [TestEntity1.ImportSource] = [
                                [
                                    #keyPath(TestEntity1.testEntityID): NSNumber(value: 106),
                                    #keyPath(TestEntity1.testBoolean): NSNumber(value: true),
                                    #keyPath(TestEntity1.testNumber): NSNumber(value: 6),
                                    #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "6"),
                                    #keyPath(TestEntity1.testString): "nil:TestEntity1:6",
                                    #keyPath(TestEntity1.testData): ("nil:TestEntity1:6" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                    #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-06T00:00:00Z")!,
                                    "throw_on_id": ""
                                ],
                                [
                                    #keyPath(TestEntity1.testEntityID): NSNumber(value: 107),
                                    #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                                    #keyPath(TestEntity1.testNumber): NSNumber(value: 7),
                                    #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "7"),
                                    #keyPath(TestEntity1.testString): "nil:TestEntity1:7",
                                    #keyPath(TestEntity1.testData): ("nil:TestEntity1:7" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                    #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-07T00:00:00Z")!
                                ]
                            ]
                            let _ = try transaction.importUniqueObjects(
                                Into<TestEntity1>(),
                                sourceArray: sourceArray
                            )
                            XCTFail()
                        }
                        catch _ as TestIDError {
                            
                            errorExpectation.fulfill()
                            XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 5)
                            
                            XCTAssertNil(transaction.fetchOne(From<TestEntity1>(), Where(#keyPath(TestEntity1.testEntityID), isEqualTo: 106)))
                            XCTAssertNil(transaction.fetchOne(From<TestEntity1>(), Where(#keyPath(TestEntity1.testEntityID), isEqualTo: 107)))
                        }
                        transaction.unsafeContext().reset()
                        self.checkExpectationsImmediately()
                    }
                )
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        let errorExpectation = self.expectation(description: "error")
                        do {
                            
                            let sourceArray: [TestEntity1.ImportSource] = [
                                [
                                    #keyPath(TestEntity1.testEntityID): NSNumber(value: 106),
                                    #keyPath(TestEntity1.testBoolean): NSNumber(value: true),
                                    #keyPath(TestEntity1.testNumber): NSNumber(value: 6),
                                    #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "6"),
                                    #keyPath(TestEntity1.testString): "nil:TestEntity1:6",
                                    #keyPath(TestEntity1.testData): ("nil:TestEntity1:6" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                    #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-06T00:00:00Z")!,
                                    "throw_on_insert": ""
                                ],
                                [
                                    #keyPath(TestEntity1.testEntityID): NSNumber(value: 107),
                                    #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                                    #keyPath(TestEntity1.testNumber): NSNumber(value: 7),
                                    #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "7"),
                                    #keyPath(TestEntity1.testString): "nil:TestEntity1:7",
                                    #keyPath(TestEntity1.testData): ("nil:TestEntity1:7" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                    #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-07T00:00:00Z")!
                                ]
                            ]
                            let _ = try transaction.importUniqueObjects(
                                Into<TestEntity1>(),
                                sourceArray: sourceArray
                            )
                            XCTFail()
                        }
                        catch _ as TestInsertError {
                            
                            errorExpectation.fulfill()
                            
                            let object = transaction.fetchOne(From<TestEntity1>(), Where(#keyPath(TestEntity1.testEntityID), isEqualTo: 106))
                            XCTAssertNotNil(object)
                            XCTAssertEqual(object?.testEntityID, NSNumber(value: 106))
                            XCTAssertNil(object?.testBoolean)
                            XCTAssertNil(object?.testNumber)
                            XCTAssertNil(object?.testDecimal)
                            XCTAssertNil(object?.testString)
                            XCTAssertNil(object?.testData)
                            XCTAssertNil(object?.testDate)
                        }
                        transaction.context.reset()
                        self.checkExpectationsImmediately()
                    }
                )
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        let errorExpectation = self.expectation(description: "error")
                        do {
                            
                            let sourceArray: [TestEntity1.ImportSource] = [
                                [
                                    #keyPath(TestEntity1.testEntityID): NSNumber(value: 105),
                                    #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                                    #keyPath(TestEntity1.testNumber): NSNumber(value: 6),
                                    #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "6"),
                                    #keyPath(TestEntity1.testString): "nil:TestEntity1:6",
                                    #keyPath(TestEntity1.testData): ("nil:TestEntity1:6" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                    #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-06T00:00:00Z")!,
                                    "throw_on_update": ""
                                ]
                            ]
                            let _ = try transaction.importUniqueObjects(
                                Into<TestEntity1>(),
                                sourceArray: sourceArray
                            )
                            XCTFail()
                        }
                        catch _ as TestUpdateError {
                            
                            errorExpectation.fulfill()
                            XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 5)
                            
                            let object = transaction.fetchOne(From<TestEntity1>(), Where(#keyPath(TestEntity1.testEntityID), isEqualTo: 105))
                            XCTAssertNotNil(object)
                            XCTAssertEqual(object?.testEntityID, NSNumber(value: 105))
                            XCTAssertEqual(object?.testBoolean, NSNumber(value: true))
                            XCTAssertEqual(object?.testNumber, NSNumber(value: 5))
                            XCTAssertEqual(object?.testDecimal, NSDecimalNumber(string: "5"))
                            XCTAssertEqual(object?.testString, "nil:TestEntity1:5")
                            XCTAssertEqual(object?.testData, ("nil:TestEntity1:5" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                            XCTAssertEqual(object?.testDate, self.dateFormatter.date(from: "2000-01-05T00:00:00Z")!)
                            
                            let existingObjects = transaction.fetchAll(From<TestEntity1>(), Where(#keyPath(TestEntity1.testEntityID), isEqualTo: 105))
                            XCTAssertNotNil(existingObjects)
                            XCTAssertEqual(existingObjects?.count, 1)
                            
                            let existingObject = existingObjects?[0]
                            XCTAssertEqual(existingObject, object)
                        }
                        transaction.context.reset()
                        self.checkExpectationsImmediately()
                    }
                )
            }
            catch {
                
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatImportUniqueObjects_CanImportCorrectly() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            do {
                
                try stack.perform(
                    synchronous: { (transaction) in
                        
                        let sourceArray: [TestEntity1.ImportSource] = [
                            [
                                #keyPath(TestEntity1.testEntityID): NSNumber(value: 105),
                                #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                                #keyPath(TestEntity1.testNumber): NSNumber(value: 15),
                                #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "15"),
                                #keyPath(TestEntity1.testString): "nil:TestEntity1:15",
                                #keyPath(TestEntity1.testData): ("nil:TestEntity1:15" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-15T00:00:00Z")!
                            ],
                            [
                                #keyPath(TestEntity1.testEntityID): NSNumber(value: 106),
                                #keyPath(TestEntity1.testBoolean): NSNumber(value: false),
                                #keyPath(TestEntity1.testNumber): NSNumber(value: 6),
                                #keyPath(TestEntity1.testDecimal): NSDecimalNumber(string: "6"),
                                #keyPath(TestEntity1.testString): "nil:TestEntity1:6",
                                #keyPath(TestEntity1.testData): ("nil:TestEntity1:6" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                                #keyPath(TestEntity1.testDate): self.dateFormatter.date(from: "2000-01-06T00:00:00Z")!
                            ]
                        ]
                        let objects = try transaction.importUniqueObjects(
                            Into<TestEntity1>(),
                            sourceArray: sourceArray
                        )
                        XCTAssertEqual(objects.count, sourceArray.count)
                        XCTAssertEqual(transaction.fetchCount(From<TestEntity1>()), 6)
                        for i in 0 ..< sourceArray.count {
                            
                            let object = objects[i]
                            let dictionary = sourceArray[i]
                            
                            XCTAssertEqual(object.testEntityID, dictionary[(#keyPath(TestEntity1.testEntityID))] as? NSNumber)
                            XCTAssertEqual(object.testBoolean, dictionary[(#keyPath(TestEntity1.testBoolean))] as? NSNumber)
                            XCTAssertEqual(object.testNumber, dictionary[(#keyPath(TestEntity1.testNumber))] as? NSNumber)
                            XCTAssertEqual(object.testDecimal, dictionary[(#keyPath(TestEntity1.testDecimal))] as? NSDecimalNumber)
                            XCTAssertEqual(object.testString, dictionary[(#keyPath(TestEntity1.testString))] as? String)
                            XCTAssertEqual(object.testData, dictionary[(#keyPath(TestEntity1.testData))] as? Data)
                            XCTAssertEqual(object.testDate, dictionary[(#keyPath(TestEntity1.testDate))] as? Date)
                        }
                        let existingObjects = transaction.fetchAll(From<TestEntity1>(), Where(#keyPath(TestEntity1.testEntityID), isEqualTo: 105))
                        XCTAssertNotNil(existingObjects)
                        XCTAssertEqual(existingObjects?.count, 1)
                        
                        let existingObject = existingObjects?[0]
                        XCTAssertEqual(existingObject, objects[0])
                    }
                )
            }
            catch {
                
                XCTFail()
            }
        }
    }
}


// MARK: - TestInsertError

private struct TestInsertError: Error {}


// MARK: - TestUpdateError

private struct TestUpdateError: Error {}


// MARK: - TestIDError

private struct TestIDError: Error {}


// MARK: - TestEntity1

extension TestEntity1: ImportableUniqueObject {
    
    // MARK: ImportableObject
    
    typealias ImportSource = [String: Any]
    
    static func shouldInsert(from source: ImportSource, in transaction: BaseDataTransaction) -> Bool {
        
        return source["skip_insert"] == nil
    }
    
    func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        
        if let _ = source["throw_on_insert"] {
            
            throw TestInsertError()
        }
        self.testBoolean = source[(#keyPath(TestEntity1.testBoolean))] as? NSNumber
        self.testNumber = source[(#keyPath(TestEntity1.testNumber))] as? NSNumber
        self.testDecimal = source[(#keyPath(TestEntity1.testDecimal))] as? NSDecimalNumber
        self.testString = source[(#keyPath(TestEntity1.testString))] as? String
        self.testData = source[(#keyPath(TestEntity1.testData))] as? Data
        self.testDate = source[(#keyPath(TestEntity1.testDate))] as? Date
        self.testNil = nil
    }
    
    
    // MARK: ImportableUniqueObject
    
    typealias UniqueIDType = Int64
    
    static var uniqueIDKeyPath: String {
        
        return #keyPath(TestEntity1.testEntityID)
    }
    
    static func shouldUpdate(from source: ImportSource, in transaction: BaseDataTransaction) -> Bool {
        
        return source["skip_update"] == nil
    }
    
    static func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> Int64? {
        
        if let _ = source["throw_on_id"] {
            
            throw TestIDError()
        }
        return source[(#keyPath(TestEntity1.testEntityID))] as? Int64
    }
    
    func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        
        if let _ = source["throw_on_update"] {
            
            throw TestUpdateError()
        }
        self.testBoolean = source[(#keyPath(TestEntity1.testBoolean))] as? NSNumber
        self.testNumber = source[(#keyPath(TestEntity1.testNumber))] as? NSNumber
        self.testDecimal = source[(#keyPath(TestEntity1.testDecimal))] as? NSDecimalNumber
        self.testString = source[(#keyPath(TestEntity1.testString))] as? String
        self.testData = source[(#keyPath(TestEntity1.testData))] as? Data
        self.testDate = source[(#keyPath(TestEntity1.testDate))] as? Date
        self.testNil = nil
    }
}
