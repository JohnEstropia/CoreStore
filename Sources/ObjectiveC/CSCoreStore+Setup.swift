//
//  CSCoreStore+Setup.swift
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


// MARK: - CSCoreStore

public extension CSCoreStore {
    
    /**
     Returns the `defaultStack`'s model version. The version string is the same as the name of the version-specific .xcdatamodeld file.
     */
    @objc
    public class var modelVersion: String {
        
        return CoreStore.defaultStack.modelVersion
    }
    
    /**
     Returns the entity name-to-class type mapping from the `defaultStack`'s model.
     */
    @objc
    public static var entityClassesByName: [String: NSManagedObject.Type] {
        
        return CoreStore.defaultStack.entityTypesByName
    }
    
    /**
     Returns the entity class for the given entity name from the `defaultStack`'s model.
     - parameter name: the entity name
     - returns: the `NSManagedObject` class for the given entity name, or `nil` if not found
     */
    @objc
    public static func entityClassWithName(name: String) -> NSManagedObject.Type? {
        
        return CoreStore.defaultStack.entityTypesByName[name]
    }
    
    /**
     Returns the `NSEntityDescription` for the specified `NSManagedObject` subclass from `defaultStack`'s model.
     */
    @objc
    public static func entityDescriptionForClass(type: NSManagedObject.Type) -> NSEntityDescription? {
        
        return CoreStore.defaultStack.entityDescriptionForType(type)
    }
    
    /**
     Creates an `CSInMemoryStore` with default parameters and adds it to the `defaultStack`. This method blocks until completion.
     ```
     CSSQLiteStore *storage = [CSCoreStore addInMemoryStorageAndWaitAndReturnError:&error];
     ```
     
     - returns: the `CSInMemoryStore` added to the `defaultStack`
     */
    @objc
    public static func addInMemoryStorageAndWait() throws -> CSInMemoryStore {
        
        return try bridge {
            
            try CoreStore.defaultStack.addStorageAndWait(InMemoryStore)
        }
    }
    
    /**
     Creates an `CSSQLiteStore` with default parameters and adds it to the `defaultStack`. This method blocks until completion.
     ```
     CSSQLiteStore *storage = [CSCoreStore addSQLiteStorageAndWaitAndReturnError:&error];
     ```
     
     - returns: the `CSSQLiteStore` added to the `defaultStack`
     */
    @objc
    public static func addSQLiteStorageAndWait() throws -> CSSQLiteStore {
        
        return try bridge {
            
            try CoreStore.defaultStack.addStorageAndWait(SQLiteStore)
        }
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
     - returns: the `CSInMemoryStore` added to the `defaultStack`
     */
    @objc
    public static func addInMemoryStorageAndWait(storage: CSInMemoryStore) throws -> CSInMemoryStore {
        
        return try bridge {
            
            try CoreStore.defaultStack.addStorageAndWait(storage.swift)
        }
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
     - returns: the `CSSQLiteStore` added to the `defaultStack`
     */
    @objc
    public static func addSQLiteStorageAndWait(storage: CSSQLiteStore) throws -> CSSQLiteStore {
        
        return try bridge {
            
            try CoreStore.defaultStack.addStorageAndWait(storage.swift)
        }
    }
}