//
//  CSCoreStore+Transaction.swift
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
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


// MARK: - CSCoreStore

public extension CSCoreStore {
    
    /**
     Using the `defaultStack`, begins a transaction asynchronously where `NSManagedObject` creates, updates, and deletes can be made.
     
     - parameter closure: the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent `NSManagedObjectContext`.
     */
    @objc
    public static func beginAsynchronous(_ closure: @escaping (_ transaction: CSAsynchronousDataTransaction) -> Void) {
        
        self.defaultStack.beginAsynchronous(closure)
    }
    
    /**
     Using the `defaultStack`, begins a transaction synchronously where `NSManagedObject` creates, updates, and deletes can be made.
     
     - parameter closure: the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent `NSManagedObjectContext`.
     - returns: a `CSSaveResult` value indicating success or failure, or `nil` if the transaction was not comitted synchronously
     */
    @objc
    public static func beginSynchronous(_ closure: @escaping (_ transaction: CSSynchronousDataTransaction) -> Void, error: NSErrorPointer) -> Bool {
        
        return self.defaultStack.beginSynchronous(closure, error: error)
    }
    
    /**
     Using the `defaultStack`, begins a child transaction where `NSManagedObject` creates, updates, and deletes can be made. This is useful for making temporary changes, such as partially filled forms.
     
     To support "undo" methods such as `-undo`, `-redo`, and `-rollback`, use the `-beginSafeWithSupportsUndo:` method passing `YES` to the argument. Without "undo" support, calling those methods will raise an exception.
     - returns: a `CSUnsafeDataTransaction` instance where creates, updates, and deletes can be made.
     */
    @objc
    public static func beginUnsafe() -> CSUnsafeDataTransaction {
        
        return bridge {
            
            CoreStore.beginUnsafe()
        }
    }
    
    /**
     Using the `defaultStack`, begins a child transaction where `NSManagedObject` creates, updates, and deletes can be made. This is useful for making temporary changes, such as partially filled forms.
     
     - prameter supportsUndo: `-undo`, `-redo`, and `-rollback` methods are only available when this parameter is `YES`, otherwise those method will raise an exception. Note that turning on Undo support may heavily impact performance especially on iOS or watchOS where memory is limited.
     - returns: a `CSUnsafeDataTransaction` instance where creates, updates, and deletes can be made.
     */
    @objc
    public static func beginUnsafeWithSupportsUndo(_ supportsUndo: Bool) -> CSUnsafeDataTransaction {
        
        return bridge {
            
            CoreStore.beginUnsafe(supportsUndo: supportsUndo)
        }
    }
    
    /**
     Refreshes all registered objects `NSManagedObject`s in the `defaultStack`.
     */
    @objc
    public static func refreshAndMergeAllObjects() {
        
        CoreStore.refreshAndMergeAllObjects()
    }
    
    
    // MARK: Deprecated
    
    @available(*, deprecated, message: "Use the new +[CSCoreStore beginSynchronous:error:] API that reports failure using an error instance.")
    @objc
    @discardableResult
    public static func beginSynchronous(_ closure: @escaping (_ transaction: CSSynchronousDataTransaction) -> Void) -> CSSaveResult? {
        
        return self.defaultStack.beginSynchronous(closure)
    }
}
