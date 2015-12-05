//
//  BaseDataTransaction.swift
//  CoreStore
//
//  Copyright (c) 2014 John Rommel Estropia
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
            self.bypassesQueueing || self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to create an entity of type \(typeName(T)) outside its designated queue."
        )
        
        let context = self.context
        let entityClass = (into.entityClass as! NSManagedObject.Type)
        if into.inferStoreIfPossible {
            
            switch context.parentStack!.persistentStoreForEntityClass(entityClass, configuration: nil, inferStoreIfPossible: true) {
                
            case (let persistentStore?, _):
                let object = entityClass.createInContext(context) as! T
                context.assignObject(object, toPersistentStore: persistentStore)
                return object
                
            case (.None, true):
                fatalError("Attempted to create an entity of type \(typeName(entityClass)) with ambiguous destination persistent store, but the configuration name was not specified.")
                
            default:
                fatalError("Attempted to create an entity of type \(typeName(entityClass)), but a destination persistent store containing the entity type could not be found.")
            }
        }
        else {
            
            switch context.parentStack!.persistentStoreForEntityClass(entityClass, configuration: into.configuration, inferStoreIfPossible: false) {
                
            case (let persistentStore?, _):
                let object = entityClass.createInContext(context) as! T
                context.assignObject(object, toPersistentStore: persistentStore)
                return object
                
            default:
                if let configuration = into.configuration {
                    
                    fatalError("Attempted to create an entity of type \(typeName(entityClass)) into the configuration \"\(configuration)\", which it doesn't belong to.")
                }
                else {
                    
                    fatalError("Attempted to create an entity of type \(typeName(entityClass)) into the default configuration, which it doesn't belong to.")
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
            self.bypassesQueueing || self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to update an entity of type \(typeName(object)) outside its designated queue."
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
            self.bypassesQueueing || self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to update an entity of type \(typeName(T)) outside its designated queue."
        )
        CoreStore.assert(
            into.inferStoreIfPossible
                || (into.configuration ?? Into.defaultConfigurationName) == objectID.persistentStore?.configurationName,
            "Attempted to update an entity of type \(typeName(T)) but the specified persistent store do not match the `NSManagedObjectID`."
        )
        return self.fetchExisting(objectID) as? T
    }
    
    /**
    Deletes a specified `NSManagedObject`.
    
    - parameter object: the `NSManagedObject` to be deleted
    */
    public func delete(object: NSManagedObject?) {
        
        CoreStore.assert(
            self.bypassesQueueing || self.transactionQueue.isCurrentExecutionContext(),
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
            self.bypassesQueueing || self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to delete entities outside their designated queue."
        )
        
        let context = self.context
        objects.forEach { context.fetchExisting($0)?.deleteFromContext() }
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
}
