//
//  WhereTests.swift
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

import CoreData
import XCTest

@testable
import CoreStore


// MARK: - XCTAssertAllEqual

private func XCTAssertAllEqual<O>(_ whereClauses: Where<O>...) {
    
    XCTAssertAllEqual(whereClauses)
}

private func XCTAssertAllEqual<O>(_ whereClauses: [Where<O>]) {
    
    for i in whereClauses.indices {
        
        for j in whereClauses.indices where j != i {
            
            XCTAssertEqual(whereClauses[i], whereClauses[j])
        }
    }
}

private func XCTAssertAllEqual<D: Equatable>(_ items: D...) {

    for i in items.indices {

        for j in items.indices where j != i {

            XCTAssertEqual(items[i], items[j])
        }
    }
}


//MARK: - WhereTests

final class WhereTests: XCTestCase {
    
    @objc
    dynamic func test_ThatExpressions_HaveCorrectKeyPaths() {

        do {

            do {

                XCTAssertAllEqual(
                    #keyPath(TestEntity1.testToOne.testEntityID),
                    (\TestEntity1.testToOne ~ \.testEntityID).description,
                    String(keyPath: \TestEntity1.testToOne ~ \.testEntityID)
                )
                XCTAssertAllEqual(
                    #keyPath(TestEntity1.testToOne.testToOne.testToManyUnordered),
                    (\TestEntity1.testToOne ~ \.testToOne ~ \.testToManyUnordered).description,
                    String(keyPath: \TestEntity1.testToOne ~ \.testToOne ~ \.testToManyUnordered)
                )
                XCTAssertAllEqual(
                    #keyPath(TestEntity2.testToOne.testToOne.testToManyOrdered),
                    (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).description,
                    String(keyPath: \TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered)
                )
            }
        }
        do {

            do {

                XCTAssertAllEqual(
                    #keyPath(TestEntity1.testToOne.testToManyUnordered) + ".@count",
                    (\TestEntity1.testToOne ~ \.testToManyUnordered).count().description,
                    String(keyPath: (\TestEntity1.testToOne ~ \.testToManyUnordered).count())
                )
                XCTAssertAllEqual(
                    #keyPath(TestEntity2.testToOne.testToOne.testToManyOrdered) + ".@count",
                    (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).count().description,
                    String(keyPath: (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).count())
                )
            }
        }
        do {

            do {

                XCTAssertAllEqual(
                    "ANY " + #keyPath(TestEntity1.testToOne.testToManyUnordered),
                    (\TestEntity1.testToOne ~ \.testToManyUnordered).any().description,
                    String(keyPath: (\TestEntity1.testToOne ~ \.testToManyUnordered).any())
                )
                XCTAssertAllEqual(
                    "ANY " + #keyPath(TestEntity2.testToOne.testToOne.testToManyOrdered),
                    (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).any().description,
                    String(keyPath: (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).any())
                )
            }
        }
        do {

            do {

                XCTAssertAllEqual(
                    "ALL " + #keyPath(TestEntity1.testToOne.testToManyUnordered),
                    (\TestEntity1.testToOne ~ \.testToManyUnordered).all().description,
                    String(keyPath: (\TestEntity1.testToOne ~ \.testToManyUnordered).all())
                )
                XCTAssertAllEqual(
                    "ALL " + #keyPath(TestEntity2.testToOne.testToOne.testToManyOrdered),
                    (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).all().description,
                    String(keyPath: (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).all())
                )
            }
        }
        do {

            do {

                XCTAssertAllEqual(
                    "NONE " + #keyPath(TestEntity1.testToOne.testToManyUnordered),
                    (\TestEntity1.testToOne ~ \.testToManyUnordered).none().description,
                    String(keyPath: (\TestEntity1.testToOne ~ \.testToManyUnordered).none())
                )
                XCTAssertAllEqual(
                    "NONE " + #keyPath(TestEntity2.testToOne.testToOne.testToManyOrdered),
                    (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).none().description,
                    String(keyPath: (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).none())
                )
            }
        }
    }

