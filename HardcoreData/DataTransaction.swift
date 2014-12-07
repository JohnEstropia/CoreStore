//
//  DataTransaction.swift
//  HardcoreData
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
import GCDKit

/**
The DataTransaction provides an interface for NSManagedObject creates, updates, and deletes. A transaction object should typically be only used from within a transaction block initiated from DataStack.performTransaction(_:), or from HardcoreData.performTransaction(_:).
*/
public class DataTransaction {
    
    // MARK: - Public
    
    /**
    The background concurrent context managed by the transaction.
    */
    public let context: NSManagedObjectContext
    
    // MARK: Object management
    
    /**
    Creates a new NSManagedObject with the specified entity type. Note that this method should not be used after either the commit(_:) or commitAndWait() method was already called once.
    
    :param: entity the NSManagedObject type to be created
    :returns: a new NSManagedObject instance of the specified entity type.
    */
    public func create<T: NSManagedObject>(entity: T.Type) -> T {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext() == true, "Attempted to create an NSManagedObject outside a transaction queue.")
        HardcoreData.assert(!self.isTransactionCommited, "Attempted to create an NSManagedObject from an already commited DataTransaction.")
        return T.createInContext(self.context)
    }
    
    /**
    Returns an editable proxy of a specified NSManagedObject. Note that this method should not be used after either the commit(_:) or commitAndWait() method was already called once.
    
    :param: object the NSManagedObject type to be edited
    :returns: an editable proxy for the specified NSManagedObject.
    */
    public func update<T: NSManagedObject>(object: T) -> T? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext() == true, "Attempted to update an NSManagedObject outside a transaction queue.")
        HardcoreData.assert(!self.isTransactionCommited, "Attempted to update an NSManagedObject from an already commited DataTransaction.")
        return object.inContext(self.context)
    }
    
    /**
    Deletes a specified NSManagedObject. Note that this method should not be used after either the commit(_:) or commitAndWait() method was already called once.
    
    :param: object the NSManagedObject type to be deleted
    */
    public func delete(object: NSManagedObject) {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext() == true, "Attempted to delete an NSManagedObject outside a transaction queue.")
        HardcoreData.assert(!self.isTransactionCommited, "Attempted to delete an NSManagedObject from an already commited DataTransaction.")
        object.deleteFromContext()
    }
    
    // MARK: Saving changes
    
    /**
    Saves the transaction changes asynchronously. Note that this method should not be used after either the commit(_:) or commitAndWait() method was already called once.
    
    :param: completion the block executed after the save completes. Success or failure is reported by the SaveResult argument of the block.
    */
    public func commit(completion: (result: SaveResult) -> ()) {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext() == true, "Attempted to commit a DataTransaction outside a transaction queue.")
        HardcoreData.assert(!self.isTransactionCommited, "Attempted to commit a DataTransaction more than once.")
        
        self.isTransactionCommited = true
        self.context.saveAsynchronouslyWithCompletion { [weak self] (result) -> () in
            
            self?.result = result
            completion(result: result)
        }
    }
    
    /**
    Saves the transaction changes and waits for completion synchronously. Note that this method should not be used after either the commit(_:) or commitAndWait() method was already called once.
    
    :returns: a SaveResult value indicating success or failure.
    */
    public func commitAndWait() -> SaveResult {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext() == true, "Attempted to commit a DataTransaction outside a transaction queue.")
        HardcoreData.assert(!self.isTransactionCommited, "Attempted to commit a DataTransaction more than once.")
        
        self.isTransactionCommited = true
        let result = self.context.saveSynchronously()
        self.result = result
        return result
    }
    
    
    // MARK: - Internal
    
    internal init(mainContext: NSManagedObjectContext, queue: GCDQueue, closure: (transaction: DataTransaction) -> ()) {
        
        self.mainContext = mainContext
        self.transactionQueue = queue
        self.context = mainContext.temporaryContext()
        self.closure = closure
    }
    
    internal func perform() {
        
        self.transactionQueue.barrierAsync {
            
            self.closure(transaction: self)
            if !self.isTransactionCommited {
                
                self.commit { (result) -> () in }
            }
        }
    }
    
    internal func performAndWait() -> SaveResult {
        
        self.transactionQueue.barrierSync {
            
            self.closure(transaction: self)
            if !self.isTransactionCommited {
                
                self.commitAndWait()
            }
        }
        return self.result!
    }
    
    
    // MARK: - Private
    
    private var isTransactionCommited = false
    private var result: SaveResult?
    private let mainContext: NSManagedObjectContext
    private let transactionQueue: GCDQueue
    private let closure: (transaction: DataTransaction) -> ()
}