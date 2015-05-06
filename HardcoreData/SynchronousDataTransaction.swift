//
//  SynchronousDataTransaction.swift
//  HardcoreData
//
//  Created by John Rommel Estropia on 2015/02/28.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import Foundation
import GCDKit

public final class SynchronousDataTransaction: BaseDataTransaction {
    
    // MARK: Public
    
    /**
    Saves the transaction changes and waits for completion synchronously. This method should not be used after the commitAndWait() method was already called once.
    
    :returns: a SaveResult value indicating success or failure.
    */
    public func commitAndWait() {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to commit a \(typeName(self)) outside its designated queue.")
        HardcoreData.assert(!self.isCommitted, "Attempted to commit a \(typeName(self)) more than once.")
        
        self.isCommitted = true
        self.result = self.context.saveSynchronously()
    }
    
    /**
    Begins a child transaction synchronously where NSManagedObject creates, updates, and deletes can be made. This method should not be used after the commitAndWait() method was already called once.
    
    :param: closure the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent NSManagedObjectContext.
    :returns: a SaveResult value indicating success or failure, or nil if the transaction was not comitted synchronously
    */
    public func beginSynchronous(closure: (transaction: SynchronousDataTransaction) -> Void) -> SaveResult? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to begin a child transaction from a \(typeName(self)) outside its designated queue.")
        HardcoreData.assert(!self.isCommitted, "Attempted to begin a child transaction from an already committed \(typeName(self)).")
        
        return SynchronousDataTransaction(
            mainContext: self.context,
            queue: self.childTransactionQueue,
            closure: closure).performAndWait()
    }
    
    
    // MARK: BaseDataTransaction
    
    /**
    Creates a new NSManagedObject with the specified entity type. This method should not be used after the commitAndWait() method was already called once.
    
    :param: entity the NSManagedObject type to be created
    :returns: a new NSManagedObject instance of the specified entity type.
    */
    public override func create<T: NSManagedObject>(entity: T.Type) -> T {
        
        HardcoreData.assert(!self.isCommitted, "Attempted to create an entity of type <\(entity)> from an already committed \(typeName(self)).")
        
        return super.create(entity)
    }
    
    /**
    Returns an editable proxy of a specified NSManagedObject. This method should not be used after the commitAndWait() method was already called once.
    
    :param: object the NSManagedObject type to be edited
    :returns: an editable proxy for the specified NSManagedObject.
    */
    public override func fetch<T: NSManagedObject>(object: T?) -> T? {
        
        HardcoreData.assert(!self.isCommitted, "Attempted to update an entity of type \(typeName(object)) from an already committed \(typeName(self)).")
        
        return super.fetch(object)
    }
    
    /**
    Deletes a specified NSManagedObject. This method should not be used after the commitAndWait() method was already called once.
    
    :param: object the NSManagedObject type to be deleted
    */
    public override func delete(object: NSManagedObject?) {
        
        HardcoreData.assert(!self.isCommitted, "Attempted to delete an entity of type \(typeName(object)) from an already committed \(typeName(self)).")
        
        super.delete(object)
    }
    
    /**
    Rolls back the transaction by resetting the NSManagedObjectContext. After calling this method, all NSManagedObjects fetched within the transaction will become invalid. This method should not be used after the commitAndWait() method was already called once.
    */
    public override func rollback() {
        
        HardcoreData.assert(!self.isCommitted, "Attempted to rollback an already committed \(typeName(self)).")
        
        super.rollback()
    }
    
    
    // MARK: Internal
    
    internal func performAndWait() -> SaveResult? {
        
        self.transactionQueue.sync {
            
            self.closure(transaction: self)
            if !self.isCommitted && self.hasChanges {
                
                HardcoreData.log(.Warning, message: "The closure for the \(typeName(self)) completed without being committed. All changes made within the transaction were discarded.")
            }
        }
        return self.result
    }
    
    internal init(mainContext: NSManagedObjectContext, queue: GCDQueue, closure: (transaction: SynchronousDataTransaction) -> Void) {
        
        self.closure = closure
        
        super.init(mainContext: mainContext, queue: queue)
    }
    
    
    // MARK: Private
    
    private let closure: (transaction: SynchronousDataTransaction) -> Void
}
