//
//  CSStorageInterface.swift
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


// MARK: - CSStorageInterface

/**
 The `CSStorageInterface` serves as the Objective-C bridging type for `StorageInterface`.
 
 - SeeAlso: `StorageInterface`
 */
@objc
public protocol CSStorageInterface {
    
    /**
     The string identifier for the `NSPersistentStore`'s `type` property. This is the same string CoreStore will use to create the `NSPersistentStore` from the `NSPersistentStoreCoordinator`'s `addPersistentStoreWithType(...)` method.
     */
    @objc
    static var storeType: String { get }
    
    /**
     The configuration name in the model file
     */
    @objc
    var configuration: String? { get }
    
    /**
     The options dictionary for the `NSPersistentStore`
     */
    @objc
    var storeOptions: [String: AnyObject]? { get }
}


// MARK: - CSLocalStorageOptions

/**
 The `CSLocalStorageOptions` provides settings that tells the `CSDataStack` how to setup the persistent store for `CSLocalStorage` implementers.
 
 - SeeAlso: `LocalStorageOptions`
 */
@objc
public enum CSLocalStorageOptions: Int {
    
    /**
     Tells the `DataStack` that the store should not be migrated or recreated, and should simply fail on model mismatch
     */
    case None = 0
    
    /**
     Tells the `DataStack` to delete and recreate the store on model mismatch, otherwise exceptions will be thrown on failure instead
     */
    case RecreateStoreOnModelMismatch = 1
    
    /**
     Tells the `DataStack` to prevent progressive migrations for the store
     */
    case PreventProgressiveMigration = 2
    
    /**
     Tells the `DataStack` to allow lightweight migration for the store when added synchronously
     */
    case AllowSynchronousLightweightMigration = 4
}


// MARK: - CSLocalStorage

/**
 The `CSLocalStorage` serves as the Objective-C bridging type for `LocalStorage`.
 
 - SeeAlso: `LocalStorage`
 */
@objc
public protocol CSLocalStorage: CSStorageInterface {
    
    /**
     The `NSURL` that points to the store file
     */
    @objc
    var fileURL: NSURL { get }
    
    /**
     The `NSBundle`s from which to search mapping models for migrations
     */
    @objc
    var mappingModelBundles: [NSBundle] { get }
    
    /**
     Options that tell the `CSDataStack` how to setup the persistent store
     */
    @objc
    var localStorageOptions: Int { get }
    
    /**
     Called by the `CSDataStack` to perform actual deletion of the store file from disk. Do not call directly! The `sourceModel` argument is a hint for the existing store's model version. Implementers can use the `sourceModel` to perform necessary store operations. (SQLite stores for example, can convert WAL journaling mode to DELETE before deleting)
     */
    @objc
    func eraseStorageAndWait(soureModel soureModel: NSManagedObjectModel, error: NSErrorPointer) -> Bool
}