    @objc
    dynamic func test_ThatWhereClauses_CanBeCreatedFromExpressionsCorrectly() {

        do {

            let dummy = "dummy"
            do {

                let whereClause: Where<TestEntity1> = (\.testToOne ~ \.testString) == dummy
                let predicate = NSPredicate(format: "\(#keyPath(TestEntity1.testToOne.testString)) == %@", dummy)
                XCTAssertAllEqual(whereClause, Where<TestEntity1>(predicate))
                XCTAssertAllEqual(whereClause.predicate, predicate)
            }
        }
        do {

            let dummy = "dummy"
            do {

                let whereClause: Where<TestEntity1> = (\.testToOne ~ \.testToOne ~ \.testString) == dummy
                let predicate = NSPredicate(format: "\(#keyPath(TestEntity1.testToOne.testToOne.testString)) == %@", dummy)
                XCTAssertAllEqual(whereClause, Where<TestEntity1>(predicate))
                XCTAssertAllEqual(whereClause.predicate, predicate)
            }
        }
        do {

            let count = 3
            do {

                let whereClause: Where<TestEntity1> = (\.testToOne ~ \.testToManyUnordered).count() == count
                let predicate = NSPredicate(format: "\(#keyPath(TestEntity1.testToOne.testToManyUnordered)).@count == %d", count)
                XCTAssertAllEqual(whereClause, Where<TestEntity1>(predicate))
                XCTAssertAllEqual(whereClause.predicate, predicate)
            }
        }
        do {

            let dummy = "dummy"
            do {

                let whereClause: Where<TestEntity1> = (\.testToOne ~ \.testToManyUnordered ~ \TestEntity1.testString).any() == dummy
                let predicate = NSPredicate(format: "ANY \(#keyPath(TestEntity1.testToOne.testToManyUnordered)).\(#keyPath(TestEntity1.testString)) == %@", dummy)
                XCTAssertAllEqual(whereClause, Where<TestEntity1>(predicate))
                XCTAssertAllEqual(whereClause.predicate, predicate)
            }
        }
        do {

            let dummy = "dummy"
            do {

                let whereClause: Where<TestEntity1> = (\.testToOne ~ \.testToManyUnordered ~ \TestEntity1.testString).all() == dummy
                let predicate = NSPredicate(format: "ALL \(#keyPath(TestEntity1.testToOne.testToManyUnordered)).\(#keyPath(TestEntity1.testString)) == %@", dummy)
                XCTAssertAllEqual(whereClause, Where<TestEntity1>(predicate))
                XCTAssertAllEqual(whereClause.predicate, predicate)
            }
        }
        do {

            let dummy = "dummy"
            do {

                let whereClause: Where<TestEntity1> = (\.testToOne ~ \.testToManyUnordered ~ \TestEntity1.testString).none() == dummy
                let predicate = NSPredicate(format: "NONE \(#keyPath(TestEntity1.testToOne.testToManyUnordered)).\(#keyPath(TestEntity1.testString)) == %@", dummy)
                XCTAssertAllEqual(whereClause, Where<TestEntity1>(predicate))
                XCTAssertAllEqual(whereClause.predicate, predicate)
            }
        }
    }
    
    @objc
    dynamic func test_ThatWhereClauses_ConfigureCorrectly() {
        
        do {
            
            let whereClause = Where<NSManagedObject>()
            XCTAssertAllEqual(whereClause, Where<NSManagedObject>(true))
            XCTAssertNotEqual(whereClause, Where<NSManagedObject>(false))
            XCTAssertAllEqual(whereClause.predicate, NSPredicate(value: true))
        }
        do {
            
            let whereClause = Where<NSManagedObject>(true)
            XCTAssertAllEqual(whereClause, Where<NSManagedObject>())
            XCTAssertNotEqual(whereClause, Where<NSManagedObject>(false))
            XCTAssertAllEqual(whereClause.predicate, NSPredicate(value: true))
        }
        do {
            
            let predicate = NSPredicate(format: "%K == %@", "key", "value")
            let whereClause = Where<NSManagedObject>(predicate)
            XCTAssertAllEqual(whereClause, Where<NSManagedObject>(predicate))
            XCTAssertAllEqual(whereClause.predicate, predicate)
        }
        do {
            
            let whereClause = Where<NSManagedObject>("%K == %@", "key", "value")
            let predicate = NSPredicate(format: "%K == %@", "key", "value")
            XCTAssertAllEqual(whereClause, Where<NSManagedObject>(predicate))
            XCTAssertAllEqual(whereClause.predicate, predicate)
        }
        do {
            
            let whereClause = Where<NSManagedObject>("%K == %@", argumentArray: ["key", "value"])
            let predicate = NSPredicate(format: "%K == %@", "key", "value")
            XCTAssertAllEqual(whereClause, Where<NSManagedObject>(predicate))
            XCTAssertAllEqual(whereClause.predicate, predicate)
        }
        do {
            
            let whereClause = Where<NSManagedObject>("key", isEqualTo: "value")
            let predicate = NSPredicate(format: "%K == %@", "key", "value")
            XCTAssertAllEqual(whereClause, Where<NSManagedObject>(predicate))
            XCTAssertAllEqual(whereClause.predicate, predicate)
        }
        do {
            
            let whereClause = Where<NSManagedObject>("key", isMemberOf: ["value1", "value2", "value3"])
            let predicate = NSPredicate(format: "%K IN %@", "key", ["value1", "value2", "value3"])
            XCTAssertAllEqual(whereClause, Where<NSManagedObject>(predicate))
            XCTAssertAllEqual(whereClause.predicate, predicate)
        }
    }
    
