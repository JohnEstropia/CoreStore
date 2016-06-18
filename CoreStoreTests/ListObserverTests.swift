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


#if os(iOS) || os(watchOS) || os(tvOS)

// MARK: - ListObserverTests

class ListObserverTests: BaseTestDataTestCase {
    
    @objc
    dynamic func test_ThatListObservers_CanReceiveInsertNotifications() {
        
        self.prepareStack { (stack) in
            
            let observer = TestListObserver()
            let monitor = stack.monitorSectionedList(
                From(TestEntity1),
                SectionBy("testBoolean"),
                OrderBy(.Ascending("testBoolean"), .Ascending("testEntityID"))
            )
            monitor.addObserver(observer)
            
            XCTAssertFalse(monitor.hasSections())
            XCTAssertFalse(monitor.hasObjects())
            XCTAssertTrue(monitor.objectsInAllSections().isEmpty)
            
            var events = 0
            
            let willChangeExpectation = self.expectationForNotification(
                "listMonitorWillChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 0)
                    XCTAssertEqual((note.userInfo ?? [:]), NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 0
                }
            )
            let didInsertSectionExpectation = self.expectationForNotification(
                "listMonitor:didInsertSection:toSectionIndex:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 1)
                    XCTAssertEqual(
                        (note.userInfo ?? [:]),
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
            let didInsertObjectExpectation = self.expectationForNotification(
                "listMonitor:didInsertObject:toIndexPath:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 2)
                    
                    let userInfo = note.userInfo
                    XCTAssertNotNil(userInfo)
                    XCTAssertEqual(
                        Set(((userInfo as? [String: AnyObject]) ?? [:]).keys),
                        ["indexPath", "object"]
                    )
                    
                    let indexPath = userInfo?["indexPath"] as? NSIndexPath
                    XCTAssertEqual(indexPath?.section, 0)
                    XCTAssertEqual(indexPath?.row, 0)
                    
                    let object = userInfo?["object"] as? TestEntity1
                    XCTAssertEqual(object?.testBoolean, NSNumber(bool: true))
                    XCTAssertEqual(object?.testNumber, NSNumber(integer: 1))
                    XCTAssertEqual(object?.testDecimal, NSDecimalNumber(string: "1"))
                    XCTAssertEqual(object?.testString, "nil:TestEntity1:1")
                    XCTAssertEqual(object?.testData, ("nil:TestEntity1:1" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                    XCTAssertEqual(object?.testDate, self.dateFormatter.dateFromString("2000-01-01T00:00:00Z")!)
                    defer {
                        
                        events += 1
                    }
                    return events == 2
                }
            )
            let didChangeExpectation = self.expectationForNotification(
                "listMonitorDidChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual((note.userInfo ?? [:]), NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 3
                }
            )
            let saveExpectation = self.expectationWithDescription("save")
            stack.beginAsynchronous { (transaction) in
                
                let object = transaction.create(Into(TestEntity1))
                object.testBoolean = NSNumber(bool: true)
                object.testNumber = NSNumber(integer: 1)
                object.testDecimal = NSDecimalNumber(string: "1")
                object.testString = "nil:TestEntity1:1"
                object.testData = ("nil:TestEntity1:1" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
                object.testDate = self.dateFormatter.dateFromString("2000-01-01T00:00:00Z")!
                
                transaction.commit { (result) in
                    
                    switch result {
                        
                    case .Success(let hasChanges):
                        XCTAssertTrue(hasChanges)
                        saveExpectation.fulfill()
                        
                    case .Failure:
                        XCTFail()
                    }
                }
            }
            self.waitAndCheckExpectations()
        }
    }
    
    @objc
    dynamic func test_ThatListObservers_CanReceiveUpdateNotifications() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            
            let observer = TestListObserver()
            let monitor = stack.monitorSectionedList(
                From(TestEntity1),
                SectionBy("testBoolean"),
                OrderBy(.Ascending("testBoolean"), .Ascending("testEntityID"))
            )
            monitor.addObserver(observer)
            
            XCTAssertTrue(monitor.hasSections())
            XCTAssertEqual(monitor.numberOfSections(), 2)
            XCTAssertTrue(monitor.hasObjects())
            XCTAssertTrue(monitor.hasObjectsInSection(0))
            XCTAssertEqual(monitor.numberOfObjectsInSection(0), 2)
            XCTAssertEqual(monitor.numberOfObjectsInSection(1), 3)
            
            var events = 0
            
            let willChangeExpectation = self.expectationForNotification(
                "listMonitorWillChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 0)
                    XCTAssertEqual((note.userInfo ?? [:]), NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 0
                }
            )
            for _ in 1 ... 2 {
                
                let didUpdateObjectExpectation = self.expectationForNotification(
                    "listMonitor:didUpdateObject:atIndexPath:",
                    object: observer,
                    handler: { (note) -> Bool in
                        
                        XCTAssert(events == 1 || events == 2)
                        
                        let userInfo = note.userInfo
                        XCTAssertNotNil(userInfo)
                        XCTAssertEqual(
                            Set(((userInfo as? [String: AnyObject]) ?? [:]).keys),
                            ["indexPath", "object"]
                        )
                        
                        let indexPath = userInfo?["indexPath"] as? NSIndexPath
                        let object = userInfo?["object"] as? TestEntity1
                        
                        switch object?.testEntityID {
                            
                        case NSNumber(integer: 101)?:
                            XCTAssertEqual(indexPath?.section, 1)
                            XCTAssertEqual(indexPath?.row, 0)
                            
                            XCTAssertEqual(object?.testBoolean, NSNumber(bool: true))
                            XCTAssertEqual(object?.testNumber, NSNumber(integer: 11))
                            XCTAssertEqual(object?.testDecimal, NSDecimalNumber(string: "11"))
                            XCTAssertEqual(object?.testString, "nil:TestEntity1:11")
                            XCTAssertEqual(object?.testData, ("nil:TestEntity1:11" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                            XCTAssertEqual(object?.testDate, self.dateFormatter.dateFromString("2000-01-11T00:00:00Z")!)
                            
                        case NSNumber(integer: 102)?:
                            XCTAssertEqual(indexPath?.section, 0)
                            XCTAssertEqual(indexPath?.row, 0)
                            
                            XCTAssertEqual(object?.testBoolean, NSNumber(bool: false))
                            XCTAssertEqual(object?.testNumber, NSNumber(integer: 22))
                            XCTAssertEqual(object?.testDecimal, NSDecimalNumber(string: "22"))
                            XCTAssertEqual(object?.testString, "nil:TestEntity1:22")
                            XCTAssertEqual(object?.testData, ("nil:TestEntity1:22" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                            XCTAssertEqual(object?.testDate, self.dateFormatter.dateFromString("2000-01-22T00:00:00Z")!)
                            
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
            let didChangeExpectation = self.expectationForNotification(
                "listMonitorDidChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 3)
                    XCTAssertEqual((note.userInfo ?? [:]), NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 3
                }
            )
            let saveExpectation = self.expectationWithDescription("save")
            stack.beginAsynchronous { (transaction) in
                
                if let object = transaction.fetchOne(
                    From(TestEntity1),
                    Where("testEntityID", isEqualTo: 101)) {
                    
                    object.testNumber = NSNumber(integer: 11)
                    object.testDecimal = NSDecimalNumber(string: "11")
                    object.testString = "nil:TestEntity1:11"
                    object.testData = ("nil:TestEntity1:11" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
                    object.testDate = self.dateFormatter.dateFromString("2000-01-11T00:00:00Z")!
                }
                else {
                    
                    XCTFail()
                }
                if let object = transaction.fetchOne(
                    From(TestEntity1),
                    Where("testEntityID", isEqualTo: 102)) {
                    
                    object.testNumber = NSNumber(integer: 22)
                    object.testDecimal = NSDecimalNumber(string: "22")
                    object.testString = "nil:TestEntity1:22"
                    object.testData = ("nil:TestEntity1:22" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
                    object.testDate = self.dateFormatter.dateFromString("2000-01-22T00:00:00Z")!
                }
                else {
                    
                    XCTFail()
                }
                transaction.commit { (result) in
                    
                    switch result {
                        
                    case .Success(let hasChanges):
                        XCTAssertTrue(hasChanges)
                        saveExpectation.fulfill()
                        
                    case .Failure:
                        XCTFail()
                    }
                }
            }
            self.waitAndCheckExpectations()
        }
    }
    
    @objc
    dynamic func test_ThatListObservers_CanReceiveMoveNotifications() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            
            let observer = TestListObserver()
            let monitor = stack.monitorSectionedList(
                From(TestEntity1),
                SectionBy("testBoolean"),
                OrderBy(.Ascending("testBoolean"), .Ascending("testEntityID"))
            )
            monitor.addObserver(observer)
            
            var events = 0
            
            let willChangeExpectation = self.expectationForNotification(
                "listMonitorWillChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 0)
                    XCTAssertEqual((note.userInfo ?? [:]), NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 0
                }
            )
            let didMoveObjectExpectation = self.expectationForNotification(
                "listMonitor:didMoveObject:fromIndexPath:toIndexPath:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 1)
                    
                    let userInfo = note.userInfo
                    XCTAssertNotNil(userInfo)
                    XCTAssertEqual(
                        Set(((userInfo as? [String: AnyObject]) ?? [:]).keys),
                        ["fromIndexPath", "toIndexPath", "object"]
                    )
                    
                    let fromIndexPath = userInfo?["fromIndexPath"] as? NSIndexPath
                    XCTAssertEqual(fromIndexPath?.section, 0)
                    XCTAssertEqual(fromIndexPath?.row, 0)
                    
                    let toIndexPath = userInfo?["toIndexPath"] as? NSIndexPath
                    XCTAssertEqual(toIndexPath?.section, 1)
                    XCTAssertEqual(toIndexPath?.row, 1)
                    
                    let object = userInfo?["object"] as? TestEntity1
                    XCTAssertEqual(object?.testEntityID, NSNumber(integer: 102))
                    XCTAssertEqual(object?.testBoolean, NSNumber(bool: true))
                    
                    defer {
                        
                        events += 1
                    }
                    return events == 1
                }
            )
            let didChangeExpectation = self.expectationForNotification(
                "listMonitorDidChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 2)
                    XCTAssertEqual((note.userInfo ?? [:]), NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 2
                }
            )
            let saveExpectation = self.expectationWithDescription("save")
            stack.beginAsynchronous { (transaction) in
                
                if let object = transaction.fetchOne(
                    From(TestEntity1),
                    Where("testEntityID", isEqualTo: 102)) {
                    
                    object.testBoolean = NSNumber(bool: true)
                }
                else {
                    
                    XCTFail()
                }
                transaction.commit { (result) in
                    
                    switch result {
                        
                    case .Success(let hasChanges):
                        XCTAssertTrue(hasChanges)
                        saveExpectation.fulfill()
                        
                    case .Failure:
                        XCTFail()
                    }
                }
            }
            self.waitAndCheckExpectations()
        }
    }
    
    @objc
    dynamic func test_ThatListObservers_CanReceiveDeleteNotifications() {
        
        self.prepareStack { (stack) in
            
            self.prepareTestDataForStack(stack)
            
            let observer = TestListObserver()
            let monitor = stack.monitorSectionedList(
                From(TestEntity1),
                SectionBy("testBoolean"),
                OrderBy(.Ascending("testBoolean"), .Ascending("testEntityID"))
            )
            monitor.addObserver(observer)
            
            var events = 0
            
            let willChangeExpectation = self.expectationForNotification(
                "listMonitorWillChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 0)
                    XCTAssertEqual((note.userInfo ?? [:]), NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 0
                }
            )
            for _ in 1 ... 2 {
                
                let didUpdateObjectExpectation = self.expectationForNotification(
                    "listMonitor:didDeleteObject:fromIndexPath:",
                    object: observer,
                    handler: { (note) -> Bool in
                        
                        XCTAssert(events == 1 || events == 2)
                        
                        let userInfo = note.userInfo
                        XCTAssertNotNil(userInfo)
                        XCTAssertEqual(
                            Set(((userInfo as? [String: AnyObject]) ?? [:]).keys),
                            ["indexPath", "object"]
                        )
                        
                        let indexPath = userInfo?["indexPath"] as? NSIndexPath
                        
                        XCTAssertEqual(indexPath?.section, 0)
                        XCTAssert(indexPath?.row == 0 || indexPath?.row == 1)
                        
                        let object = userInfo?["object"] as? TestEntity1
                        XCTAssertEqual(object?.deleted, true)
                        
                        defer {
                            
                            events += 1
                        }
                        return events == 1 || events == 2
                    }
                )
            }
            let didDeleteSectionExpectation = self.expectationForNotification(
                "listMonitor:didDeleteSection:fromSectionIndex:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 3)
                    
                    let userInfo = note.userInfo
                    XCTAssertNotNil(userInfo)
                    XCTAssertEqual(
                        Set(((userInfo as? [String: AnyObject]) ?? [:]).keys),
                        ["sectionInfo", "sectionIndex"]
                    )
                    
                    let sectionInfo = userInfo?["sectionInfo"]
                    XCTAssertNotNil(sectionInfo)
                    XCTAssertEqual(sectionInfo?.name, "0")
                    
                    let sectionIndex = userInfo?["sectionIndex"]
                    XCTAssertEqual(sectionIndex as? NSNumber, NSNumber(integer: 0))
                    
                    defer {
                        
                        events += 1
                    }
                    return events == 3
                }
            )
            let didChangeExpectation = self.expectationForNotification(
                "listMonitorDidChange:",
                object: observer,
                handler: { (note) -> Bool in
                    
                    XCTAssertEqual(events, 4)
                    XCTAssertEqual((note.userInfo ?? [:]), NSDictionary())
                    defer {
                        
                        events += 1
                    }
                    return events == 4
                }
            )
            let saveExpectation = self.expectationWithDescription("save")
            stack.beginAsynchronous { (transaction) in
                
                transaction.deleteAll(
                    From(TestEntity1),
                    Where("testBoolean", isEqualTo: false)
                )
                transaction.commit { (result) in
                    
                    switch result {
                        
                    case .Success(let hasChanges):
                        XCTAssertTrue(hasChanges)
                        saveExpectation.fulfill()
                        
                    case .Failure:
                        XCTFail()
                    }
                }
            }
            self.waitAndCheckExpectations()
        }
    }
}


// MARK: TestListObserver

class TestListObserver: ListSectionObserver {
    
    // MARK: ListObserver
    
    typealias ListEntityType = TestEntity1
    
    func listMonitorWillChange(monitor: ListMonitor<TestEntity1>) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            "listMonitorWillChange:",
            object: self,
            userInfo: [:]
        )
    }
    
    func listMonitorDidChange(monitor: ListMonitor<TestEntity1>) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            "listMonitorDidChange:",
            object: self,
            userInfo: [:]
        )
    }
    
    func listMonitorWillRefetch(monitor: ListMonitor<TestEntity1>) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            "listMonitorWillRefetch:",
            object: self,
            userInfo: [:]
        )
    }
    
    func listMonitorDidRefetch(monitor: ListMonitor<TestEntity1>) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            "listMonitorDidRefetch:",
            object: self,
            userInfo: [:]
        )
    }
    
    
    // MARK: ListObjectObserver
    
    func listMonitor(monitor: ListMonitor<TestEntity1>, didInsertObject object: TestEntity1, toIndexPath indexPath: NSIndexPath) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            "listMonitor:didInsertObject:toIndexPath:",
            object: self,
            userInfo: [
                "object": object,
                "indexPath": indexPath
            ]
        )
    }
    
    func listMonitor(monitor: ListMonitor<TestEntity1>, didDeleteObject object: TestEntity1, fromIndexPath indexPath: NSIndexPath) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            "listMonitor:didDeleteObject:fromIndexPath:",
            object: self,
            userInfo: [
                "object": object,
                "indexPath": indexPath
            ]
        )
    }
    
    func listMonitor(monitor: ListMonitor<TestEntity1>, didUpdateObject object: TestEntity1, atIndexPath indexPath: NSIndexPath) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            "listMonitor:didUpdateObject:atIndexPath:",
            object: self,
            userInfo: [
                "object": object,
                "indexPath": indexPath
            ]
        )
    }
    
    
    func listMonitor(monitor: ListMonitor<TestEntity1>, didMoveObject object: TestEntity1, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            "listMonitor:didMoveObject:fromIndexPath:toIndexPath:",
            object: self,
            userInfo: [
                "object": object,
                "fromIndexPath": fromIndexPath,
                "toIndexPath": toIndexPath
            ]
        )
    }
    
    
    // MARK: ListSectionObserver
    
    func listMonitor(monitor: ListMonitor<TestEntity1>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            "listMonitor:didInsertSection:toSectionIndex:",
            object: self,
            userInfo: [
                "sectionInfo": sectionInfo,
                "sectionIndex": sectionIndex
            ]
        )
    }
    
    func listMonitor(monitor: ListMonitor<TestEntity1>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            "listMonitor:didDeleteSection:fromSectionIndex:",
            object: self,
            userInfo: [
                "sectionInfo": sectionInfo,
                "sectionIndex": sectionIndex
            ]
        )
    }
}

#endif
