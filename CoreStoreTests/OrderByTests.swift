//
//  OrderByTests.swift
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


//MARK: - OrderByTests

final class OrderByTests: XCTestCase {
    
    @objc
    dynamic func test_ThatOrderByClauses_ConfigureCorrectly() {
        
        do {
            
            let orderBy = OrderBy<NSManagedObject>()
            XCTAssertEqual(orderBy, OrderBy<NSManagedObject>([NSSortDescriptor]()))
            XCTAssertNotEqual(orderBy, OrderBy<NSManagedObject>(NSSortDescriptor(key: "key", ascending: false)))
            XCTAssertTrue(orderBy.sortDescriptors.isEmpty)
        }
        do {
            
            let sortDescriptor = NSSortDescriptor(key: "key1", ascending: true)
            let orderBy = OrderBy<NSManagedObject>(sortDescriptor)
            XCTAssertEqual(orderBy, OrderBy(sortDescriptor))
            XCTAssertEqual(orderBy, OrderBy<NSManagedObject>(.ascending("key1")))
            XCTAssertNotEqual(orderBy, OrderBy<NSManagedObject>(.ascending("key2")))
            XCTAssertNotEqual(orderBy, OrderBy<NSManagedObject>(.descending("key1")))
            XCTAssertNotEqual(orderBy, OrderBy<NSManagedObject>(NSSortDescriptor(key: "key1", ascending: false)))
            XCTAssertEqual(orderBy, OrderBy<NSManagedObject>([sortDescriptor]))
            XCTAssertEqual(orderBy.sortDescriptors, [sortDescriptor])
        }
        do {
            
            let sortDescriptors = [
                NSSortDescriptor(key: "key1", ascending: true),
                NSSortDescriptor(key: "key2", ascending: false)
            ]
            let orderBy = OrderBy<NSManagedObject>(sortDescriptors)
            XCTAssertEqual(orderBy, OrderBy<NSManagedObject>(sortDescriptors))
            XCTAssertEqual(orderBy, OrderBy<NSManagedObject>(.ascending("key1"), .descending("key2")))
            XCTAssertNotEqual(
                orderBy,
                OrderBy<NSManagedObject>(
                    [
                        NSSortDescriptor(key: "key1", ascending: false),
                        NSSortDescriptor(key: "key2", ascending: false)
                    ]
                )
            )
            XCTAssertNotEqual(orderBy, OrderBy<NSManagedObject>(.ascending("key1"), .ascending("key2")))
            XCTAssertNotEqual(orderBy, OrderBy<NSManagedObject>(.ascending("key1"), .descending("key3")))
            XCTAssertEqual(orderBy.sortDescriptors, sortDescriptors)
        }
        do {
            
            let orderBy = OrderBy<NSManagedObject>(.ascending("key1"))
            let sortDescriptor = NSSortDescriptor(key: "key1", ascending: true)
            XCTAssertEqual(orderBy, OrderBy<NSManagedObject>(sortDescriptor))
            XCTAssertEqual(orderBy, OrderBy<NSManagedObject>(.ascending("key1")))
            XCTAssertNotEqual(orderBy, OrderBy<NSManagedObject>(.descending("key1")))
            XCTAssertNotEqual(orderBy, OrderBy<NSManagedObject>(.ascending("key2")))
            XCTAssertEqual(orderBy, OrderBy<NSManagedObject>([sortDescriptor]))
            XCTAssertEqual(orderBy.sortDescriptors, [sortDescriptor])
        }
        do {
            
            let orderBy = OrderBy<NSManagedObject>(.ascending("key1"), .descending("key2"))
            let sortDescriptors = [
                NSSortDescriptor(key: "key1", ascending: true),
                NSSortDescriptor(key: "key2", ascending: false)
            ]
            XCTAssertEqual(orderBy, OrderBy<NSManagedObject>(sortDescriptors))
            XCTAssertEqual(orderBy, OrderBy<NSManagedObject>(.ascending("key1"), .descending("key2")))
            XCTAssertNotEqual(
                orderBy,
                OrderBy<NSManagedObject>(
                    [
                        NSSortDescriptor(key: "key1", ascending: false),
                        NSSortDescriptor(key: "key2", ascending: false)
                    ]
                )
            )
            XCTAssertNotEqual(orderBy, OrderBy<NSManagedObject>(.ascending("key1"), .ascending("key2")))
            XCTAssertNotEqual(orderBy, OrderBy<NSManagedObject>(.ascending("key1"), .descending("key3")))
            XCTAssertEqual(orderBy.sortDescriptors, sortDescriptors)
        }
        do {
            
            let sortKeys: [OrderBy<NSManagedObject>.SortKey] = [.ascending("key1"), .descending("key2")]
            let orderBy = OrderBy<NSManagedObject>(sortKeys)
            let sortDescriptors = [
                NSSortDescriptor(key: "key1", ascending: true),
                NSSortDescriptor(key: "key2", ascending: false)
            ]
            XCTAssertEqual(orderBy, OrderBy<NSManagedObject>(sortDescriptors))
            XCTAssertEqual(orderBy, OrderBy<NSManagedObject>(.ascending("key1"), .descending("key2")))
            XCTAssertNotEqual(
                orderBy,
                OrderBy<NSManagedObject>(
                    [
                        NSSortDescriptor(key: "key1", ascending: false),
                        NSSortDescriptor(key: "key2", ascending: false)
                    ]
                )
            )
            XCTAssertNotEqual(orderBy, OrderBy<NSManagedObject>(.ascending("key1"), .ascending("key2")))
            XCTAssertNotEqual(orderBy, OrderBy<NSManagedObject>(.ascending("key1"), .descending("key3")))
            XCTAssertEqual(orderBy.sortDescriptors, sortDescriptors)
        }
    }
    
