//
//  StorageInterface.swift
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

import CoreData


// MARK: - StorageInterface

/**
 The `StorageInterface` represents the data store managed (or to be managed) by the `DataStack`. When added to the `DataStack`, the `StorageInterface` serves as the interface for the `NSPersistentStore`. This may be a database file, an in-memory store, etc.
 */
public protocol StorageInterface: class {
    
    /**
     The string identifier for the `NSPersistentStore`'s `type` property. This is the same string CoreStore will use to create the `NSPersistentStore` from the `NSPersistentStoreCoordinator`'s `addPersistentStoreWithType(...)` method.
     */
    static var storeType: String { get }
    
    /**
     The configuration name in the model file
     */
    var configuration: String? { get }
    
    /**
     The options dictionary for the `NSPersistentStore`
     */
    var storeOptions: [String: AnyObject]? { get }
}


// MARK: - DefaultInitializableStore

/**
 The `DefaultInitializableStore` represents `StorageInterface`s that can be initialized with default values
 */
public protocol DefaultInitializableStore: StorageInterface {
    
    /**
     Initializes the `StorageInterface` with the default configurations
     */
    init()
}


// MARK: - LocalStorage

/**
 The `LocalStorage` represents `StorageInterface`s that are backed by local files.
 */
public protocol LocalStorage: StorageInterface {
    
    /**
     The `NSURL` that points to the store file
     */
    var fileURL: NSURL { get }
    
    /**
     The `NSBundle`s from which to search mapping models for migrations
     */
    var mappingModelBundles: [NSBundle] { get }
    
    /**
     Options that tell the `DataStack` how to setup the persistent store
     */
    var localStorageOptions: LocalStorageOptions { get }
    
    /**
     Called by the `DataStack` to perform actual deletion of the store file from disk. Do not call directly! The `sourceModel` argument is a hint for the existing store's model version. Implementers can use the `sourceModel` to perform necessary store operations. (SQLite stores for example, can convert WAL journaling mode to DELETE before deleting)
     */
    func eraseStorageAndWait(soureModel soureModel: NSManagedObjectModel) throws
}


// MARK: Internal

internal extension LocalStorage {
    
    internal func matchesPersistentStore(persistentStore: NSPersistentStore) -> Bool {
        
        return persistentStore.type == self.dynamicType.storeType
            && persistentStore.configurationName == (self.configuration ?? Into.defaultConfigurationName)
            && persistentStore.URL == self.fileURL
    }
}
