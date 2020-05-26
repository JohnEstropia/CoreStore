//
//  ObjectPublisherTests.swift
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


// MARK: - ObjectPublisherTests

@available(macOS 10.12, *)
class ObjectPublisherTests: BaseTestDataTestCase {

    @objc
    dynamic func test_ThatObjectPublishers_CanReceiveUpdateNotifications() {

        self.prepareStack { (stack) in

            self.prepareTestDataForStack(stack)

            guard let object = try stack.fetchOne(
                From<TestEntity1>(),
                Where<TestEntity1>(#keyPath(TestEntity1.testEntityID), isEqualTo: 101)) else {

                    XCTFail()
                    return
            }
            let observer = NSObject()
            let objectPublisher = stack.publishObject(object)
            XCTAssertEqual(objectPublisher.object, object)
            XCTAssertNotNil(objectPublisher.snapshot)

            let didChangeExpectation = self.expectation(description: "didChange")
            objectPublisher.addObserver(observer) { objectPublisher in

                XCTAssertEqual(objectPublisher.object?.testNumber, NSNumber(value: 10))
                XCTAssertEqual(objectPublisher.object?.testString, "nil:TestEntity1:10")

                didChangeExpectation.fulfill()
            }

            let saveExpectation = self.expectation(description: "save")
            stack.perform(
                asynchronous: { (transaction) -> Bool in

                    guard let object = transaction.edit(object) else {

                        XCTFail()
                        try transaction.cancel()
                    }
                    object.testNumber = NSNumber(value: 10)
                    object.testString = "nil:TestEntity1:10"

                    return transaction.hasChanges
                },
                success: { (hasChanges) in

                    XCTAssertTrue(hasChanges)
                    saveExpectation.fulfill()
                },
                failure: { _ in

                    XCTFail()
                }
            )
            self.waitAndCheckExpectations()

            withExtendedLifetime(objectPublisher, {})
            withExtendedLifetime(observer, {})
        }
    }

    @objc
    dynamic func test_ThatObjectPublishers_CanReceiveDeleteNotifications() {

        self.prepareStack { (stack) in

            self.prepareTestDataForStack(stack)

            guard let object = try stack.fetchOne(
                From<TestEntity1>(),
                Where<TestEntity1>(#keyPath(TestEntity1.testEntityID), isEqualTo: 101)) else {

                    XCTFail()
                    return
            }
            let observer = NSObject()
            let objectPublisher = stack.publishObject(object)
            XCTAssertEqual(objectPublisher.object, object)
            XCTAssertNotNil(objectPublisher.snapshot)

            let didChangeExpectation = self.expectation(description: "didChange")
            objectPublisher.addObserver(observer) { objectPublisher in

                XCTAssertNil(objectPublisher.object)
                XCTAssertNil(objectPublisher.snapshot)

                didChangeExpectation.fulfill()
            }

            let saveExpectation = self.expectation(description: "save")
            stack.perform(
                asynchronous: { (transaction) -> Bool in

                    guard let object = transaction.edit(object) else {

                        XCTFail()
                        try transaction.cancel()
                    }
                    transaction.delete(object)

                    return transaction.hasChanges
                },
                success: { (hasChanges) in

                    XCTAssertTrue(hasChanges)
                    saveExpectation.fulfill()
                },
                failure: { _ in

                    XCTFail()
                }
            )
            
            self.waitAndCheckExpectations()

            withExtendedLifetime(objectPublisher, {})
            withExtendedLifetime(observer, {})
        }
    }
}