    @objc
    dynamic func test_ThatOrderByClauseOperations_ComputeCorrectly() {
        
        let orderBy1 = OrderBy<NSManagedObject>(.ascending("key1"))
        let orderBy2 = OrderBy<NSManagedObject>(.descending("key2"))
        let orderBy3 = OrderBy<NSManagedObject>(.ascending("key3"))
        
        do {
            
            let plusOrderBy = orderBy1 + orderBy2 + orderBy3
            XCTAssertEqual(plusOrderBy, OrderBy<NSManagedObject>(.ascending("key1"), .descending("key2"), .ascending("key3")))
            XCTAssertEqual(plusOrderBy, OrderBy<NSManagedObject>(.ascending("key1")) + OrderBy<NSManagedObject>(.descending("key2"), .ascending("key3")))
            XCTAssertNotEqual(plusOrderBy, orderBy1 + orderBy3 + orderBy2)
            XCTAssertNotEqual(plusOrderBy, orderBy2 + orderBy1 + orderBy3)
            XCTAssertNotEqual(plusOrderBy, orderBy2 + orderBy3 + orderBy1)
            XCTAssertNotEqual(plusOrderBy, orderBy3 + orderBy1 + orderBy2)
            XCTAssertNotEqual(plusOrderBy, orderBy3 + orderBy2 + orderBy1)
            XCTAssertEqual(plusOrderBy.sortDescriptors, orderBy1.sortDescriptors + orderBy2.sortDescriptors + orderBy3.sortDescriptors)
        }
        do {
            
            var plusOrderBy = orderBy1
            plusOrderBy += orderBy2
            XCTAssertEqual(plusOrderBy, OrderBy<NSManagedObject>(.ascending("key1"), .descending("key2")))
            XCTAssertEqual(plusOrderBy, OrderBy<NSManagedObject>(.ascending("key1")) + OrderBy<NSManagedObject>(.descending("key2")))
            XCTAssertNotEqual(plusOrderBy, orderBy2 + orderBy1)
            XCTAssertEqual(plusOrderBy.sortDescriptors, orderBy1.sortDescriptors + orderBy2.sortDescriptors)
            
            plusOrderBy += orderBy3
            XCTAssertEqual(plusOrderBy, OrderBy<NSManagedObject>(.ascending("key1"), .descending("key2"), .ascending("key3")))
            XCTAssertEqual(plusOrderBy, OrderBy<NSManagedObject>(.ascending("key1"), .descending("key2")) + OrderBy<NSManagedObject>(.ascending("key3")))
            XCTAssertNotEqual(plusOrderBy, orderBy1 + orderBy3 + orderBy2)
            XCTAssertNotEqual(plusOrderBy, orderBy2 + orderBy1 + orderBy3)
            XCTAssertNotEqual(plusOrderBy, orderBy2 + orderBy3 + orderBy1)
            XCTAssertNotEqual(plusOrderBy, orderBy3 + orderBy1 + orderBy2)
            XCTAssertNotEqual(plusOrderBy, orderBy3 + orderBy2 + orderBy1)
            XCTAssertEqual(plusOrderBy.sortDescriptors, orderBy1.sortDescriptors + orderBy2.sortDescriptors + orderBy3.sortDescriptors)
        }
    }
    
    @objc
    dynamic func test_ThatOrderByClauses_ApplyToFetchRequestsCorrectly() {
        
        let orderBy = OrderBy<NSManagedObject>(.ascending("key"))
        let request = CoreStoreFetchRequest<NSFetchRequestResult>()
        orderBy.applyToFetchRequest(request)
        XCTAssertNotNil(request.sortDescriptors)
        XCTAssertEqual(request.sortDescriptors ?? [], orderBy.sortDescriptors)
    }
}
