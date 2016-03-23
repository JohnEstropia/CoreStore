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


// MARK: - DataStack

extension BaseDataTransaction {
    
    var objc: CSBaseDataTransaction {
        
        return CSBaseDataTransaction(self)
    }
}


// MARK: - CSBaseDataTransaction

/**
 The `CSBaseDataTransaction` serves as the Objective-C bridging type for `BaseDataTransaction`.
 */
@objc
public class CSBaseDataTransaction: NSObject {
    
    // MARK: Object management
    
    /**
     Indicates if the transaction has pending changes
     */
    @objc
    public var hasChanges: Bool {
        
        return self.swift.hasChanges
    }
    
    /**
     Creates a new `NSManagedObject` with the specified entity type.
     
     - parameter into: the `Into` clause indicating the destination `NSManagedObject` entity type and the destination configuration
     - returns: a new `NSManagedObject` instance of the specified entity type.
     */
    @objc
    public func create(into into: NSManagedObject.Type) -> NSManagedObject {
        
        return self.swift.create(Into(into))
    }
    
    /**
     Returns an editable proxy of a specified `NSManagedObject`.
     
     - parameter object: the `NSManagedObject` type to be edited
     - returns: an editable proxy for the specified `NSManagedObject`.
     */
    @objc
    @warn_unused_result
    public func edit(object: NSManagedObject?) -> NSManagedObject? {
        
        return self.swift.edit(object)
    }
    
//    /**
//     Returns an editable proxy of the object with the specified `NSManagedObjectID`.
//     
//     - parameter into: an `Into` clause specifying the entity type
//     - parameter objectID: the `NSManagedObjectID` for the object to be edited
//     - returns: an editable proxy for the specified `NSManagedObject`.
//     */
//    @warn_unused_result
//    public func edit<T: NSManagedObject>(into: Into<T>, _ objectID: NSManagedObjectID) -> T? {
//        
//        CoreStore.assert(
//            self.isRunningInAllowedQueue(),
//            "Attempted to update an entity of type \(typeName(T)) outside its designated queue."
//        )
//        CoreStore.assert(
//            into.inferStoreIfPossible
//                || (into.configuration ?? Into.defaultConfigurationName) == objectID.persistentStore?.configurationName,
//            "Attempted to update an entity of type \(typeName(T)) but the specified persistent store do not match the `NSManagedObjectID`."
//        )
//        return self.fetchExisting(objectID) as? T
//    }
//    
//    /**
//     Deletes a specified `NSManagedObject`.
//     
//     - parameter object: the `NSManagedObject` to be deleted
//     */
//    public func delete(object: NSManagedObject?) {
//        
//        CoreStore.assert(
//            self.isRunningInAllowedQueue(),
//            "Attempted to delete an entity outside its designated queue."
//        )
//        guard let object = object else {
//            
//            return
//        }
//        self.context.fetchExisting(object)?.deleteFromContext()
//    }
//    
//    /**
//     Deletes the specified `NSManagedObject`s.
//     
//     - parameter object1: the `NSManagedObject` to be deleted
//     - parameter object2: another `NSManagedObject` to be deleted
//     - parameter objects: other `NSManagedObject`s to be deleted
//     */
//    public func delete(object1: NSManagedObject?, _ object2: NSManagedObject?, _ objects: NSManagedObject?...) {
//        
//        self.delete(([object1, object2] + objects).flatMap { $0 })
//    }
//    
//    /**
//     Deletes the specified `NSManagedObject`s.
//     
//     - parameter objects: the `NSManagedObject`s to be deleted
//     */
//    public func delete<S: SequenceType where S.Generator.Element: NSManagedObject>(objects: S) {
//        
//        CoreStore.assert(
//            self.isRunningInAllowedQueue(),
//            "Attempted to delete entities outside their designated queue."
//        )
//        
//        let context = self.context
//        objects.forEach { context.fetchExisting($0)?.deleteFromContext() }
//    }
//    
//    /**
//     Refreshes all registered objects `NSManagedObject`s in the transaction.
//     */
//    public func refreshAllObjectsAsFaults() {
//        
//        CoreStore.assert(
//            self.isRunningInAllowedQueue(),
//            "Attempted to refresh entities outside their designated queue."
//        )
//        
//        self.context.refreshAllObjectsAsFaults()
//    }
//    
//    
//    // MARK: Inspecting Pending Objects
//    
//    /**
//     Returns all pending `NSManagedObject`s that were inserted to the transaction. This method should not be called after the `commit()` method was called.
//     
//     - returns: a `Set` of pending `NSManagedObject`s that were inserted to the transaction.
//     */
//    public func insertedObjects() -> Set<NSManagedObject> {
//        
//        CoreStore.assert(
//            self.transactionQueue.isCurrentExecutionContext(),
//            "Attempted to access inserted objects from a \(typeName(self)) outside its designated queue."
//        )
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to access inserted objects from an already committed \(typeName(self))."
//        )
//        
//        return self.context.insertedObjects
//    }
//    
//    /**
//     Returns all pending `NSManagedObject`s of the specified type that were inserted to the transaction. This method should not be called after the `commit()` method was called.
//     
//     - parameter entity: the `NSManagedObject` subclass to filter
//     - returns: a `Set` of pending `NSManagedObject`s of the specified type that were inserted to the transaction.
//     */
//    public func insertedObjects<T: NSManagedObject>(entity: T.Type) -> Set<T> {
//        
//        CoreStore.assert(
//            self.transactionQueue.isCurrentExecutionContext(),
//            "Attempted to access inserted objects from a \(typeName(self)) outside its designated queue."
//        )
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to access inserted objects from an already committed \(typeName(self))."
//        )
//        
//        return Set(self.context.insertedObjects.flatMap { $0 as? T })
//    }
//    
//    /**
//     Returns all pending `NSManagedObjectID`s that were inserted to the transaction. This method should not be called after the `commit()` method was called.
//     
//     - returns: a `Set` of pending `NSManagedObjectID`s that were inserted to the transaction.
//     */
//    public func insertedObjectIDs() -> Set<NSManagedObjectID> {
//        
//        CoreStore.assert(
//            self.transactionQueue.isCurrentExecutionContext(),
//            "Attempted to access inserted object IDs from a \(typeName(self)) outside its designated queue."
//        )
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to access inserted objects IDs from an already committed \(typeName(self))."
//        )
//        
//        return Set(self.context.insertedObjects.map { $0.objectID })
//    }
//    
//    /**
//     Returns all pending `NSManagedObjectID`s of the specified type that were inserted to the transaction. This method should not be called after the `commit()` method was called.
//     
//     - parameter entity: the `NSManagedObject` subclass to filter
//     - returns: a `Set` of pending `NSManagedObjectID`s of the specified type that were inserted to the transaction.
//     */
//    public func insertedObjectIDs<T: NSManagedObject>(entity: T.Type) -> Set<NSManagedObjectID> {
//        
//        CoreStore.assert(
//            self.transactionQueue.isCurrentExecutionContext(),
//            "Attempted to access inserted object IDs from a \(typeName(self)) outside its designated queue."
//        )
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to access inserted objects IDs from an already committed \(typeName(self))."
//        )
//        
//        return Set(self.context.insertedObjects.flatMap { $0 as? T }.map { $0.objectID })
//    }
//    
//    /**
//     Returns all pending `NSManagedObject`s that were updated in the transaction. This method should not be called after the `commit()` method was called.
//     
//     - returns: a `Set` of pending `NSManagedObject`s that were updated to the transaction.
//     */
//    public func updatedObjects() -> Set<NSManagedObject> {
//        
//        CoreStore.assert(
//            self.transactionQueue.isCurrentExecutionContext(),
//            "Attempted to access updated objects from a \(typeName(self)) outside its designated queue."
//        )
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to access updated objects from an already committed \(typeName(self))."
//        )
//        
//        return self.context.updatedObjects
//    }
//    
//    /**
//     Returns all pending `NSManagedObject`s of the specified type that were updated in the transaction. This method should not be called after the `commit()` method was called.
//     
//     - parameter entity: the `NSManagedObject` subclass to filter
//     - returns: a `Set` of pending `NSManagedObject`s of the specified type that were updated in the transaction.
//     */
//    public func updatedObjects<T: NSManagedObject>(entity: T.Type) -> Set<T> {
//        
//        CoreStore.assert(
//            self.transactionQueue.isCurrentExecutionContext(),
//            "Attempted to access updated objects from a \(typeName(self)) outside its designated queue."
//        )
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to access updated objects from an already committed \(typeName(self))."
//        )
//        
//        return Set(self.context.updatedObjects.flatMap { $0 as? T })
//    }
//    
//    /**
//     Returns all pending `NSManagedObjectID`s that were updated in the transaction. This method should not be called after the `commit()` method was called.
//     
//     - returns: a `Set` of pending `NSManagedObjectID`s that were updated in the transaction.
//     */
//    public func updatedObjectIDs() -> Set<NSManagedObjectID> {
//        
//        CoreStore.assert(
//            self.transactionQueue.isCurrentExecutionContext(),
//            "Attempted to access updated object IDs from a \(typeName(self)) outside its designated queue."
//        )
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to access updated object IDs from an already committed \(typeName(self))."
//        )
//        
//        return Set(self.context.updatedObjects.map { $0.objectID })
//    }
//    
//    /**
//     Returns all pending `NSManagedObjectID`s of the specified type that were updated in the transaction. This method should not be called after the `commit()` method was called.
//     
//     - parameter entity: the `NSManagedObject` subclass to filter
//     - returns: a `Set` of pending `NSManagedObjectID`s of the specified type that were updated in the transaction.
//     */
//    public func updatedObjectIDs<T: NSManagedObject>(entity: T.Type) -> Set<NSManagedObjectID> {
//        
//        CoreStore.assert(
//            self.transactionQueue.isCurrentExecutionContext(),
//            "Attempted to access updated object IDs from a \(typeName(self)) outside its designated queue."
//        )
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to access updated object IDs from an already committed \(typeName(self))."
//        )
//        
//        return Set(self.context.updatedObjects.flatMap { $0 as? T }.map { $0.objectID })
//    }
//    
//    /**
//     Returns all pending `NSManagedObject`s that were deleted from the transaction. This method should not be called after the `commit()` method was called.
//     
//     - returns: a `Set` of pending `NSManagedObject`s that were deleted from the transaction.
//     */
//    public func deletedObjects() -> Set<NSManagedObject> {
//        
//        CoreStore.assert(
//            self.transactionQueue.isCurrentExecutionContext(),
//            "Attempted to access deleted objects from a \(typeName(self)) outside its designated queue."
//        )
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to access deleted objects from an already committed \(typeName(self))."
//        )
//        
//        return self.context.deletedObjects
//    }
//    
//    /**
//     Returns all pending `NSManagedObject`s of the specified type that were deleted from the transaction. This method should not be called after the `commit()` method was called.
//     
//     - parameter entity: the `NSManagedObject` subclass to filter
//     - returns: a `Set` of pending `NSManagedObject`s of the specified type that were deleted from the transaction.
//     */
//    public func deletedObjects<T: NSManagedObject>(entity: T.Type) -> Set<T> {
//        
//        CoreStore.assert(
//            self.transactionQueue.isCurrentExecutionContext(),
//            "Attempted to access deleted objects from a \(typeName(self)) outside its designated queue."
//        )
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to access deleted objects from an already committed \(typeName(self))."
//        )
//        
//        return Set(self.context.deletedObjects.flatMap { $0 as? T })
//    }
//    
//    /**
//     Returns all pending `NSManagedObjectID`s of the specified type that were deleted from the transaction. This method should not be called after the `commit()` method was called.
//     
//     - parameter entity: the `NSManagedObject` subclass to filter
//     - returns: a `Set` of pending `NSManagedObjectID`s of the specified type that were deleted from the transaction.
//     */
//    public func deletedObjectIDs() -> Set<NSManagedObjectID> {
//        
//        CoreStore.assert(
//            self.transactionQueue.isCurrentExecutionContext(),
//            "Attempted to access deleted object IDs from a \(typeName(self)) outside its designated queue."
//        )
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to access deleted object IDs from an already committed \(typeName(self))."
//        )
//        
//        return Set(self.context.deletedObjects.map { $0.objectID })
//    }
//    
//    /**
//     Returns all pending `NSManagedObjectID`s of the specified type that were deleted from the transaction. This method should not be called after the `commit()` method was called.
//     
//     - parameter entity: the `NSManagedObject` subclass to filter
//     - returns: a `Set` of pending `NSManagedObjectID`s of the specified type that were deleted from the transaction.
//     */
//    public func deletedObjectIDs<T: NSManagedObject>(entity: T.Type) -> Set<NSManagedObjectID> {
//        
//        CoreStore.assert(
//            self.transactionQueue.isCurrentExecutionContext(),
//            "Attempted to access deleted object IDs from a \(typeName(self)) outside its designated queue."
//        )
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to access deleted object IDs from an already committed \(typeName(self))."
//        )
//        
//        return Set(self.context.deletedObjects.flatMap { $0 as? T }.map { $0.objectID })
//    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return ObjectIdentifier(self.swift).hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSBaseDataTransaction else {
            
            return false
        }
        return self.swift === object.swift
    }
    
    
    // MARK: CoreStoreBridge
    
    internal let swift: BaseDataTransaction
    
    internal init(_ swiftObject: BaseDataTransaction) {
        
        self.swift = swiftObject
        super.init()
    }
}
