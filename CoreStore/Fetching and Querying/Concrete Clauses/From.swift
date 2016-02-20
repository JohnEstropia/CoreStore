//
//  From.swift
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


// MARK: - From

/**
 A `From` clause specifies the source entity and source persistent store for fetch and query methods. A common usage is to just indicate the entity:
 ```
 let person = transaction.fetchOne(From(MyPersonEntity))
 ```
 For cases where multiple `NSPersistentStore`s contain the same entity, the source configuration's name needs to be specified as well:
 ```
 let person = transaction.fetchOne(From<MyPersonEntity>("Configuration1"))
 ```
 */
public struct From<T: NSManagedObject> {
    
    /**
     Initializes a `From` clause.
     Sample Usage:
     ```
     let people = transaction.fetchAll(From<MyPersonEntity>())
     ```
     */
    public init(){
        
        self.init(entityClass: T.self)
    }
    
    /**
     Initializes a `From` clause with the specified entity type.
     Sample Usage:
     ```
     let people = transaction.fetchAll(From<MyPersonEntity>())
     ```
     - parameter entity: the `NSManagedObject` type to be created
     */
    public init(_ entity: T.Type) {
        
        self.init(entityClass: entity)
    }
    
    /**
     Initializes a `From` clause with the specified entity class.
     Sample Usage:
     ```
     let people = transaction.fetchAll(From<MyPersonEntity>())
     ```
     - parameter entityClass: the `NSManagedObject` class type to be created
     */
    public init(_ entityClass: AnyClass) {
        
        self.init(entityClass: entityClass)
    }
    
    /**
     Initializes a `From` clause with the specified configurations.
     Sample Usage:
     ```
     let people = transaction.fetchAll(From<MyPersonEntity>(nil, "Configuration1"))
     ```
     - parameter configuration: the `NSPersistentStore` configuration name to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     - parameter otherConfigurations: an optional list of other configuration names to associate objects from (see `configuration` parameter)
     */
    public init(_ configuration: String?, otherConfigurations: String?...) {
        
        self.init(entityClass: T.self, configurations: [configuration] + otherConfigurations)
    }
    
    /**
     Initializes a `From` clause with the specified configurations.
     Sample Usage:
     ```
     let people = transaction.fetchAll(From<MyPersonEntity>(["Configuration1", "Configuration2"]))
     ```
     - parameter configurations: a list of `NSPersistentStore` configuration names to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     */
    public init(_ configurations: [String?]) {
        
        self.init(entityClass: T.self, configurations: configurations)
    }
    
    /**
     Initializes a `From` clause with the specified configurations.
     Sample Usage:
     ```
     let people = transaction.fetchAll(From(MyPersonEntity.self, nil, "Configuration1"))
     ```
     - parameter entity: the associated `NSManagedObject` type
     - parameter configuration: the `NSPersistentStore` configuration name to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     - parameter otherConfigurations: an optional list of other configuration names to associate objects from (see `configuration` parameter)
     */
    public init(_ entity: T.Type, _ configuration: String?, _ otherConfigurations: String?...) {
        
        self.init(entityClass: entity, configurations: [configuration] + otherConfigurations)
    }
    
    /**
     Initializes a `From` clause with the specified configurations.
     Sample Usage:
     ```
     let people = transaction.fetchAll(From(MyPersonEntity.self, ["Configuration1", "Configuration1"]))
     ```
     - parameter entity: the associated `NSManagedObject` type
     - parameter configurations: a list of `NSPersistentStore` configuration names to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     */
    public init(_ entity: T.Type, _ configurations: [String?]) {
        
        self.init(entityClass: entity, configurations: configurations)
    }
    
    /**
     Initializes a `From` clause with the specified configurations.
     Sample Usage:
     ```
     let people = transaction.fetchAll(From(MyPersonEntity.self, nil, "Configuration1"))
     ```
     - parameter entity: the associated `NSManagedObject` entity class
     - parameter configuration: the `NSPersistentStore` configuration name to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     - parameter otherConfigurations: an optional list of other configuration names to associate objects from (see `configuration` parameter)
     */
    public init(_ entityClass: AnyClass, _ configuration: String?, _ otherConfigurations: String?...) {
        
        self.init(entityClass: entityClass, configurations: [configuration] + otherConfigurations)
    }
    
