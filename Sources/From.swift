//
//  From.swift
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


// MARK: - From

/**
 A `From` clause specifies the source entity and source persistent store for fetch and query methods. A common usage is to just indicate the entity:
 ```
 let person = transaction.fetchOne(From<Person>())
 ```
 For cases where multiple `NSPersistentStore`s contain the same entity, the source configuration's name needs to be specified as well:
 ```
 let person = transaction.fetchOne(From<Person>("Configuration1"))
 ```
 */
public struct From<D: DynamicObject> {
    
    /**
     The associated `NSManagedObject` or `CoreStoreObject` entity class
     */
    public let entityClass: D.Type
    
    /**
     The `NSPersistentStore` configuration names to associate objects from.
     May contain `String`s to pertain to named configurations, or `nil` to pertain to the default configuration
     */
    public let configurations: [ModelConfiguration]?
    
    /**
     Initializes a `From` clause.
     ```
     let people = transaction.fetchAll(From<MyPersonEntity>())
     ```
     */
    public init() {
        
        self.init(entityClass: D.self, configurations: nil)
    }
    
    /**
     Initializes a `From` clause with the specified entity type.
     ```
     let people = transaction.fetchAll(From<MyPersonEntity>())
     ```
     - parameter entity: the associated `NSManagedObject` or `CoreStoreObject` type
     */
    public init(_ entity: D.Type) {
        
        self.init(entityClass: entity, configurations: nil)
    }
    
    /**
     Initializes a `From` clause with the specified configurations.
     ```
     let people = transaction.fetchAll(From<MyPersonEntity>(nil, "Configuration1"))
     ```
     - parameter configuration: the `NSPersistentStore` configuration name to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject` or `CoreStoreObject`'s entity type. Set to `nil` to use the default configuration.
     - parameter otherConfigurations: an optional list of other configuration names to associate objects from (see `configuration` parameter)
     */
    public init(_ configuration: ModelConfiguration, _ otherConfigurations: ModelConfiguration...) {
        
        self.init(entityClass: D.self, configurations: [configuration] + otherConfigurations)
    }
    
    /**
     Initializes a `From` clause with the specified configurations.
     ```
     let people = transaction.fetchAll(From<MyPersonEntity>(["Configuration1", "Configuration2"]))
     ```
     - parameter configurations: a list of `NSPersistentStore` configuration names to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject` or `CoreStoreObject`'s entity type. Set to `nil` to use the default configuration.
     */
    public init(_ configurations: [ModelConfiguration]) {
        
        self.init(entityClass: D.self, configurations: configurations)
    }
    
    /**
     Initializes a `From` clause with the specified configurations.
     ```
     let people = transaction.fetchAll(From(MyPersonEntity.self, nil, "Configuration1"))
     ```
     - parameter entity: the associated `NSManagedObject` or `CoreStoreObject` type
     - parameter configuration: the `NSPersistentStore` configuration name to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject` or `CoreStoreObject`'s entity type. Set to `nil` to use the default configuration.
     - parameter otherConfigurations: an optional list of other configuration names to associate objects from (see `configuration` parameter)
     */
    public init(_ entity: D.Type, _ configuration: ModelConfiguration, _ otherConfigurations: ModelConfiguration...) {
        
        self.init(entityClass: entity, configurations: [configuration] + otherConfigurations)
    }
    
    /**
     Initializes a `From` clause with the specified configurations.
     ```
     let people = transaction.fetchAll(From(MyPersonEntity.self, ["Configuration1", "Configuration1"]))
     ```
     - parameter entity: the associated `NSManagedObject` or `CoreStoreObject` type
     - parameter configurations: a list of `NSPersistentStore` configuration names to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject` or `CoreStoreObject`'s entity type. Set to `nil` to use the default configuration.
     */
    public init(_ entity: D.Type, _ configurations: [ModelConfiguration]) {
        
        self.init(entityClass: entity, configurations: configurations)
    }
    
    
    // MARK: Internal
    
    internal let findPersistentStores: (_ context: NSManagedObjectContext) -> [NSPersistentStore]?
    
    internal init(entityClass: D.Type, configurations: [ModelConfiguration]?, findPersistentStores: @escaping (_ context: NSManagedObjectContext) -> [NSPersistentStore]?) {
        
        self.entityClass = entityClass
        self.configurations = configurations
        self.findPersistentStores = findPersistentStores
    }
    
    internal func applyToFetchRequest<ResultType>(_ fetchRequest: NSFetchRequest<ResultType>, context: NSManagedObjectContext, applyAffectedStores: Bool = true) -> Bool {
        
        fetchRequest.entity = context.parentStack!.entityDescription(for: EntityIdentifier(self.entityClass))!
        guard applyAffectedStores else {
            
            return true
        }
        if self.applyAffectedStoresForFetchedRequest(fetchRequest, context: context) {
            
            return true
        }
        CoreStore.log(
            .warning,
            message: "Attempted to perform a fetch but could not find any persistent store for the entity \(cs_typeName(fetchRequest.entityName))"
        )
        return false
    }
    
    internal func applyAffectedStoresForFetchedRequest<U>(_ fetchRequest: NSFetchRequest<U>, context: NSManagedObjectContext) -> Bool {
        
        let stores = self.findPersistentStores(context)
        fetchRequest.affectedStores = stores
        return stores?.isEmpty == false
    }
    
    
    // MARK: Private
    
    private init(entityClass: D.Type, configurations: [ModelConfiguration]?) {
        
        self.entityClass = entityClass
        self.configurations = configurations
        
        let entityIdentifier = EntityIdentifier(entityClass)
        if let configurations = configurations {
            
            let configurationsSet = Set(configurations.map({ $0 ?? DataStack.defaultConfigurationName }))
            self.findPersistentStores = { (context: NSManagedObjectContext) -> [NSPersistentStore]? in
                
                return context.parentStack?.persistentStores(for: entityIdentifier)?.filter {
                    
                    return configurationsSet.contains($0.configurationName)
                }
            }
        }
        else {
            
            self.findPersistentStores = { (context: NSManagedObjectContext) -> [NSPersistentStore]? in
                
                return context.parentStack?.persistentStores(for: entityIdentifier)
            }
        }
    }
}
