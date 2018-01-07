//
//  CoreStoreObject+Querying.swift
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


// MARK: - ValueContainer.Required

public extension ValueContainer.Required {
    
    /**
     Creates a `Where` clause by comparing if a property is equal to a value
     ```
     let person = CoreStore.fetchOne(From<Person>().where({ $0.nickname == "John" }))
     ```
     */
    public static func == (_ attribute: ValueContainer<O>.Required<V>, _ value: V) -> Where<O> {
        
        return Where(attribute.keyPath, isEqualTo: value)
    }
    
    /**
     Creates a `Where` clause by comparing if a property is not equal to a value
     ```
     let person = CoreStore.fetchOne(From<Person>().where({ $0.nickname != "John" }))
     ```
     */
    public static func != (_ attribute: ValueContainer<O>.Required<V>, _ value: V) -> Where<O> {
        
        return !Where(attribute.keyPath, isEqualTo: value)
    }
    
    /**
     Creates a `Where` clause by comparing if a property is less than a value
     ```
     let person = CoreStore.fetchOne(From<Person>().where({ $0.age < 20 }))
     ```
     */
    public static func < (_ attribute: ValueContainer<O>.Required<V>, _ value: V) -> Where<O> {
        
        return Where("%K < %@", attribute.keyPath, value.cs_toQueryableNativeType())
    }
    
    /**
     Creates a `Where` clause by comparing if a property is greater than a value
     ```
     let person = CoreStore.fetchOne(From<Person>().where({ $0.age > 20 }))
     ```
     */
    public static func > (_ attribute: ValueContainer<O>.Required<V>, _ value: V) -> Where<O> {
        
        return Where("%K > %@", attribute.keyPath, value.cs_toQueryableNativeType())
    }
    
    /**
     Creates a `Where` clause by comparing if a property is less than or equal to a value
     ```
     let person = CoreStore.fetchOne(From<Person>().where({ $0.age <= 20 }))
     ```
     */
    public static func <= (_ attribute: ValueContainer<O>.Required<V>, _ value: V) -> Where<O> {
        
        return Where("%K <= %@", attribute.keyPath, value.cs_toQueryableNativeType())
    }
    
    /**
     Creates a `Where` clause by comparing if a property is greater than or equal to a value
     ```
     let person = CoreStore.fetchOne(From<Person>().where({ $0.age >= 20 }))
     ```
     */
    public static func >= (_ attribute: ValueContainer<O>.Required<V>, _ value: V) -> Where<O> {
        
        return Where("%K >= %@", attribute.keyPath, value.cs_toQueryableNativeType())
    }
    
    /**
     Creates a `Where` clause by checking if a sequence contains the value of a property
     ```
     let dog = CoreStore.fetchOne(From<Dog>().where({ ["Pluto", "Snoopy", "Scooby"] ~= $0.nickname }))
     ```
     */
    public static func ~= <S: Sequence>(_ sequence: S, _ attribute: ValueContainer<O>.Required<V>) -> Where<O> where S.Iterator.Element == V {
        
        return Where(attribute.keyPath, isMemberOf: sequence)
    }
}


// MARK: - ValueContainer.Optional

public extension ValueContainer.Optional {
    
    /**
     Creates a `Where` clause by comparing if a property is equal to a value
     ```
     let person = CoreStore.fetchOne(From<Person>().where({ $0.nickname == "John" }))
     ```
     */
    public static func == (_ attribute: ValueContainer<O>.Optional<V>, _ value: V?) -> Where<O> {
        
        return Where(attribute.keyPath, isEqualTo: value)
    }
    
    /**
     Creates a `Where` clause by comparing if a property is not equal to a value
     ```
     let person = CoreStore.fetchOne(From<Person>().where({ $0.nickname != "John" }))
     ```
     */
    public static func != (_ attribute: ValueContainer<O>.Optional<V>, _ value: V?) -> Where<O> {
        
        return !Where(attribute.keyPath, isEqualTo: value)
    }
    
    /**
     Creates a `Where` clause by comparing if a property is less than a value
     ```
     let person = CoreStore.fetchOne(From<Person>().where({ $0.age < 20 }))
     ```
     */
    public static func < (_ attribute: ValueContainer<O>.Optional<V>, _ value: V?) -> Where<O> {
        
        if let value = value {
            
            return Where("%K < %@", attribute.keyPath, value.cs_toQueryableNativeType())
        }
        else {
            
            return Where("%K < nil", attribute.keyPath)
        }
    }
    
    /**
     Creates a `Where` clause by comparing if a property is greater than a value
     ```
     let person = CoreStore.fetchOne(From<Person>().where({ $0.age > 20 }))
     ```
     */
    public static func > (_ attribute: ValueContainer<O>.Optional<V>, _ value: V?) -> Where<O> {
        
        if let value = value {
            
            return Where("%K > %@", attribute.keyPath, value.cs_toQueryableNativeType())
        }
        else {
            
            return Where("%K > nil", attribute.keyPath)
        }
    }
    
    /**
     Creates a `Where` clause by comparing if a property is less than or equal to a value
     ```
     let person = CoreStore.fetchOne(From<Person>().where({ $0.age <= 20 }))
     ```
     */
    public static func <= (_ attribute: ValueContainer<O>.Optional<V>, _ value: V?) -> Where<O> {
        
        if let value = value {
            
            return Where("%K <= %@", attribute.keyPath, value.cs_toQueryableNativeType())
        }
        else {
            
            return Where("%K <= nil", attribute.keyPath)
        }
    }
    
