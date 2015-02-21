//
//  DataStack+Transaction.swift
//  HardcoreData
//
//  Created by John Rommel Estropia on 2015/02/15.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import Foundation
import CoreData


// MARK: - DataStack+Transaction

extension DataStack {
    
    // MARK: Public
    
    /**
    Begins a transaction asynchronously where NSManagedObject creates, updates, and deletes can be made.
    
    :param: closure the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent NSManagedObjectContext.
    */
    public func performTransaction(closure: (transaction: DataTransaction) -> Void) {
        
        DataTransaction(
            mainContext: self.mainContext,
            queue: self.transactionQueue,
            closure: closure).perform()
    }
    
    /**
    Begins a transaction synchronously where NSManagedObject creates, updates, and deletes can be made.
    
    :param: closure the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent NSManagedObjectContext.
    :returns: a SaveResult value indicating success or failure, or nil if the transaction was not comitted synchronously
    */
    public func performTransactionAndWait(closure: (transaction: DataTransaction) -> Void) -> SaveResult? {
        
        return DataTransaction(
            mainContext: self.mainContext,
            queue: self.transactionQueue,
            closure: closure).performAndWait()
    }
}