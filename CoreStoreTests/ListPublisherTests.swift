//
//  ListPublisherTests.swift
//  CoreStore iOS
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

#if canImport(UIKit) || canImport(AppKit)

import XCTest

@testable
import CoreStore


// MARK: - ListPublisherTests

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
class ListPublisherTests: BaseTestDataTestCase {

    @objc
    dynamic func test_ThatListPublishers_CanReceiveInsertNotifications() {

        self.prepareStack { (stack) in

            let observer = NSObject()
            let listPublisher = stack.publishList(
                From<TestEntity1>(),
                SectionBy(#keyPath(TestEntity1.testBoolean)),
                OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testBoolean)), .ascending(#keyPath(TestEntity1.testEntityID)))
            )
            XCTAssertFalse(listPublisher.snapshot.hasSections())
            XCTAssertFalse(listPublisher.snapshot.hasItems())
            XCTAssertTrue(listPublisher.snapshot.itemIDs.isEmpty)

            let didChangeExpectation = self.expectation(description: "didChange")
            listPublisher.addObserver(observer) { listPublisher in

                XCTAssertTrue(listPublisher.snapshot.hasSections())
                XCTAssertTrue(listPublisher.snapshot.hasItems())
                XCTAssertEqual(listPublisher.snapshot.numberOfItems(inSectionIndex: 0), 1)

                didChangeExpectation.fulfill()
            }
            
            let saveExpectation = self.expectation(description: "save")
            stack.perform(
                asynchronous: { (transaction) -> Bool in

                    let object = transaction.create(Into<TestEntity1>())
                    object.testBoolean = NSNumber(value: true)
                    object.testNumber = NSNumber(value: 1)
                    object.testDecimal = NSDecimalNumber(string: "1")
                    object.testString = "nil:TestEntity1:1"
                    object.testData = ("nil:TestEntity1:1" as NSString).data(using: String.Encoding.utf8.rawValue)!
                    object.testDate = self.dateFormatter.date(from: "2000-01-01T00:00:00Z")!

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

            withExtendedLifetime(listPublisher, {})
            withExtendedLifetime(observer, {})
        }
    }

    @objc
    dynamic func test_ThatListPublishers_CanReceiveUpdateNotifications() {

        self.prepareStack { (stack) in

            self.prepareTestDataForStack(stack)

            let observer = NSObject()
            let listPublisher = stack.publishList(
                From<TestEntity1>(),
                SectionBy(#keyPath(TestEntity1.testBoolean)),
                OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testBoolean)), .ascending(#keyPath(TestEntity1.testEntityID)))
            )
            XCTAssertTrue(listPublisher.snapshot.hasSections())
            XCTAssertEqual(listPublisher.snapshot.numberOfSections, 2)
            XCTAssertTrue(listPublisher.snapshot.hasItems())
            XCTAssertTrue(listPublisher.snapshot.hasItems(inSectionIndex: 0))
            XCTAssertEqual(listPublisher.snapshot.numberOfItems(inSectionIndex: 0), 2)
            XCTAssertEqual(listPublisher.snapshot.numberOfItems(inSectionIndex: 1), 3)

            let didChangeExpectation = self.expectation(description: "didChange")
            listPublisher.addObserver(observer) { listPublisher in

                XCTAssertTrue(listPublisher.snapshot.hasSections())
                XCTAssertEqual(listPublisher.snapshot.numberOfSections, 2)
                XCTAssertTrue(listPublisher.snapshot.hasItems())
                XCTAssertTrue(listPublisher.snapshot.hasItems(inSectionIndex: 0))
                XCTAssertEqual(listPublisher.snapshot.numberOfItems(inSectionIndex: 0), 2)
                XCTAssertEqual(listPublisher.snapshot.numberOfItems(inSectionIndex: 1), 3)

                didChangeExpectation.fulfill()
            }

            let saveExpectation = self.expectation(description: "save")
            stack.perform(
                asynchronous: { (transaction) -> Bool in

                    if let object = try transaction.fetchOne(
                        From<TestEntity1>(),
                        Where<TestEntity1>(#keyPath(TestEntity1.testEntityID), isEqualTo: 101)) {

                        object.testNumber = NSNumber(value: 11)
                        object.testDecimal = NSDecimalNumber(string: "11")
                        object.testString = "nil:TestEntity1:11"
                        object.testData = ("nil:TestEntity1:11" as NSString).data(using: String.Encoding.utf8.rawValue)!
                        object.testDate = self.dateFormatter.date(from: "2000-01-11T00:00:00Z")!
                    }
                    else {

                        XCTFail()
                    }
                    if let object = try transaction.fetchOne(
                        From<TestEntity1>(),
                        Where<TestEntity1>(#keyPath(TestEntity1.testEntityID), isEqualTo: 102)) {

                        object.testNumber = NSNumber(value: 22)
                        object.testDecimal = NSDecimalNumber(string: "22")
                        object.testString = "nil:TestEntity1:22"
                        object.testData = ("nil:TestEntity1:22" as NSString).data(using: String.Encoding.utf8.rawValue)!
                        object.testDate = self.dateFormatter.date(from: "2000-01-22T00:00:00Z")!
                    }
                    else {

                        XCTFail()
                    }
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

            withExtendedLifetime(listPublisher, {})
            withExtendedLifetime(observer, {})
        }
    }

    @objc
    dynamic func test_ThatListPublishers_CanReceiveMoveNotifications() {

        self.prepareStack { (stack) in

            self.prepareTestDataForStack(stack)

            let observer = NSObject()
            let listPublisher = stack.publishList(
                From<TestEntity1>(),
                SectionBy(#keyPath(TestEntity1.testBoolean)),
                OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testBoolean)), .ascending(#keyPath(TestEntity1.testEntityID)))
            )
            XCTAssertTrue(listPublisher.snapshot.hasSections())
            XCTAssertEqual(listPublisher.snapshot.numberOfSections, 2)
            XCTAssertTrue(listPublisher.snapshot.hasItems())
            XCTAssertTrue(listPublisher.snapshot.hasItems(inSectionIndex: 0))
            XCTAssertEqual(listPublisher.snapshot.numberOfItems(inSectionIndex: 0), 2)
            XCTAssertEqual(listPublisher.snapshot.numberOfItems(inSectionIndex: 1), 3)

            let didChangeExpectation = self.expectation(description: "didChange")
            listPublisher.addObserver(observer) { listPublisher in

                XCTAssertTrue(listPublisher.snapshot.hasSections())
                XCTAssertEqual(listPublisher.snapshot.numberOfSections, 2)
                XCTAssertTrue(listPublisher.snapshot.hasItems())
                XCTAssertTrue(listPublisher.snapshot.hasItems(inSectionIndex: 0))
                XCTAssertEqual(listPublisher.snapshot.numberOfItems(inSectionIndex: 0), 1)
                XCTAssertEqual(listPublisher.snapshot.numberOfItems(inSectionIndex: 1), 4)

                didChangeExpectation.fulfill()
            }

            let saveExpectation = self.expectation(description: "save")
            stack.perform(
                asynchronous: { (transaction) -> Bool in

                    if let object = try transaction.fetchOne(
                        From<TestEntity1>(),
                        Where<TestEntity1>(#keyPath(TestEntity1.testEntityID), isEqualTo: 102)) {

                        object.testBoolean = NSNumber(value: true)
                    }
                    else {

                        XCTFail()
                    }
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

            withExtendedLifetime(listPublisher, {})
            withExtendedLifetime(observer, {})
        }
    }

    @objc
    dynamic func test_ThatListPublishers_CanReceiveDeleteNotifications() {

        self.prepareStack { (stack) in

            self.prepareTestDataForStack(stack)

            let observer = NSObject()
            let listPublisher = stack.publishList(
                From<TestEntity1>(),
                SectionBy(#keyPath(TestEntity1.testBoolean)),
                OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testBoolean)), .ascending(#keyPath(TestEntity1.testEntityID)))
            )
            XCTAssertTrue(listPublisher.snapshot.hasSections())
            XCTAssertEqual(listPublisher.snapshot.numberOfSections, 2)
            XCTAssertTrue(listPublisher.snapshot.hasItems())
            XCTAssertTrue(listPublisher.snapshot.hasItems(inSectionIndex: 0))
            XCTAssertEqual(listPublisher.snapshot.numberOfItems(inSectionIndex: 0), 2)
            XCTAssertEqual(listPublisher.snapshot.numberOfItems(inSectionIndex: 1), 3)

            let didChangeExpectation = self.expectation(description: "didChange")
            listPublisher.addObserver(observer) { listPublisher in

            XCTAssertTrue(listPublisher.snapshot.hasSections())
            XCTAssertEqual(listPublisher.snapshot.numberOfSections, 1)
            XCTAssertTrue(listPublisher.snapshot.hasItems())
            XCTAssertTrue(listPublisher.snapshot.hasItems(inSectionIndex: 0))
            XCTAssertEqual(listPublisher.snapshot.numberOfItems(inSectionIndex: 0), 3)

                didChangeExpectation.fulfill()
            }

            let saveExpectation = self.expectation(description: "save")
            stack.perform(
                asynchronous: { (transaction) -> Bool in

                    let count = try transaction.deleteAll(
                        From<TestEntity1>(),
                        Where<TestEntity1>(#keyPath(TestEntity1.testBoolean), isEqualTo: false)
                    )
                    XCTAssertEqual(count, 2)
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
        }
    }
}

#endif

