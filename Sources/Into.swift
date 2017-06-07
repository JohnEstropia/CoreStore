//
//  Into.swift
//  CoreStore
//
//  Copyright © 2014 John Rommel Estropia
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


// MARK: - Into

/**
 An `Into` clause contains the destination entity and destination persistent store for a `create(...)` method. A common usage is to just indicate the entity:
 ```
 let person = transaction.create(Into<MyPersonEntity>())
 ```
 For cases where multiple `NSPersistentStore`s contain the same entity, the destination configuration's name needs to be specified as well:
 ```
 let person = transaction.create(Into<MyPersonEntity>("Configuration1"))
 ```
 */
public struct Into<T: DynamicObject>: Hashable {
    
    /**
     The associated `NSManagedObject` or `CoreStoreObject` entity class
     */
    public let entityClass: T.Type
    
    /**
     The `NSPersistentStore` configuration name to associate objects from.
     May contain a `String` to pertain to a named configuration, or `nil` to pertain to the default configuration
     */
    public let configuration: ModelConfiguration
    
    /**
     Initializes an `Into` clause.
     ```
     let person = transaction.create(Into<MyPersonEntity>())
     ```
     */
    public init() {
        
        self.init(entityClass: T.self, configuration: nil, inferStoreIfPossible: true)
    }
    
    /**
     Initializes an `Into` clause with the specified entity type.
     ```
     let person = transaction.create(Into(MyPersonEntity.self))
     ```
     - parameter entity: the `NSManagedObject` type to be created
     */
    public init(_ entity: T.Type) {
        
        self.init(entityClass: entity, configuration: nil, inferStoreIfPossible: true)
    }
    
    /**
     Initializes an `Into` clause with the specified configuration.
     ```
     let person = transaction.create(Into<MyPersonEntity>("Configuration1"))
     ```
     - parameter configuration: the `NSPersistentStore` configuration name to associate the object to. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     */
    public init(_ configuration: ModelConfiguration) {
        
        self.init(entityClass: T.self, configuration: configuration, inferStoreIfPossible: false)
    }
    
    /**
     Initializes an `Into` clause with the specified entity type and configuration.
     ```
     let person = transaction.create(Into(MyPersonEntity.self, "Configuration1"))
     ```
     - parameter entity: the `NSManagedObject` type to be created
     - parameter configuration: the `NSPersistentStore` configuration name to associate the object to. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     */
    public init(_ entity: T.Type, _ configuration: ModelConfiguration) {
        
        self.init(entityClass: entity, configuration: configuration, inferStoreIfPossible: false)
    }
    
    
    // MARK: Equatable
    
    public static func == <U, V>(lhs: Into<U>, rhs: Into<V>) -> Bool {
        
        return lhs.entityClass == rhs.entityClass
            && lhs.configuration == rhs.configuration
            && lhs.inferStoreIfPossible == rhs.inferStoreIfPossible
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
    
        return ObjectIdentifier(self.entityClass).hashValue
            ^ (self.configuration?.hashValue ?? 0)
            ^ self.inferStoreIfPossible.hashValue
    }
    
    
    // MARK: Internal
    
    internal let inferStoreIfPossible: Bool
    
    internal init(entityClass: T.Type, configuration: ModelConfiguration, inferStoreIfPossible: Bool) {
        
        self.entityClass = entityClass
        self.configuration = configuration
        self.inferStoreIfPossible = inferStoreIfPossible
    }
}
