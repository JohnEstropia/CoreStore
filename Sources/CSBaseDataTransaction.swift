//
//  CSBaseDataTransaction.swift
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


// MARK: - CSBaseDataTransaction

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
@objc
public class CSBaseDataTransaction: NSObject {
    
    // MARK: Object management

    @objc
    public var hasChanges: Bool {

        fatalError()
    }

    @objc
    public func createInto(_ into: CSInto) -> Any {

        fatalError()
    }

    @objc
    public func editObject(_ object: NSManagedObject?) -> Any? {

        fatalError()
    }

    @objc
    public func editInto(_ into: CSInto, objectID: NSManagedObjectID) -> Any? {

        fatalError()
    }

    @objc
    public func deleteObject(_ object: NSManagedObject?) {

        fatalError()
    }

    @objc
    public func deleteObjects(_ objects: [NSManagedObject]) {

        fatalError()
    }

    @objc
    public func refreshAndMergeAllObjects() {

        fatalError()
    }
    
    
    // MARK: Inspecting Pending Objects

    @objc
    public func insertedObjectsOfType(_ entity: NSManagedObject.Type) -> Set<NSManagedObject> {

        fatalError()
    }

    @objc
    public func insertedObjectIDs() -> Set<NSManagedObjectID> {

        fatalError()
    }

    @objc
    public func insertedObjectIDsOfType(_ entity: NSManagedObject.Type) -> Set<NSManagedObjectID> {

        fatalError()
    }

    @objc
    public func updatedObjectsOfType(_ entity: NSManagedObject.Type) -> Set<NSManagedObject> {

        fatalError()
    }

    @objc
    public func updatedObjectIDs() -> Set<NSManagedObjectID> {

        fatalError()
    }

    @objc
    public func updatedObjectIDsOfType(_ entity: NSManagedObject.Type) -> Set<NSManagedObjectID> {

        fatalError()
    }

    @objc
    public func deletedObjectsOfType(_ entity: NSManagedObject.Type) -> Set<NSManagedObject> {

        fatalError()
    }

    @objc
    public func deletedObjectIDs() -> Set<NSManagedObjectID> {

        fatalError()
    }

    @objc
    public func deletedObjectIDsOfType(_ entity: NSManagedObject.Type) -> Set<NSManagedObjectID> {

        fatalError()
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {

        fatalError()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {

        fatalError()
    }
}
