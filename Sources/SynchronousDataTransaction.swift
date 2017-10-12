//
//  SynchronousDataTransaction.swift
//  CoreStore
//
//  Copyright © 2015 John Rommel Estropia
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


// MARK: - SynchronousDataTransaction

/**
 The `SynchronousDataTransaction` provides an interface for `DynamicObject` creates, updates, and deletes. A transaction object should typically be only used from within a transaction block initiated from `DataStack.beginSynchronous(_:)`, or from `CoreStore.beginSynchronous(_:)`.
 */
public final class SynchronousDataTransaction: BaseDataTransaction {
    
    /**
     Cancels a transaction by throwing `CoreStoreError.userCancelled`.
     ```
     try transaction.cancel()
     ```
     - Important: Always use plain `try` on a `cancel()` call. Never use `try?` or `try!`. Using `try?` will swallow the cancellation and the transaction will proceed to commit as normal. Using `try!` will crash the app as `cancel()` will *always* throw an error.
     */
    public func cancel() throws -> Never {
        
        throw CoreStoreError.userCancelled
    }
    
    
    // MARK: BaseDataTransaction
    
    /**
     Creates a new `NSManagedObject` or `CoreStoreObject` with the specified entity type.
     
     - parameter into: the `Into` clause indicating the destination `NSManagedObject` or `CoreStoreObject` entity type and the destination configuration
     - returns: a new `NSManagedObject` or `CoreStoreObject` instance of the specified entity type.
     */
    public override func create<T>(_ into: Into<T>) -> T {
        
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to create an entity of type \(cs_typeName(into.entityClass)) from an already committed \(cs_typeName(self))."
        )
        
        return super.create(into)
    }
    
    /**
     Returns an editable proxy of a specified `NSManagedObject` or `CoreStoreObject`.
     
     - parameter object: the `NSManagedObject` or `CoreStoreObject` to be edited
     - returns: an editable proxy for the specified `NSManagedObject` or `CoreStoreObject`.
     */
    public override func edit<T: DynamicObject>(_ object: T?) -> T? {
        
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to update an entity of type \(cs_typeName(object)) from an already committed \(cs_typeName(self))."
        )
        
        return super.edit(object)
    }
    
    /**
     Returns an editable proxy of the object with the specified `NSManagedObjectID`.
     
     - parameter into: an `Into` clause specifying the entity type
     - parameter objectID: the `NSManagedObjectID` for the object to be edited
     - returns: an editable proxy for the specified `NSManagedObject` or `CoreStoreObject`.
     */
    public override func edit<T>(_ into: Into<T>, _ objectID: NSManagedObjectID) -> T? {
        
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to update an entity of type \(cs_typeName(into.entityClass)) from an already committed \(cs_typeName(self))."
        )
        
        return super.edit(into, objectID)
    }
    
    /**
     Deletes a specified `NSManagedObject` or `CoreStoreObject`.
     
     - parameter object: the `NSManagedObject` or `CoreStoreObject` type to be deleted
     */
    public override func delete<T: DynamicObject>(_ object: T?) {
        
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to delete an entity of type \(cs_typeName(object)) from an already committed \(cs_typeName(self))."
        )
        
        super.delete(object)
    }
    
    /**
     Deletes the specified `DynamicObject`s.
     
     - parameter object1: the `DynamicObject` to be deleted
     - parameter object2: another `DynamicObject` to be deleted
     - parameter objects: other `DynamicObject`s to be deleted
     */
    public override func delete<T: DynamicObject>(_ object1: T?, _ object2: T?, _ objects: T?...) {
        
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to delete an entities from an already committed \(cs_typeName(self))."
        )
        
        super.delete(([object1, object2] + objects).flatMap { $0 })
    }
    
    /**
     Deletes the specified `DynamicObject`s.
     
     - parameter objects: the `DynamicObject`s to be deleted
     */
    public override func delete<S: Sequence>(_ objects: S) where S.Iterator.Element: DynamicObject {
        
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to delete an entities from an already committed \(cs_typeName(self))."
        )
        
        super.delete(objects)
    }
    
    
    // MARK: Internal
    
    internal init(mainContext: NSManagedObjectContext, queue: DispatchQueue) {
        
        super.init(mainContext: mainContext, queue: queue, supportsUndo: false, bypassesQueueing: false)
    }
    
    internal func autoCommit(waitForMerge: Bool) -> (hasChanges: Bool, error: CoreStoreError?) {
        
        self.isCommitted = true
        let result = self.context.saveSynchronously(waitForMerge: waitForMerge)
        self.result = result
        defer {
            
            self.context.reset()
        }
        return result
    }
    
    
    // MARK: Deprecated
    
    @available(*, deprecated, message: "Use the new auto-commit method DataStack.perform(synchronous:waitForAllObservers:)")
    public func commitAndWait() -> SaveResult {
        
        CoreStore.assert(
            self.transactionQueue.cs_isCurrentExecutionContext(),
            "Attempted to commit a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to commit a \(cs_typeName(self)) more than once."
        )
        switch self.autoCommit(waitForMerge: true) {
            
        case (let hasChanges, nil): return SaveResult(hasChanges: hasChanges)
        case (_, let error?):       return SaveResult(error)
        }
    }
    
    @available(*, deprecated, message: "Use the new auto-commit method DataStack.perform(synchronous:waitForAllObservers:)")
    public func commit() -> SaveResult {
        
        CoreStore.assert(
            self.transactionQueue.cs_isCurrentExecutionContext(),
            "Attempted to commit a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to commit a \(cs_typeName(self)) more than once."
        )
        switch self.autoCommit(waitForMerge: false) {
            
        case (let hasChanges, nil): return SaveResult(hasChanges: hasChanges)
        case (_, let error?):       return SaveResult(error)
        }
    }
    
    @available(*, deprecated, message: "Secondary tasks spawned from AsynchronousDataTransactions and SynchronousDataTransactions are no longer supported. ")
    @discardableResult
    public func beginSynchronous(_ closure: @escaping (_ transaction: SynchronousDataTransaction) -> Void) -> SaveResult? {
        
        CoreStore.assert(
            self.transactionQueue.cs_isCurrentExecutionContext(),
            "Attempted to begin a child transaction from a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.isCommitted,
            "Attempted to begin a child transaction from an already committed \(cs_typeName(self))."
        )
        let childTransaction = SynchronousDataTransaction(
            mainContext: self.context,
            queue: self.childTransactionQueue
        )
        childTransaction.transactionQueue.cs_sync {
            
            closure(childTransaction)
            
            if !childTransaction.isCommitted && childTransaction.hasChanges {
                
                CoreStore.log(
                    .warning,
                    message: "The closure for the \(cs_typeName(childTransaction)) completed without being committed. All changes made within the transaction were discarded."
                )
            }
        }
        switch childTransaction.result {
            
        case .none:                         return nil
        case .some(let hasChanges, nil):    return SaveResult(hasChanges: hasChanges)
        case .some(_, let error?):          return SaveResult(error)
        }
    }
}