    @objc
    dynamic func test_ThatWhereClauses_BridgeArgumentsCorrectly() {
        
        do {
            
            let value: Int = 100
            XCTAssertAllEqual(
                Where<NSManagedObject>("%K == %d", "key", value),
                Where<NSManagedObject>("%K == %d", "key", value as AnyObject),
                Where<NSManagedObject>("%K == %d", "key", NSNumber(value: value)),
                Where<NSManagedObject>("%K == %@", "key", value),
                Where<NSManagedObject>("%K == %@", "key", value as AnyObject),
                Where<NSManagedObject>("%K == %@", "key", NSNumber(value: value)),
                Where<NSManagedObject>("key", isEqualTo: value),
                Where<NSManagedObject>("key", isEqualTo: NSNumber(value: value))
            )
        }
        do {
            
            let value = NSNumber(value: 100)
            XCTAssertAllEqual(
                Where<NSManagedObject>("%K == %d", "key", value),
                Where<NSManagedObject>("%K == %d", "key", value as AnyObject),
                Where<NSManagedObject>("%K == %d", "key", value.intValue),
                Where<NSManagedObject>("%K == %@", "key", value),
                Where<NSManagedObject>("%K == %@", "key", value as AnyObject),
                Where<NSManagedObject>("%K == %@", "key", value.intValue),
                Where<NSManagedObject>("key", isEqualTo: value),
                Where<NSManagedObject>("key", isEqualTo: value.intValue)
            )
        }
        do {
            
            let value: Int64 = Int64.max
            XCTAssertAllEqual(
                Where<NSManagedObject>("%K == %d", "key", value),
                Where<NSManagedObject>("%K == %d", "key", value as AnyObject),
                Where<NSManagedObject>("%K == %d", "key", NSNumber(value: value)),
                Where<NSManagedObject>("%K == %@", "key", value),
                Where<NSManagedObject>("%K == %@", "key", value as AnyObject),
                Where<NSManagedObject>("%K == %@", "key", NSNumber(value: value)),
                Where<NSManagedObject>("key", isEqualTo: value),
                Where<NSManagedObject>("key", isEqualTo: NSNumber(value: value))
            )
        }
        do {
            
            let value = NSNumber(value: Int64.max)
            XCTAssertAllEqual(
                Where<NSManagedObject>("%K == %d", "key", value),
                Where<NSManagedObject>("%K == %d", "key", value as AnyObject),
                Where<NSManagedObject>("%K == %d", "key", value.int64Value),
                Where<NSManagedObject>("%K == %@", "key", value),
                Where<NSManagedObject>("%K == %@", "key", value as AnyObject),
                Where<NSManagedObject>("%K == %@", "key", value.int64Value),
                Where<NSManagedObject>("key", isEqualTo: value),
                Where<NSManagedObject>("key", isEqualTo: value.int64Value)
            )
        }
        do {
            
            let value: String = "value"
            XCTAssertAllEqual(
                Where<NSManagedObject>("%K == %s", "key", value),
                Where<NSManagedObject>("%K == %s", "key", value as AnyObject),
                Where<NSManagedObject>("%K == %s", "key", NSString(string: value)),
                Where<NSManagedObject>("%K == %@", "key", value),
                Where<NSManagedObject>("%K == %@", "key", value as AnyObject),
                Where<NSManagedObject>("%K == %@", "key", NSString(string: value)),
                Where<NSManagedObject>("key", isEqualTo: value),
                Where<NSManagedObject>("key", isEqualTo: value as NSString),
                Where<NSManagedObject>("key", isEqualTo: NSString(string: value))
            )
        }
        do {
            
            let value = NSString(string: "value")
            XCTAssertAllEqual(
                Where<NSManagedObject>("%K == %s", "key", value),
                Where<NSManagedObject>("%K == %s", "key", value as String),
                Where<NSManagedObject>("%K == %s", "key", value as String as AnyObject),
                Where<NSManagedObject>("%K == %@", "key", value),
                Where<NSManagedObject>("%K == %@", "key", value as String),
                Where<NSManagedObject>("%K == %@", "key", value as String as AnyObject),
                Where<NSManagedObject>("key", isEqualTo: value),
                Where<NSManagedObject>("key", isEqualTo: value as String),
                Where<NSManagedObject>("key", isEqualTo: value as String as NSString)
            )
        }
        do {
            
            let value: [Int] = [100, 200]
            XCTAssertAllEqual(
                Where<NSManagedObject>("%K IN %@", "key", value),
                Where<NSManagedObject>("%K IN %@", "key", value as AnyObject),
                Where<NSManagedObject>("%K IN %@", "key", value as [AnyObject]),
                Where<NSManagedObject>("%K IN %@", "key", value as NSArray),
                Where<NSManagedObject>("%K IN %@", "key", NSArray(array: value)),
                Where<NSManagedObject>("%K IN %@", "key", value as AnyObject as! NSArray),
                Where<NSManagedObject>("key", isMemberOf: value)
            )
        }
        do {
            
            let value: [Int64] = [Int64.min, 100, Int64.max]
            XCTAssertAllEqual(
                Where<NSManagedObject>("%K IN %@", "key", value),
                Where<NSManagedObject>("%K IN %@", "key", value as AnyObject),
                Where<NSManagedObject>("%K IN %@", "key", value as [AnyObject]),
                Where<NSManagedObject>("%K IN %@", "key", value as NSArray),
                Where<NSManagedObject>("%K IN %@", "key", NSArray(array: value)),
                Where<NSManagedObject>("%K IN %@", "key", value as AnyObject as! NSArray),
                Where<NSManagedObject>("key", isMemberOf: value)
            )
        }
    }
    
