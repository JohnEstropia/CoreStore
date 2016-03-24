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


// MARK: - CSAsynchronousDataTransaction

/**
 The `CSAsynchronousDataTransaction` serves as the Objective-C bridging type for `AsynchronousDataTransaction`.
 */
@objc
public final class CSAsynchronousDataTransaction: CSBaseDataTransaction {
    
//    /**
//     Saves the transaction changes. This method should not be used after the `commit()` method was already called once.
//     
//     - parameter completion: the block executed after the save completes. Success or failure is reported by the `SaveResult` argument of the block.
//     */
//    public func commit(completion: (result: SaveResult) -> Void = { _ in }) {
//        
//        CoreStore.assert(
//            self.transactionQueue.isCurrentExecutionContext(),
//            "Attempted to commit a \(typeName(self)) outside its designated queue."
//        )
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to commit a \(typeName(self)) more than once."
//        )
//        
//        self.isCommitted = true
//        let group = GCDGroup()
//        group.enter()
//        self.context.saveAsynchronouslyWithCompletion { (result) -> Void in
//            
//            self.result = result
//            completion(result: result)
//            group.leave()
//        }
//        group.wait()
//    }
//    
//    /**
//     Begins a child transaction synchronously where NSManagedObject creates, updates, and deletes can be made. This method should not be used after the `commit()` method was already called once.
//     
//     - parameter closure: the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent `NSManagedObjectContext`.
//     - returns: a `SaveResult` value indicating success or failure, or `nil` if the transaction was not comitted synchronously
//     */
//    public func beginSynchronous(closure: (transaction: SynchronousDataTransaction) -> Void) -> SaveResult? {
//        
//        CoreStore.assert(
//            self.transactionQueue.isCurrentExecutionContext(),
//            "Attempted to begin a child transaction from a \(typeName(self)) outside its designated queue."
//        )
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to begin a child transaction from an already committed \(typeName(self))."
//        )
//        
//        return SynchronousDataTransaction(
//            mainContext: self.context,
//            queue: self.childTransactionQueue,
//            closure: closure).performAndWait()
//    }
//    
//    
//    // MARK: BaseDataTransaction
//    
//    /**
//     Creates a new `NSManagedObject` with the specified entity type.
//     
//     - parameter into: the `Into` clause indicating the destination `NSManagedObject` entity type and the destination configuration
//     - returns: a new `NSManagedObject` instance of the specified entity type.
//     */
//    public override func create<T: NSManagedObject>(into: Into<T>) -> T {
//        
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to create an entity of type \(typeName(T)) from an already committed \(typeName(self))."
//        )
//        
//        return super.create(into)
//    }
//    
//    /**
//     Returns an editable proxy of a specified `NSManagedObject`. This method should not be used after the `commit()` method was already called once.
//     
//     - parameter object: the `NSManagedObject` type to be edited
//     - returns: an editable proxy for the specified `NSManagedObject`.
//     */
//    @warn_unused_result
//    public override func edit<T: NSManagedObject>(object: T?) -> T? {
//        
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to update an entity of type \(typeName(object)) from an already committed \(typeName(self))."
//        )
//        
//        return super.edit(object)
//    }
//    
//    /**
//     Returns an editable proxy of the object with the specified `NSManagedObjectID`. This method should not be used after the `commit()` method was already called once.
//     
//     - parameter into: an `Into` clause specifying the entity type
//     - parameter objectID: the `NSManagedObjectID` for the object to be edited
//     - returns: an editable proxy for the specified `NSManagedObject`.
//     */
//    @warn_unused_result
//    public override func edit<T: NSManagedObject>(into: Into<T>, _ objectID: NSManagedObjectID) -> T? {
//        
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to update an entity of type \(typeName(T)) from an already committed \(typeName(self))."
//        )
//        
//        return super.edit(into, objectID)
//    }
//    
//    /**
//     Deletes a specified `NSManagedObject`. This method should not be used after the `commit()` method was already called once.
//     
//     - parameter object: the `NSManagedObject` type to be deleted
//     */
//    public override func delete(object: NSManagedObject?) {
//        
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to delete an entity of type \(typeName(object)) from an already committed \(typeName(self))."
//        )
//        
//        super.delete(object)
//    }
//    
//    /**
//     Deletes the specified `NSManagedObject`s.
//     
//     - parameter object1: the `NSManagedObject` type to be deleted
//     - parameter object2: another `NSManagedObject` type to be deleted
//     - parameter objects: other `NSManagedObject`s type to be deleted
//     */
//    public override func delete(object1: NSManagedObject?, _ object2: NSManagedObject?, _ objects: NSManagedObject?...) {
//        
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to delete an entities from an already committed \(typeName(self))."
//        )
//        
//        super.delete(([object1, object2] + objects).flatMap { $0 })
//    }
//    
//    /**
//     Deletes the specified `NSManagedObject`s.
//     
//     - parameter objects: the `NSManagedObject`s type to be deleted
//     */
//    public override func delete<S: SequenceType where S.Generator.Element: NSManagedObject>(objects: S) {
//        
//        CoreStore.assert(
//            !self.isCommitted,
//            "Attempted to delete an entities from an already committed \(typeName(self))."
//        )
//        
//        super.delete(objects)
    //    }
    
    
    // MARK: CoreStoreBridge
    
    internal override var swift: AsynchronousDataTransaction {
        
        return super.swift as! AsynchronousDataTransaction
    }
    
    public required init(_ swiftObject: AsynchronousDataTransaction) {
        
        super.init(swiftObject)
    }
    
    required public init(_ swiftObject: BaseDataTransaction) {
        
        fatalError("init has not been implemented")
    }
}


// MARK: - AsynchronousDataTransaction

extension AsynchronousDataTransaction {
    
    // MARK: CoreStoreBridgeable
    
    internal typealias ObjCType = CSAsynchronousDataTransaction
}