    /**
     Creates a `Where` clause by comparing if a property is greater than or equal to a value
     ```
     let person = CoreStore.fetchOne(From<Person>().where({ $0.age >= 20 }))
     ```
     */
    public static func >= (_ attribute: ValueContainer<O>.Optional<V>, _ value: V?) -> Where<O> {
        
        if let value = value {
            
            return Where("%K >= %@", attribute.keyPath, value.cs_toQueryableNativeType())
        }
        else {
            
            return Where("%K >= nil", attribute.keyPath)
        }
    }
    
    /**
     Creates a `Where` clause by checking if a sequence contains the value of a property
     ```
     let dog = CoreStore.fetchOne(From<Dog>().where({ ["Pluto", "Snoopy", "Scooby"] ~= $0.nickname }))
     ```
     */
    public static func ~= <S: Sequence>(_ sequence: S, _ attribute: ValueContainer<O>.Optional<V>) -> Where<O> where S.Iterator.Element == V {
        
        return Where(attribute.keyPath, isMemberOf: sequence)
    }
}


// MARK: - RelationshipContainer.ToOne

public extension RelationshipContainer.ToOne {
    
    /**
     Creates a `Where` clause by comparing if a property is equal to a value
     ```
     let dog = CoreStore.fetchOne(From<Dog>().where({ $0.master == me }))
     ```
     */
    public static func == (_ relationship: RelationshipContainer<O>.ToOne<D>, _ object: D?) -> Where<O> {
        
        return Where(relationship.keyPath, isEqualTo: object)
    }
    
    /**
     Creates a `Where` clause by comparing if a property is not equal to a value
     ```
     let dog = CoreStore.fetchOne(From<Dog>().where({ $0.master != me }))
     ```
     */
    public static func != (_ relationship: RelationshipContainer<O>.ToOne<D>, _ object: D?) -> Where<O> {
        
        return !Where(relationship.keyPath, isEqualTo: object)
    }
    
    /**
     Creates a `Where` clause by checking if a sequence contains the value of a property
     ```
     let dog = CoreStore.fetchOne(From<Dog>().where({ [john, joe, bob] ~= $0.master }))
     ```
     */
    public static func ~= <S: Sequence>(_ sequence: S, _ relationship: RelationshipContainer<O>.ToOne<D>) -> Where<O> where S.Iterator.Element == D {
        
        return Where(relationship.keyPath, isMemberOf: sequence)
    }
}


// MARK: Deprecated

extension DynamicObject where Self: CoreStoreObject {
    
    @available(*, deprecated, message: "Use the String(keyPath:) initializer and pass the KeyPath: String(keyPath: \\Person.name)")
    public static func keyPath<O, V>(_ attribute: (Self) -> ValueContainer<O>.Required<V>) -> String  {
        
        return attribute(self.meta).keyPath
    }
    
    @available(*, deprecated, message: "Use the String(keyPath:) initializer and pass the KeyPath: String(keyPath: \\Person.name)")
    public static func keyPath<O, V>(_ attribute: (Self) -> ValueContainer<O>.Optional<V>) -> String  {
        
        return attribute(self.meta).keyPath
    }
    
    @available(*, deprecated, message: "Use the String(keyPath:) initializer and pass the KeyPath: String(keyPath: \\Person.friend)")
    public static func keyPath<O, D>(_ relationship: (Self) -> RelationshipContainer<O>.ToOne<D>) -> String  {
        
        return relationship(self.meta).keyPath
    }
    
    @available(*, deprecated, message: "Use the String(keyPath:) initializer and pass the KeyPath: String(keyPath: \\Person.friends)")
    public static func keyPath<O, D>(_ relationship: (Self) -> RelationshipContainer<O>.ToManyOrdered<D>) -> String  {
        
        return relationship(self.meta).keyPath
    }
    
    @available(*, deprecated, message: "Use the String(keyPath:) initializer and pass the KeyPath: String(keyPath: \\Person.friends)")
    public static func keyPath<O, D>(_ relationship: (Self) -> RelationshipContainer<O>.ToManyUnordered<D>) -> String  {
        
        return relationship(self.meta).keyPath
    }
    
    @available(*, deprecated, message: "Use the Where<DynamicObject>(_:) initializer that accepts the same closure argument")
    public static func `where`(_ condition: (Self) -> Where<Self>) -> Where<Self>  {
        
        return condition(self.meta)
    }
    
    @available(*, deprecated, message: "Use the new OrderBy<DynamicObject>(ascending:) overload that accepts the same closure argument")
    public static func orderBy<O, V>(ascending attribute: (Self) -> ValueContainer<O>.Required<V>) -> OrderBy<Self>  {
        
        return OrderBy(.ascending(attribute(self.meta).keyPath))
    }
    
    @available(*, deprecated, message: "Use the new OrderBy<DynamicObject>(ascending:) overload that accepts the same closure argument")
    public static func orderBy<O, V>(ascending attribute: (Self) -> ValueContainer<O>.Optional<V>) -> OrderBy<Self>  {
        
        return OrderBy(.ascending(attribute(self.meta).keyPath))
    }
    
    @available(*, deprecated, message: "Use the new OrderBy<DynamicObject>(descending:) overload that accepts the same closure argument")
    public static func orderBy<O, V>(descending attribute: (Self) -> ValueContainer<O>.Required<V>) -> OrderBy<Self>  {
        
        return OrderBy(.descending(attribute(self.meta).keyPath))
    }
    
    @available(*, deprecated, message: "Use the new OrderBy<DynamicObject>(descending:) overload that accepts the same closure argument")
    public static func orderBy<O, V>(descending attribute: (Self) -> ValueContainer<O>.Optional<V>) -> OrderBy<Self>  {
        
        return OrderBy(.descending(attribute(self.meta).keyPath))
    }
}
