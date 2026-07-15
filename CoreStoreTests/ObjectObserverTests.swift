//
//  ObjectObserverTests.swift
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


// MARK: - ObjectObserverTests

class ObjectObserverTests: BaseTestDataTestCase {
    
    @objc
    @MainActor
    dynamic func test_ThatObjectObservers_CanReceiveUpdateNotifications() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            
            guard let object = try stack.fetchOne(
                From<TestEntity1>(),
                Where<TestEntity1>(#keyPath(TestEntity1.testEntityID), isEqualTo: 101)) else {
                    
                    XCTFail()
                    return
            }
            let observer = TestObjectObserver()
            let monitor = stack.monitorObject(object)
            monitor.addObserver(observer)
            
            XCTAssertEqual(monitor.object, object)
            XCTAssertFalse(monitor.isObjectDeleted)
            
            let events: Internals.Mutex<Int> = .init(0)
            let persistentID = object.persistentID()
            
            _ = self.expectation(
                forNotification: NSNotification.Name(rawValue: "objectMonitor:willUpdateObject:"),
                object: observer,
                handler: { (note) -> Bool in
                    
                    nonisolated(unsafe) let note = note
                    return events.withLock { events in
                        
                        XCTAssertEqual(events, 0)
                        XCTAssertEqual(
                            (note.userInfo?["object"] as? TestEntity1)?.persistentID(),
                            persistentID
                        )
                        defer {
                            
                            events += 1
                        }
                        return events == 0
                    }
                }
            )
            _ = self.expectation(
                forNotification: NSNotification.Name(rawValue: "objectMonitor:didUpdateObject:changedPersistentKeys:"),
                object: observer,
                handler: { (note) -> Bool in
                    
                    nonisolated(unsafe) let note = note
                    return events.withLock { events in
                        
                        XCTAssertEqual(events, 1)
                        XCTAssertEqual(
                            (note.userInfo?["object"] as? TestEntity1)?.persistentID(),
                            persistentID
                        )
                        XCTAssertEqual(
                            note.userInfo?["changedPersistentKeys"] as? Set<String>,
                            Set(
                                [
                                    #keyPath(TestEntity1.testNumber),
                                    #keyPath(TestEntity1.testString)
                                ]
                            )
                        )
                        let object = note.userInfo?["object"] as? TestEntity1
                        XCTAssertEqual(object?.testNumber, NSNumber(value: 10))
                        XCTAssertEqual(object?.testString, "nil:TestEntity1:10")
                        
                        defer {
                            
                            events += 1
                        }
                        return events == 1
                    }
                }
            )
            let saveExpectation = self.expectation(description: "save")
            stack.perform(
                asynchronous: { (transaction) -> Bool in
                    
                    guard let object = transaction.edit(persistentID) else {
                        
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
        }
    }
    
    @objc
    @MainActor
    dynamic func test_ThatObjectObservers_CanReceiveDeleteNotifications() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            
            guard let object = try stack.fetchOne(
                From<TestEntity1>(),
                Where<TestEntity1>(#keyPath(TestEntity1.testEntityID), isEqualTo: 101)) else {
                    
                    XCTFail()
                    return
            }
            let observer = TestObjectObserver()
            let monitor = stack.monitorObject(object)
            monitor.addObserver(observer)
            
            XCTAssertEqual(monitor.object, object)
            XCTAssertFalse(monitor.isObjectDeleted)
            
            let events: Internals.Mutex<Int> = .init(0)
            let persistentID = object.persistentID()
            
            _ = self.expectation(
                forNotification: NSNotification.Name(rawValue: "objectMonitor:didDeleteObject:"),
                object: observer,
                handler: { (note) -> Bool in
                    
                    nonisolated(unsafe) let note = note
                    return events.withLock { events in
                        
                        XCTAssertEqual(events, 0)
                        XCTAssertEqual(
                            (note.userInfo?["object"] as? TestEntity1)?.persistentID(),
                            persistentID
                        )
                        defer {
                            
                            events += 1
                        }
                        return events == 0
                    }
                }
            )
            let saveExpectation = self.expectation(description: "save")
            stack.perform(
                asynchronous: { (transaction) -> Bool in
                    
                    guard let object = transaction.edit(persistentID) else {
                        
                        XCTFail()
                        try transaction.cancel()
                    }
                    transaction.delete(object)
                    
                    return transaction.hasChanges
                },
                success: { (hasChanges) in
                    
                    XCTAssertTrue(hasChanges)
                    XCTAssertTrue(monitor.isObjectDeleted)
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


// MARK: TestObjectObserver

final class TestObjectObserver: ObjectObserver {
    
    typealias ObjectEntityType = TestEntity1
    
    func objectMonitor(_ monitor: ObjectMonitor<TestEntity1>, willUpdateObject object: TestEntity1) {
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "objectMonitor:willUpdateObject:"),
            object: self,
            userInfo: [
                "object": object
            ]
        )
    }
    
    func objectMonitor(_ monitor: ObjectMonitor<TestEntity1>, didUpdateObject object: TestEntity1, changedPersistentKeys: Set<String>) {
        
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "objectMonitor:didUpdateObject:changedPersistentKeys:"),
            object: self,
            userInfo: [
                "object": object,
                "changedPersistentKeys": changedPersistentKeys
            ]
        )
    }
    
    func objectMonitor(_ monitor: ObjectMonitor<TestEntity1>, didDeleteObject object: TestEntity1) {
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "objectMonitor:didDeleteObject:"),
            object: self,
            userInfo: [
                "object": object
            ]
        )
    }
}
