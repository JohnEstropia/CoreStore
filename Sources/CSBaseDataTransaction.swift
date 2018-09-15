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

/**
 The `CSBaseDataTransaction` serves as the Objective-C bridging type for `BaseDataTransaction`.
 
 - SeeAlso: `BaseDataTransaction`
 */
@objc
public class CSBaseDataTransaction: NSObject {
    
    // MARK: Object management
    
    /**
     Indicates if the transaction has pending changes
     */
    @objc
    public var hasChanges: Bool {
        
        return self.swiftTransaction.hasChanges
    }
    
    /**
     Creates a new `NSManagedObject` with the specified entity type.
     
     - parameter into: the `CSInto` clause indicating the destination `NSManagedObject` entity type and the destination configuration
     - returns: a new `NSManagedObject` instance of the specified entity type.
     */
    @objc
    public func createInto(_ into: CSInto) -> Any {
        
        return self.swiftTransaction.create(into.bridgeToSwift)
    }
    
    /**
     Returns an editable proxy of a specified `NSManagedObject`.
     
     - parameter object: the `NSManagedObject` type to be edited
     - returns: an editable proxy for the specified `NSManagedObject`.
     */
    @objc
    public func editObject(_ object: NSManagedObject?) -> Any? {
        
        return self.swiftTransaction.edit(object)
    }
    
    /**
     Returns an editable proxy of the object with the specified `NSManagedObjectID`.
     
     - parameter into: a `CSInto` clause specifying the entity type
     - parameter objectID: the `NSManagedObjectID` for the object to be edited
     - returns: an editable proxy for the specified `NSManagedObject`.
     */
    @objc
    public func editInto(_ into: CSInto, objectID: NSManagedObjectID) -> Any? {
        
        return self.swiftTransaction.edit(into.bridgeToSwift, objectID)
    }

    /**
     Deletes a specified `NSManagedObject`.
     
     - parameter object: the `NSManagedObject` to be deleted
     */
    @objc
    public func deleteObject(_ object: NSManagedObject?) {
        
        self.swiftTransaction.delete(object)
    }
    
    /**
     Deletes the specified `NSManagedObject`s.
     
     - parameter objects: the `NSManagedObject`s to be deleted
     */
    @objc
    public func deleteObjects(_ objects: [NSManagedObject]) {
        
        self.swiftTransaction.delete(objects)
    }
    
    /**
     Refreshes all registered objects `NSManagedObject`s in the transaction.
     */
    @objc
    public func refreshAndMergeAllObjects() {
        
        self.swiftTransaction.refreshAndMergeAllObjects()
    }
    
    
    // MARK: Inspecting Pending Objects
    
    /**
     Returns all pending `NSManagedObject`s of the specified type that were inserted to the transaction. This method should not be called after the `-commit*:` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: an `NSSet` of pending `NSManagedObject`s of the specified type that were inserted to the transaction.
     */
    @objc
    public func insertedObjectsOfType(_ entity: NSManagedObject.Type) -> Set<NSManagedObject> {
        
        return self.swiftTransaction.insertedObjects(entity)
    }
    
    /**
     Returns all pending `NSManagedObjectID`s that were inserted to the transaction. This method should not be called after the `-commit*:` method was called.
     
     - returns: an `NSSet` of pending `NSManagedObjectID`s that were inserted to the transaction.
     */
    @objc
    public func insertedObjectIDs() -> Set<NSManagedObjectID> {
        
        return self.swiftTransaction.insertedObjectIDs()
    }
    
    /**
     Returns all pending `NSManagedObjectID`s of the specified type that were inserted to the transaction. This method should not be called after the `-commit*:` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: an `NSSet` of pending `NSManagedObjectID`s of the specified type that were inserted to the transaction.
     */
    @objc
    public func insertedObjectIDsOfType(_ entity: NSManagedObject.Type) -> Set<NSManagedObjectID> {
        
        return self.swiftTransaction.insertedObjectIDs(entity)
    }
    
