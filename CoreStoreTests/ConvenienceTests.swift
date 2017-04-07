//
//  ConvenienceTests.swift
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

@testable
import CoreStore


// MARK: - ConvenienceTests

@available(OSX 10.12, *)
class ConvenienceTests: BaseTestCase {
    
    @objc
    dynamic func test_ThatDataStacks_CanCreateFetchedResultsControllers() {

        self.prepareStack { (stack) in
            
            let controller = stack.createFetchedResultsController(
                From<TestEntity1>(),
                SectionBy(#keyPath(TestEntity1.testString)),
                Where("%@ > %d", #keyPath(TestEntity1.testEntityID), 100),
                OrderBy(.ascending(#keyPath(TestEntity1.testString))),
                Tweak { $0.fetchLimit = 10 }
            )
            XCTAssertEqual(controller.managedObjectContext, stack.mainContext)
            XCTAssertEqual(controller.fetchRequest.entity?.managedObjectClassName, NSStringFromClass(TestEntity1.self))
            XCTAssertEqual(controller.sectionNameKeyPath, #keyPath(TestEntity1.testString))
            XCTAssertEqual(
                controller.fetchRequest.sortDescriptors!,
                OrderBy(.ascending(#keyPath(TestEntity1.testString))).sortDescriptors
            )
            XCTAssertEqual(
                controller.fetchRequest.predicate,
                Where("%@ > %d", #keyPath(TestEntity1.testEntityID), 100).predicate
            )
            XCTAssertEqual(controller.fetchRequest.fetchLimit, 10)
        }
    }
    
    @objc
    dynamic func test_ThatUnsafeDataTransactions_CanCreateFetchedResultsControllers() {
        
        self.prepareStack { (stack) in
            
            _ = withExtendedLifetime(stack.beginUnsafe()) { (transaction: UnsafeDataTransaction) in
                
                let controller = transaction.createFetchedResultsController(
                    From<TestEntity1>(),
                    SectionBy(#keyPath(TestEntity1.testString)),
                    Where("%@ > %d", #keyPath(TestEntity1.testEntityID), 100),
                    OrderBy(.ascending(#keyPath(TestEntity1.testString))),
                    Tweak { $0.fetchLimit = 10 }
                )
                XCTAssertEqual(controller.managedObjectContext, transaction.context)
                XCTAssertEqual(controller.fetchRequest.entity?.managedObjectClassName, NSStringFromClass(TestEntity1.self))
                XCTAssertEqual(controller.sectionNameKeyPath, #keyPath(TestEntity1.testString))
                XCTAssertEqual(
                    controller.fetchRequest.sortDescriptors!,
                    OrderBy(.ascending(#keyPath(TestEntity1.testString))).sortDescriptors
                )
                XCTAssertEqual(
                    controller.fetchRequest.predicate,
                    Where("%@ > %d", #keyPath(TestEntity1.testEntityID), 100).predicate
                )
                XCTAssertEqual(controller.fetchRequest.fetchLimit, 10)
            }
        }
    }
}
