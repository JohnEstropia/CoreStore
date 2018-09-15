//
//  CSCoreStore+Setup.swift
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


// MARK: - CSCoreStore

public extension CSCoreStore {
    
    /**
     Returns the `defaultStack`'s model version. The version string is the same as the name of the version-specific .xcdatamodeld file.
     */
    @objc
    public static var modelVersion: String {
        
        return CoreStore.modelVersion
    }
    
    /**
     Returns the entity name-to-class type mapping from the `defaultStack`'s model.
     */
    @objc
    public static func entityTypesByNameForType(_ type: NSManagedObject.Type) -> [EntityName: NSManagedObject.Type] {
        
        return CoreStore.entityTypesByName(for: type)
    }
    
    /**
     Returns the `NSEntityDescription` for the specified `NSManagedObject` subclass from `defaultStack`'s model.
     */
    @objc
    public static func entityDescriptionForClass(_ type: NSManagedObject.Type) -> NSEntityDescription? {
        
        return CoreStore.entityDescription(for: type)
    }
    
    /**
     Creates an `CSInMemoryStore` with default parameters and adds it to the `defaultStack`. This method blocks until completion.
     ```
     CSSQLiteStore *storage = [CSCoreStore addInMemoryStorageAndWaitAndReturnError:&error];
     ```
     - parameter error: the `NSError` pointer that indicates the reason in case of an failure
     - returns: the `CSInMemoryStore` added to the `defaultStack`
     */
    @objc
    @discardableResult
    public static func addInMemoryStorageAndWaitAndReturnError(_ error: NSErrorPointer) -> CSInMemoryStore? {
        
        return self.defaultStack.addInMemoryStorageAndWaitAndReturnError(error)
    }
    
    /**
     Creates an `CSSQLiteStore` with default parameters and adds it to the `defaultStack`. This method blocks until completion.
     ```
     CSSQLiteStore *storage = [CSCoreStore addSQLiteStorageAndWaitAndReturnError:&error];
     ```
     - parameter error: the `NSError` pointer that indicates the reason in case of an failure
     - returns: the `CSSQLiteStore` added to the `defaultStack`
     */
    @objc
    @discardableResult
    public static func addSQLiteStorageAndWaitAndReturnError(_ error: NSErrorPointer) -> CSSQLiteStore? {
        
        return self.defaultStack.addSQLiteStorageAndWaitAndReturnError(error)
    }
    
    /**
     Adds a `CSInMemoryStore` to the `defaultStack` and blocks until completion.
     ```
     NSError *error;
     CSInMemoryStore *storage = [CSCoreStore
         addStorageAndWait: [[CSInMemoryStore alloc] initWithConfiguration: @"Config1"]
         error: &error];
     ```
     - parameter storage: the `CSInMemoryStore`
     - parameter error: the `NSError` pointer that indicates the reason in case of an failure
     - returns: the `CSInMemoryStore` added to the `defaultStack`
     */
    @objc
    @discardableResult
    public static func addInMemoryStorageAndWait(_ storage: CSInMemoryStore, error: NSErrorPointer) -> CSInMemoryStore? {
        
        return self.defaultStack.addInMemoryStorageAndWait(storage, error: error)
    }
    
    /**
     Adds a `CSSQLiteStore` to the `defaultStack` and blocks until completion.
     ```
     NSError *error;
     CSSQLiteStore *storage = [CSCoreStore
         addStorageAndWait: [[CSSQLiteStore alloc] initWithConfiguration: @"Config1"]
         error: &error];
     ```
     - parameter storage: the `CSSQLiteStore`
     - parameter error: the `NSError` pointer that indicates the reason in case of an failure
     - returns: the `CSSQLiteStore` added to the `defaultStack`
     */
    @objc
    @discardableResult
    public static func addSQLiteStorageAndWait(_ storage: CSSQLiteStore, error: NSErrorPointer) -> CSSQLiteStore? {
        
        return self.defaultStack.addSQLiteStorageAndWait(storage, error: error)
    }
    
    
    // MARK: Deprecated
    
    @available(*, deprecated, message: "Use the new +entityTypesByNameForType: method passing `[NSManagedObject class]` as argument.")
    @objc
    public static var entityClassesByName: [EntityName: NSManagedObject.Type] {
        
        return CoreStore.entityTypesByName
    }
    
    @available(*, deprecated, message: "Use the new +entityTypesByNameForType: method passing `[NSManagedObject class]` as argument.")
    @objc
    public static func entityClassWithName(_ name: EntityName) -> NSManagedObject.Type? {
        
        return CoreStore.entityTypesByName[name]
    }
}
