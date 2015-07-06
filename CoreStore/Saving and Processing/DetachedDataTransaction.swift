//
//  DetachedDataTransaction.swift
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
import GCDKit


// MARK: - DetachedDataTransaction

/**
The `DetachedDataTransaction` provides an interface for non-contiguous `NSManagedObject` creates, updates, and deletes. This is useful for making temporary changes, such as partially filled forms. A detached transaction object should typically be only used from the main queue.
*/
public final class DetachedDataTransaction: BaseDataTransaction {
    
    // MARK: Public
    
    /**
    Saves the transaction changes asynchronously. For a `DetachedDataTransaction`, multiple commits are allowed, although it is the developer's responsibility to ensure a reasonable leeway to prevent blocking the main thread.
    
    - parameter completion: the block executed after the save completes. Success or failure is reported by the `SaveResult` argument of the block.
    */
    public func commit(completion: (result: SaveResult) -> Void) {
        
        CoreStore.assert(
            self.transactionQueue.isCurrentExecutionContext(),
            "Attempted to commit a \(typeName(self)) outside its designated queue."
        )
        
        self.context.saveAsynchronouslyWithCompletion { (result) -> Void in
            
            self.result = result
            completion(result: result)
        }
    }
}

