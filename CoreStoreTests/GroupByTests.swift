//
//  GroupByTests.swift
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


//MARK: - GroupByTests

final class GroupByTests: BaseTestCase {
    
    @objc
    dynamic func test_ThatGroupByClauses_ConfigureCorrectly() {
        
        do {
            
            let groupBy = GroupBy()
            XCTAssertEqual(groupBy, GroupBy([] as [String]))
            XCTAssertNotEqual(groupBy, GroupBy("key"))
            XCTAssertTrue(groupBy.keyPaths.isEmpty)
        }
        do {
            
            let groupBy = GroupBy("key1")
            XCTAssertEqual(groupBy, GroupBy("key1"))
            XCTAssertEqual(groupBy, GroupBy(["key1"]))
            XCTAssertNotEqual(groupBy, GroupBy("key2"))
            XCTAssertEqual(groupBy.keyPaths, ["key1"])
        }
        do {
            
            let groupBy = GroupBy("key1", "key2")
            XCTAssertEqual(groupBy, GroupBy("key1", "key2"))
            XCTAssertEqual(groupBy, GroupBy(["key1", "key2"]))
            XCTAssertNotEqual(groupBy, GroupBy("key2", "key1"))
            XCTAssertEqual(groupBy.keyPaths, ["key1", "key2"])
        }
    }
    
    @objc
    dynamic func test_ThatGroupByClauses_ApplyToFetchRequestsCorrectly() {
        
        self.prepareStack { (dataStack) in
            
            let groupBy = GroupBy(#keyPath(TestEntity1.testString))
            
            let request = CoreStoreFetchRequest()
            _ = From<TestEntity1>().applyToFetchRequest(request, context: dataStack.mainContext)
            groupBy.applyToFetchRequest(request)
            
            XCTAssertNotNil(request.propertiesToGroupBy)
            
            let attributes = (request.propertiesToGroupBy ?? []) as! [NSAttributeDescription]
            XCTAssertEqual(attributes.map { $0.name }, groupBy.keyPaths)
        }
    }
}
