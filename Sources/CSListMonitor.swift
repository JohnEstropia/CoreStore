//
//  CSListMonitor.swift
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

import Foundation
import CoreData


// MARK: - CSListMonitor

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
@objc
public final class CSListMonitor: NSObject {
    
    // MARK: Public (Accessors)
    
    @objc
    public subscript(index: Int) -> Any {

        fatalError()
    }

    @objc
    public func objectAtSafeIndex(_ index: Int) -> Any? {

        fatalError()
    }

    @objc
    public func objectAtSectionIndex(_ sectionIndex: Int, itemIndex: Int) -> Any {

        fatalError()
    }

    @objc
    public func objectAtSafeSectionIndex(_ sectionIndex: Int, safeItemIndex itemIndex: Int) -> Any? {

        fatalError()
    }

    @objc
    public func objectAtIndexPath(_ indexPath: IndexPath) -> Any {

        fatalError()
    }

    @objc
    public func objectAtSafeIndexPath(_ indexPath: IndexPath) -> Any? {

        fatalError()
    }

    @objc
    public func hasObjects() -> Bool {

        fatalError()
    }

    @objc
    public func hasObjectsInSection(_ section: Int) -> Bool {

        fatalError()
    }

    @objc
    public func objectsInAllSections() -> [NSManagedObject] {

        fatalError()
    }

    @objc
    public func objectsInSection(_ section: Int) -> [NSManagedObject] {

        fatalError()
    }

    @objc
    public func objectsInSafeSection(safeSectionIndex section: Int) -> [NSManagedObject]? {

        fatalError()
    }

    @objc
    public func numberOfSections() -> Int {

        fatalError()
    }

    @objc
    public func numberOfObjects() -> Int {

        fatalError()
    }

    @objc
    public func numberOfObjectsInSection(_ section: Int) -> Int {

        fatalError()
    }

    @objc
    public func numberOfObjectsInSafeSection(safeSectionIndex section: Int) -> NSNumber? {

        fatalError()
    }

    @objc
    public func sectionInfoAtIndex(_ section: Int) -> NSFetchedResultsSectionInfo {

        fatalError()
    }

    @objc
    public func sectionInfoAtSafeSectionIndex(safeSectionIndex section: Int) -> NSFetchedResultsSectionInfo? {

        fatalError()
    }

    @objc
    public func sections() -> [NSFetchedResultsSectionInfo] {

        fatalError()
    }

    @objc
    public func targetSectionForSectionIndexTitle(title: String, index: Int) -> Int {

        fatalError()
    }

    @objc
    public func sectionIndexTitles() -> [String] {

        fatalError()
    }

    @objc
    public func indexOf(_ object: NSManagedObject) -> NSNumber? {

        fatalError()
    }

    @objc
    public func indexPathOf(_ object: NSManagedObject) -> IndexPath? {

        fatalError()
    }
    
    
    // MARK: Public (Observers)

    @objc
    public func addListObserver(_ observer: CSListObserver) {

        fatalError()
    }

    public func addListObjectObserver(_ observer: CSListObjectObserver) {

        fatalError()
    }

    @objc
    public func addListSectionObserver(_ observer: CSListSectionObserver) {

        fatalError()
    }

    @objc
    public func removeListObserver(_ observer: CSListObserver) {

        fatalError()
    }

    
    // MARK: Public (Refetching)

    @objc
    public var isPendingRefetch: Bool {

        fatalError()
    }

    @objc
    public func refetch(_ fetchClauses: [CSFetchClause]) {

        fatalError()
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {

        fatalError()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {

        fatalError()
    }
    
    public override var description: String {

        fatalError()
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    @nonobjc
    public let bridgeToSwift: ListMonitor<NSManagedObject>
    
    @nonobjc
    public required init<T: NSManagedObject>(_ swiftValue: ListMonitor<T>) {

        fatalError()
    }
}


// MARK: - ListMonitor

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
extension ListMonitor where ListMonitor.ObjectType: NSManagedObject {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSListMonitor {

        fatalError()
    }
}