    /**
     Initializes a `From` clause with the specified configurations.
     Sample Usage:
     ```
     let people = transaction.fetchAll(From(MyPersonEntity.self, ["Configuration1", "Configuration1"]))
     ```
     - parameter entity: the associated `NSManagedObject` entity class
     - parameter configurations: a list of `NSPersistentStore` configuration names to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     */
    public init(_ entityClass: AnyClass, _ configurations: [String?]) {
        
        self.init(entityClass: entityClass, configurations: configurations)
    }
    
    /**
     Initializes a `From` clause with the specified store URLs.
     
     - parameter storeURL: the persistent store URL to associate objects from.
     - parameter otherStoreURLs: an optional list of other persistent store URLs to associate objects from (see `storeURL` parameter)
     */
    public init(_ storeURL: NSURL, _ otherStoreURLs: NSURL...) {
        
        self.init(entityClass: T.self, storeURLs: [storeURL] + otherStoreURLs)
    }
    
    /**
     Initializes a `From` clause with the specified store URLs.
     
     - parameter storeURLs: the persistent store URLs to associate objects from.
     */
    public init(_ storeURLs: [NSURL]) {
        
        self.init(entityClass: T.self, storeURLs: storeURLs)
    }
    
    /**
     Initializes a `From` clause with the specified store URLs.
     
     - parameter entity: the associated `NSManagedObject` type
     - parameter storeURL: the persistent store URL to associate objects from.
     - parameter otherStoreURLs: an optional list of other persistent store URLs to associate objects from (see `storeURL` parameter)
     */
    public init(_ entity: T.Type, _ storeURL: NSURL, _ otherStoreURLs: NSURL...) {
        
        self.init(entityClass: entity, storeURLs: [storeURL] + otherStoreURLs)
    }
    
    /**
     Initializes a `From` clause with the specified store URLs.
     
     - parameter entity: the associated `NSManagedObject` type
     - parameter storeURLs: the persistent store URLs to associate objects from.
     */
    public init(_ entity: T.Type, _ storeURLs: [NSURL]) {
        
        self.init(entityClass: entity, storeURLs: storeURLs)
    }
    
    /**
     Initializes a `From` clause with the specified store URLs.
     
     - parameter entity: the associated `NSManagedObject` entity class
     - parameter storeURL: the persistent store URL to associate objects from.
     - parameter otherStoreURLs: an optional list of other persistent store URLs to associate objects from (see `storeURL` parameter)
     */
    public init(_ entityClass: AnyClass, _ storeURL: NSURL, _ otherStoreURLs: NSURL...) {
        
        self.init(entityClass: entityClass, storeURLs: [storeURL] + otherStoreURLs)
    }
    
    /**
     Initializes a `From` clause with the specified store URLs.
     
     - parameter entity: the associated `NSManagedObject` entity class
     - parameter storeURLs: the persistent store URLs to associate objects from.
     */
    public init(_ entityClass: AnyClass, _ storeURLs: [NSURL]) {
        
        self.init(entityClass: entityClass, storeURLs: storeURLs)
    }
    
    /**
     Initializes a `From` clause with the specified `NSPersistentStore`s.
     
     - parameter persistentStore: the `NSPersistentStore` to associate objects from.
     - parameter otherPersistentStores: an optional list of other `NSPersistentStore`s to associate objects from (see `persistentStore` parameter)
     */
    public init(_ persistentStore: NSPersistentStore, _ otherPersistentStores: NSPersistentStore...) {
        
        self.init(entityClass: T.self, persistentStores: [persistentStore] + otherPersistentStores)
    }
    
    /**
     Initializes a `From` clause with the specified `NSPersistentStore`s.
     
     - parameter persistentStores: the `NSPersistentStore`s to associate objects from.
     */
    public init(_ persistentStores: [NSPersistentStore]) {
        
        self.init(entityClass: T.self, persistentStores: persistentStores)
    }
    
    /**
     Initializes a `From` clause with the specified `NSPersistentStore`s.
     
     - parameter entity: the associated `NSManagedObject` type
     - parameter persistentStore: the `NSPersistentStore` to associate objects from.
     - parameter otherPersistentStores: an optional list of other `NSPersistentStore`s to associate objects from (see `persistentStore` parameter)
     */
    public init(_ entity: T.Type, _ persistentStore: NSPersistentStore, _ otherPersistentStores: NSPersistentStore...) {
        
        self.init(entityClass: entity, persistentStores: [persistentStore] + otherPersistentStores)
    }
    
