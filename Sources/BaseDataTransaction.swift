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
     Creates a new `NSManagedObject` or `CoreStoreObject` with the specified entity type.
     
     - parameter into: the `Into` clause indicating the destination `NSManagedObject` or `CoreStoreObject` entity type and the destination configuration
     - returns: a new `NSManagedObject` or `CoreStoreObject` instance of the specified entity type.
     */
    public func create<T: DynamicObject>(_ into: Into<T>) -> T {
        
        let entityClass = into.entityClass
        CoreStore.assert(
            self.isRunningInAllowedQueue(),
            "Attempted to create an entity of type \(cs_typeName(entityClass)) outside its designated queue."
        )
        
        let context = self.context
        let dataStack = context.parentStack!
        let entityIdentifier = EntityIdentifier(entityClass)
        if into.inferStoreIfPossible {
            
            switch dataStack.persistentStore(
                for: entityIdentifier,
                configuration: nil,
                inferStoreIfPossible: true
            ) {
                
            case (let persistentStore?, _):
                return entityClass.cs_forceCreate(
                    entityDescription: dataStack.entityDescription(for: entityIdentifier)!,
                    into: context,
                    assignTo: persistentStore
                )
                
            case (nil, true):
                CoreStore.abort("Attempted to create an entity of type \(cs_typeName(entityClass)) with ambiguous destination persistent store, but the configuration name was not specified.")
                
            default:
                CoreStore.abort("Attempted to create an entity of type \(cs_typeName(entityClass)), but a destination persistent store containing the entity type could not be found.")
            }
        }
        else {
            
            switch dataStack.persistentStore(
                for: entityIdentifier,
                configuration: into.configuration
                    ?? DataStack.defaultConfigurationName,
                inferStoreIfPossible: false
            ) {
                
            case (let persistentStore?, _):
                return entityClass.cs_forceCreate(
                    entityDescription: dataStack.entityDescription(for: entityIdentifier)!,
                    into: context,
                    assignTo: persistentStore
                )
                
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
    public func edit<T: DynamicObject>(_ object: T?) -> T? {
        
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
    public func edit<T: DynamicObject>(_ into: Into<T>, _ objectID: NSManagedObjectID) -> T? {
        
        CoreStore.assert(
            self.isRunningInAllowedQueue(),
            "Attempted to update an entity of type \(cs_typeName(into.entityClass)) outside its designated queue."
        )
        CoreStore.assert(
            into.inferStoreIfPossible
                || (into.configuration ?? DataStack.defaultConfigurationName) == objectID.persistentStore?.configurationName,
            "Attempted to update an entity of type \(cs_typeName(into.entityClass)) but the specified persistent store do not match the `NSManagedObjectID`."
        )
        return self.fetchExisting(objectID)
    }
    
    /**
     Deletes a specified `NSManagedObject`.
     
     - parameter object: the `NSManagedObject` to be deleted
     */
    public func delete<T: DynamicObject>(_ object: T?) {
        
        CoreStore.assert(
            self.isRunningInAllowedQueue(),
            "Attempted to delete an entity outside its designated queue."
        )
        let context = self.context
        object
            .flatMap(context.fetchExisting)
            .flatMap({ context.delete($0.cs_toRaw()) })
    }
    
    /**
     Deletes the specified `NSManagedObject`s.
     
     - parameter object1: the `NSManagedObject` to be deleted
     - parameter object2: another `NSManagedObject` to be deleted
     - parameter objects: other `NSManagedObject`s to be deleted
     */
    public func delete<T: DynamicObject>(_ object1: T?, _ object2: T?, _ objects: T?...) {
        
        self.delete(([object1, object2] + objects).flatMap { $0 })
    }
    
    /**
     Deletes the specified `NSManagedObject`s.
     
     - parameter objects: the `NSManagedObject`s to be deleted
     */
    public func delete<S: Sequence>(_ objects: S) where S.Iterator.Element: DynamicObject {
        
        CoreStore.assert(
            self.isRunningInAllowedQueue(),
            "Attempted to delete entities outside their designated queue."
        )
        let context = self.context
        objects.forEach { context.fetchExisting($0).flatMap({ context.delete($0.cs_toRaw()) }) }
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
     Returns all pending `DynamicObject`s of the specified type that were inserted to the transaction. This method should not be called after the `commit()` method was called.
     
     - parameter entity: the `DynamicObject` subclass to filter
     - returns: a `Set` of pending `DynamicObject`s of the specified type that were inserted to the transaction.
     */
    public func insertedObjects<T: DynamicObject>(_ entity: T.Type) -> Set<T> {
        
        CoreStore.assert(
            self.transactionQueue.cs_isCurrentExecutionContext(),
            "Attempted to access inserted objects from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access inserted objects from an already committed \(cs_typeName(self))."
        )
        return Set(self.context.insertedObjects.flatMap({ entity.cs_matches(object: $0) ? entity.cs_fromRaw(object: $0) : nil }))
    }
    
    /**
     Returns all pending `NSManagedObjectID`s that were inserted to the transaction. This method should not be called after the `commit()` method was called.
     
     - returns: a `Set` of pending `NSManagedObjectID`s that were inserted to the transaction.
     */
    public func insertedObjectIDs() -> Set<NSManagedObjectID> {
        
        CoreStore.assert(
            self.transactionQueue.cs_isCurrentExecutionContext(),
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
     
     - parameter entity: the `DynamicObject` subclass to filter
     - returns: a `Set` of pending `NSManagedObjectID`s of the specified type that were inserted to the transaction.
     */
    public func insertedObjectIDs<T: DynamicObject>(_ entity: T.Type) -> Set<NSManagedObjectID> {
        
        CoreStore.assert(
            self.transactionQueue.cs_isCurrentExecutionContext(),
            "Attempted to access inserted object IDs from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access inserted objects IDs from an already committed \(cs_typeName(self))."
        )
        return Set(self.context.insertedObjects.flatMap({ entity.cs_matches(object: $0) ? $0.objectID : nil }))
    }
    
    /**
     Returns all pending `DynamicObject`s of the specified type that were updated in the transaction. This method should not be called after the `commit()` method was called.
     
     - parameter entity: the `DynamicObject` subclass to filter
     - returns: a `Set` of pending `DynamicObject`s of the specified type that were updated in the transaction.
     */
    public func updatedObjects<T: DynamicObject>(_ entity: T.Type) -> Set<T> {
        
        CoreStore.assert(
            self.transactionQueue.cs_isCurrentExecutionContext(),
            "Attempted to access updated objects from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access updated objects from an already committed \(cs_typeName(self))."
        )
        return Set(self.context.updatedObjects.flatMap({ entity.cs_matches(object: $0) ? entity.cs_fromRaw(object: $0) : nil }))
    }
    
    /**
     Returns all pending `NSManagedObjectID`s that were updated in the transaction. This method should not be called after the `commit()` method was called.
     
     - returns: a `Set` of pending `NSManagedObjectID`s that were updated in the transaction.
     */
    public func updatedObjectIDs() -> Set<NSManagedObjectID> {
        
        CoreStore.assert(
            self.transactionQueue.cs_isCurrentExecutionContext(),
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
     
     - parameter entity: the `DynamicObject` subclass to filter
     - returns: a `Set` of pending `NSManagedObjectID`s of the specified type that were updated in the transaction.
     */
    public func updatedObjectIDs<T: DynamicObject>(_ entity: T.Type) -> Set<NSManagedObjectID> {
        
        CoreStore.assert(
            self.transactionQueue.cs_isCurrentExecutionContext(),
            "Attempted to access updated object IDs from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access updated object IDs from an already committed \(cs_typeName(self))."
        )
        return Set(self.context.updatedObjects.flatMap({ entity.cs_matches(object: $0) ? $0.objectID : nil }))
    }
    
    /**
     Returns all pending `DynamicObject`s of the specified type that were deleted from the transaction. This method should not be called after the `commit()` method was called.
     
     - parameter entity: the `DynamicObject` subclass to filter
     - returns: a `Set` of pending `DynamicObject`s of the specified type that were deleted from the transaction.
     */
    public func deletedObjects<T: DynamicObject>(_ entity: T.Type) -> Set<T> {
        
        CoreStore.assert(
            self.transactionQueue.cs_isCurrentExecutionContext(),
            "Attempted to access deleted objects from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access deleted objects from an already committed \(cs_typeName(self))."
        )
        return Set(self.context.deletedObjects.flatMap({ entity.cs_matches(object: $0) ? entity.cs_fromRaw(object: $0) : nil }))
    }
    
    /**
     Returns all pending `NSManagedObjectID`s of the specified type that were deleted from the transaction. This method should not be called after the `commit()` method was called.
     
     - parameter entity: the `DynamicObject` subclass to filter
     - returns: a `Set` of pending `NSManagedObjectID`s of the specified type that were deleted from the transaction.
     */
    public func deletedObjectIDs() -> Set<NSManagedObjectID> {
        
        CoreStore.assert(
            self.transactionQueue.cs_isCurrentExecutionContext(),
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
     
     - parameter entity: the `DynamicObject` subclass to filter
     - returns: a `Set` of pending `NSManagedObjectID`s of the specified type that were deleted from the transaction.
     */
    public func deletedObjectIDs<T: DynamicObject>(_ entity: T.Type) -> Set<NSManagedObjectID> {
        
        CoreStore.assert(
            self.transactionQueue.cs_isCurrentExecutionContext(),
            "Attempted to access deleted object IDs from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access deleted object IDs from an already committed \(cs_typeName(self))."
        )
        return Set(self.context.deletedObjects.flatMap({ entity.cs_matches(object: $0) ? $0.objectID : nil }))
    }
    
    
    // MARK: 3rd Party Utilities
    
    /**
     Allow external libraries to store custom data in the transaction. App code should rarely have a need for this.
     ```
     enum Static {
        static var myDataKey: Void?
     }
     transaction.userInfo[&Static.myDataKey] = myObject
     ```
     - Important: Do not use this method to store thread-sensitive data.
     */
    public let userInfo = UserInfo()
    
    
    // MARK: Internal
    
    internal let context: NSManagedObjectContext
    internal let transactionQueue: DispatchQueue
    internal let childTransactionQueue = DispatchQueue.serial("com.corestore.datastack.childTransactionQueue")
    internal let supportsUndo: Bool
    internal let bypassesQueueing: Bool
    internal var isCommitted = false
    internal var result: (hasChanges: Bool, error: CoreStoreError?)?
    
    internal init(mainContext: NSManagedObjectContext, queue: DispatchQueue, supportsUndo: Bool, bypassesQueueing: Bool) {
        
        let context = mainContext.temporaryContextInTransactionWithConcurrencyType(
            queue == .main
                ? .mainQueueConcurrencyType
                : .privateQueueConcurrencyType
        )
        self.transactionQueue = queue
        self.context = context
        self.supportsUndo = supportsUndo
        self.bypassesQueueing = bypassesQueueing
        
        context.parentTransaction = self
        context.isTransactionContext = true
        if !supportsUndo {
            
            context.undoManager = nil
        }
        else if context.undoManager == nil {
            
            context.undoManager = UndoManager()
        }
    }
    
    internal func isRunningInAllowedQueue() -> Bool {
        
        return self.bypassesQueueing || self.transactionQueue.cs_isCurrentExecutionContext()
    }
    
    deinit {
        
        self.context.reset()
    }
    
    
    // MARK: Deprecated
    
    @available(*, deprecated, message: "Use insertedObjects(_:) and pass the specific entity type")
    public func insertedObjects() -> Set<NSManagedObject> {
        
        CoreStore.assert(
            self.transactionQueue.cs_isCurrentExecutionContext(),
            "Attempted to access inserted objects from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access inserted objects from an already committed \(cs_typeName(self))."
        )
        return self.context.insertedObjects
    }
    
    @available(*, deprecated, message: "Use updatedObjects(_:) and pass the specific entity type")
    public func updatedObjects() -> Set<NSManagedObject> {
        
        CoreStore.assert(
            self.transactionQueue.cs_isCurrentExecutionContext(),
            "Attempted to access updated objects from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access updated objects from an already committed \(cs_typeName(self))."
        )
        return self.context.updatedObjects
    }
    
    @available(*, deprecated, message: "Use deletedObjects(_:) and pass the specific entity type")
    public func deletedObjects() -> Set<NSManagedObject> {
        
        CoreStore.assert(
            self.transactionQueue.cs_isCurrentExecutionContext(),
            "Attempted to access deleted objects from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to access deleted objects from an already committed \(cs_typeName(self))."
        )
        return self.context.deletedObjects
    }
}
