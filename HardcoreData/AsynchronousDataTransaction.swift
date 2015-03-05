//
//  AsynchronousDataTransaction.swift
//  HardcoreData
//
//  Copyright (c) 2015 John Rommel Estropia
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
import GCDKit


/**
The AsynchronousDataTransaction provides an interface for NSManagedObject creates, updates, and deletes. A transaction object should typically be only used from within a transaction block initiated from DataStack.performTransaction(_:), or from HardcoreData.performTransaction(_:).
*/
public class AsynchronousDataTransaction: DataTransaction {
    
    // MARK: Public
    
    /**
    Saves the transaction changes asynchronously. Note that this method should not be used after either the commit(_:) or commitAndWait() method was already called once.
    
    :param: completion the block executed after the save completes. Success or failure is reported by the SaveResult argument of the block.
    */
    public func commit(completion: (result: SaveResult) -> Void) {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to commit a <\(self.dynamicType)> outside a transaction queue.")
        HardcoreData.assert(!self.isCommitted, "Attempted to commit a <\(self.dynamicType)> more than once.")
        
        self.isCommitted = true
        let semaphore = GCDSemaphore(0)
        self.context.saveAsynchronouslyWithCompletion { (result) -> Void in
            
            self.result = result
            completion(result: result)
            semaphore.signal()
        }
        semaphore.wait()
    }
    
    /**
    Saves the transaction changes and waits for completion synchronously. Note that this method should not be used after either the commit(_:) or commitAndWait() method was already called once.
    
    :returns: a SaveResult value indicating success or failure.
    */
    public func commitAndWait() {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to commit a <\(self.dynamicType)> outside a transaction queue.")
        HardcoreData.assert(!self.isCommitted, "Attempted to commit a <\(self.dynamicType)> more than once.")
        
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
    
    internal init(mainContext: NSManagedObjectContext, queue: GCDQueue, closure: (transaction: AsynchronousDataTransaction) -> Void) {
        
        self.closure = closure
        
        super.init(mainContext: mainContext, queue: queue)
    }
    
    internal func perform() {
        
        self.transactionQueue.async {
            
            self.closure(transaction: self)
            if !self.isCommitted {
                
                HardcoreData.log(.Warning, message: "The closure for the <\(self.dynamicType)> completed without being committed. All changes made within the transaction were discarded.")
            }
        }
    }
    
    internal func performAndWait() -> SaveResult? {
        
        self.transactionQueue.sync {
            
            self.closure(transaction: self)
            if !self.isCommitted {
                
                HardcoreData.log(.Warning, message: "The closure for the <\(self.dynamicType)> completed without being committed. All changes made within the transaction were discarded.")
            }
        }
        return self.result
    }
    
    
    // MARK: Private
    
    private let closure: (transaction: AsynchronousDataTransaction) -> Void
}
