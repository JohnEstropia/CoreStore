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


// MARK: - DataStack

public extension DataStack {
    
    
    public func perform<T>(asynchronous task: @escaping (_ transaction: AsynchronousDataTransaction) throws -> T, completion: @escaping (TransactionResult<T>) -> Void) {
        
        self.perform(
            asynchronous: task,
            success: { completion(TransactionResult(userInfo: $0)) },
            failure: { completion(TransactionResult(error: $0)) }
        )
    }
    
    public func perform<T>(asynchronous task: @escaping (_ transaction: AsynchronousDataTransaction) throws -> T, success: @escaping (T) -> Void, failure: @escaping (CoreStoreError) -> Void) {
        
        let transaction = AsynchronousDataTransaction(
            mainContext: self.rootSavingContext,
            queue: self.childTransactionQueue,
            closure: { _ in }
        )
        transaction.transactionQueue.cs_async {
            
            let userInfo: T
            do {
                
                userInfo = try task(transaction)
            }
            catch let error as CoreStoreError {
                
                DispatchQueue.main.async { failure(error) }
                return
            }
            catch let error {
                
                DispatchQueue.main.async { failure(.userError(error: error)) }
                return
            }
            transaction.commit { (result) in
                
                switch result {
                    
                case .success: success(userInfo)
                case .failure(let error): failure(error)
                }
            }
        }
    }
    
    public func perform<T>(synchronous task: ((_ transaction: SynchronousDataTransaction) throws -> T), waitForObserverNotifications: Bool = true) throws -> T {
        
        let transaction = SynchronousDataTransaction(
            mainContext: self.rootSavingContext,
            queue: self.childTransactionQueue,
            closure: { _ in }
        )
        return try transaction.transactionQueue.cs_sync {
            
            let userInfo: T
            do {
                
                userInfo = try task(transaction)
            }
            catch let error as CoreStoreError {
                
                throw error
            }
            catch let error {
                
                throw CoreStoreError.userError(error: error)
            }
            let result = waitForObserverNotifications
                ? transaction.commitAndWait()
                : transaction.commit()
            switch result {
                
            case .success: return userInfo
            case .failure(let error): throw error
            }
        }
    }
    
    
    /**
     Begins a transaction asynchronously where `NSManagedObject` creates, updates, and deletes can be made.
     
     - parameter closure: the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent `NSManagedObjectContext`.
     */
    public func beginAsynchronous(_ closure: @escaping (_ transaction: AsynchronousDataTransaction) -> Void) {
        
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
    @discardableResult
    public func beginSynchronous(_ closure: @escaping (_ transaction: SynchronousDataTransaction) -> Void) -> SaveResult? {
        
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
    public func beginUnsafe(supportsUndo: Bool = false) -> UnsafeDataTransaction {
        
        return UnsafeDataTransaction(
            mainContext: self.rootSavingContext,
            queue: DispatchQueue.serial("com.coreStore.dataStack.unsafeTransactionQueue", qos: .userInitiated),
            supportsUndo: supportsUndo
        )
    }
    
    /**
     Refreshes all registered objects `NSManagedObject`s in the `DataStack`.
     */
    public func refreshAndMergeAllObjects() {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to refresh entities outside their designated queue."
        )
        self.mainContext.refreshAndMergeAllObjects()
    }
}
