//
//  Entity.swift
//  CoreStore
//
//  Copyright © 2017 John Rommel Estropia
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
import Foundation
import ObjectiveC


// MARK: Entity

/**
 The `Entity<O>` contains `NSEntityDescription` metadata for `CoreStoreObject` subclasses. Pass the `Entity` instances to `CoreStoreSchema` initializer.
 ```
 class Animal: CoreStoreObject {
     let species = Value.Required<String>("species", initial: "")
     let nickname = Value.Optional<String>("nickname")
     let master = Relationship.ToOne<Person>("master")
 }
 
 class Person: CoreStoreObject {
     let name = Value.Required<String>("name", initial: "")
     let pet = Relationship.ToOne<Animal>("pet", inverse: { $0.master })
 }
 
 CoreStore.defaultStack = DataStack(
     CoreStoreSchema(
         modelVersion: "V1",
         entities: [
             Entity<Animal>("Animal"),
             Entity<Person>("Person")
         ]
     )
 )
 ```
 - SeeAlso: CoreStoreSchema
 - SeeAlso: CoreStoreObject
 */
public final class Entity<O: DynamicObject>: DynamicEntity {
    
    /**
     Initializes an `Entity`. Always provide a concrete generic type to `Entity`.
     ```
     Entity<Animal>("Animal")
     ```
     - parameter entityName: the `NSEntityDescription` name to use for the entity
     - parameter isAbstract: set to `true` if the entity is meant to be an abstract class and can only be initialized with subclass types.
     - parameter versionHashModifier: The version hash modifier for the entity. Used to mark or denote an entity as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where, for example, the structure of an entity is unchanged but the format or content of data has changed.)
     */
    public convenience init(_ entityName: String, isAbstract: Bool = false, versionHashModifier: String? = nil) {
        
        self.init(O.self, entityName, isAbstract: isAbstract, versionHashModifier: versionHashModifier)
    }
    
    /**
     Initializes an `Entity`.
     ```
     Entity(Animal.self, "Animal")
     ```
     - parameter type: the `DynamicObject` type associated with the entity
     - parameter entityName: the `NSEntityDescription` name to use for the entity
     - parameter isAbstract: set to `true` if the entity is meant to be an abstract class and can only be initialized with subclass types.
     - parameter versionHashModifier: The version hash modifier for the entity. Used to mark or denote an entity as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where, for example, the structure of an entity is unchanged but the format or content of data has changed.)
     */
    public init(_ type: O.Type, _ entityName: String, isAbstract: Bool = false, versionHashModifier: String? = nil) {
        
        super.init(type: type, entityName: entityName, isAbstract: isAbstract, versionHashModifier: versionHashModifier)
    }
}


// MARK: - DynamicEntity

/**
 Use concrete instances of `Entity<O>` in API that accept `DynamicEntity` arguments.
 */
public /*abstract*/ class DynamicEntity: Hashable {
    
    /**
     Do not use directly.
     */
    public let type: DynamicObject.Type
    
    /**
     Do not use directly.
     */
    public let entityName: EntityName
    
    /**
     Do not use directly.
     */
    public let isAbstract: Bool
    
    /**
     Do not use directly.
     */
    public let versionHashModifier: String?
    
    
    // MARK: Equatable
    
    public static func == (lhs: DynamicEntity, rhs: DynamicEntity) -> Bool {
        
        return lhs.type == rhs.type
            && lhs.entityName == rhs.entityName
            && lhs.isAbstract == rhs.isAbstract
            && lhs.versionHashModifier == rhs.versionHashModifier
    }
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        return ObjectIdentifier(self.type).hashValue
            ^ self.entityName.hashValue
            ^ self.isAbstract.hashValue
            ^ (self.versionHashModifier ?? "").hashValue
    }
    
    
    // MARK: Internal
    
    internal init(type: DynamicObject.Type, entityName: String, isAbstract: Bool = false, versionHashModifier: String?) {
        
        self.type = type
        self.entityName = entityName
        self.isAbstract = isAbstract
        self.versionHashModifier = versionHashModifier
    }
}
