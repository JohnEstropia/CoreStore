//
//  BaseDataTransaction.swift
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


// MARK: - BaseDataTransaction

/**
The BaseDataTransaction is an abstract interface for NSManagedObject creates, updates, and deletes. All BaseDataTransaction subclasses manage a private NSManagedObjectContext which are direct children of the NSPersistentStoreCoordinator's root NSManagedObjectContext. This means that all updates are saved first to the persistent store, and then propagated up to the read-only NSManagedObjectContext.
*/
public /*abstract*/ class BaseDataTransaction {
    
    // MARK: Object management
    
    var hasChanges: Bool {
        
        return self.context.hasChanges
    }
    
    /**
    Creates a new NSManagedObject with the specified entity type.
    
    :param: entity the NSManagedObject type to be created
    :returns: a new NSManagedObject instance of the specified entity type.
    */
    public func create<T: NSManagedObject>(entity: T.Type) -> T {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to create an entity of type <\(entity)> outside its designated queue.")
        
        return T.createInContext(self.context)
    }
    
    /**
    Returns an editable proxy of a specified NSManagedObject.
    
    :param: object the NSManagedObject type to be edited
    :returns: an editable proxy for the specified NSManagedObject.
    */
    public func fetch<T: NSManagedObject>(object: T) -> T? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to update an entity of type \(typeName(object)) outside its designated queue.")
        
        return object.inContext(self.context)
    }
    
    /**
    Deletes a specified NSManagedObject.
    
    :param: object the NSManagedObject type to be deleted
    */
    public func delete(object: NSManagedObject) {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to delete an entity of type \(typeName(object)) outside its designated queue.")
        
        object.inContext(self.context)?.deleteFromContext()
    }
    
    // MARK: Saving changes
    
    /**
    Rolls back the transaction by resetting the NSManagedObjectContext. After calling this method, all NSManagedObjects fetched within the transaction will become invalid.
    */
    public func rollback() {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to rollback a \(typeName(self)) outside its designated queue.")
        
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
        
        let context = mainContext.temporaryContextInTransactionWithConcurrencyType(
            queue == .Main
                ? .MainQueueConcurrencyType
                : .PrivateQueueConcurrencyType
        )
        self.context = context
        
        context.parentTransaction = self
    }
}
