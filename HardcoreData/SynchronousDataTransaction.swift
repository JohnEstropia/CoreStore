//
//  SynchronousDataTransaction.swift
//  HardcoreData
//
//  Created by John Rommel Estropia on 2015/02/28.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import Foundation
import GCDKit

public class SynchronousDataTransaction: DataTransaction {
    
    // MARK: Public
    
    /**
    Saves the transaction changes and waits for completion synchronously. Note that this method should not be used after either the commit(_:) or commitAndWait() method was already called once.
    
    :returns: a SaveResult value indicating success or failure.
    */
    public func commitAndWait() {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext() == true, "Attempted to commit a \(self.dynamicType) outside a transaction queue.")
        HardcoreData.assert(!self.isCommitted, "Attempted to commit a \(self.dynamicType) more than once.")
        
        self.isCommitted = true
        self.result = self.context.saveSynchronously()
    }
    
    /**
    Begins a child transaction synchronously where NSManagedObject creates, updates, and deletes can be made.
    
    :param: closure the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent NSManagedObjectContext.
    :returns: a SaveResult value indicating success or failure, or nil if the transaction was not comitted synchronously
    */
    public func performTransactionAndWait(closure: (transaction: SynchronousDataTransaction) -> Void) -> SaveResult? {
        
        return SynchronousDataTransaction(
            mainContext: self.context,
            queue: self.childTransactionQueue,
            closure: closure).performAndWait()
    }
    
    
    // MARK: Internal
    
    internal func performAndWait() -> SaveResult? {
        
        self.transactionQueue.sync {
            
            self.closure(transaction: self)
            if !self.isCommitted {
                
                HardcoreData.log(.Warning, message: "The closure for the \(self.dynamicType) completed without being committed. All changes made within the transaction were discarded.")
            }
        }
        return self.result
    }
    
    internal init(mainContext: NSManagedObjectContext, queue: GCDQueue, closure: (transaction: SynchronousDataTransaction) -> Void) {
        
        self.closure = closure
        
        super.init(mainContext: mainContext, queue: queue)
    }
    
    
    // MARK: - Private
    
    private let closure: (transaction: SynchronousDataTransaction) -> Void
}
