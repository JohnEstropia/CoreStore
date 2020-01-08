//
//  CSSynchronousDataTransaction.swift
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
import CoreData


// MARK: - CSSynchronousDataTransaction

/**
 The `CSSynchronousDataTransaction` serves as the Objective-C bridging type for `SynchronousDataTransaction`.
 
 - SeeAlso: `SynchronousDataTransaction`
 */
@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
@objc
public final class CSSynchronousDataTransaction: CSBaseDataTransaction, CoreStoreObjectiveCType {
    
    /**
     Saves the transaction changes and waits for completion synchronously. This method should not be used after the `-commitAndWaitWithError:` method was already called once.
     
     - parameter error: the `CSError` pointer that indicates the reason in case of an failure
     - returns: `YES` if the commit succeeded, `NO` if the commit failed. If `NO`, the `error` argument will hold error information.
     */
    @objc
    public func commitAndWait(error: NSErrorPointer) -> Bool {
        
        return bridge(error) {
            
            if case (_, let error?) = self.bridgeToSwift.context.saveSynchronously(waitForMerge: true) {
                
                throw error
            }
        }
    }
    
    
    // MARK: NSObject
    
    public override var description: String {
        
        return "(\(String(reflecting: Self.self))) \(self.bridgeToSwift.coreStoreDumpString)"
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
     Returns an editable proxy of a specified `NSManagedObject`. This method should not be used after the `-commitAndWait` method was already called once.
     
     - parameter object: the `NSManagedObject` type to be edited
     - returns: an editable proxy for the specified `NSManagedObject`.
     */
    @objc
    public override func editObject(_ object: NSManagedObject?) -> Any? {
        
        return self.bridgeToSwift.edit(object)
    }
    
    /**
     Returns an editable proxy of the object with the specified `NSManagedObjectID`. This method should not be used after the `-commitAndWait` method was already called once.
     
     - parameter into: a `CSInto` clause specifying the entity type
     - parameter objectID: the `NSManagedObjectID` for the object to be edited
     - returns: an editable proxy for the specified `NSManagedObject`.
     */
    @objc
    public override func editInto(_ into: CSInto, objectID: NSManagedObjectID) -> Any? {
        
        return self.bridgeToSwift.edit(into.bridgeToSwift, objectID)
    }
    
    /**
     Deletes a specified `NSManagedObject`. This method should not be used after the `-commitAndWait` method was already called once.
     
     - parameter object: the `NSManagedObject` type to be deleted
     */
    @objc
    public override func deleteObject(_ object: NSManagedObject?) {
        
        return self.bridgeToSwift.delete(object)
    }
    
    /**
     Deletes the specified `NSManagedObject`s.
     
     - parameter objects: the `NSManagedObject`s to be deleted
     */
    public override func deleteObjects(_ objects: [NSManagedObject]) {
        
        self.bridgeToSwift.delete(objects)
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public typealias SwiftType = SynchronousDataTransaction
    
    public var bridgeToSwift: SynchronousDataTransaction {
        
        return super.swiftTransaction as! SynchronousDataTransaction
    }
    
    public required init(_ swiftValue: SynchronousDataTransaction) {
        
        super.init(swiftValue as BaseDataTransaction)
    }
    
    public required override init(_ swiftValue: BaseDataTransaction) {
        
        super.init(swiftValue)
    }
}


// MARK: - SynchronousDataTransaction

@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
extension SynchronousDataTransaction: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSSynchronousDataTransaction {
        
        return CSSynchronousDataTransaction(self)
    }
}
