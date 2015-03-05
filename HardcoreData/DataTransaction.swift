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


// MARK: - DataTransaction

/**
The DataTransaction provides an interface for NSManagedObject creates, updates, and deletes. A transaction object should typically be only used from within a transaction block initiated from DataStack.performTransaction(_:), or from HardcoreData.performTransaction(_:).
*/
public /*abstract*/ class DataTransaction {
    
    // MARK: Object management
    
    /**
    Creates a new NSManagedObject with the specified entity type. Note that this method should not be used after either the commit(_:) or commitAndWait() method was already called once.
    
    :param: entity the NSManagedObject type to be created
    :returns: a new NSManagedObject instance of the specified entity type.
    */
    public func create<T: NSManagedObject>(entity: T.Type) -> T {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to create an entity of type <\(entity)> outside a transaction queue.")
        HardcoreData.assert(!self.isCommitted, "Attempted to create an entity of type <\(entity)> from an already committed <\(self.dynamicType)>.")
        
        return T.createInContext(self.context)
    }
    
    /**
    Returns an editable proxy of a specified NSManagedObject. Note that this method should not be used after either the commit(_:) or commitAndWait() method was already called once.
    
    :param: object the NSManagedObject type to be edited
    :returns: an editable proxy for the specified NSManagedObject.
    */
    public func fetch<T: NSManagedObject>(object: T) -> T? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to update an entity of type <\(object.dynamicType)> outside a transaction queue.")
        HardcoreData.assert(!self.isCommitted, "Attempted to update an entity of type <\(object.dynamicType)> from an already committed <\(self.dynamicType)>.")
        
        return object.inContext(self.context)
    }
    
    /**
    Deletes a specified NSManagedObject. Note that this method should not be used after either the commit(_:) or commitAndWait() method was already called once.
    
    :param: object the NSManagedObject type to be deleted
    */
    public func delete(object: NSManagedObject) {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to delete an entity of type <\(object.dynamicType)> outside a transaction queue.")
        HardcoreData.assert(!self.isCommitted, "Attempted to delete an entity of type <\(object.dynamicType)> from an already committed <\(self.dynamicType)>.")
        
        object.deleteFromContext()
    }
    
    // MARK: Saving changes
    
    /**
    Rolls back the transaction by resetting the NSManagedObjectContext. Note that after calling this method, all NSManagedObjects fetched within the transaction will become invalid.
    */
    public func rollback() {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to rollback a <\(self.dynamicType)> outside a transaction queue.")
        HardcoreData.assert(!self.isCommitted, "Attempted to rollback an already committed <\(self.dynamicType)>.")
        
        self.context.reset()
    }
    
    
    // MARK: Internal
    
    internal let context: NSManagedObjectContext
    internal let transactionQueue: GCDQueue
    internal let childTransactionQueue: GCDQueue = .createSerial("com.hardcoredata.datastack.childtransactionqueue")
    
    internal var isCommitted = false
    internal var result: SaveResult?
    
    internal init(mainContext: NSManagedObjectContext, queue: GCDQueue) {
        
        self.transactionQueue = queue
        
        let context = mainContext.temporaryContextInTransaction(nil)
        self.context = context
        
        context.retainsRegisteredObjects = true
        context.parentTransaction = self
    }
}
