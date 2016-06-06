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

final class FetchTests: BaseTestCase {
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchOneFromDefaultConfiguration() {
        
        let configurations: [String?] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            do {
                
                let object2 = stack.fetchOne(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testString, "nil:TestEntity1:2")
                
                let object3 = stack.fetchOne(
                    From(TestEntity1),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testString, "nil:TestEntity1:3")
                
                let nilObject = stack.fetchOne(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
            do {
                
                let object2 = stack.fetchOne(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testString, "nil:TestEntity1:2")
                
                let object3 = stack.fetchOne(
                    From<TestEntity1>(nil),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testString, "nil:TestEntity1:3")
                
                let nilObject = stack.fetchOne(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
            do {
                
                let nilObject1 = stack.fetchOne(
                    From<TestEntity1>("Config1"),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject1)
                
                let nilObject2 = stack.fetchOne(
                    From<TestEntity1>("Config1"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNil(nilObject2)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchOneFromSingleConfiguration() {
        
        let configurations: [String?] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            do {
                
                let object2 = stack.fetchOne(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testNumber, 2) // configuration ambiguous
                
                let object3 = stack.fetchOne(
                    From(TestEntity1),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testNumber, 3) // configuration ambiguous
                
                let nilObject = stack.fetchOne(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
            do {
                
                let object2 = stack.fetchOne(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testString, "nil:TestEntity1:2")
                
                let object3 = stack.fetchOne(
                    From<TestEntity1>(nil),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testString, "nil:TestEntity1:3")
                
                let nilObject = stack.fetchOne(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
            do {
                
                let object2 = stack.fetchOne(
                    From<TestEntity1>("Config1"),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testString, "Config1:TestEntity1:2")
                
                let object3 = stack.fetchOne(
                    From<TestEntity1>("Config1"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testString, "Config1:TestEntity1:3")
                
                let nilObject = stack.fetchOne(
                    From<TestEntity1>("Config1"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
            do {
                
                let nilObject1 = stack.fetchOne(
                    From<TestEntity1>("Config2"),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject1)
                
                let nilObject2 = stack.fetchOne(
                    From<TestEntity1>("Config2"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNil(nilObject2)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchOneFromMultipleConfigurations() {
        
        let configurations: [String?] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            do {
                
                let object2 = stack.fetchOne(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testNumber, 2) // configuration is ambiguous
                
                let object3 = stack.fetchOne(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testNumber, 3) // configuration is ambiguous
                
                let nilObject = stack.fetchOne(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
            do {
                
                let object2 = stack.fetchOne(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testString, "nil:TestEntity1:2")
                
                let object3 = stack.fetchOne(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testString, "nil:TestEntity1:3")
                
                let nilObject = stack.fetchOne(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
            do {
                
                let object2 = stack.fetchOne(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testString, "Config1:TestEntity1:2")
                
                let object3 = stack.fetchOne(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testString, "Config1:TestEntity1:3")
                
                let nilObject = stack.fetchOne(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchAllFromDefaultConfiguration() {
        
        let configurations: [String?] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            do {
                
                let objects2to4 = stack.fetchAll(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to4)
                XCTAssertEqual(objects2to4?.count, 3)
                XCTAssertEqual(
                    (objects2to4 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:2",
                        "nil:TestEntity1:3",
                        "nil:TestEntity1:4"
                    ]
                )
                
                let objects4to2 = stack.fetchAll(
                    From(TestEntity1),
                    Where("%K < %@", "testNumber", 5),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to2)
                XCTAssertEqual(objects4to2?.count, 3)
                XCTAssertEqual(
                    (objects4to2 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:4",
                        "nil:TestEntity1:3",
                        "nil:TestEntity1:2"
                    ]
                )
                
                let emptyObjects = stack.fetchAll(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
            do {
                
                let objects2to4 = stack.fetchAll(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to4)
                XCTAssertEqual(objects2to4?.count, 3)
                XCTAssertEqual(
                    (objects2to4 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:2",
                        "nil:TestEntity1:3",
                        "nil:TestEntity1:4"
                    ]
                )
                
                let objects4to2 = stack.fetchAll(
                    From<TestEntity1>(nil),
                    Where("%K < %@", "testNumber", 5),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to2)
                XCTAssertEqual(objects4to2?.count, 3)
                XCTAssertEqual(
                    (objects4to2 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:4",
                        "nil:TestEntity1:3",
                        "nil:TestEntity1:2"
                    ]
                )
                
                let emptyObjects = stack.fetchAll(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
            do {
                
                let nilObject1 = stack.fetchAll(
                    From<TestEntity1>("Config1"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject1)
                
                let nilObject2 = stack.fetchAll(
                    From<TestEntity1>("Config1"),
                    Where("testNumber", isEqualTo: 0),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNil(nilObject2)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchAllFromSingleConfiguration() {
        
        let configurations: [String?] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            do {
                
                let objects4to5 = stack.fetchAll(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to5)
                XCTAssertEqual(objects4to5?.count, 3)
                XCTAssertEqual(
                    Set((objects4to5 ?? []).map { $0.testNumber!.integerValue }),
                    [4, 5] as Set<Int>
                ) // configuration is ambiguous
                
                let objects2to1 = stack.fetchAll(
                    From(TestEntity1),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to1)
                XCTAssertEqual(objects2to1?.count, 3)
                XCTAssertEqual(
                    Set((objects2to1 ?? []).map { $0.testNumber!.integerValue }),
                    [1, 2] as Set<Int>
                ) // configuration is ambiguous
                
                let emptyObjects = stack.fetchAll(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
            do {
                
                let objects4to5 = stack.fetchAll(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to5)
                XCTAssertEqual(objects4to5?.count, 2)
                XCTAssertEqual(
                    (objects4to5 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:4",
                        "nil:TestEntity1:5"
                    ]
                )
                
                let objects2to1 = stack.fetchAll(
                    From<TestEntity1>(nil),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to1)
                XCTAssertEqual(objects2to1?.count, 2)
                XCTAssertEqual(
                    (objects2to1 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:2",
                        "nil:TestEntity1:1"
                    ]
                )
                
                let emptyObjects = stack.fetchAll(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
            do {
                
                let objects4to5 = stack.fetchAll(
                    From<TestEntity1>("Config1"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to5)
                XCTAssertEqual(objects4to5?.count, 2)
                XCTAssertEqual(
                    (objects4to5 ?? []).map { $0.testString ?? "" },
                    [
                        "Config1:TestEntity1:4",
                        "Config1:TestEntity1:5"
                    ]
                )
                
                let objects2to1 = stack.fetchAll(
                    From<TestEntity1>("Config1"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to1)
                XCTAssertEqual(objects2to1?.count, 2)
                XCTAssertEqual(
                    (objects2to1 ?? []).map { $0.testString ?? "" },
                    [
                        "Config1:TestEntity1:2",
                        "Config1:TestEntity1:1"
                    ]
                )
                
                let emptyObjects = stack.fetchAll(
                    From<TestEntity1>("Config1"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
            do {
                
                let object1 = stack.fetchOne(
                    From<TestEntity1>("Config2"),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(object1)
                
                let object5 = stack.fetchOne(
                    From<TestEntity1>("Config2"),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNil(object5)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchAllFromMultipleConfigurations() {
        
        let configurations: [String?] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            do {
                
                let objects4to5 = stack.fetchAll(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to5)
                XCTAssertEqual(objects4to5?.count, 3)
                XCTAssertEqual(
                    Set((objects4to5 ?? []).map { $0.testNumber!.integerValue }),
                    [4, 5] as Set<Int>
                ) // configuration is ambiguous
                
                let objects2to1 = stack.fetchAll(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to1)
                XCTAssertEqual(objects2to1?.count, 3)
                XCTAssertEqual(
                    Set((objects2to1 ?? []).map { $0.testNumber!.integerValue }),
                    [1, 2] as Set<Int>
                ) // configuration is ambiguous
                
                let emptyObjects = stack.fetchAll(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
            do {
                
                let objects4to5 = stack.fetchAll(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to5)
                XCTAssertEqual(objects4to5?.count, 2)
                XCTAssertEqual(
                    (objects4to5 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:4",
                        "nil:TestEntity1:5"
                    ]
                )
                
                let objects2to1 = stack.fetchAll(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to1)
                XCTAssertEqual(objects2to1?.count, 2)
                XCTAssertEqual(
                    (objects2to1 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:2",
                        "nil:TestEntity1:1"
                    ]
                )
                
                let emptyObjects = stack.fetchAll(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
            do {
                
                let objects4to5 = stack.fetchAll(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to5)
                XCTAssertEqual(objects4to5?.count, 2)
                XCTAssertEqual(
                    (objects4to5 ?? []).map { $0.testString ?? "" },
                    [
                        "Config1:TestEntity1:4",
                        "Config1:TestEntity1:5"
                    ]
                )
                
                let objects2to1 = stack.fetchAll(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to1)
                XCTAssertEqual(objects2to1?.count, 2)
                XCTAssertEqual(
                    (objects2to1 ?? []).map { $0.testString ?? "" },
                    [
                        "Config1:TestEntity1:2",
                        "Config1:TestEntity1:1"
                    ]
                )
                
                let emptyObjects = stack.fetchAll(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchCountFromDefaultConfiguration() {
        
        let configurations: [String?] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            do {
                
                let count2to4 = stack.fetchCount(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to4)
                XCTAssertEqual(count2to4, 3)
                
                let count4to2 = stack.fetchCount(
                    From(TestEntity1),
                    Where("%K < %@", "testNumber", 5),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to2)
                XCTAssertEqual(count4to2, 3)
                
                let emptyCount = stack.fetchCount(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
            do {
                
                let count2to4 = stack.fetchCount(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to4)
                XCTAssertEqual(count2to4, 3)
                
                let count4to2 = stack.fetchCount(
                    From<TestEntity1>(nil),
                    Where("%K < %@", "testNumber", 5),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to2)
                XCTAssertEqual(count4to2, 3)
                
                let emptyCount = stack.fetchCount(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
            do {
                
                let nilCount1 = stack.fetchCount(
                    From<TestEntity1>("Config1"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilCount1)
                
                let nilCount2 = stack.fetchCount(
                    From<TestEntity1>("Config1"),
                    Where("testNumber", isEqualTo: 0),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNil(nilCount2)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchCountFromSingleConfiguration() {
        
        let configurations: [String?] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            do {
                
                let count4to5 = stack.fetchCount(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to5)
                XCTAssertEqual(count4to5, 3)
                
                let count2to1 = stack.fetchCount(
                    From(TestEntity1),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to1)
                XCTAssertEqual(count2to1, 3)
                
                let emptyCount = stack.fetchCount(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
            do {
                
                let count4to5 = stack.fetchCount(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to5)
                XCTAssertEqual(count4to5, 2)
                
                let count2to1 = stack.fetchCount(
                    From<TestEntity1>(nil),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to1)
                XCTAssertEqual(count2to1, 2)
                
                let emptyCount = stack.fetchCount(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
            do {
                
                let count4to5 = stack.fetchCount(
                    From<TestEntity1>("Config1"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to5)
                XCTAssertEqual(count4to5, 2)
                
                let count2to1 = stack.fetchCount(
                    From<TestEntity1>("Config1"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to1)
                XCTAssertEqual(count2to1, 2)
                
                let emptyCount = stack.fetchCount(
                    From<TestEntity1>("Config1"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
            do {
                
                let nilCount1 = stack.fetchCount(
                    From<TestEntity1>("Config2"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilCount1)
                
                let nilCount2 = stack.fetchCount(
                    From<TestEntity1>("Config2"),
                    Where("testNumber", isEqualTo: 0),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNil(nilCount2)
            }
        }
    }
    
    @objc
    dynamic func test_ThatDataStacks_CanFetchCountFromMultipleConfigurations() {
        
        let configurations: [String?] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            do {
                
                let count4to5 = stack.fetchCount(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to5)
                XCTAssertEqual(count4to5, 3)
                
                let count2to1 = stack.fetchCount(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to1)
                XCTAssertEqual(count2to1, 3)
                
                let emptyCount = stack.fetchCount(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
            do {
                
                let count4to5 = stack.fetchCount(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to5)
                XCTAssertEqual(count4to5, 2)
                
                let count2to1 = stack.fetchCount(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to1)
                XCTAssertEqual(count2to1, 2)
                
                let emptyCount = stack.fetchCount(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
            do {
                
                let count4to5 = stack.fetchCount(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to5)
                XCTAssertEqual(count4to5, 2)
                
                let count2to1 = stack.fetchCount(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to1)
                XCTAssertEqual(count2to1, 2)
                
                let emptyCount = stack.fetchCount(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchOneFromDefaultConfiguration() {
        
        let configurations: [String?] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            stack.beginSynchronous { (transaction) in
                
                let object2 = transaction.fetchOne(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testString, "nil:TestEntity1:2")
                
                let object3 = transaction.fetchOne(
                    From(TestEntity1),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testString, "nil:TestEntity1:3")
                
                let nilObject = transaction.fetchOne(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
            stack.beginSynchronous { (transaction) in
                
                let object2 = transaction.fetchOne(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testString, "nil:TestEntity1:2")
                
                let object3 = transaction.fetchOne(
                    From<TestEntity1>(nil),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testString, "nil:TestEntity1:3")
                
                let nilObject = transaction.fetchOne(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
            stack.beginSynchronous { (transaction) in
                
                let nilObject1 = transaction.fetchOne(
                    From<TestEntity1>("Config1"),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject1)
                
                let nilObject2 = transaction.fetchOne(
                    From<TestEntity1>("Config1"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNil(nilObject2)
            }
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchOneFromSingleConfiguration() {
        
        let configurations: [String?] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            stack.beginSynchronous { (transaction) in
                
                let object2 = transaction.fetchOne(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testNumber, 2) // configuration ambiguous
                
                let object3 = transaction.fetchOne(
                    From(TestEntity1),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testNumber, 3) // configuration ambiguous
                
                let nilObject = transaction.fetchOne(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
            stack.beginSynchronous { (transaction) in
                
                let object2 = transaction.fetchOne(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testString, "nil:TestEntity1:2")
                
                let object3 = transaction.fetchOne(
                    From<TestEntity1>(nil),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testString, "nil:TestEntity1:3")
                
                let nilObject = transaction.fetchOne(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
            stack.beginSynchronous { (transaction) in
                
                let object2 = transaction.fetchOne(
                    From<TestEntity1>("Config1"),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testString, "Config1:TestEntity1:2")
                
                let object3 = transaction.fetchOne(
                    From<TestEntity1>("Config1"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testString, "Config1:TestEntity1:3")
                
                let nilObject = transaction.fetchOne(
                    From<TestEntity1>("Config1"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
            stack.beginSynchronous { (transaction) in
                
                let nilObject1 = transaction.fetchOne(
                    From<TestEntity1>("Config2"),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject1)
                
                let nilObject2 = transaction.fetchOne(
                    From<TestEntity1>("Config2"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNil(nilObject2)
            }
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchOneFromMultipleConfigurations() {
        
        let configurations: [String?] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            stack.beginSynchronous { (transaction) in
                
                let object2 = transaction.fetchOne(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testNumber, 2) // configuration is ambiguous
                
                let object3 = transaction.fetchOne(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testNumber, 3) // configuration is ambiguous
                
                let nilObject = transaction.fetchOne(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
            stack.beginSynchronous { (transaction) in
                
                let object2 = transaction.fetchOne(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testString, "nil:TestEntity1:2")
                
                let object3 = transaction.fetchOne(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testString, "nil:TestEntity1:3")
                
                let nilObject = transaction.fetchOne(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
            stack.beginSynchronous { (transaction) in
                
                let object2 = transaction.fetchOne(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(object2)
                XCTAssertEqual(object2?.testString, "Config1:TestEntity1:2")
                
                let object3 = transaction.fetchOne(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNotNil(object3)
                XCTAssertEqual(object3?.testString, "Config1:TestEntity1:3")
                
                let nilObject = transaction.fetchOne(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject)
            }
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchAllFromDefaultConfiguration() {
        
        let configurations: [String?] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            stack.beginSynchronous { (transaction) in
                
                let objects2to4 = transaction.fetchAll(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to4)
                XCTAssertEqual(objects2to4?.count, 3)
                XCTAssertEqual(
                    (objects2to4 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:2",
                        "nil:TestEntity1:3",
                        "nil:TestEntity1:4"
                    ]
                )
                
                let objects4to2 = transaction.fetchAll(
                    From(TestEntity1),
                    Where("%K < %@", "testNumber", 5),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to2)
                XCTAssertEqual(objects4to2?.count, 3)
                XCTAssertEqual(
                    (objects4to2 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:4",
                        "nil:TestEntity1:3",
                        "nil:TestEntity1:2"
                    ]
                )
                
                let emptyObjects = transaction.fetchAll(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
            stack.beginSynchronous { (transaction) in
                
                let objects2to4 = transaction.fetchAll(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to4)
                XCTAssertEqual(objects2to4?.count, 3)
                XCTAssertEqual(
                    (objects2to4 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:2",
                        "nil:TestEntity1:3",
                        "nil:TestEntity1:4"
                    ]
                )
                
                let objects4to2 = transaction.fetchAll(
                    From<TestEntity1>(nil),
                    Where("%K < %@", "testNumber", 5),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to2)
                XCTAssertEqual(objects4to2?.count, 3)
                XCTAssertEqual(
                    (objects4to2 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:4",
                        "nil:TestEntity1:3",
                        "nil:TestEntity1:2"
                    ]
                )
                
                let emptyObjects = transaction.fetchAll(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
            stack.beginSynchronous { (transaction) in
                
                let nilObject1 = transaction.fetchAll(
                    From<TestEntity1>("Config1"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilObject1)
                
                let nilObject2 = transaction.fetchAll(
                    From<TestEntity1>("Config1"),
                    Where("testNumber", isEqualTo: 0),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNil(nilObject2)
            }
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchAllFromSingleConfiguration() {
        
        let configurations: [String?] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            stack.beginSynchronous { (transaction) in
                
                let objects4to5 = transaction.fetchAll(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to5)
                XCTAssertEqual(objects4to5?.count, 3)
                XCTAssertEqual(
                    Set((objects4to5 ?? []).map { $0.testNumber!.integerValue }),
                    [4, 5] as Set<Int>
                ) // configuration is ambiguous
                
                let objects2to1 = transaction.fetchAll(
                    From(TestEntity1),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to1)
                XCTAssertEqual(objects2to1?.count, 3)
                XCTAssertEqual(
                    Set((objects2to1 ?? []).map { $0.testNumber!.integerValue }),
                    [1, 2] as Set<Int>
                ) // configuration is ambiguous
                
                let emptyObjects = transaction.fetchAll(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
            stack.beginSynchronous { (transaction) in
                
                let objects4to5 = transaction.fetchAll(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to5)
                XCTAssertEqual(objects4to5?.count, 2)
                XCTAssertEqual(
                    (objects4to5 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:4",
                        "nil:TestEntity1:5"
                    ]
                )
                
                let objects2to1 = transaction.fetchAll(
                    From<TestEntity1>(nil),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to1)
                XCTAssertEqual(objects2to1?.count, 2)
                XCTAssertEqual(
                    (objects2to1 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:2",
                        "nil:TestEntity1:1"
                    ]
                )
                
                let emptyObjects = transaction.fetchAll(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
            stack.beginSynchronous { (transaction) in
                
                let objects4to5 = transaction.fetchAll(
                    From<TestEntity1>("Config1"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to5)
                XCTAssertEqual(objects4to5?.count, 2)
                XCTAssertEqual(
                    (objects4to5 ?? []).map { $0.testString ?? "" },
                    [
                        "Config1:TestEntity1:4",
                        "Config1:TestEntity1:5"
                    ]
                )
                
                let objects2to1 = transaction.fetchAll(
                    From<TestEntity1>("Config1"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to1)
                XCTAssertEqual(objects2to1?.count, 2)
                XCTAssertEqual(
                    (objects2to1 ?? []).map { $0.testString ?? "" },
                    [
                        "Config1:TestEntity1:2",
                        "Config1:TestEntity1:1"
                    ]
                )
                
                let emptyObjects = transaction.fetchAll(
                    From<TestEntity1>("Config1"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
            stack.beginSynchronous { (transaction) in
                
                let object1 = transaction.fetchOne(
                    From<TestEntity1>("Config2"),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(object1)
                
                let object5 = transaction.fetchOne(
                    From<TestEntity1>("Config2"),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNil(object5)
            }
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchAllFromMultipleConfigurations() {
        
        let configurations: [String?] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            stack.beginSynchronous { (transaction) in
                
                let objects4to5 = transaction.fetchAll(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to5)
                XCTAssertEqual(objects4to5?.count, 3)
                XCTAssertEqual(
                    Set((objects4to5 ?? []).map { $0.testNumber!.integerValue }),
                    [4, 5] as Set<Int>
                ) // configuration is ambiguous
                
                let objects2to1 = transaction.fetchAll(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to1)
                XCTAssertEqual(objects2to1?.count, 3)
                XCTAssertEqual(
                    Set((objects2to1 ?? []).map { $0.testNumber!.integerValue }),
                    [1, 2] as Set<Int>
                ) // configuration is ambiguous
                
                let emptyObjects = transaction.fetchAll(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
            stack.beginSynchronous { (transaction) in
                
                let objects4to5 = transaction.fetchAll(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to5)
                XCTAssertEqual(objects4to5?.count, 2)
                XCTAssertEqual(
                    (objects4to5 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:4",
                        "nil:TestEntity1:5"
                    ]
                )
                
                let objects2to1 = transaction.fetchAll(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to1)
                XCTAssertEqual(objects2to1?.count, 2)
                XCTAssertEqual(
                    (objects2to1 ?? []).map { $0.testString ?? "" },
                    [
                        "nil:TestEntity1:2",
                        "nil:TestEntity1:1"
                    ]
                )
                
                let emptyObjects = transaction.fetchAll(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
            stack.beginSynchronous { (transaction) in
                
                let objects4to5 = transaction.fetchAll(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects4to5)
                XCTAssertEqual(objects4to5?.count, 2)
                XCTAssertEqual(
                    (objects4to5 ?? []).map { $0.testString ?? "" },
                    [
                        "Config1:TestEntity1:4",
                        "Config1:TestEntity1:5"
                    ]
                )
                
                let objects2to1 = transaction.fetchAll(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(objects2to1)
                XCTAssertEqual(objects2to1?.count, 2)
                XCTAssertEqual(
                    (objects2to1 ?? []).map { $0.testString ?? "" },
                    [
                        "Config1:TestEntity1:2",
                        "Config1:TestEntity1:1"
                    ]
                )
                
                let emptyObjects = transaction.fetchAll(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyObjects)
                XCTAssertEqual(emptyObjects?.count, 0)
            }
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchCountFromDefaultConfiguration() {
        
        let configurations: [String?] = [nil]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            stack.beginSynchronous { (transaction) in
                
                let count2to4 = transaction.fetchCount(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to4)
                XCTAssertEqual(count2to4, 3)
                
                let count4to2 = transaction.fetchCount(
                    From(TestEntity1),
                    Where("%K < %@", "testNumber", 5),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to2)
                XCTAssertEqual(count4to2, 3)
                
                let emptyCount = transaction.fetchCount(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
            stack.beginSynchronous { (transaction) in
                
                let count2to4 = transaction.fetchCount(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 1),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to4)
                XCTAssertEqual(count2to4, 3)
                
                let count4to2 = transaction.fetchCount(
                    From<TestEntity1>(nil),
                    Where("%K < %@", "testNumber", 5),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to2)
                XCTAssertEqual(count4to2, 3)
                
                let emptyCount = transaction.fetchCount(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
            stack.beginSynchronous { (transaction) in
                
                let nilCount1 = transaction.fetchCount(
                    From<TestEntity1>("Config1"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilCount1)
                
                let nilCount2 = transaction.fetchCount(
                    From<TestEntity1>("Config1"),
                    Where("testNumber", isEqualTo: 0),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNil(nilCount2)
            }
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchCountFromSingleConfiguration() {
        
        let configurations: [String?] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            stack.beginSynchronous { (transaction) in
                
                let count4to5 = transaction.fetchCount(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to5)
                XCTAssertEqual(count4to5, 3)
                
                let count2to1 = transaction.fetchCount(
                    From(TestEntity1),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to1)
                XCTAssertEqual(count2to1, 3)
                
                let emptyCount = transaction.fetchCount(
                    From(TestEntity1),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
            stack.beginSynchronous { (transaction) in
                
                let count4to5 = transaction.fetchCount(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to5)
                XCTAssertEqual(count4to5, 2)
                
                let count2to1 = transaction.fetchCount(
                    From<TestEntity1>(nil),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to1)
                XCTAssertEqual(count2to1, 2)
                
                let emptyCount = transaction.fetchCount(
                    From<TestEntity1>(nil),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
            stack.beginSynchronous { (transaction) in
                
                let count4to5 = transaction.fetchCount(
                    From<TestEntity1>("Config1"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to5)
                XCTAssertEqual(count4to5, 2)
                
                let count2to1 = transaction.fetchCount(
                    From<TestEntity1>("Config1"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to1)
                XCTAssertEqual(count2to1, 2)
                
                let emptyCount = transaction.fetchCount(
                    From<TestEntity1>("Config1"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
            stack.beginSynchronous { (transaction) in
                
                let nilCount1 = transaction.fetchCount(
                    From<TestEntity1>("Config2"),
                    Where("%K < %@", "testNumber", 4),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNil(nilCount1)
                
                let nilCount2 = transaction.fetchCount(
                    From<TestEntity1>("Config2"),
                    Where("testNumber", isEqualTo: 0),
                    OrderBy(.Descending("testEntityID"))
                )
                XCTAssertNil(nilCount2)
            }
        }
    }
    
    @objc
    dynamic func test_ThatTransactions_CanFetchCountFromMultipleConfigurations() {
        
        let configurations: [String?] = [nil, "Config1", "Config2"]
        self.prepareStack(configurations: configurations) { (stack) in
            
            self.prepareStubsForStack(stack, configurations: configurations)
            
            stack.beginSynchronous { (transaction) in
                
                let count4to5 = transaction.fetchCount(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to5)
                XCTAssertEqual(count4to5, 3)
                
                let count2to1 = transaction.fetchCount(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to1)
                XCTAssertEqual(count2to1, 3)
                
                let emptyCount = transaction.fetchCount(
                    From<TestEntity1>(nil, "Config1"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
            stack.beginSynchronous { (transaction) in
                
                let count4to5 = transaction.fetchCount(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to5)
                XCTAssertEqual(count4to5, 2)
                
                let count2to1 = transaction.fetchCount(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to1)
                XCTAssertEqual(count2to1, 2)
                
                let emptyCount = transaction.fetchCount(
                    From<TestEntity1>(nil, "Config2"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
            stack.beginSynchronous { (transaction) in
                
                let count4to5 = transaction.fetchCount(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K > %@", "testNumber", 3),
                    OrderBy(.Ascending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count4to5)
                XCTAssertEqual(count4to5, 2)
                
                let count2to1 = transaction.fetchCount(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K < %@", "testNumber", 3),
                    OrderBy(.Descending("testEntityID")),
                    Tweak { $0.fetchLimit = 3 }
                )
                XCTAssertNotNil(count2to1)
                XCTAssertEqual(count2to1, 2)
                
                let emptyCount = transaction.fetchCount(
                    From<TestEntity1>("Config1", "Config2"),
                    Where("%K > %@", "testNumber", 5),
                    OrderBy(.Ascending("testEntityID"))
                )
                XCTAssertNotNil(emptyCount)
                XCTAssertEqual(emptyCount, 0)
            }
        }
    }
    
    
    // MARK: Private
    
    @nonobjc
    private let dateFormatter: NSDateFormatter = {

        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone(name: "UTC")
        formatter.calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        return formatter
    }()
    
    @nonobjc
    private func prepareStubsForStack(stack: DataStack, configurations: [String?]) {
        
        stack.beginSynchronous { (transaction) in
            
            for (configurationIndex, configuration) in configurations.enumerate() {
                
                if configuration == nil || configuration == "Config1" {
                    
                    for idIndex in 1 ... 5 {
                        
                        let object = transaction.create(Into<TestEntity1>(configuration))
                        object.testEntityID = NSNumber(integer: (configurationIndex * 100) + idIndex)
                        object.testString = "\(configuration ?? "nil"):TestEntity1:\(idIndex)"
                        object.testNumber = idIndex
                        object.testDate = self.dateFormatter.dateFromString("2000-\(configurationIndex)-\(idIndex)T00:00:00Z")
                    }
                }
                if configuration == nil || configuration == "Config2" {
                    
                    for idIndex in 1 ... 5 {
                        
                        let object = transaction.create(Into<TestEntity2>(configuration))
                        object.testEntityID = NSNumber(integer: (configurationIndex * 200) + idIndex)
                        object.testString = "\(configuration ?? "nil"):TestEntity2:\(idIndex)"
                        object.testNumber = idIndex
                        object.testDate = self.dateFormatter.dateFromString("2000-\(configurationIndex)-\(idIndex)T00:00:00Z")
                    }
                }
            }
            transaction.commitAndWait()
        }
    }
}
