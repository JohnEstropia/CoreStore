//
//  CSBaseDataTransaction.swift
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

import Foundation
import CoreData


// MARK: - CSBaseDataTransaction

/**
 The `CSBaseDataTransaction` serves as the Objective-C bridging type for `BaseDataTransaction`.
 
 - SeeAlso: `BaseDataTransaction`
 */
@objc
public class CSBaseDataTransaction: NSObject, CoreStoreObjectiveCType {
    
    // MARK: Object management
    
    /**
     Indicates if the transaction has pending changes
     */
    @objc
    public var hasChanges: Bool {
        
        return self.bridgeToSwift.hasChanges
    }
    
    /**
     Creates a new `NSManagedObject` with the specified entity type.
     
     - parameter into: the `CSInto` clause indicating the destination `NSManagedObject` entity type and the destination configuration
     - returns: a new `NSManagedObject` instance of the specified entity type.
     */
    @objc
    public func createInto(into: CSInto) -> AnyObject {
        
        return self.bridgeToSwift.create(into.bridgeToSwift)
    }
    
    /**
     Returns an editable proxy of a specified `NSManagedObject`.
     
     - parameter object: the `NSManagedObject` type to be edited
     - returns: an editable proxy for the specified `NSManagedObject`.
     */
    @objc
    @warn_unused_result
    public func editObject(object: NSManagedObject?) -> AnyObject? {
        
        return self.bridgeToSwift.edit(object)
    }
    
    /**
     Returns an editable proxy of the object with the specified `NSManagedObjectID`.
     
     - parameter into: a `CSInto` clause specifying the entity type
     - parameter objectID: the `NSManagedObjectID` for the object to be edited
     - returns: an editable proxy for the specified `NSManagedObject`.
     */
    @objc
    @warn_unused_result
    public func editInto(into: CSInto, objectID: NSManagedObjectID) -> AnyObject? {
        
        return self.bridgeToSwift.edit(into.bridgeToSwift, objectID)
    }

    /**
     Deletes a specified `NSManagedObject`.
     
     - parameter object: the `NSManagedObject` to be deleted
     */
    @objc
    public func deleteObject(object: NSManagedObject?) {
        
        self.bridgeToSwift.delete(object)
    }
    
    /**
     Deletes the specified `NSManagedObject`s.
     
     - parameter objects: the `NSManagedObject`s to be deleted
     */
    @objc
    public func deleteObjects(objects: [NSManagedObject]) {
        
        self.bridgeToSwift.delete(objects)
    }
    
    /**
     Refreshes all registered objects `NSManagedObject`s in the transaction.
     */
    @objc
    public func refreshAndMergeAllObjects() {
        
        self.bridgeToSwift.refreshAndMergeAllObjects()
    }
    
    
    // MARK: Inspecting Pending Objects
    
    /**
     Returns all pending `NSManagedObject`s that were inserted to the transaction. This method should not be called after the `-commit*:` method was called.
     
     - returns: an `NSSet` of pending `NSManagedObject`s that were inserted to the transaction.
     */
    @objc
    @warn_unused_result
    public func insertedObjects() -> Set<NSManagedObject> {
        
        return self.bridgeToSwift.insertedObjects()
    }
    
    /**
     Returns all pending `NSManagedObject`s of the specified type that were inserted to the transaction. This method should not be called after the `-commit*:` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: an `NSSet` of pending `NSManagedObject`s of the specified type that were inserted to the transaction.
     */
    @objc
    @warn_unused_result
    public func insertedObjectsOfType(entity: NSManagedObject.Type) -> Set<NSManagedObject> {
        
        return self.bridgeToSwift.insertedObjects(entity)
    }
    
    /**
     Returns all pending `NSManagedObjectID`s that were inserted to the transaction. This method should not be called after the `-commit*:` method was called.
     
     - returns: an `NSSet` of pending `NSManagedObjectID`s that were inserted to the transaction.
     */
    @objc
    @warn_unused_result
    public func insertedObjectIDs() -> Set<NSManagedObjectID> {
        
        return self.bridgeToSwift.insertedObjectIDs()
    }
    
    /**
     Returns all pending `NSManagedObjectID`s of the specified type that were inserted to the transaction. This method should not be called after the `-commit*:` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: an `NSSet` of pending `NSManagedObjectID`s of the specified type that were inserted to the transaction.
     */
    @objc
    @warn_unused_result
    public func insertedObjectIDsOfType(entity: NSManagedObject.Type) -> Set<NSManagedObjectID> {
        
        return self.bridgeToSwift.insertedObjectIDs(entity)
    }
    
