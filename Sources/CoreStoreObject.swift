//
//  CoreStoreObject.swift
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


// MARK: - CoreStoreObject

/**
 The `CoreStoreObject` is an abstract class for creating CoreStore-managed objects that are more type-safe and more convenient than `NSManagedObject` subclasses. The model entities for `CoreStoreObject` subclasses are inferred from the Swift declaration themselves; no .xcdatamodeld files are needed. To declare persisted attributes and relationships for the `CoreStoreObject` subclass, declare properties of type `Value.Required<T>`, `Value.Optional<T>` for values, or `Relationship.ToOne<T>`, `Relationship.ToManyOrdered<T>`, `Relationship.ToManyUnordered<T>` for relationships.
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
 ```
 `CoreStoreObject` entities for a model version should be added to `CoreStoreSchema` instance.
 ```
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
 - SeeAlso: CoreStoreObject.Value
 - SeeAlso: CoreStoreObject.Relationship
 */
open /*abstract*/ class CoreStoreObject: DynamicObject, Hashable {
    
    /**
     Do not call this directly. This is exposed as public only as a required initializer.
     - Important: subclasses that need a custom initializer should override both `init(_:)` and `init(asMeta:)`, and to call their corresponding super implementations.
     */
    public required init(rawObject: NSManagedObject) {
        
        self.isMeta = false
        self.rawObject = (rawObject as! CoreStoreManagedObject)
        self.initializeAttributes(Mirror(reflecting: self), self)
    }
    
    /**
     Do not call this directly. This is exposed as public only as a required initializer.
     - Important: subclasses that need a custom initializer should override both `init(_:)` and `init(asMeta:)`, and to call their corresponding super implementations.
     */
    public required init(asMeta: Void) {
        
        self.isMeta = true
        self.rawObject = nil
    }
    
    
    // MARK: Equatable
    
    public static func == (lhs: CoreStoreObject, rhs: CoreStoreObject) -> Bool {
        
        guard lhs.isMeta == rhs.isMeta else {
            
            return false
        }
        if lhs.isMeta {
            
            return type(of: lhs) == type(of: rhs)
        }
        return lhs.rawObject!.isEqual(rhs.rawObject!)
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
    
        return ObjectIdentifier(self).hashValue
            ^ (self.isMeta ? 0 : self.rawObject!.hashValue)
    }
    
    
    // MARK: Internal
    
    internal let rawObject: CoreStoreManagedObject?
    internal let isMeta: Bool
    
    
    // MARK: Private
    
    private func initializeAttributes(_ mirror: Mirror, _ parentObject: CoreStoreObject) {
        
        _ = mirror.superclassMirror.flatMap({ self.initializeAttributes($0, parentObject) })
        for child in mirror.children {
            
            switch child.value {
                
            case let property as AttributeProtocol:
                property.parentObject = parentObject
                    
            case let property as RelationshipProtocol:
                property.parentObject = parentObject
                
            default:
                continue
            }
        }
    }
}


// MARK: - DynamicObject where Self: CoreStoreObject

public extension DynamicObject where Self: CoreStoreObject {
    
    /**
     Returns the `PartialObject` instance for the object, which acts as a fast, type-safe KVC interface for `CoreStoreObject`.
     */
    public func partialObject() -> PartialObject<Self> {
        
        CoreStore.assert(
            !self.isMeta,
            "Attempted to create a \(cs_typeName(PartialObject<Self>.self)) from a meta object. Meta objects are only used for querying keyPaths and infering types."
        )
        return PartialObject<Self>(self.rawObject!)
    }
    
    internal static var meta: Self {
        
        return self.init(asMeta: ())
    }
}
