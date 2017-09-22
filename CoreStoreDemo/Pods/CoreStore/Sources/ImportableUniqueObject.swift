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
 class Person: NSManagedObject, ImportableObject {
     typealias ImportSource = NSDictionary
     typealias UniqueIDType = NSString
     // ...
 }
 
 CoreStore.perform(
     asynchronous: { (transaction) -> Void in
         let json: NSDictionary = // ...
         let person = try transaction.importUniqueObject(
             Into<Person>(),
             source: json
         )
         // ...
     },
     completion: { (result) in
         // ...
     }
 )
 ```
 */
public protocol ImportableUniqueObject: ImportableObject {
    
    /**
     The data type for the import source. This is most commonly an json type, `NSDictionary`, or another external source such as `NSUserDefaults`.
     */
    associatedtype ImportSource
    
    /**
     The data type for the entity's unique ID attribute
     */
    associatedtype UniqueIDType: ImportableAttributeType
    
    /**
     The keyPath to the entity's unique ID attribute
     */
    static var uniqueIDKeyPath: String { get }
    
    /**
     The object's unique ID value. The default implementation returns the value of the attribute pertained to by `uniqueIDKeyPath`
     - Important: It is the developer's responsibility to ensure that the attribute value pertained by `uniqueIDKeyPath` is not `nil` during the call to `uniqueIDValue`.
     */
    var uniqueIDValue: UniqueIDType { get set }
    
    /**
     Return `true` if an object should be created from `source`. Return `false` to ignore and skip `source`. The default implementation returns the value returned by the `shouldUpdate(from:in:)` implementation.
     
     - parameter source: the object to import from
     - parameter transaction: the transaction that invoked the import. Use the transaction to fetch or create related objects if needed.
     - returns: `true` if an object should be created from `source`. Return `false` to ignore.
     */
    static func shouldInsert(from source: ImportSource, in transaction: BaseDataTransaction) -> Bool
    
    /**
     Return `true` if an object should be updated from `source`. Return `false` to ignore and skip `source`. The default implementation returns `true`.
     
     - parameter source: the object to import from
     - parameter transaction: the transaction that invoked the import. Use the transaction to fetch or create related objects if needed.
     - returns: `true` if an object should be updated from `source`. Return `false` to ignore.
     */
    static func shouldUpdate(from source: ImportSource, in transaction: BaseDataTransaction) -> Bool
    
    /**
     Return the unique ID as extracted from `source`. This method is called before `shouldInsert(from:in:)` or `shouldUpdate(from:in:)`. Return `nil` to skip importing from `source`. Note that throwing from this method will cause subsequent imports that are part of the same `importUniqueObjects(:sourceArray:)` call to be cancelled.
     
     - parameter source: the object to import from
     - parameter transaction: the transaction that invoked the import. Use the transaction to fetch or create related objects if needed.
     - returns: the unique ID as extracted from `source`, or `nil` to skip importing from `source`.
     */
    static func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> UniqueIDType?
    
    /**
     Implements the actual importing of data from `source`. This method is called just after the object is created and assigned its unique ID as returned from `uniqueID(from:in:)`. Implementers should pull values from `source` and assign them to the receiver's attributes. Note that throwing from this method will cause subsequent imports that are part of the same `importUniqueObjects(:sourceArray:)` call to be cancelled. The default implementation simply calls `update(from:in:)`.
     
     - parameter source: the object to import from
     - parameter transaction: the transaction that invoked the import. Use the transaction to fetch or create related objects if needed.
     */
    func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws
    
    /**
     Implements the actual importing of data from `source`. This method is called just after the existing object is fetched using its unique ID. Implementers should pull values from `source` and assign them to the receiver's attributes. Note that throwing from this method will cause subsequent imports that are part of the same `importUniqueObjects(:sourceArray:)` call to be cancelled.
     
     - parameter source: the object to import from
     - parameter transaction: the transaction that invoked the import. Use the transaction to fetch or create related objects if needed.
     */
    func update(from source: ImportSource, in transaction: BaseDataTransaction) throws
}


// MARK: - ImportableUniqueObject (Default Implementations)

public extension ImportableUniqueObject {
    
    static func shouldInsert(from source: ImportSource, in transaction: BaseDataTransaction) -> Bool {
        
        return Self.shouldUpdate(from: source, in: transaction)
    }
    
    static func shouldUpdate(from source: ImportSource, in transaction: BaseDataTransaction) -> Bool{
        
        return true
    }
    
    func didInsert(from source: Self.ImportSource, in transaction: BaseDataTransaction) throws {
        
        try self.update(from: source, in: transaction)
    }
    
    
    // MARK: Obsolete
    
    @available(*, obsoleted: 3.1, renamed: "shouldInsert(from:in:)")
    static func shouldInsertFromImportSource(_ source: ImportSource, inTransaction transaction: BaseDataTransaction) -> Bool {
        
        return Self.shouldInsert(from: source, in: transaction)
    }
    
    @available(*, obsoleted: 3.1, renamed: "shouldUpdate(from:in:)")
    static func shouldUpdateFromImportSource(_ source: ImportSource, inTransaction transaction: BaseDataTransaction) -> Bool {
        
        return Self.shouldUpdate(from: source, in: transaction)
    }
    
    @available(*, obsoleted: 3.1, renamed: "uniqueID(from:in:)")
    static func uniqueIDFromImportSource(_ source: ImportSource, inTransaction transaction: BaseDataTransaction) throws -> UniqueIDType? {
        
        return try Self.uniqueID(from: source, in: transaction)
    }
    
    @available(*, obsoleted: 3.1, renamed: "didInsert(from:in:)")
    func didInsertFromImportSource(_ source: ImportSource, inTransaction transaction: BaseDataTransaction) throws {
        
        try self.didInsert(from: source, in: transaction)
    }
    
    @available(*, obsoleted: 3.1, renamed: "update(from:in:)")
    func updateFromImportSource(_ source: ImportSource, inTransaction transaction: BaseDataTransaction) throws {
        
        try self.update(from: source, in: transaction)
    }
}


// MARK: - ImportableUniqueObject (Default Implementations)

public extension ImportableUniqueObject where Self: DynamicObject {
    
    var uniqueIDValue: UniqueIDType {
        
        get {
            
            return self.cs_toRaw().getValue(
                forKvcKey: type(of: self).uniqueIDKeyPath,
                didGetValue: { UniqueIDType.cs_fromImportableNativeType($0 as! UniqueIDType.ImportableNativeType)! }
            )
        }
        set {
            
            self.cs_toRaw()
                .setValue(
                    newValue,
                    forKvcKey: type(of: self).uniqueIDKeyPath,
                    willSetValue: { ($0.cs_toImportableNativeType() as! CoreDataNativeType) }
                )
        }
    }
}
