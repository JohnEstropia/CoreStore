//
//  ListObserverTests.swift
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


// MARK: - ListObserverTests

@available(OSX 10.12, *)
class ListObserverTests: BaseTestDataTestCase {
    
    @objc
    dynamic func test_ThatListObservers_CanReceiveInsertNotifications() {
        
        self.prepareStack { (stack) in
            
            let observer = TestListObserver()
            let monitor = stack.monitorSectionedList(
                From<TestEntity1>(),
                SectionBy(#keyPath(TestEntity1.testBoolean)),
                OrderBy(.ascending(#keyPath(TestEntity1.testBoolean)), .ascending(#keyPath(TestEntity1.testEntityID)))
            )
            monitor.addObserver(observer)
            
            XCTAssertFalse(monitor.hasSections())
            XCTAssertFalse(monitor.hasObjects())
            XCTAssertTrue(monitor.objectsInAllSections().isEmpty)
            
            var events = 0
            
            let willChangeExpectation = self.expectation(
                forNotification: "listMonitorWillChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 0)
                    XCTAssertEqual((note.userInfo as NSDictionary?) ?? [:], NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 0
                }
            )
            let didInsertSectionExpectation = self.expectation(
                forNotification: "listMonitor:didInsertSection:toSectionIndex:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 1)
                    XCTAssertEqual(
                        ((note.userInfo as NSDictionary?) ?? [:]),
                        [
                            "sectionInfo": monitor.sectionInfoAtIndex(0),
                            "sectionIndex": 0
                        ] as NSDictionary
                    )
                    defer {
                        
                        events += 1
                    }
                    return events == 1
                }
            )
            let didInsertObjectExpectation = self.expectation(
                forNotification: "listMonitor:didInsertObject:toIndexPath:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 2)
                    
                    let userInfo = note.userInfo
                    XCTAssertNotNil(userInfo)
                    XCTAssertEqual(
                        Set(userInfo?.keys.map({ $0 as! String }) ?? []),
                        ["indexPath", "object"]
                    )
                    
                    let indexPath = userInfo?["indexPath"] as? NSIndexPath
                    XCTAssertEqual(indexPath?.index(atPosition: 0), 0)
                    XCTAssertEqual(indexPath?.index(atPosition: 1), 0)
                    
                    let object = userInfo?["object"] as? TestEntity1
                    XCTAssertEqual(object?.testBoolean, NSNumber(value: true))
                    XCTAssertEqual(object?.testNumber, NSNumber(value: 1))
                    XCTAssertEqual(object?.testDecimal, NSDecimalNumber(string: "1"))
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:1")
                    XCTAssertEqual(object?.testData, ("nil:TestEntity1:1" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                    XCTAssertEqual(object?.testDate, self.dateFormatter.date(from: "2000-01-01T00:00:00Z")!)
                    defer {
                        
                        events += 1
                    }
                    return events == 2
                }
            )
            let didChangeExpectation = self.expectation(
                forNotification: "listMonitorDidChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual((note.userInfo as NSDictionary?) ?? [:], NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 3
                }
            )
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
        }
    }
    
    @objc
    dynamic func test_ThatListObservers_CanReceiveUpdateNotifications() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            
            let observer = TestListObserver()
            let monitor = stack.monitorSectionedList(
                From<TestEntity1>(),
                SectionBy(#keyPath(TestEntity1.testBoolean)),
                OrderBy(.ascending(#keyPath(TestEntity1.testBoolean)), .ascending(#keyPath(TestEntity1.testEntityID)))
            )
            monitor.addObserver(observer)
            
            XCTAssertTrue(monitor.hasSections())
            XCTAssertEqual(monitor.numberOfSections(), 2)
            XCTAssertTrue(monitor.hasObjects())
            XCTAssertTrue(monitor.hasObjectsInSection(0))
            XCTAssertEqual(monitor.numberOfObjectsInSection(0), 2)
            XCTAssertEqual(monitor.numberOfObjectsInSection(1), 3)
            
            var events = 0
            
            let willChangeExpectation = self.expectation(
                forNotification: "listMonitorWillChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 0)
                    XCTAssertEqual((note.userInfo as NSDictionary?) ?? [:], NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 0
                }
            )
            for _ in 1 ... 2 {
                
                let didUpdateObjectExpectation = self.expectation(
                    forNotification: "listMonitor:didUpdateObject:atIndexPath:",
                    object: observer,
                    handler: { (note) -> Bool in
                        
                        XCTAssert(events == 1 || events == 2)
                        
                        let userInfo = note.userInfo
                        XCTAssertNotNil(userInfo)
                        XCTAssertEqual(
                            Set(userInfo?.keys.map({ $0 as! String }) ?? []),
                            ["indexPath", "object"]
                        )
                        
                        let indexPath = userInfo?["indexPath"] as? NSIndexPath
                        let object = userInfo?["object"] as? TestEntity1
                        
                        switch object?.testEntityID {
                            
                        case NSNumber(value: 101)?:
                            XCTAssertEqual(indexPath?.index(atPosition: 0), 1)
                            XCTAssertEqual(indexPath?.index(atPosition: 1), 0)
                            
                            XCTAssertEqual(object?.testBoolean, NSNumber(value: true))
                            XCTAssertEqual(object?.testNumber, NSNumber(value: 11))
                            XCTAssertEqual(object?.testDecimal, NSDecimalNumber(string: "11"))
                            XCTAssertEqual(object?.testString, "nil:TestEntity1:11")
                            XCTAssertEqual(object?.testData, ("nil:TestEntity1:11" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                            XCTAssertEqual(object?.testDate, self.dateFormatter.date(from: "2000-01-11T00:00:00Z")!)
                            
                        case NSNumber(value: 102)?:
                            XCTAssertEqual(indexPath?.index(atPosition: 0), 0)
                            XCTAssertEqual(indexPath?.index(atPosition: 1), 0)
                            
                            XCTAssertEqual(object?.testBoolean, NSNumber(value: false))
                            XCTAssertEqual(object?.testNumber, NSNumber(value: 22))
                            XCTAssertEqual(object?.testDecimal, NSDecimalNumber(string: "22"))
                            XCTAssertEqual(object?.testString, "nil:TestEntity1:22")
                            XCTAssertEqual(object?.testData, ("nil:TestEntity1:22" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                            XCTAssertEqual(object?.testDate, self.dateFormatter.date(from: "2000-01-22T00:00:00Z")!)
                            
                        default:
                            XCTFail()
                        }
                        defer {
                            
                            events += 1
                        }
                        return events == 1 || events == 2
                    }
                )
            }
            let didChangeExpectation = self.expectation(
                forNotification: "listMonitorDidChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 3)
                    XCTAssertEqual((note.userInfo as NSDictionary?) ?? [:], NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 3
                }
            )
            let saveExpectation = self.expectation(description: "save")
            stack.perform(
                asynchronous: { (transaction) -> Bool in
                    
                    if let object = transaction.fetchOne(
                        From<TestEntity1>(),
                        Where(#keyPath(TestEntity1.testEntityID), isEqualTo: 101)) {
                        
                        object.testNumber = NSNumber(value: 11)
                        object.testDecimal = NSDecimalNumber(string: "11")
                        object.testString = "nil:TestEntity1:11"
                        object.testData = ("nil:TestEntity1:11" as NSString).data(using: String.Encoding.utf8.rawValue)!
                        object.testDate = self.dateFormatter.date(from: "2000-01-11T00:00:00Z")!
                    }
                    else {
                        
                        XCTFail()
                    }
                    if let object = transaction.fetchOne(
                        From<TestEntity1>(),
                        Where(#keyPath(TestEntity1.testEntityID), isEqualTo: 102)) {
                        
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
        }
    }
    
    @objc
    dynamic func test_ThatListObservers_CanReceiveMoveNotifications() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            
            let observer = TestListObserver()
            let monitor = stack.monitorSectionedList(
                From<TestEntity1>(),
                SectionBy(#keyPath(TestEntity1.testBoolean)),
                OrderBy(.ascending(#keyPath(TestEntity1.testBoolean)), .ascending(#keyPath(TestEntity1.testEntityID)))
            )
            monitor.addObserver(observer)
            
            var events = 0
            
            let willChangeExpectation = self.expectation(
                forNotification: "listMonitorWillChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 0)
                    XCTAssertEqual((note.userInfo as NSDictionary?) ?? [:], NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 0
                }
            )
            let didMoveObjectExpectation = self.expectation(
                forNotification: "listMonitor:didMoveObject:fromIndexPath:toIndexPath:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 1)
                    
                    let userInfo = note.userInfo
                    XCTAssertNotNil(userInfo)
                    XCTAssertEqual(
                        Set(userInfo?.keys.map({ $0 as! String }) ?? []),
                        ["fromIndexPath", "toIndexPath", "object"]
                    )
                    
                    let fromIndexPath = userInfo?["fromIndexPath"] as? NSIndexPath
                    XCTAssertEqual(fromIndexPath?.index(atPosition: 0), 0)
                    XCTAssertEqual(fromIndexPath?.index(atPosition: 1), 0)
                    
                    let toIndexPath = userInfo?["toIndexPath"] as? NSIndexPath
                    XCTAssertEqual(toIndexPath?.index(atPosition: 0), 1)
                    XCTAssertEqual(toIndexPath?.index(atPosition: 1), 1)
                    
                    let object = userInfo?["object"] as? TestEntity1
                    XCTAssertEqual(object?.testEntityID, NSNumber(value: 102))
                    XCTAssertEqual(object?.testBoolean, NSNumber(value: true))
                    
                    defer {
                        
                        events += 1
                    }
                    return events == 1
                }
            )
            let didChangeExpectation = self.expectation(
                forNotification: "listMonitorDidChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 2)
                    XCTAssertEqual((note.userInfo as NSDictionary?) ?? [:], NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 2
                }
            )
            let saveExpectation = self.expectation(description: "save")
            stack.perform(
                asynchronous: { (transaction) -> Bool in
                    
                    if let object = transaction.fetchOne(
                        From<TestEntity1>(),
                        Where(#keyPath(TestEntity1.testEntityID), isEqualTo: 102)) {
                        
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
        }
    }
    
    @objc
    dynamic func test_ThatListObservers_CanReceiveDeleteNotifications() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            
            let observer = TestListObserver()
            let monitor = stack.monitorSectionedList(
                From<TestEntity1>(),
                SectionBy(#keyPath(TestEntity1.testBoolean)),
                OrderBy(.ascending(#keyPath(TestEntity1.testBoolean)), .ascending(#keyPath(TestEntity1.testEntityID)))
            )
            monitor.addObserver(observer)
            
            var events = 0
            
            let willChangeExpectation = self.expectation(
                forNotification: "listMonitorWillChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 0)
                    XCTAssertEqual((note.userInfo as NSDictionary?) ?? [:], NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 0
                }
            )
            for _ in 1 ... 2 {
                
                let didUpdateObjectExpectation = self.expectation(
                    forNotification: "listMonitor:didDeleteObject:fromIndexPath:",
                    object: observer,
                    handler: { (note) -> Bool in
                        
                        XCTAssert(events == 1 || events == 2)
                        
                        let userInfo = note.userInfo
                        XCTAssertNotNil(userInfo)
                        XCTAssertEqual(
                            Set(userInfo?.keys.map({ $0 as! String }) ?? []),
                            ["indexPath", "object"]
                        )
                        
                        let indexPath = userInfo?["indexPath"] as? NSIndexPath
                        
                        XCTAssertEqual(indexPath?.section, 0)
                        XCTAssert(indexPath?.index(atPosition: 1) == 0 || indexPath?.index(atPosition: 1) == 1)
                        
                        let object = userInfo?["object"] as? TestEntity1
                        XCTAssertEqual(object?.isDeleted, true)
                        
                        defer {
                            
                            events += 1
                        }
                        return events == 1 || events == 2
                    }
                )
            }
            let didDeleteSectionExpectation = self.expectation(
                forNotification: "listMonitor:didDeleteSection:fromSectionIndex:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 3)
                    
                    let userInfo = note.userInfo
                    XCTAssertNotNil(userInfo)
                    XCTAssertEqual(
                        Set(userInfo?.keys.map({ $0 as! String }) ?? []),
                        ["sectionInfo", "sectionIndex"]
                    )
                    
                    let sectionInfo = userInfo?["sectionInfo"] as? NSFetchedResultsSectionInfo
                    XCTAssertNotNil(sectionInfo)
                    XCTAssertEqual(sectionInfo?.name, "0")
                    
                    let sectionIndex = userInfo?["sectionIndex"]
                    XCTAssertEqual(sectionIndex as? NSNumber, NSNumber(value: 0))
                    
                    defer {
                        
                        events += 1
                    }
                    return events == 3
                }
            )
            let didChangeExpectation = self.expectation(
                forNotification: "listMonitorDidChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 4)
                    XCTAssertEqual((note.userInfo as NSDictionary?) ?? [:], NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 4
                }
            )
            let saveExpectation = self.expectation(description: "save")
            stack.perform(
                asynchronous: { (transaction) -> Bool in
                    
                    transaction.deleteAll(
                        From<TestEntity1>(),
                        Where(#keyPath(TestEntity1.testBoolean), isEqualTo: false)
                    )
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


// MARK: TestListObserver

@available(OSX 10.12, *)
class TestListObserver: ListSectionObserver {
    
    // MARK: ListObserver
    
    typealias ListEntityType = TestEntity1
    
    func listMonitorWillChange(_ monitor: ListMonitor<TestEntity1>) {
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "listMonitorWillChange:"),
            object: self,
            userInfo: [:]
        )
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<TestEntity1>) {
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "listMonitorDidChange:"),
            object: self,
            userInfo: [:]
        )
    }
    
    func listMonitorWillRefetch(_ monitor: ListMonitor<TestEntity1>) {
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "listMonitorWillRefetch:"),
            object: self,
            userInfo: [:]
        )
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<TestEntity1>) {
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "listMonitorDidRefetch:"),
            object: self,
            userInfo: [:]
        )
    }
    
    
    // MARK: ListObjectObserver
    
    func listMonitor(_ monitor: ListMonitor<TestEntity1>, didInsertObject object: TestEntity1, toIndexPath indexPath: IndexPath) {
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "listMonitor:didInsertObject:toIndexPath:"),
            object: self,
            userInfo: [
                "object": object,
                "indexPath": indexPath
            ]
        )
    }
    
    func listMonitor(_ monitor: ListMonitor<TestEntity1>, didDeleteObject object: TestEntity1, fromIndexPath indexPath: IndexPath) {
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "listMonitor:didDeleteObject:fromIndexPath:"),
            object: self,
            userInfo: [
                "object": object,
                "indexPath": indexPath
            ]
        )
    }
    
    func listMonitor(_ monitor: ListMonitor<TestEntity1>, didUpdateObject object: TestEntity1, atIndexPath indexPath: IndexPath) {
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "listMonitor:didUpdateObject:atIndexPath:"),
            object: self,
            userInfo: [
                "object": object,
                "indexPath": indexPath
            ]
        )
    }
    
    
    func listMonitor(_ monitor: ListMonitor<TestEntity1>, didMoveObject object: TestEntity1, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "listMonitor:didMoveObject:fromIndexPath:toIndexPath:"),
            object: self,
            userInfo: [
                "object": object,
                "fromIndexPath": fromIndexPath,
                "toIndexPath": toIndexPath
            ]
        )
    }
    
    
    // MARK: ListSectionObserver
    
    func listMonitor(_ monitor: ListMonitor<TestEntity1>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "listMonitor:didInsertSection:toSectionIndex:"),
            object: self,
            userInfo: [
                "sectionInfo": sectionInfo,
                "sectionIndex": sectionIndex
            ]
        )
    }
    
    func listMonitor(_ monitor: ListMonitor<TestEntity1>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "listMonitor:didDeleteSection:fromSectionIndex:"),
            object: self,
            userInfo: [
                "sectionInfo": sectionInfo,
                "sectionIndex": sectionIndex
            ]
        )
    }
}