    @objc
    dynamic func test_ThatWhereClauseOperations_ComputeCorrectly() {
        
        let whereClause1 = Where<NSManagedObject>("key1", isEqualTo: "value1")
        let whereClause2 = Where<NSManagedObject>("key2", isEqualTo: "value2")
        let whereClause3 = Where<NSManagedObject>("key3", isEqualTo: "value3")
        
        do {
            
            let notWhere = !whereClause1
            let notPredicate = NSCompoundPredicate(
                type: .not,
                subpredicates: [whereClause1.predicate]
            )
            XCTAssertAllEqual(notWhere.predicate, notPredicate)
            XCTAssertAllEqual(notWhere, !whereClause1)
        }
        do {
            
            let andWhere = whereClause1 && whereClause2 && whereClause3
            let andPredicate = NSCompoundPredicate(
                type: .and,
                subpredicates: [
                    NSCompoundPredicate(
                        type: .and,
                        subpredicates: [whereClause1.predicate, whereClause2.predicate]
                    ),
                    whereClause3.predicate
                ]
            )
            XCTAssertAllEqual(andWhere.predicate, andPredicate)
            XCTAssertAllEqual(andWhere, whereClause1 && whereClause2 && whereClause3)
        }
        do {
            
            let andWhere = whereClause1 && whereClause2 && whereClause3
            let noneWhere: Where<NSManagedObject>? = nil
            let someWhere: Where<NSManagedObject>? = Where<NSManagedObject>("key4", isEqualTo: "value4")

            
            let finalNoneWhere = andWhere &&? noneWhere
            let finalSomeWhere = andWhere &&? someWhere
            let unwrappedFinalSomeWhere = andWhere && someWhere!

        
            XCTAssertAllEqual(andWhere.predicate, finalNoneWhere.predicate)
            XCTAssertAllEqual(finalSomeWhere.predicate, unwrappedFinalSomeWhere.predicate)
        }
        do {
            
            let orWhere = whereClause1 || whereClause2 || whereClause3
            let orPredicate = NSCompoundPredicate(
                type: .or,
                subpredicates: [
                    NSCompoundPredicate(
                        type: .or,
                        subpredicates: [whereClause1.predicate, whereClause2.predicate]
                    ),
                    whereClause3.predicate
                ]
            )
            XCTAssertAllEqual(orWhere.predicate, orPredicate)
            XCTAssertAllEqual(orWhere, whereClause1 || whereClause2 || whereClause3)
        }
        do {
            
            let orWhere = whereClause1 || whereClause2 || whereClause3
            let noneWhere: Where<NSManagedObject>? = nil
            let someWhere: Where<NSManagedObject>? = Where<NSManagedObject>("key4", isEqualTo: "value4")
            
            
            let finalNoneWhere = orWhere &&? noneWhere
            let finalSomeWhere = orWhere &&? someWhere
            let unwrappedFinalSomeWhere = orWhere && someWhere!
            
            XCTAssertAllEqual(orWhere.predicate, finalNoneWhere.predicate)
            XCTAssertAllEqual(finalSomeWhere.predicate, unwrappedFinalSomeWhere.predicate)
        }

    }
    
    @objc
    dynamic func test_ThatWhereClauses_ApplyToFetchRequestsCorrectly() {
        
        let whereClause = Where<NSManagedObject>("key", isEqualTo: "value")
        let request = Internals.CoreStoreFetchRequest<NSFetchRequestResult>()
        whereClause.applyToFetchRequest(request)
        XCTAssertNotNil(request.predicate)
        XCTAssertAllEqual(request.predicate, whereClause.predicate)
    }
}
