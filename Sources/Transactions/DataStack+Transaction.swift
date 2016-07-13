//
//  DataStack+Transaction.swift
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
#if USE_FRAMEWORKS
    import GCDKit
#endif


// MARK: - DataStack

public extension DataStack {
    
    /**
     Begins a transaction asynchronously where `NSManagedObject` creates, updates, and deletes can be made.
     
     - parameter closure: the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent `NSManagedObjectContext`.
     */
    public func beginAsynchronous(closure: (transaction: AsynchronousDataTransaction) -> Void) {
        
        AsynchronousDataTransaction(
            mainContext: self.rootSavingContext,
            queue: self.childTransactionQueue,
            closure: closure).perform()
    }
    
    /**
     Begins a transaction synchronously where `NSManagedObject` creates, updates, and deletes can be made.
     
     - parameter closure: the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent `NSManagedObjectContext`.
     - returns: a `SaveResult` value indicating success or failure, or `nil` if the transaction was not comitted synchronously
     */
    public func beginSynchronous(closure: (transaction: SynchronousDataTransaction) -> Void) -> SaveResult? {
        
        return SynchronousDataTransaction(
            mainContext: self.rootSavingContext,
            queue: self.childTransactionQueue,
            closure: closure).performAndWait()
    }
    
    /**
     Begins a non-contiguous transaction where `NSManagedObject` creates, updates, and deletes can be made. This is useful for making temporary changes, such as partially filled forms.
     
     - prameter supportsUndo: `undo()`, `redo()`, and `rollback()` methods are only available when this parameter is `true`, otherwise those method will raise an exception. Defaults to `false`. Note that turning on Undo support may heavily impact performance especially on iOS or watchOS where memory is limited.
     - returns: a `UnsafeDataTransaction` instance where creates, updates, and deletes can be made.
     */
    @warn_unused_result
    public func beginUnsafe(supportsUndo supportsUndo: Bool = false) -> UnsafeDataTransaction {
        
        return UnsafeDataTransaction(
            mainContext: self.rootSavingContext,
            queue: .createSerial(
                "com.coreStore.dataStack.unsafeTransactionQueue",
                targetQueue: .UserInitiated
            ),
            supportsUndo: supportsUndo
        )
    }
    
    /**
     Refreshes all registered objects `NSManagedObject`s in the `DataStack`.
     */
    public func refreshAndMergeAllObjects() {
        
        CoreStore.assert(
            NSThread.isMainThread(),
            "Attempted to refresh entities outside their designated queue."
        )
        
        self.mainContext.refreshAndMergeAllObjects()
    }
    
    
    // MARK: Deprecated
    
    @available(*, deprecated=1.3.1, obsoleted=2.0.0, renamed="beginUnsafe")
    @warn_unused_result
    public func beginDetached() -> UnsafeDataTransaction {
        
        return self.beginUnsafe()
    }
}
