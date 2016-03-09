//
//  ImportableUniqueObject.swift
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


// MARK: - ImportableUniqueObject

/**
 `NSManagedObject` subclasses that conform to the `ImportableUniqueObject` protocol can be imported from a specified `ImportSource`. This allows transactions to either update existing objects or create new instances this way:
 ```
 class MyPersonEntity: NSManagedObject, ImportableUniqueObject {
     typealias ImportSource = NSDictionary
     typealias UniqueIDType = NSString
     // ...
 }
 
 CoreStore.beginAsynchronous { (transaction) -> Void in
     let json: NSDictionary = // ...
     let person = try! transaction.importUniqueObject(
         Into(MyPersonEntity),
         source: json
     )
     // ...
     transaction.commit()
 }
 ```
 */
public protocol ImportableUniqueObject: ImportableObject {
    
    /**
     The data type for the import source. This is most commonly an `NSDictionary` or another external source such as an `NSUserDefaults`.
     */
    associatedtype ImportSource
    
    /**
     The data type for the entity's unique ID attribute
     */
    associatedtype UniqueIDType: NSObject
    
    /**
     The keyPath to the entity's unique ID attribute
     */
    static var uniqueIDKeyPath: String { get }
    
    /**
     The object's unique ID value
     */
    var uniqueIDValue: UniqueIDType { get set }
    
    /**
     Return `true` if an object should be created from `source`. Return `false` to ignore and skip `source`. The default implementation returns the value returned by the `shouldUpdateFromImportSource(:inTransaction:)` implementation.
     
     - parameter source: the object to import from
     - parameter transaction: the transaction that invoked the import. Use the transaction to fetch or create related objects if needed.
     - returns: `true` if an object should be created from `source`. Return `false` to ignore.
     */
    static func shouldInsertFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) -> Bool
    
    /**
     Return `true` if an object should be updated from `source`. Return `false` to ignore and skip `source`. The default implementation returns `true`.
     
     - parameter source: the object to import from
     - parameter transaction: the transaction that invoked the import. Use the transaction to fetch or create related objects if needed.
     - returns: `true` if an object should be updated from `source`. Return `false` to ignore.
     */
    static func shouldUpdateFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) -> Bool
    
    /**
     Return the unique ID as extracted from `source`. This method is called before `shouldInsertFromImportSource(...)` or `shouldUpdateFromImportSource(...)`. Return `nil` to skip importing from `source`. Note that throwing from this method will cause subsequent imports that are part of the same `importUniqueObjects(:sourceArray:)` call to be cancelled.
     
     - parameter source: the object to import from
     - parameter transaction: the transaction that invoked the import. Use the transaction to fetch or create related objects if needed.
     - returns: the unique ID as extracted from `source`, or `nil` to skip importing from `source`.
     */
    static func uniqueIDFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) throws -> UniqueIDType?
    
    /**
     Implements the actual importing of data from `source`. This method is called just after the object is created and assigned its unique ID as returned from `uniqueIDFromImportSource(...)`. Implementers should pull values from `source` and assign them to the receiver's attributes. Note that throwing from this method will cause subsequent imports that are part of the same `importUniqueObjects(:sourceArray:)` call to be cancelled. The default implementation simply calls `updateFromImportSource(...)`.
     
     - parameter source: the object to import from
     - parameter transaction: the transaction that invoked the import. Use the transaction to fetch or create related objects if needed.
     */
    func didInsertFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) throws
    
    /**
     Implements the actual importing of data from `source`. This method is called just after the existing object is fetched using its unique ID. Implementers should pull values from `source` and assign them to the receiver's attributes. Note that throwing from this method will cause subsequent imports that are part of the same `importUniqueObjects(:sourceArray:)` call to be cancelled.
     
     - parameter source: the object to import from
     - parameter transaction: the transaction that invoked the import. Use the transaction to fetch or create related objects if needed.
     */
    func updateFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) throws
}


// MARK: - ImportableUniqueObject (Default Implementations)

public extension ImportableUniqueObject {
    
    static func shouldInsertFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) -> Bool {
        
        return self.shouldUpdateFromImportSource(source, inTransaction: transaction)
    }
    
    static func shouldUpdateFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) -> Bool {
        
        return true
    }
    
    func didInsertFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) throws {
        
        try self.updateFromImportSource(source, inTransaction: transaction)
    }
}
