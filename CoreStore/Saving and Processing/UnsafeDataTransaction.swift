//
//  UnsafeDataTransaction.swift
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


@available(*, deprecated=1.3.1, renamed="UnsafeDataTransaction")
public typealias DetachedDataTransaction = UnsafeDataTransaction


// MARK: - UnsafeDataTransaction

/**
 The `UnsafeDataTransaction` provides an interface for non-contiguous `NSManagedObject` creates, updates, and deletes. This is useful for making temporary changes, such as partially filled forms. An unsafe transaction object should typically be only used from the main queue.
 */
public final class UnsafeDataTransaction: BaseDataTransaction {
    
    /**
     Saves the transaction changes asynchronously. For a `UnsafeDataTransaction`, multiple commits are allowed, although it is the developer's responsibility to ensure a reasonable leeway to prevent blocking the main thread.
     
     - parameter completion: the block executed after the save completes. Success or failure is reported by the `SaveResult` argument of the block.
     */
    public func commit(completion: (result: SaveResult) -> Void) {
        
        self.context.saveAsynchronouslyWithCompletion { (result) -> Void in
            
            self.result = result
            completion(result: result)
        }
    }
    
    /**
     Saves the transaction changes and waits for completion synchronously. For a `UnsafeDataTransaction`, multiple commits are allowed, although it is the developer's responsibility to ensure a reasonable leeway to prevent blocking the main thread.
     
     - returns: a `SaveResult` containing the success or failure information
     */
    public func commitAndWait() -> SaveResult {
        
        let result = self.context.saveSynchronously()
        self.result = result
        return result
    }
    
    /**
     Rolls back the transaction.
     */
    public func rollback() {
        
        CoreStore.assert(
            self.supportsUndo,
            "Attempted to rollback a \(typeName(self)) with Undo support disabled."
        )
        self.context.rollback()
    }
    
    /**
     Undo's the last change made to the transaction.
     */
    public func undo() {
        
        CoreStore.assert(
            self.supportsUndo,
            "Attempted to undo a \(typeName(self)) with Undo support disabled."
        )
        self.context.undo()
    }
    
    /**
     Immediately flushes all pending changes to the transaction's observers. This is useful in conjunction with `ListMonitor`s and `ObjectMonitor`s created from `UnsafeDataTransaction`s used to manage temporary "scratch" data.
     
     - Important: Note that unlike `commit()`, `flush()` does not propagate/save updates to the `DataStack` and the persistent store. However, the flushed changes will be seen by children transactions created further from the current transaction (i.e. through `transaction.beginUnsafe()`)
     - throws: an error thrown from `closure`, or an error thrown by Core Data (usually validation errors or conflict errors)
     */
    public func flush() {
        
        self.context.processPendingChanges()
    }
    
    /**
     Flushes all pending changes to the transaction's observers at the end of the `closure`'s execution. This is useful in conjunction with `ListMonitor`s and `ObjectMonitor`s created from `UnsafeDataTransaction`s used to manage temporary "scratch" data.
     
     - Important: Note that unlike `commit()`, `flush()` does not propagate/save updates to the `DataStack` and the persistent store. However, the flushed changes will be seen by children transactions created further from the current transaction (i.e. through `transaction.beginUnsafe()`)
     - parameter closure: the closure where changes can be made prior to the flush
     - throws: an error thrown from `closure`, or an error thrown by Core Data (usually validation errors or conflict errors)
     */
    public func flush(@noescape closure: () throws -> Void) rethrows {
        
        try closure()
        self.context.processPendingChanges()
    }
    
    /**
     Redo's the last undone change to the transaction.
     */
    public func redo() {
        
        CoreStore.assert(
            self.supportsUndo,
            "Attempted to redo a \(typeName(self)) with Undo support disabled."
        )
        self.context.redo()
    }
    
    /**
     Begins a child transaction where `NSManagedObject` creates, updates, and deletes can be made. This is useful for making temporary changes, such as partially filled forms.
     
     - prameter supportsUndo: `undo()`, `redo()`, and `rollback()` methods are only available when this parameter is `true`, otherwise those method will raise an exception. Defaults to `false`. Note that turning on Undo support may heavily impact performance especially on iOS or watchOS where memory is limited.
     - returns: a `UnsafeDataTransaction` instance where creates, updates, and deletes can be made.
     */
    @warn_unused_result
    public func beginUnsafe(supportsUndo supportsUndo: Bool = false) -> UnsafeDataTransaction {
        
        return UnsafeDataTransaction(
            mainContext: self.context,
            queue: self.transactionQueue,
            supportsUndo: supportsUndo
        )
    }
    
    /**
     Returns the `NSManagedObjectContext` for this unsafe transaction. Use only for cases where external frameworks need an `NSManagedObjectContext` instance to work with.
     
     - Important: Note that it is the developer's responsibility to ensure the following:
     - that the `UnsafeDataTransaction` that owns this context should be strongly referenced and prevented from being deallocated during the context's lifetime
     - that all saves will be done either through the `UnsafeDataTransaction`'s `commit(...)` method, or by calling `save()` manually on the context, its parent, and all other ancestor contexts if there are any.
     */
    public var internalContext: NSManagedObjectContext {
        
        return self.context
    }
    
    @available(*, deprecated=1.3.1, renamed="beginUnsafe")
    @warn_unused_result
    public func beginDetached() -> UnsafeDataTransaction {
        
        return self.beginUnsafe()
    }
    
    
    // MARK: Internal
    
    internal init(mainContext: NSManagedObjectContext, queue: GCDQueue, supportsUndo: Bool) {
        
        super.init(mainContext: mainContext, queue: queue, supportsUndo: supportsUndo, bypassesQueueing: true)
    }
}
