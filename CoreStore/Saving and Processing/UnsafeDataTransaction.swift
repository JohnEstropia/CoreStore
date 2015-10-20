//
//  UnsafeDataTransaction.swift
//  CoreStore
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
import CoreData
import GCDKit


@available(*, deprecated=1.3.1, renamed="UnsafeDataTransaction")
public typealias DetachedDataTransaction = UnsafeDataTransaction


// MARK: - UnsafeDataTransaction

/**
The `UnsafeDataTransaction` provides an interface for non-contiguous `NSManagedObject` creates, updates, and deletes. This is useful for making temporary changes, such as partially filled forms. An unsafe transaction object should typically be only used from the main queue.
*/
public final class UnsafeDataTransaction: BaseDataTransaction {
    
    // MARK: Public
    
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
    Begins a child transaction where `NSManagedObject` creates, updates, and deletes can be made. This is useful for making temporary changes, such as partially filled forms.
    
    - returns: a `UnsafeDataTransaction` instance where creates, updates, and deletes can be made.
    */
    @warn_unused_result
    public func beginUnsafe() -> UnsafeDataTransaction {
        
        return UnsafeDataTransaction(
            mainContext: self.context,
            queue: self.transactionQueue
        )
    }
    
    /**
    Returns the `NSManagedObjectContext` for this unsafe transaction. Use only for cases where external frameworks need an `NSManagedObjectContext` instance to work with.
    
    Note that it is the developer's responsibility to ensure the following:
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
    
    internal override var bypassesQueueing: Bool {
        
        return true
    }
}

