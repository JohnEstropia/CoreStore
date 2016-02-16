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
 let person = transaction.create(Into(MyPersonEntity))
 ```
 For cases where multiple `NSPersistentStore`s contain the same entity, the destination configuration's name needs to be specified as well:
 ```
 let person = transaction.create(Into<MyPersonEntity>("Configuration1"))
 ```
 */
public struct Into<T: NSManagedObject> {
    
    /**
     Initializes an `Into` clause.
     Sample Usage:
     ```
     let person = transaction.create(Into<MyPersonEntity>())
     ```
     */
    public init(){
        
        self.configuration = nil
        self.inferStoreIfPossible = true
        self.entityClass = T.self
    }
    
    /**
     Initializes an `Into` clause with the specified entity type.
     Sample Usage:
     ```
     let person = transaction.create(Into(MyPersonEntity))
     ```
     - parameter entity: the `NSManagedObject` type to be created
     */
    public init(_ entity: T.Type) {
        
        self.configuration = nil
        self.inferStoreIfPossible = true
        self.entityClass = entity
    }
    
    /**
     Initializes an `Into` clause with the specified entity class.
     Sample Usage:
     ```
     let person = transaction.create(Into(MyPersonEntity))
     ```
     - parameter entityClass: the `NSManagedObject` class type to be created
     */
    public init(_ entityClass: AnyClass) {
        
        self.configuration = nil
        self.inferStoreIfPossible = true
        self.entityClass = entityClass
    }
    
    /**
     Initializes an `Into` clause with the specified configuration.
     Sample Usage:
     ```
     let person = transaction.create(Into<MyPersonEntity>("Configuration1"))
     ```
     - parameter configuration: the `NSPersistentStore` configuration name to associate the object to. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     */
    public init(_ configuration: String?) {
        
        self.configuration = configuration
        self.inferStoreIfPossible = false
        self.entityClass = T.self
    }
    
    /**
     Initializes an `Into` clause with the specified entity type and configuration.
     Sample Usage:
     ```
     let person = transaction.create(Into(MyPersonEntity.self, "Configuration1"))
     ```
     - parameter entity: the `NSManagedObject` type to be created
     - parameter configuration: the `NSPersistentStore` configuration name to associate the object to. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     */
    public init(_ entity: T.Type, _ configuration: String?) {
        
        self.configuration = configuration
        self.inferStoreIfPossible = false
        self.entityClass = entity
    }
    
    /**
     Initializes an `Into` clause with the specified entity class and configuration.
     Sample Usage:
     ```
     let person = transaction.create(Into(MyPersonEntity.self, "Configuration1"))
     ```
     - parameter entityClass: the `NSManagedObject` class type to be created
     - parameter configuration: the `NSPersistentStore` configuration name to associate the object to. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     */
    public init(_ entityClass: AnyClass, _ configuration: String?) {
        
        self.configuration = configuration
        self.inferStoreIfPossible = false
        self.entityClass = entityClass
    }
    
    
    // MARK: Internal
    
    internal static var defaultConfigurationName: String {
        
        return "PF_DEFAULT_CONFIGURATION_NAME"
    }
    
    internal let entityClass: AnyClass
    internal let configuration: String?
    internal let inferStoreIfPossible: Bool
}