    /**
     Returns all pending `NSManagedObject`s of the specified type that were updated in the transaction. This method should not be called after the `-commit*:` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: an `NSSet` of pending `NSManagedObject`s of the specified type that were updated in the transaction.
     */
    @objc
    public func updatedObjectsOfType(_ entity: NSManagedObject.Type) -> Set<NSManagedObject> {
        
        return self.swiftTransaction.updatedObjects(entity)
    }
    
    /**
     Returns all pending `NSManagedObjectID`s that were updated in the transaction. This method should not be called after the `-commit*:` method was called.
     
     - returns: an `NSSet` of pending `NSManagedObjectID`s that were updated in the transaction.
     */
    @objc
    public func updatedObjectIDs() -> Set<NSManagedObjectID> {
        
        return self.swiftTransaction.updatedObjectIDs()
    }
    
    /**
     Returns all pending `NSManagedObjectID`s of the specified type that were updated in the transaction. This method should not be called after the `-commit*:` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: an `NSSet` of pending `NSManagedObjectID`s of the specified type that were updated in the transaction.
     */
    @objc
    public func updatedObjectIDsOfType(_ entity: NSManagedObject.Type) -> Set<NSManagedObjectID> {
        
        return self.swiftTransaction.updatedObjectIDs(entity)
    }
    
    /**
     Returns all pending `NSManagedObject`s of the specified type that were deleted from the transaction. This method should not be called after the `-commit*:` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: an `NSSet` of pending `NSManagedObject`s of the specified type that were deleted from the transaction.
     */
    @objc
    public func deletedObjectsOfType(_ entity: NSManagedObject.Type) -> Set<NSManagedObject> {
        
        return self.swiftTransaction.deletedObjects(entity)
    }
    
    /**
     Returns all pending `NSManagedObjectID`s of the specified type that were deleted from the transaction. This method should not be called after the `-commit*:` method was called.
     
     - returns: an `NSSet` of pending `NSManagedObjectID`s of the specified type that were deleted from the transaction.
     */
    @objc
    public func deletedObjectIDs() -> Set<NSManagedObjectID> {
        
        return self.swiftTransaction.deletedObjectIDs()
    }

    /**
     Returns all pending `NSManagedObjectID`s of the specified type that were deleted from the transaction. This method should not be called after the `-commit*:` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: a `Set` of pending `NSManagedObjectID`s of the specified type that were deleted from the transaction.
     */
    @objc
    public func deletedObjectIDsOfType(_ entity: NSManagedObject.Type) -> Set<NSManagedObjectID> {
        
        return self.swiftTransaction.deletedObjectIDs(entity)
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return ObjectIdentifier(self.swiftTransaction).hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let object = object as? CSBaseDataTransaction else {
            
            return false
        }
        return self.swiftTransaction === object.swiftTransaction
    }
    
    
    // MARK: Internal
    
    internal let swiftTransaction: BaseDataTransaction
    
    internal init(_ swiftValue: BaseDataTransaction) {
        
        self.swiftTransaction = swiftValue
        super.init()
    }
    
    
    // MARK: Deprecated
    
    @available(*, deprecated, message: "Use -[insertedObjectsOfType:] and pass the specific entity class")
    @objc
    public func insertedObjects() -> Set<NSManagedObject> {
        
        return self.swiftTransaction.insertedObjects()
    }
    
    @available(*, deprecated, message: "Use -[updatedObjectsOfType:] and pass the specific entity class")
    @objc
    public func updatedObjects() -> Set<NSManagedObject> {
        
        return self.swiftTransaction.updatedObjects()
    }
    
    @available(*, deprecated, message: "Use -[deletedObjectsOfType:] and pass the specific entity class")
    @objc
    public func deletedObjects() -> Set<NSManagedObject> {
        
        return self.swiftTransaction.deletedObjects()
    }
}
