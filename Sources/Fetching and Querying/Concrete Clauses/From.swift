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
     The associated `NSManagedObject` entity class
     */
    public let entityClass: AnyClass
    
    /**
     The `NSPersistentStore` configuration names to associate objects from.
     May contain `String`s to pertain to named configurations, or `nil` to pertain to the default configuration
     */
    public let configurations: [String?]?
    
    /**
     Initializes a `From` clause.
     ```
     let people = transaction.fetchAll(From<MyPersonEntity>())
     ```
     */
    public init(){
        
        self.init(entityClass: T.self, configurations: nil)
    }
    
    /**
     Initializes a `From` clause with the specified entity type.
     ```
     let people = transaction.fetchAll(From<MyPersonEntity>())
     ```
     
     - parameter entity: the associated `NSManagedObject` type
     */
    public init(_ entity: T.Type) {
        
        self.init(entityClass: entity, configurations: nil)
    }
    
    /**
     Initializes a `From` clause with the specified entity class.
     ```
     let people = transaction.fetchAll(From<MyPersonEntity>())
     ```
     
     - parameter entityClass: the associated `NSManagedObject` entity class
     */
    public init(_ entityClass: AnyClass) {
        
        CoreStore.assert(
            entityClass is T.Type,
            "Attempted to create generic type \(cs_typeName(From<T>)) with entity class \(cs_typeName(entityClass))"
        )
        self.init(entityClass: entityClass, configurations: nil)
    }
    
    /**
     Initializes a `From` clause with the specified configurations.
     ```
     let people = transaction.fetchAll(From<MyPersonEntity>(nil, "Configuration1"))
     ```
     
     - parameter configuration: the `NSPersistentStore` configuration name to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     - parameter otherConfigurations: an optional list of other configuration names to associate objects from (see `configuration` parameter)
     */
    public init(_ configuration: String?, _ otherConfigurations: String?...) {
        
        self.init(entityClass: T.self, configurations: [configuration] + otherConfigurations)
    }
    
    /**
     Initializes a `From` clause with the specified configurations.
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
     ```
     let people = transaction.fetchAll(From(MyPersonEntity.self, nil, "Configuration1"))
     ```
     
     - parameter entity: the associated `NSManagedObject` entity class
     - parameter configuration: the `NSPersistentStore` configuration name to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     - parameter otherConfigurations: an optional list of other configuration names to associate objects from (see `configuration` parameter)
     */
    public init(_ entityClass: AnyClass, _ configuration: String?, _ otherConfigurations: String?...) {
        
        CoreStore.assert(
            entityClass is T.Type,
            "Attempted to create generic type \(cs_typeName(From<T>)) with entity class \(cs_typeName(entityClass))"
        )
        self.init(entityClass: entityClass, configurations: [configuration] + otherConfigurations)
    }
    
    /**
     Initializes a `From` clause with the specified configurations.
     ```
     let people = transaction.fetchAll(From(MyPersonEntity.self, ["Configuration1", "Configuration1"]))
     ```
     
     - parameter entity: the associated `NSManagedObject` entity class
     - parameter configurations: a list of `NSPersistentStore` configuration names to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     */
    public init(_ entityClass: AnyClass, _ configurations: [String?]) {
        
        CoreStore.assert(
            entityClass is T.Type,
            "Attempted to create generic type \(cs_typeName(From<T>)) with entity class \(cs_typeName(entityClass))"
        )
        self.init(entityClass: entityClass, configurations: configurations)
    }
    
    
    // MARK: Internal
    
    @warn_unused_result
    internal func applyToFetchRequest(fetchRequest: NSFetchRequest, context: NSManagedObjectContext, applyAffectedStores: Bool = true) -> Bool {
        
        fetchRequest.entity = context.entityDescriptionForEntityClass(self.entityClass)
        guard applyAffectedStores else {
            
            return true
        }
        if self.applyAffectedStoresForFetchedRequest(fetchRequest, context: context) {
            
            return true
        }
        CoreStore.log(
            .Warning,
            message: "Attempted to perform a fetch but could not find any persistent store for the entity \(cs_typeName(fetchRequest.entityName))"
        )
        return false
    }
    
    internal func applyAffectedStoresForFetchedRequest(fetchRequest: NSFetchRequest, context: NSManagedObjectContext) -> Bool {
        
        let stores = self.findPersistentStores(context: context)
        fetchRequest.affectedStores = stores
        return stores?.isEmpty == false
    }
    
    internal func upcast() -> From<NSManagedObject> {
        
        return From<NSManagedObject>(
            entityClass: self.entityClass,
            configurations: self.configurations,
            findPersistentStores: self.findPersistentStores
        )
    }
    
    
    // MARK: Private
    
    private let findPersistentStores: (context: NSManagedObjectContext) -> [NSPersistentStore]?
    
    private init(entityClass: AnyClass, configurations: [String?]?) {
        
        self.entityClass = entityClass
        self.configurations = configurations
        if let configurations = configurations {
            
            let configurationsSet = Set(configurations.map { $0 ?? Into.defaultConfigurationName })
            self.findPersistentStores = { (context: NSManagedObjectContext) -> [NSPersistentStore]? in
                
                return context.parentStack?.persistentStoresForEntityClass(entityClass)?.filter {
                    
                    return configurationsSet.contains($0.configurationName)
                }
            }
        }
        else {
            
            self.findPersistentStores = { (context: NSManagedObjectContext) -> [NSPersistentStore]? in
                
                return context.parentStack?.persistentStoresForEntityClass(entityClass)
            }
        }
    }
    
    private init(entityClass: AnyClass, configurations: [String?]?, findPersistentStores: (context: NSManagedObjectContext) -> [NSPersistentStore]?) {
        
        self.entityClass = entityClass
        self.configurations = configurations
        self.findPersistentStores = findPersistentStores
    }
    
    
    // MARK: Obsolete
    
    /**
     Obsolete. Use initializers that accept configuration names.
     */
    @available(*, obsoleted=2.0.0, message="Use initializers that accept configuration names.")
    public init(_ storeURL: NSURL, _ otherStoreURLs: NSURL...) {
        
        CoreStore.abort("Use initializers that accept configuration names.")
    }
    
    /**
     Obsolete. Use initializers that accept configuration names.
     */
    @available(*, obsoleted=2.0.0, message="Use initializers that accept configuration names.")
    public init(_ storeURLs: [NSURL]) {
        
        CoreStore.abort("Use initializers that accept configuration names.")
    }
    
    /**
     Obsolete. Use initializers that accept configuration names.
     */
    @available(*, obsoleted=2.0.0, message="Use initializers that accept configuration names.")
    public init(_ entity: T.Type, _ storeURL: NSURL, _ otherStoreURLs: NSURL...) {
        
        CoreStore.abort("Use initializers that accept configuration names.")
    }
    
    /**
     Obsolete. Use initializers that accept configuration names.
     */
    @available(*, obsoleted=2.0.0, message="Use initializers that accept configuration names.")
    public init(_ entity: T.Type, _ storeURLs: [NSURL]) {
        
        CoreStore.abort("Use initializers that accept configuration names.")
    }
    
    /**
     Obsolete. Use initializers that accept configuration names.
     */
    @available(*, obsoleted=2.0.0, message="Use initializers that accept configuration names.")
    public init(_ entityClass: AnyClass, _ storeURL: NSURL, _ otherStoreURLs: NSURL...) {
        
        CoreStore.abort("Use initializers that accept configuration names.")
    }
    
    /**
     Obsolete. Use initializers that accept configuration names.
     */
    @available(*, obsoleted=2.0.0, message="Use initializers that accept configuration names.")
    public init(_ entityClass: AnyClass, _ storeURLs: [NSURL]) {
        
        CoreStore.abort("Use initializers that accept configuration names.")
    }
    
    /**
     Obsolete. Use initializers that accept configuration names.
     */
    @available(*, obsoleted=2.0.0, message="Use initializers that accept configuration names.")
    public init(_ persistentStore: NSPersistentStore, _ otherPersistentStores: NSPersistentStore...) {
        
        CoreStore.abort("Use initializers that accept configuration names.")
    }
    
    /**
     Obsolete. Use initializers that accept configuration names.
     */
    @available(*, obsoleted=2.0.0, message="Use initializers that accept configuration names.")
    public init(_ persistentStores: [NSPersistentStore]) {
        
        CoreStore.abort("Use initializers that accept configuration names.")
    }
    
    /**
     Obsolete. Use initializers that accept configuration names.
     */
    @available(*, obsoleted=2.0.0, message="Use initializers that accept configuration names.")
    public init(_ entity: T.Type, _ persistentStore: NSPersistentStore, _ otherPersistentStores: NSPersistentStore...) {
        
        CoreStore.abort("Use initializers that accept configuration names.")
    }
    
    /**
     Obsolete. Use initializers that accept configuration names.
     */
    @available(*, obsoleted=2.0.0, message="Use initializers that accept configuration names.")
    public init(_ entity: T.Type, _ persistentStores: [NSPersistentStore]) {
        
        CoreStore.abort("Use initializers that accept configuration names.")
    }
    
    /**
     Obsolete. Use initializers that accept configuration names.
     */
    @available(*, obsoleted=2.0.0, message="Use initializers that accept configuration names.")
    public init(_ entityClass: AnyClass, _ persistentStore: NSPersistentStore, _ otherPersistentStores: NSPersistentStore...) {
        
        CoreStore.abort("Use initializers that accept configuration names.")
    }
    
    /**
     Obsolete. Use initializers that accept configuration names.
     */
    @available(*, obsoleted=2.0.0, message="Use initializers that accept configuration names.")
    public init(_ entityClass: AnyClass, _ persistentStores: [NSPersistentStore]) {
        
        CoreStore.abort("Use initializers that accept configuration names.")
    }
}
