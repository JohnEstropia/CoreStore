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

import XCTest

@testable
import CoreStore


// MARK: - XCTAssertAllEqual

private func XCTAssertAllEqual<D>(_ whereClauses: Where<D>...) {
    
    XCTAssertAllEqual(whereClauses)
}

private func XCTAssertAllEqual<D>(_ whereClauses: [Where<D>]) {
    
    for i in whereClauses.indices {
        
        for j in whereClauses.indices where j != i {
            
            XCTAssertEqual(whereClauses[i], whereClauses[j])
        }
    }
}


//MARK: - WhereTests

final class WhereTests: XCTestCase {
    
    @objc
    dynamic func test_ThatDynamicModelKeyPaths_CanBeCreated() {
        
        XCTAssertEqual(String(keyPath: \TestEntity1.testEntityID), "testEntityID")
        XCTAssertEqual(String(keyPath: \Animal.color), "color")
    }

    @objc
    dynamic func test_ThatExpressions_HaveCorrectKeyPaths() {

        do {

            do {

                XCTAssertEqual(
                    #keyPath(TestEntity1.testToOne.testEntityID),
                    (\TestEntity1.testToOne ~ \.testEntityID).description,
                    String(keyPath: \TestEntity1.testToOne ~ \.testEntityID)
                )
                XCTAssertEqual(
                    #keyPath(TestEntity1.testToOne.testToOne.testToManyUnordered),
                    (\TestEntity1.testToOne ~ \.testToOne ~ \.testToManyUnordered).description,
                    String(keyPath: \TestEntity1.testToOne ~ \.testToOne ~ \.testToManyUnordered)
                )
                XCTAssertEqual(
                    #keyPath(TestEntity2.testToOne.testToOne.testToManyOrdered),
                    (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).description,
                    String(keyPath: \TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered)
                )
            }
            do {

                XCTAssertEqual(
                    "master.pets",
                    (\Animal.master ~ \.pets).description,
                    String(keyPath: \Animal.master ~ \.pets)
                )
                XCTAssertEqual(
                    "master.pets.species",
                    (\Animal.master ~ \.pets ~ \.species).description,
                    String(keyPath: \Animal.master ~ \.pets ~ \.species)
                )
                XCTAssertEqual(
                    "master.pets.master",
                    (\Animal.master ~ \.pets ~ \.master).description,
                    String(keyPath: \Animal.master ~ \.pets ~ \.master)
                )
            }
        }
        do {

            do {

                XCTAssertEqual(
                    #keyPath(TestEntity1.testToOne.testToManyUnordered) + ".@count",
                    (\TestEntity1.testToOne ~ \.testToManyUnordered).count().description,
                    String(keyPath: (\TestEntity1.testToOne ~ \.testToManyUnordered).count())
                )
                XCTAssertEqual(
                    #keyPath(TestEntity2.testToOne.testToOne.testToManyOrdered) + ".@count",
                    (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).count().description,
                    String(keyPath: (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).count())
                )
            }
            do {

                XCTAssertEqual(
                    "master.pets.@count",
                    (\Animal.master ~ \.pets).count().description,
                    String(keyPath: (\Animal.master ~ \.pets).count())
                )
            }
        }
        do {

            do {

                XCTAssertEqual(
                    "ANY " + #keyPath(TestEntity1.testToOne.testToManyUnordered),
                    (\TestEntity1.testToOne ~ \.testToManyUnordered).any().description,
                    String(keyPath: (\TestEntity1.testToOne ~ \.testToManyUnordered).any())
                )
                XCTAssertEqual(
                    "ANY " + #keyPath(TestEntity2.testToOne.testToOne.testToManyOrdered),
                    (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).any().description,
                    String(keyPath: (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).any())
                )
            }
            do {

                XCTAssertEqual(
                    "ANY master.pets",
                    (\Animal.master ~ \.pets).any().description,
                    String(keyPath: (\Animal.master ~ \.pets).any())
                )
                XCTAssertEqual(
                    "ANY master.pets.species",
                    (\Animal.master ~ \.pets ~ \.species).any().description,
                    String(keyPath: (\Animal.master ~ \.pets ~ \.species).any())
                )
            }
        }
        do {

            do {

                XCTAssertEqual(
                    "ALL " + #keyPath(TestEntity1.testToOne.testToManyUnordered),
                    (\TestEntity1.testToOne ~ \.testToManyUnordered).all().description,
                    String(keyPath: (\TestEntity1.testToOne ~ \.testToManyUnordered).all())
                )
                XCTAssertEqual(
                    "ALL " + #keyPath(TestEntity2.testToOne.testToOne.testToManyOrdered),
                    (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).all().description,
                    String(keyPath: (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).all())
                )
            }
            do {

                XCTAssertEqual(
                    "ALL master.pets",
                    (\Animal.master ~ \.pets).all().description,
                    String(keyPath: (\Animal.master ~ \.pets).all())
                )
                XCTAssertEqual(
                    "ALL master.pets.species",
                    (\Animal.master ~ \.pets ~ \.species).all().description,
                    String(keyPath: (\Animal.master ~ \.pets ~ \.species).all())
                )
            }
        }
        do {

            do {

                XCTAssertEqual(
                    "NONE " + #keyPath(TestEntity1.testToOne.testToManyUnordered),
                    (\TestEntity1.testToOne ~ \.testToManyUnordered).none().description,
                    String(keyPath: (\TestEntity1.testToOne ~ \.testToManyUnordered).none())
                )
                XCTAssertEqual(
                    "NONE " + #keyPath(TestEntity2.testToOne.testToOne.testToManyOrdered),
                    (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).none().description,
                    String(keyPath: (\TestEntity2.testToOne ~ \.testToOne ~ \.testToManyOrdered).none())
                )
            }
            do {

                XCTAssertEqual(
                    "NONE master.pets",
                    (\Animal.master ~ \.pets).none().description,
                    String(keyPath: (\Animal.master ~ \.pets).none())
                )
                XCTAssertEqual(
                    "NONE master.pets.species",
                    (\Animal.master ~ \.pets ~ \.species).none().description,
                    String(keyPath: (\Animal.master ~ \.pets ~ \.species).none())
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
                XCTAssertEqual(whereClause, Where<TestEntity1>(predicate))
                XCTAssertEqual(whereClause.predicate, predicate)
            }
            do {

                let whereClause: Where<Animal> = (\.master ~ \.name) == dummy
                let predicate = NSPredicate(format: "master.name == %@", dummy)
                XCTAssertEqual(whereClause, Where<Animal>(predicate))
                XCTAssertEqual(whereClause.predicate, predicate)
            }
        }
        do {

            let dummy = "dummy"
            do {

                let whereClause: Where<TestEntity1> = (\.testToOne ~ \.testToOne ~ \.testString) == dummy
                let predicate = NSPredicate(format: "\(#keyPath(TestEntity1.testToOne.testToOne.testString)) == %@", dummy)
                XCTAssertEqual(whereClause, Where<TestEntity1>(predicate))
                XCTAssertEqual(whereClause.predicate, predicate)
            }
            do {

                let whereClause: Where<Animal> = (\.master ~ \.spouse ~ \.name) == dummy
                let predicate = NSPredicate(format: "master.spouse.name == %@", dummy)
                XCTAssertEqual(whereClause, Where<Animal>(predicate))
                XCTAssertEqual(whereClause.predicate, predicate)
            }
        }
        do {

            let count = 3
            do {

                let whereClause: Where<TestEntity1> = (\.testToOne ~ \.testToManyUnordered).count() == count
                let predicate = NSPredicate(format: "\(#keyPath(TestEntity1.testToOne.testToManyUnordered)).@count == %d", count)
                XCTAssertEqual(whereClause, Where<TestEntity1>(predicate))
                XCTAssertEqual(whereClause.predicate, predicate)
            }
            do {

                let whereClause: Where<Animal> = (\.master ~ \.pets).count() == count
                let predicate = NSPredicate(format: "master.pets.@count == %d", count)
                XCTAssertEqual(whereClause, Where<Animal>(predicate))
                XCTAssertEqual(whereClause.predicate, predicate)
            }
        }
        do {

            let dummy = "dummy"
            do {

                let whereClause: Where<TestEntity1> = (\.testToOne ~ \.testToManyUnordered ~ \TestEntity1.testString).any() == dummy
                let predicate = NSPredicate(format: "ANY \(#keyPath(TestEntity1.testToOne.testToManyUnordered)).\(#keyPath(TestEntity1.testString)) == %@", dummy)
                XCTAssertEqual(whereClause, Where<TestEntity1>(predicate))
                XCTAssertEqual(whereClause.predicate, predicate)
            }
            do {

                let whereClause: Where<Animal> = (\.master ~ \.pets ~ \.species).any() == dummy
                let predicate = NSPredicate(format: "ANY master.pets.species == %@", dummy)
                XCTAssertEqual(whereClause, Where<Animal>(predicate))
                XCTAssertEqual(whereClause.predicate, predicate)
            }
        }
        do {

            let dummy = "dummy"
            do {

                let whereClause: Where<TestEntity1> = (\.testToOne ~ \.testToManyUnordered ~ \TestEntity1.testString).all() == dummy
                let predicate = NSPredicate(format: "ALL \(#keyPath(TestEntity1.testToOne.testToManyUnordered)).\(#keyPath(TestEntity1.testString)) == %@", dummy)
                XCTAssertEqual(whereClause, Where<TestEntity1>(predicate))
                XCTAssertEqual(whereClause.predicate, predicate)
            }
            do {

                let whereClause: Where<Animal> = (\.master ~ \.pets ~ \.species).all() == dummy
                let predicate = NSPredicate(format: "ALL master.pets.species == %@", dummy)
                XCTAssertEqual(whereClause, Where<Animal>(predicate))
                XCTAssertEqual(whereClause.predicate, predicate)
            }
        }
        do {

            let dummy = "dummy"
            do {

                let whereClause: Where<TestEntity1> = (\.testToOne ~ \.testToManyUnordered ~ \TestEntity1.testString).none() == dummy
                let predicate = NSPredicate(format: "NONE \(#keyPath(TestEntity1.testToOne.testToManyUnordered)).\(#keyPath(TestEntity1.testString)) == %@", dummy)
                XCTAssertEqual(whereClause, Where<TestEntity1>(predicate))
                XCTAssertEqual(whereClause.predicate, predicate)
            }
            do {

                let whereClause: Where<Animal> = (\.master ~ \.pets ~ \.species).none() == dummy
                let predicate = NSPredicate(format: "NONE master.pets.species == %@", dummy)
                XCTAssertEqual(whereClause, Where<Animal>(predicate))
                XCTAssertEqual(whereClause.predicate, predicate)
            }
        }
    }
    
    @objc
    dynamic func test_ThatWhereClauses_ConfigureCorrectly() {
        
        do {
            
            let whereClause = Where<NSManagedObject>()
            XCTAssertEqual(whereClause, Where<NSManagedObject>(true))
            XCTAssertNotEqual(whereClause, Where<NSManagedObject>(false))
            XCTAssertEqual(whereClause.predicate, NSPredicate(value: true))
        }
        do {
            
            let whereClause = Where<NSManagedObject>(true)
            XCTAssertEqual(whereClause, Where<NSManagedObject>())
            XCTAssertNotEqual(whereClause, Where<NSManagedObject>(false))
            XCTAssertEqual(whereClause.predicate, NSPredicate(value: true))
        }
        do {
            
            let predicate = NSPredicate(format: "%K == %@", "key", "value")
            let whereClause = Where<NSManagedObject>(predicate)
            XCTAssertEqual(whereClause, Where<NSManagedObject>(predicate))
            XCTAssertEqual(whereClause.predicate, predicate)
        }
        do {
            
            let whereClause = Where<NSManagedObject>("%K == %@", "key", "value")
            let predicate = NSPredicate(format: "%K == %@", "key", "value")
            XCTAssertEqual(whereClause, Where<NSManagedObject>(predicate))
            XCTAssertEqual(whereClause.predicate, predicate)
        }
        do {
            
            let whereClause = Where<NSManagedObject>("%K == %@", argumentArray: ["key", "value"])
            let predicate = NSPredicate(format: "%K == %@", "key", "value")
            XCTAssertEqual(whereClause, Where<NSManagedObject>(predicate))
            XCTAssertEqual(whereClause.predicate, predicate)
        }
        do {
            
            let whereClause = Where<NSManagedObject>("key", isEqualTo: "value")
            let predicate = NSPredicate(format: "%K == %@", "key", "value")
            XCTAssertEqual(whereClause, Where<NSManagedObject>(predicate))
            XCTAssertEqual(whereClause.predicate, predicate)
        }
        do {
            
            let whereClause = Where<NSManagedObject>("key", isMemberOf: ["value1", "value2", "value3"])
            let predicate = NSPredicate(format: "%K IN %@", "key", ["value1", "value2", "value3"])
            XCTAssertEqual(whereClause, Where<NSManagedObject>(predicate))
            XCTAssertEqual(whereClause.predicate, predicate)
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
            XCTAssertEqual(notWhere.predicate, notPredicate)
            XCTAssertEqual(notWhere, !whereClause1)
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
            XCTAssertEqual(andWhere.predicate, andPredicate)
            XCTAssertEqual(andWhere, whereClause1 && whereClause2 && whereClause3)
        }
        do {
            
            let andWhere = whereClause1 && whereClause2 && whereClause3
            let noneWhere: Where<NSManagedObject>? = nil
            let someWhere: Where<NSManagedObject>? = Where<NSManagedObject>("key4", isEqualTo: "value4")

            
            let finalNoneWhere = andWhere &&? noneWhere
            let finalSomeWhere = andWhere &&? someWhere
            let unwrappedFinalSomeWhere = andWhere && someWhere!

        
            XCTAssertEqual(andWhere.predicate, finalNoneWhere.predicate)
            XCTAssertEqual(finalSomeWhere.predicate, unwrappedFinalSomeWhere.predicate)
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
            XCTAssertEqual(orWhere.predicate, orPredicate)
            XCTAssertEqual(orWhere, whereClause1 || whereClause2 || whereClause3)
        }
        do {
            
            let orWhere = whereClause1 || whereClause2 || whereClause3
            let noneWhere: Where<NSManagedObject>? = nil
            let someWhere: Where<NSManagedObject>? = Where<NSManagedObject>("key4", isEqualTo: "value4")
            
            
            let finalNoneWhere = orWhere &&? noneWhere
            let finalSomeWhere = orWhere &&? someWhere
            let unwrappedFinalSomeWhere = orWhere && someWhere!
            
            XCTAssertEqual(orWhere.predicate, finalNoneWhere.predicate)
            XCTAssertEqual(finalSomeWhere.predicate, unwrappedFinalSomeWhere.predicate)
        }

    }
    
    @objc
    dynamic func test_ThatWhereClauses_ApplyToFetchRequestsCorrectly() {
        
        let whereClause = Where<NSManagedObject>("key", isEqualTo: "value")
        let request = CoreStoreFetchRequest<NSFetchRequestResult>()
        whereClause.applyToFetchRequest(request)
        XCTAssertNotNil(request.predicate)
        XCTAssertEqual(request.predicate, whereClause.predicate)
    }
}
