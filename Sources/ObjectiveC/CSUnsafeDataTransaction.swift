//
//  CSUnsafeDataTransaction.swift
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
import CoreData


// MARK: - CSUnsafeDataTransaction

/**
 The `CSUnsafeDataTransaction` serves as the Objective-C bridging type for `UnsafeDataTransaction`.
 
 - SeeAlso: `UnsafeDataTransaction`
 */
@objc
public final class CSUnsafeDataTransaction: CSBaseDataTransaction {
    
    /**
     Saves the transaction changes asynchronously. For a `CSUnsafeDataTransaction`, multiple commits are allowed, although it is the developer's responsibility to ensure a reasonable leeway to prevent blocking the main thread.
     
     - parameter completion: the block executed after the save completes. Success or failure is reported by the `CSSaveResult` argument of the block.
     */
    @objc
    public func commit(completion: ((result: CSSaveResult) -> Void)?) {
        
        self.bridgeToSwift.commit { (result) in
            
            completion?(result: result.bridgeToObjectiveC)
        }
    }
    
    /**
     Saves the transaction changes and waits for completion synchronously. For a `CSUnsafeDataTransaction`, multiple commits are allowed, although it is the developer's responsibility to ensure a reasonable leeway to prevent blocking the main thread.
     
     - returns: a `CSSaveResult` containing the success or failure information
     */
    @objc
    public func commitAndWait() -> CSSaveResult {
        
        return bridge {
            
            self.bridgeToSwift.commitAndWait()
        }
    }
    
    /**
     Rolls back the transaction.
     */
    @objc
    public func rollback() {
        
        self.bridgeToSwift.rollback()
    }
    
    /**
     Undo's the last change made to the transaction.
     */
    @objc
    public func undo() {
        
        self.bridgeToSwift.undo()
    }
    
    /**
     Redo's the last undone change to the transaction.
     */
    @objc
    public func redo() {
        
        self.bridgeToSwift.redo()
    }
    
    /**
     Immediately flushes all pending changes to the transaction's observers. This is useful in conjunction with `ListMonitor`s and `ObjectMonitor`s created from `UnsafeDataTransaction`s used to manage temporary "scratch" data.
     
     - Important: Note that unlike `commit()`, `flush()` does not propagate/save updates to the `DataStack` and the persistent store. However, the flushed changes will be seen by children transactions created further from the current transaction (i.e. through `transaction.beginUnsafe()`)
     */
    @objc
    public func flush() {
        
        self.bridgeToSwift.flush()
    }
    
    /**
     Flushes all pending changes to the transaction's observers at the end of the `closure`'s execution. This is useful in conjunction with `ListMonitor`s and `ObjectMonitor`s created from `UnsafeDataTransaction`s used to manage temporary "scratch" data.
     
     - Important: Note that unlike `commit()`, `flush()` does not propagate/save updates to the `DataStack` and the persistent store. However, the flushed changes will be seen by children transactions created further from the current transaction (i.e. through `transaction.beginUnsafe()`)
     - parameter closure: the closure where changes can be made prior to the flush
     */
    @objc
    public func flush(block: () -> Void) {
        
        self.bridgeToSwift.flush {
            
            block()
        }
    }
    
    /**
     Begins a child transaction where `NSManagedObject` creates, updates, and deletes can be made. This is useful for making temporary changes, such as partially filled forms.
     
     To support "undo" methods such as `-undo`, `-redo`, and `-rollback`, use the `-beginSafeWithSupportsUndo:` method passing `YES` to the argument. Without "undo" support, calling those methods will raise an exception.
     - returns: a `CSUnsafeDataTransaction` instance where creates, updates, and deletes can be made.
     */
    @objc
    @warn_unused_result
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
    @warn_unused_result
    public func beginUnsafeWithSupportsUndo(supportsUndo: Bool) -> CSUnsafeDataTransaction {
        
        return bridge {
            
            self.bridgeToSwift.beginUnsafe(supportsUndo: supportsUndo)
        }
    }
    
    /**
     Returns the `NSManagedObjectContext` for this unsafe transaction. Use only for cases where external frameworks need an `NSManagedObjectContext` instance to work with.
     
     Note that it is the developer's responsibility to ensure the following:
     - that the `CSUnsafeDataTransaction` that owns this context should be strongly referenced and prevented from being deallocated during the context's lifetime
     - that all saves will be done either through the `CSUnsafeDataTransaction`'s `-commit:` or `-commitAndWait` method, or by calling `-save:` manually on the context, its parent, and all other ancestor contexts if there are any.
     */
    @objc
    public var internalContext: NSManagedObjectContext {
        
        return self.bridgeToSwift.context
    }
    
    
    // MARK: NSObject
    
    public override var description: String {
        
        return "(\(String(reflecting: self.dynamicType))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    internal typealias SwiftType = UnsafeDataTransaction
    
    public override var bridgeToSwift: UnsafeDataTransaction {
        
        return super.bridgeToSwift as! UnsafeDataTransaction
    }
    
    public required init(_ swiftValue: UnsafeDataTransaction) {
        
        super.init(swiftValue)
    }
    
    public required init(_ swiftValue: BaseDataTransaction) {
        
        fatalError("init(_:) requires an UnsafeDataTransaction instance")
    }
}


// MARK: - UnsafeDataTransaction

extension UnsafeDataTransaction {
    
    // MARK: CoreStoreSwiftType
    
    internal typealias ObjectiveCType = CSUnsafeDataTransaction
}
