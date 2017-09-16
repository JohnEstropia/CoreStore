//
//  CSDataStack+Transaction.swift
//  CoreStore
//
//  Copyright © 2016 John Rommel Estropia
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


// MARK: - CSDataStack

public extension CSDataStack {
    
    /**
     Begins a transaction asynchronously where `NSManagedObject` creates, updates, and deletes can be made.
     
     - parameter closure: the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent `NSManagedObjectContext`.
     */
    @objc
    public func beginAsynchronous(_ closure: @escaping (_ transaction: CSAsynchronousDataTransaction) -> Void) {
        
        self.bridgeToSwift.perform(
            asynchronous: { (transaction) in
                
                let csTransaction = transaction.bridgeToObjectiveC
                closure(csTransaction)
                if !transaction.isCommitted && transaction.hasChanges {
                    
                    CoreStore.log(
                        .warning,
                        message: "The closure for the \(cs_typeName(csTransaction)) completed without being committed. All changes made within the transaction were discarded."
                    )
                }
                try transaction.cancel()
            },
            completion: { _ in }
        )
    }
    
    /**
     Begins a transaction synchronously where `NSManagedObject` creates, updates, and deletes can be made.
     
     - parameter closure: the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent `NSManagedObjectContext`.
     - parameter error: the `CSError` pointer that indicates the reason in case of an failure
     - returns: `YES` if the commit succeeded, `NO` if the commit failed. If `NO`, the `error` argument will hold error information.
     */
    @objc
    public func beginSynchronous(_ closure: @escaping (_ transaction: CSSynchronousDataTransaction) -> Void, error: NSErrorPointer) -> Bool {
        
        return bridge(error) {
            
            do {
                
                try self.bridgeToSwift.perform(
                    synchronous: { (transaction) in
                        
                        let csTransaction = transaction.bridgeToObjectiveC
                        closure(csTransaction)
                        if !transaction.isCommitted && transaction.hasChanges {
                            
                            CoreStore.log(
                                .warning,
                                message: "The closure for the \(cs_typeName(csTransaction)) completed without being committed. All changes made within the transaction were discarded."
                            )
                        }
                        try transaction.cancel()
                    }
                )
            }
            catch CoreStoreError.userCancelled {
                
                return
            }
        }
    }
    
    /**
     Begins a child transaction where `NSManagedObject` creates, updates, and deletes can be made. This is useful for making temporary changes, such as partially filled forms.
     
     To support "undo" methods such as `-undo`, `-redo`, and `-rollback`, use the `-beginSafeWithSupportsUndo:` method passing `YES` to the argument. Without "undo" support, calling those methods will raise an exception.
     - returns: a `CSUnsafeDataTransaction` instance where creates, updates, and deletes can be made.
     */
    @objc
    public func beginUnsafe() -> CSUnsafeDataTransaction {
        
        return bridge {
            
            self.bridgeToSwift.beginUnsafe()
        }
    }
    
    /**
     Begins a child transaction where `NSManagedObject` creates, updates, and deletes can be made. This is useful for making temporary changes, such as partially filled forms.
     
     - prameter supportsUndo: `-undo`, `-redo`, and `-rollback` methods are only available when this parameter is `YES`, otherwise those method will raise an exception. Note that turning on Undo support may heavily impact performance especially on iOS or watchOS where memory is limited.
     - returns: a `CSUnsafeDataTransaction` instance where creates, updates, and deletes can be made.
     */
    @objc
    public func beginUnsafeWithSupportsUndo(_ supportsUndo: Bool) -> CSUnsafeDataTransaction {
        
        return bridge {
            
            self.bridgeToSwift.beginUnsafe(supportsUndo: supportsUndo)
        }
    }
    
    /**
     Refreshes all registered objects `NSManagedObject`s in the `DataStack`.
     */
    @objc
    public func refreshAndMergeAllObjects() {
        
        self.bridgeToSwift.refreshAndMergeAllObjects()
    }
    
    
    // MARK: Deprecated
    
    @available(*, deprecated, message: "Use the new -[CSDataStack beginSynchronous:error:] API that reports failure using an error instance.")
    @objc
    @discardableResult
    public func beginSynchronous(_ closure: @escaping (_ transaction: CSSynchronousDataTransaction) -> Void) -> CSSaveResult? {
        
        return bridge {
            
            self.bridgeToSwift.beginSynchronous { (transaction) in
                
                closure(transaction.bridgeToObjectiveC)
            }
        }
    }
}