    /**
     Returns all pending `NSManagedObject`s that were updated in the transaction. This method should not be called after the `-commit*:` method was called.
     
     - returns: an `NSSet` of pending `NSManagedObject`s that were updated to the transaction.
     */
    @objc
    @warn_unused_result
    public func updatedObjects() -> Set<NSManagedObject> {
        
        return self.bridgeToSwift.updatedObjects()
    }
    
    /**
     Returns all pending `NSManagedObject`s of the specified type that were updated in the transaction. This method should not be called after the `-commit*:` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: an `NSSet` of pending `NSManagedObject`s of the specified type that were updated in the transaction.
     */
    @objc
    @warn_unused_result
    public func updatedObjectsOfType(entity: NSManagedObject.Type) -> Set<NSManagedObject> {
        
        return self.bridgeToSwift.updatedObjects(entity)
    }
    
    /**
     Returns all pending `NSManagedObjectID`s that were updated in the transaction. This method should not be called after the `-commit*:` method was called.
     
     - returns: an `NSSet` of pending `NSManagedObjectID`s that were updated in the transaction.
     */
    @objc
    @warn_unused_result
    public func updatedObjectIDs() -> Set<NSManagedObjectID> {
        
        return self.bridgeToSwift.updatedObjectIDs()
    }
    
    /**
     Returns all pending `NSManagedObjectID`s of the specified type that were updated in the transaction. This method should not be called after the `-commit*:` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: an `NSSet` of pending `NSManagedObjectID`s of the specified type that were updated in the transaction.
     */
    @objc
    @warn_unused_result
    public func updatedObjectIDsOfType(entity: NSManagedObject.Type) -> Set<NSManagedObjectID> {
        
        return self.bridgeToSwift.updatedObjectIDs(entity)
    }
    
    /**
     Returns all pending `NSManagedObject`s that were deleted from the transaction. This method should not be called after the `-commit*:` method was called.
     
     - returns: an `NSSet` of pending `NSManagedObject`s that were deleted from the transaction.
     */
    @objc
    @warn_unused_result
    public func deletedObjects() -> Set<NSManagedObject> {
        
        return self.bridgeToSwift.deletedObjects()
    }
    
    /**
     Returns all pending `NSManagedObject`s of the specified type that were deleted from the transaction. This method should not be called after the `-commit*:` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: an `NSSet` of pending `NSManagedObject`s of the specified type that were deleted from the transaction.
     */
    @objc
    @warn_unused_result
    public func deletedObjectsOfType(entity: NSManagedObject.Type) -> Set<NSManagedObject> {
        
        return self.bridgeToSwift.deletedObjects(entity)
    }
    
    /**
     Returns all pending `NSManagedObjectID`s of the specified type that were deleted from the transaction. This method should not be called after the `-commit*:` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: an `NSSet` of pending `NSManagedObjectID`s of the specified type that were deleted from the transaction.
     */
    @objc
    @warn_unused_result
    public func deletedObjectIDs() -> Set<NSManagedObjectID> {
        
        return self.bridgeToSwift.deletedObjectIDs()
    }

    /**
     Returns all pending `NSManagedObjectID`s of the specified type that were deleted from the transaction. This method should not be called after the `-commit*:` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: a `Set` of pending `NSManagedObjectID`s of the specified type that were deleted from the transaction.
     */
    @objc
    @warn_unused_result
    public func deletedObjectIDsOfType(entity: NSManagedObject.Type) -> Set<NSManagedObjectID> {
        
        return self.bridgeToSwift.deletedObjectIDs(entity)
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return ObjectIdentifier(self.bridgeToSwift).hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSBaseDataTransaction else {
            
            return false
        }
        return self.bridgeToSwift === object.bridgeToSwift
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public typealias SwiftType = BaseDataTransaction
    
    public required init(_ swiftValue: BaseDataTransaction) {
        
        self.swiftTransaction = swiftValue
        super.init()
    }
    
    public var bridgeToSwift: BaseDataTransaction {
        
        return self.swiftTransaction
    }
    
    
    // MARK: Private
    
    private let swiftTransaction: BaseDataTransaction
}


// MARK: - BaseDataTransaction

extension BaseDataTransaction: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public typealias ObjectiveCType = CSBaseDataTransaction
}
