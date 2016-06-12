//
//  BaseDataTransaction.swift
//  CoreStore
//
//  Copyright © 2014 John Rommel Estropia
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
#if USE_FRAMEWORKS
    import GCDKit
#endif


// MARK: - BaseDataTransaction

/**
 The `BaseDataTransaction` is an abstract interface for `NSManagedObject` creates, updates, and deletes. All `BaseDataTransaction` subclasses manage a private `NSManagedObjectContext` which are direct children of the `NSPersistentStoreCoordinator`'s root `NSManagedObjectContext`. This means that all updates are saved first to the persistent store, and then propagated up to the read-only `NSManagedObjectContext`.
 */
public /*abstract*/ class BaseDataTransaction {
    
    // MARK: Object management
    
    /**
     Indicates if the transaction has pending changes
     */
    public var hasChanges: Bool {
        
        return self.context.hasChanges
    }
    
    /**
     Creates a new `NSManagedObject` with the specified entity type.
     
     - parameter into: the `Into` clause indicating the destination `NSManagedObject` entity type and the destination configuration
     - returns: a new `NSManagedObject` instance of the specified entity type.
     */
    public func create<T: NSManagedObject>(into: Into<T>) -> T {
        
        CoreStore.assert(
            self.isRunningInAllowedQueue(),
            "Attempted to create an entity of type \(cs_typeName(T)) outside its designated queue."
        )
        
        let context = self.context
        let entityClass = (into.entityClass as! NSManagedObject.Type)
        if into.inferStoreIfPossible {
            
            switch context.parentStack!.persistentStoreForEntityClass(
                entityClass,
                configuration: nil,
                inferStoreIfPossible: true
            ) {
                
            case (let persistentStore?, _):
                let object = entityClass.createInContext(context) as! T
                context.assignObject(object, toPersistentStore: persistentStore)
                return object
                
            case (nil, true):
                CoreStore.abort("Attempted to create an entity of type \(cs_typeName(entityClass)) with ambiguous destination persistent store, but the configuration name was not specified.")
                
            default:
                CoreStore.abort("Attempted to create an entity of type \(cs_typeName(entityClass)), but a destination persistent store containing the entity type could not be found.")
            }
        }
        else {
            
            switch context.parentStack!.persistentStoreForEntityClass(
                entityClass,
                configuration: into.configuration
                    ?? into.dynamicType.defaultConfigurationName,
                inferStoreIfPossible: false
            ) {
                
            case (let persistentStore?, _):
                let object = entityClass.createInContext(context) as! T
                context.assignObject(object, toPersistentStore: persistentStore)
                return object
                
            case (nil, true):
                CoreStore.abort("Attempted to create an entity of type \(cs_typeName(entityClass)) with ambiguous destination persistent store, but the configuration name was not specified.")
                
            default:
                if let configuration = into.configuration {
                    
                    CoreStore.abort("Attempted to create an entity of type \(cs_typeName(entityClass)) into the configuration \"\(configuration)\", which it doesn't belong to.")
                }
                else {
                    
                    CoreStore.abort("Attempted to create an entity of type \(cs_typeName(entityClass)) into the default configuration, which it doesn't belong to.")
                }
            }
        }
    }
    
    /**
     Returns an editable proxy of a specified `NSManagedObject`.
     
     - parameter object: the `NSManagedObject` type to be edited
     - returns: an editable proxy for the specified `NSManagedObject`.
     */
    @warn_unused_result
    public func edit<T: NSManagedObject>(object: T?) -> T? {
        
        CoreStore.assert(
            self.isRunningInAllowedQueue(),
            "Attempted to update an entity of type \(cs_typeName(object)) outside its designated queue."
        )
        guard let object = object else {
            
            return nil
        }
        return self.context.fetchExisting(object)
    }
    
    /**
     Returns an editable proxy of the object with the specified `NSManagedObjectID`.
     
     - parameter into: an `Into` clause specifying the entity type
     - parameter objectID: the `NSManagedObjectID` for the object to be edited
     - returns: an editable proxy for the specified `NSManagedObject`.
     */
    @warn_unused_result
    public func edit<T: NSManagedObject>(into: Into<T>, _ objectID: NSManagedObjectID) -> T? {
        
        CoreStore.assert(
            self.isRunningInAllowedQueue(),
            "Attempted to update an entity of type \(cs_typeName(T)) outside its designated queue."
        )
        CoreStore.assert(
            into.inferStoreIfPossible
                || (into.configuration ?? Into.defaultConfigurationName) == objectID.persistentStore?.configurationName,
            "Attempted to update an entity of type \(cs_typeName(T)) but the specified persistent store do not match the `NSManagedObjectID`."
        )
        return self.fetchExisting(objectID) as? T
    }
    
    /**
     Deletes a specified `NSManagedObject`.
     
     - parameter object: the `NSManagedObject` to be deleted
     */
    public func delete(object: NSManagedObject?) {
        
        CoreStore.assert(
            self.isRunningInAllowedQueue(),
            "Attempted to delete an entity outside its designated queue."
        )
        guard let object = object else {
            
            return
        }
        self.context.fetchExisting(object)?.deleteFromContext()
    }
    
    /**
     Deletes the specified `NSManagedObject`s.
     
     - parameter object1: the `NSManagedObject` to be deleted
     - parameter object2: another `NSManagedObject` to be deleted
     - parameter objects: other `NSManagedObject`s to be deleted
     */
    public func delete(object1: NSManagedObject?, _ object2: NSManagedObject?, _ objects: NSManagedObject?...) {
        
        self.delete(([object1, object2] + objects).flatMap { $0 })
    }
    
    /**
     Deletes the specified `NSManagedObject`s.
     
     - parameter objects: the `NSManagedObject`s to be deleted
     */
    public func delete<S: SequenceType where S.Generator.Element: NSManagedObject>(objects: S) {
        
        CoreStore.assert(
            self.isRunningInAllowedQueue(),
            "Attempted to delete entities outside their designated queue."
        )
        
        let context = self.context
        objects.forEach { context.fetchExisting($0)?.deleteFromContext() }
    }
    
    /**
     Refreshes all registered objects `NSManagedObject`s in the transaction.
     */
    public func refreshAndMergeAllObjects() {
        
        CoreStore.assert(
            self.isRunningInAllowedQueue(),
            "Attempted to refresh entities outside their designated queue."
        )
        
        self.context.refreshAndMergeAllObjects()
    }
    
    
    // MARK: Inspecting Pending Objects
    
    /**
    Returns all pending `NSManagedObject`s that were inserted to the transaction. This method should not be called after the `commit()` method was called.
    
    - returns: a `Set` of pending `NSManagedObject`s that were inserted to the transaction.
     */
    @warn_unused_result
    public func insertedObjects() -> Set<NSManagedObject> {
        
        CoreStore.assert(
            self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to access inserted objects from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access inserted objects from an already committed \(cs_typeName(self))."
        )
        
        return self.context.insertedObjects
    }
    
    /**
     Returns all pending `NSManagedObject`s of the specified type that were inserted to the transaction. This method should not be called after the `commit()` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: a `Set` of pending `NSManagedObject`s of the specified type that were inserted to the transaction.
     */
    @warn_unused_result
    public func insertedObjects<T: NSManagedObject>(entity: T.Type) -> Set<T> {
        
        CoreStore.assert(
            self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to access inserted objects from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access inserted objects from an already committed \(cs_typeName(self))."
        )
        
        return Set(self.context.insertedObjects.flatMap { $0 as? T })
    }
    
    /**
     Returns all pending `NSManagedObjectID`s that were inserted to the transaction. This method should not be called after the `commit()` method was called.
     
     - returns: a `Set` of pending `NSManagedObjectID`s that were inserted to the transaction.
     */
    @warn_unused_result
    public func insertedObjectIDs() -> Set<NSManagedObjectID> {
        
        CoreStore.assert(
            self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to access inserted object IDs from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access inserted objects IDs from an already committed \(cs_typeName(self))."
        )
        
        return Set(self.context.insertedObjects.map { $0.objectID })
    }
    
    /**
     Returns all pending `NSManagedObjectID`s of the specified type that were inserted to the transaction. This method should not be called after the `commit()` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: a `Set` of pending `NSManagedObjectID`s of the specified type that were inserted to the transaction.
     */
    @warn_unused_result
    public func insertedObjectIDs<T: NSManagedObject>(entity: T.Type) -> Set<NSManagedObjectID> {
        
        CoreStore.assert(
            self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to access inserted object IDs from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access inserted objects IDs from an already committed \(cs_typeName(self))."
        )
        
        return Set(self.context.insertedObjects.filter { $0.isKindOfClass(entity) }.map { $0.objectID })
    }
    
    /**
     Returns all pending `NSManagedObject`s that were updated in the transaction. This method should not be called after the `commit()` method was called.
     
     - returns: a `Set` of pending `NSManagedObject`s that were updated to the transaction.
     */
    @warn_unused_result
    public func updatedObjects() -> Set<NSManagedObject> {
        
        CoreStore.assert(
            self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to access updated objects from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access updated objects from an already committed \(cs_typeName(self))."
        )
        
        return self.context.updatedObjects
    }
    
    /**
     Returns all pending `NSManagedObject`s of the specified type that were updated in the transaction. This method should not be called after the `commit()` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: a `Set` of pending `NSManagedObject`s of the specified type that were updated in the transaction.
     */
    @warn_unused_result
    public func updatedObjects<T: NSManagedObject>(entity: T.Type) -> Set<T> {
        
        CoreStore.assert(
            self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to access updated objects from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access updated objects from an already committed \(cs_typeName(self))."
        )
        
        return Set(self.context.updatedObjects.filter { $0.isKindOfClass(entity) }.map { $0 as! T })
    }
    
    /**
     Returns all pending `NSManagedObjectID`s that were updated in the transaction. This method should not be called after the `commit()` method was called.
     
     - returns: a `Set` of pending `NSManagedObjectID`s that were updated in the transaction.
     */
    @warn_unused_result
    public func updatedObjectIDs() -> Set<NSManagedObjectID> {
        
        CoreStore.assert(
            self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to access updated object IDs from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access updated object IDs from an already committed \(cs_typeName(self))."
        )
        
        return Set(self.context.updatedObjects.map { $0.objectID })
    }
    
    /**
     Returns all pending `NSManagedObjectID`s of the specified type that were updated in the transaction. This method should not be called after the `commit()` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: a `Set` of pending `NSManagedObjectID`s of the specified type that were updated in the transaction.
     */
    @warn_unused_result
    public func updatedObjectIDs<T: NSManagedObject>(entity: T.Type) -> Set<NSManagedObjectID> {
        
        CoreStore.assert(
            self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to access updated object IDs from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access updated object IDs from an already committed \(cs_typeName(self))."
        )
        
        return Set(self.context.updatedObjects.filter { $0.isKindOfClass(entity) }.map { $0.objectID })
    }
    
    /**
     Returns all pending `NSManagedObject`s that were deleted from the transaction. This method should not be called after the `commit()` method was called.
     
     - returns: a `Set` of pending `NSManagedObject`s that were deleted from the transaction.
     */
    @warn_unused_result
    public func deletedObjects() -> Set<NSManagedObject> {
        
        CoreStore.assert(
            self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to access deleted objects from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access deleted objects from an already committed \(cs_typeName(self))."
        )
        
        return self.context.deletedObjects
    }
    
    /**
     Returns all pending `NSManagedObject`s of the specified type that were deleted from the transaction. This method should not be called after the `commit()` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: a `Set` of pending `NSManagedObject`s of the specified type that were deleted from the transaction.
     */
    @warn_unused_result
    public func deletedObjects<T: NSManagedObject>(entity: T.Type) -> Set<T> {
        
        CoreStore.assert(
            self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to access deleted objects from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access deleted objects from an already committed \(cs_typeName(self))."
        )
        
        return Set(self.context.deletedObjects.filter { $0.isKindOfClass(entity) }.map { $0 as! T })
    }
    
    /**
     Returns all pending `NSManagedObjectID`s of the specified type that were deleted from the transaction. This method should not be called after the `commit()` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: a `Set` of pending `NSManagedObjectID`s of the specified type that were deleted from the transaction.
     */
    @warn_unused_result
    public func deletedObjectIDs() -> Set<NSManagedObjectID> {
        
        CoreStore.assert(
            self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to access deleted object IDs from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access deleted object IDs from an already committed \(cs_typeName(self))."
        )
        
        return Set(self.context.deletedObjects.map { $0.objectID })
    }
    
    /**
     Returns all pending `NSManagedObjectID`s of the specified type that were deleted from the transaction. This method should not be called after the `commit()` method was called.
     
     - parameter entity: the `NSManagedObject` subclass to filter
     - returns: a `Set` of pending `NSManagedObjectID`s of the specified type that were deleted from the transaction.
     */
    @warn_unused_result
    public func deletedObjectIDs<T: NSManagedObject>(entity: T.Type) -> Set<NSManagedObjectID> {
        
        CoreStore.assert(
            self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to access deleted object IDs from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access deleted object IDs from an already committed \(cs_typeName(self))."
        )
        
        return Set(self.context.deletedObjects.filter { $0.isKindOfClass(entity) }.map { $0.objectID })
    }
    
    
    // MARK: Internal
    
    internal let context: NSManagedObjectContext
    internal let transactionQueue: GCDQueue
    internal let childTransactionQueue: GCDQueue = .createSerial("com.corestore.datastack.childtransactionqueue")
    internal let supportsUndo: Bool
    internal let bypassesQueueing: Bool
    
    
    internal var isCommitted = false
    internal var result: SaveResult?
    
    internal init(mainContext: NSManagedObjectContext, queue: GCDQueue, supportsUndo: Bool, bypassesQueueing: Bool) {
        
        let context = mainContext.temporaryContextInTransactionWithConcurrencyType(
            queue == .Main
                ? .MainQueueConcurrencyType
                : .PrivateQueueConcurrencyType
        )
        self.transactionQueue = queue
        self.context = context
        self.supportsUndo = supportsUndo
        self.bypassesQueueing = bypassesQueueing
        
        context.parentTransaction = self
        if !supportsUndo {
            
            context.undoManager = nil
        }
        else if context.undoManager == nil {
            
            context.undoManager = NSUndoManager()
        }
    }
    
    internal func isRunningInAllowedQueue() -> Bool {
        
        return self.bypassesQueueing || self.transactionQueue.isCurrentExecutionContext()
    }
}
