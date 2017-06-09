//
//  CSAsynchronousDataTransaction.swift
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


// MARK: - CSAsynchronousDataTransaction

/**
 The `CSAsynchronousDataTransaction` serves as the Objective-C bridging type for `AsynchronousDataTransaction`.
 
 - SeeAlso: `AsynchronousDataTransaction`
 */
@objc
public final class CSAsynchronousDataTransaction: CSBaseDataTransaction, CoreStoreObjectiveCType {
    
    /**
     Saves the transaction changes. This method should not be used after the `-commitWithCompletion:` method was already called once.
     
     - parameter success: the block executed if the save succeeds.
     - parameter failure: the block executed if the save fails. A `CSError` is reported as the argument of the block.
     */
    @objc
    public func commitWithSuccess(_ success: (() -> Void)?, failure: ((CSError) -> Void)?) {
        
        CoreStore.assert(
            self.bridgeToSwift.transactionQueue.cs_isCurrentExecutionContext(),
            "Attempted to commit a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.bridgeToSwift.isCommitted,
            "Attempted to commit a \(cs_typeName(self)) more than once."
        )
        self.bridgeToSwift.autoCommit { (_, error) in
            
            if let error = error {
                
                failure?(error.bridgeToObjectiveC)
            }
            else {
                
                success?()
            }
        }
    }
    
    
    // MARK: NSObject
    
    public override var description: String {
        
        return "(\(String(reflecting: type(of: self)))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: BaseDataTransaction
    
    /**
     Creates a new `NSManagedObject` with the specified entity type.
     
     - parameter into: the `CSInto` clause indicating the destination `NSManagedObject` entity type and the destination configuration
     - returns: a new `NSManagedObject` instance of the specified entity type.
     */
    @objc
    public override func createInto(_ into: CSInto) -> Any {
        
        return self.bridgeToSwift.create(into.bridgeToSwift)
    }
    
    /**
     Returns an editable proxy of a specified `NSManagedObject`. This method should not be used after the `-commitWithCompletion:` method was already called once.
     
     - parameter object: the `NSManagedObject` type to be edited
     - returns: an editable proxy for the specified `NSManagedObject`.
     */
    @objc
    public override func editObject(_ object: NSManagedObject?) -> Any? {
        
        return self.bridgeToSwift.edit(object)
    }
    
    /**
     Returns an editable proxy of the object with the specified `NSManagedObjectID`. This method should not be used after the `-commitWithCompletion:` method was already called once.
     
     - parameter into: a `CSInto` clause specifying the entity type
     - parameter objectID: the `NSManagedObjectID` for the object to be edited
     - returns: an editable proxy for the specified `NSManagedObject`.
     */
    @objc
    public override func editInto(_ into: CSInto, objectID: NSManagedObjectID) -> Any? {
        
        return self.bridgeToSwift.edit(into.bridgeToSwift, objectID)
    }
    
    /**
     Deletes a specified `NSManagedObject`. This method should not be used after the `-commitWithCompletion:` method was already called once.
     
     - parameter object: the `NSManagedObject` type to be deleted
     */
    @objc
    public override func deleteObject(_ object: NSManagedObject?) {
        
        self.bridgeToSwift.delete(object)
    }
    
    /**
     Deletes the specified `NSManagedObject`s.
     
     - parameter objects: the `NSManagedObject`s type to be deleted
     */
    @objc
    public override func deleteObjects(_ objects: [NSManagedObject]) {
        
        self.bridgeToSwift.delete(objects)
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public typealias SwiftType = AsynchronousDataTransaction
    
    public var bridgeToSwift: AsynchronousDataTransaction {
        
        return super.swiftTransaction as! AsynchronousDataTransaction
    }
    
    public required init(_ swiftValue: AsynchronousDataTransaction) {
        
        super.init(swiftValue as BaseDataTransaction)
    }
    
    public required override init(_ swiftValue: BaseDataTransaction) {
        
        super.init(swiftValue)
    }
    
    
    // MARK: Deprecated
    
    @available(*, deprecated, message: "Use the new -[CSAsynchronousDataTransaction commitWithSuccess:failure:] method.")
    @objc
    public func commitWithCompletion(_ completion: ((_ result: CSSaveResult) -> Void)?) {
        
        CoreStore.assert(
            self.bridgeToSwift.transactionQueue.cs_isCurrentExecutionContext(),
            "Attempted to commit a \(cs_typeName(self)) outside its designated queue."
        )
        CoreStore.assert(
            !self.bridgeToSwift.isCommitted,
            "Attempted to commit a \(cs_typeName(self)) more than once."
        )
        self.bridgeToSwift.commit { (result) in
            
            completion?(result.bridgeToObjectiveC)
        }
    }
    
    @available(*, deprecated, message: "Secondary tasks spawned from CSAsynchronousDataTransactions and CSSynchronousDataTransactions are no longer supported. ")
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


// MARK: - AsynchronousDataTransaction

extension AsynchronousDataTransaction: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSAsynchronousDataTransaction {
        
        return CSAsynchronousDataTransaction(self)
    }
}
