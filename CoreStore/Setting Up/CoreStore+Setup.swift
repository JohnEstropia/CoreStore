//
//  CoreStore+Setup.swift
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
#if USE_FRAMEWORKS
    import GCDKit
#endif


// MARK: - CoreStore

public extension CoreStore {
    
    /**
     Returns the `defaultStack`'s model version. The version string is the same as the name of the version-specific .xcdatamodeld file.
     */
    public static var modelVersion: String {
        
        return self.defaultStack.modelVersion
    }
    
    /**
     Returns the entity name-to-class type mapping from the `defaultStack`'s model.
     */
    public static var entityTypesByName: [String: NSManagedObject.Type] {
        
        return self.defaultStack.entityTypesByName
    }
    
    /**
     Returns the `NSEntityDescription` for the specified `NSManagedObject` subclass from `defaultStack`'s model.
     */
    public static func entityDescriptionForType(type: NSManagedObject.Type) -> NSEntityDescription? {
        
        return self.defaultStack.entityDescriptionForType(type)
    }
    
    /**
     Adds an in-memory store to the `defaultStack`.
     
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`.
     - returns: the `NSPersistentStore` added to the stack.
     */
    public static func addInMemoryStoreAndWait(configuration configuration: String? = nil) throws -> NSPersistentStore {
        
        return try self.defaultStack.addInMemoryStoreAndWait(configuration: configuration)
    }
    
    /**
     Adds to the `defaultStack` an SQLite store from the given SQLite file name.
     
     - parameter fileName: the local filename for the SQLite persistent store in the "Application Support" directory (or the "Caches" directory on tvOS). A new SQLite file will be created if it does not exist.
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to nil.
     - parameter resetStoreOnModelMismatch: Set to true to delete the store on model mismatch; or set to false to throw exceptions on failure instead. Typically should only be set to true when debugging, or if the persistent store can be recreated easily. If not specified, defaults to false
     - returns: the `NSPersistentStore` added to the stack.
     */
    public static func addSQLiteStoreAndWait(fileName fileName: String, configuration: String? = nil, resetStoreOnModelMismatch: Bool = false) throws -> NSPersistentStore {
        
        return try self.defaultStack.addSQLiteStoreAndWait(
            fileName: fileName,
            configuration: configuration,
            resetStoreOnModelMismatch: resetStoreOnModelMismatch
        )
    }
    
    /**
     Adds to the `defaultStack` an SQLite store from the given SQLite file URL.
     
     - parameter fileURL: the local file URL for the SQLite persistent store. A new SQLite file will be created if it does not exist. If not specified, defaults to a file URL pointing to a "<Application name>.sqlite" file in the "Application Support" directory (or the "Caches" directory on tvOS).
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to nil.
     - parameter resetStoreOnModelMismatch: Set to true to delete the store on model mismatch; or set to false to throw exceptions on failure instead. Typically should only be set to true when debugging, or if the persistent store can be recreated easily. If not specified, defaults to false.
     - returns: the `NSPersistentStore` added to the stack.
     */
    public static func addSQLiteStoreAndWait(fileURL: NSURL = defaultSQLiteStoreURL, configuration: String? = nil, resetStoreOnModelMismatch: Bool = false) throws -> NSPersistentStore {
        
        return try self.defaultStack.addSQLiteStoreAndWait(
            fileURL: fileURL,
            configuration: configuration,
            resetStoreOnModelMismatch: resetStoreOnModelMismatch
        )
    }
}