    /**
     Initializes a `From` clause with the specified `NSPersistentStore`s.
     
     - parameter entity: the associated `NSManagedObject` type
     - parameter persistentStores: the `NSPersistentStore`s to associate objects from.
     */
    public init(_ entity: T.Type, _ persistentStores: [NSPersistentStore]) {
        
        self.init(entityClass: entity, persistentStores: persistentStores)
    }
    
    /**
     Initializes a `From` clause with the specified `NSPersistentStore`s.
     
     - parameter entity: the associated `NSManagedObject` entity class
     - parameter persistentStore: the `NSPersistentStore` to associate objects from.
     - parameter otherPersistentStores: an optional list of other `NSPersistentStore`s to associate objects from (see `persistentStore` parameter)
     */
    public init(_ entityClass: AnyClass, _ persistentStore: NSPersistentStore, _ otherPersistentStores: NSPersistentStore...) {
        
        self.init(entityClass: entityClass, persistentStores: [persistentStore] + otherPersistentStores)
    }
    
    /**
     Initializes a `From` clause with the specified `NSPersistentStore`s.
     
     - parameter entity: the associated `NSManagedObject` entity class
     - parameter persistentStores: the `NSPersistentStore`s to associate objects from.
     */
    public init(_ entityClass: AnyClass, _ persistentStores: [NSPersistentStore]) {
        
        self.init(entityClass: entityClass, persistentStores: persistentStores)
    }
    
    
    // MARK: Internal
    
    internal func applyToFetchRequest(fetchRequest: NSFetchRequest, context: NSManagedObjectContext, applyAffectedStores: Bool = true) {
        
        fetchRequest.entity = context.entityDescriptionForEntityClass(self.entityClass)
        if applyAffectedStores {
            
            self.applyAffectedStoresForFetchedRequest(fetchRequest, context: context)
        }
    }
    
    internal func applyAffectedStoresForFetchedRequest(fetchRequest: NSFetchRequest, context: NSManagedObjectContext) -> Bool {
        
        let stores = self.findPersistentStores(context: context)
        fetchRequest.affectedStores = stores
        return stores?.isEmpty == false
    }
    
    
    // MARK: Private
    
    private let entityClass: AnyClass
    
    private let findPersistentStores: (context: NSManagedObjectContext) -> [NSPersistentStore]?
    
    private init(entityClass: AnyClass) {
        
        self.entityClass = entityClass
        self.findPersistentStores = { (context: NSManagedObjectContext) -> [NSPersistentStore]? in
            
            return context.parentStack?.persistentStoresForEntityClass(entityClass)
        }
    }
    
    private init(entityClass: AnyClass, configurations: [String?]) {
        
        let configurationsSet = Set(configurations.map { $0 ?? Into.defaultConfigurationName })
        self.entityClass = entityClass
        self.findPersistentStores = { (context: NSManagedObjectContext) -> [NSPersistentStore]? in
            
            return context.parentStack?.persistentStoresForEntityClass(entityClass)?.filter {
                
                return configurationsSet.contains($0.configurationName)
            }
        }
    }
    
    private init(entityClass: AnyClass, storeURLs: [NSURL]) {
        
        let storeURLsSet = Set(storeURLs)
        self.entityClass = entityClass
        self.findPersistentStores = { (context: NSManagedObjectContext) -> [NSPersistentStore]? in
            
            return context.parentStack?.persistentStoresForEntityClass(entityClass)?.filter {
                
                return $0.URL != nil && storeURLsSet.contains($0.URL!)
            }
        }
    }
    
    private init(entityClass: AnyClass, persistentStores: [NSPersistentStore]) {
        
        let persistentStores = Set(persistentStores)
        self.entityClass = entityClass
        self.findPersistentStores = { (context: NSManagedObjectContext) -> [NSPersistentStore]? in
            
            return context.parentStack?.persistentStoresForEntityClass(entityClass)?.filter {
                
                return persistentStores.contains($0)
            }
        }
    }
}
