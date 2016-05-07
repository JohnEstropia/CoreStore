//
//  CoreStore+Transaction.swift
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


// MARK: - CoreStore

public extension CoreStore {
    
    /**
     Using the `defaultStack`, begins a transaction asynchronously where `NSManagedObject` creates, updates, and deletes can be made.
     
     - parameter closure: the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent `NSManagedObjectContext`.
     */
    public static func beginAsynchronous(closure: (transaction: AsynchronousDataTransaction) -> Void) {
        
        self.defaultStack.beginAsynchronous(closure)
    }
    
    /**
     Using the `defaultStack`, begins a transaction asynchronously where `NSManagedObject` creates, updates, and deletes can be made.
     
     - parameter closure: the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent `NSManagedObjectContext`.
     - returns: a `SaveResult` value indicating success or failure, or `nil` if the transaction was not comitted synchronously
     */
    public static func beginSynchronous(closure: (transaction: SynchronousDataTransaction) -> Void) -> SaveResult? {
        
        return self.defaultStack.beginSynchronous(closure)
    }
    
    /**
     Using the `defaultStack`, begins a non-contiguous transaction where `NSManagedObject` creates, updates, and deletes can be made. This is useful for making temporary changes, such as partially filled forms. An unsafe transaction object should typically be only used from the main queue.
     
     - prameter supportsUndo: `undo()`, `redo()`, and `rollback()` methods are only available when this parameter is `true`, otherwise those method will raise an exception. Defaults to `false`. Note that turning on Undo support may heavily impact performance especially on iOS or watchOS where memory is limited.
     - returns: a `UnsafeDataTransaction` instance where creates, updates, and deletes can be made.
     */
    @warn_unused_result
    public static func beginUnsafe(supportsUndo supportsUndo: Bool = false) -> UnsafeDataTransaction {
        
        return self.defaultStack.beginUnsafe(supportsUndo: supportsUndo)
    }
    
    /**
     Refreshes all registered objects `NSManagedObject`s in the `DataStack`.
     */
    public static func refreshAndMergeAllObjects() {
        
        self.defaultStack.refreshAndMergeAllObjects()
    }
    
    @available(*, deprecated=1.3.1, renamed="beginUnsafe")
    @warn_unused_result
    public static func beginDetached() -> UnsafeDataTransaction {
        
        return self.beginUnsafe()
    }
}
