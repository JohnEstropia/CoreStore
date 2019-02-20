//
//  Where.Expression.swift
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


// MARK: - ~

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
```
let owner = CoreStore.fetchOne(
    From<Pet>().where(
        (\.master ~ \.name) == "John"
    )
)
```
 */
infix operator ~ : AdditionPrecedence


// MARK: - WhereExpressionTrait

/**
 Used only for `Where.Expression` type constraints. Currently supports `SingleTarget` and `CollectionTarget`.
 */
public protocol WhereExpressionTrait {}


// MARK: - Where

extension Where {

    // MARK: - Expression

    /**
     Type-safe keyPath chain usable in query/fetch expressions.
     ```
     let expression: Where<Pet>.Expression = (\.master ~ \.name)
     let owner = CoreStore.fetchOne(
        From<Pet>().where(expression == "John")
     )
     ```
     */
    public struct Expression<T: WhereExpressionTrait, V>: CustomStringConvertible, DynamicKeyPath {

        /**
         Currently supports `SingleTarget` and `CollectionTarget`.
         */
        public typealias Trait = T


        // MARK: AnyDynamicKeyPath

        public let cs_keyPathString: String


        // MARK: DynamicKeyPath

        public typealias ObjectType = D
        public typealias ValueType = V


        // MARK: CustomStringConvertible

        public var description: String {

            return self.cs_keyPathString
        }


        // MARK: Internal

        internal init(_ component: String) {

            self.cs_keyPathString = component
        }

        internal init(_ component1: String, _ component2: String) {

            self.cs_keyPathString = component1 + "." + component2
        }
    }


    // MARK: - SingleTarget

    /**
     Used only for `Where.Expression` type constraints. Specifies that this `Where.Expression` type pertains to an attribute property expression.
     */
    public enum SingleTarget: WhereExpressionTrait {}


    // MARK: - CollectionTarget

    /**
     Used only for `Where.Expression` type constraints. Specifies that this `Where.Expression` type pertains to a to-many relationship expression.
     */
    public enum CollectionTarget: WhereExpressionTrait {}
}


// MARK: - ~ (Where.Expression Creation Operators)

// MARK: ~ where D: NSManagedObject

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let owner = CoreStore.fetchOne(From<Pet>().where((\.master ~ \.name) == "John"))
 ```
 */
public func ~<D: NSManagedObject, O: NSManagedObject, V: AllowedObjectiveCKeyPathValue>(_ lhs: KeyPath<D, O>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<Where<D>.SingleTarget, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let owner = CoreStore.fetchOne(From<Pet>().where((\.master ~ \.name) == "John"))
 ```
 */
public func ~ <D: NSManagedObject, O: NSManagedObject, V: AllowedObjectiveCKeyPathValue>(_ lhs: KeyPath<D, O?>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<Where<D>.SingleTarget, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let happyPets = CoreStore.fetchAll(From<Pet>().where((\.master ~ \.pets).count() > 1))
 ```
 */
public func ~ <D: NSManagedObject, O: NSManagedObject, V: AllowedObjectiveCCollectionKeyPathValue>(_ lhs: KeyPath<D, O>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<Where<D>.CollectionTarget, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let happyPets = CoreStore.fetchAll(From<Pet>().where((\.master ~ \.pets).count() > 1))
 ```
 */
public func ~ <D: NSManagedObject, O: NSManagedObject, V: AllowedObjectiveCCollectionKeyPathValue>(_ lhs: KeyPath<D, O?>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<Where<D>.CollectionTarget, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let johnsSonInLaw = CoreStore.fetchOne(From<Person>().where((\.spouse ~ \.father ~ \.name) == "John"))
 ```
 */
public func ~ <D: NSManagedObject, O: NSManagedObject, T, V: AllowedObjectiveCKeyPathValue>(_ lhs: Where<D>.Expression<T, O>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<T, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let johnsSonInLaw = CoreStore.fetchOne(From<Person>().where((\.spouse ~ \.father ~ \.name) == "John"))
 ```
 */
public func ~ <D: NSManagedObject, O: NSManagedObject, T, V: AllowedObjectiveCKeyPathValue>(_ lhs: Where<D>.Expression<T, O?>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<T, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let spouseHasSiblings = CoreStore.fetchOne(From<Person>().where((\.spouse ~ \.father ~ \.children).count() > 0))
 ```
 */
public func ~ <D: NSManagedObject, O: NSManagedObject, T, V: AllowedObjectiveCCollectionKeyPathValue>(_ lhs: Where<D>.Expression<T, O>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<Where<D>.CollectionTarget, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let spouseHasSiblings = CoreStore.fetchOne(From<Person>().where((\.spouse ~ \.father ~ \.children).count() > 0))
 ```
 */
public func ~ <D: NSManagedObject, O: NSManagedObject, T, V: AllowedObjectiveCCollectionKeyPathValue>(_ lhs: Where<D>.Expression<T, O?>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<Where<D>.CollectionTarget, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let spousesWithBadNamingSense = CoreStore.fetchAll(From<Person>().where((\.spouse ~ \.pets ~ \.name).any() == "Spot"))
 ```
 */
public func ~ <D: NSManagedObject, O: NSManagedObject, T, C: AllowedObjectiveCCollectionKeyPathValue, V: AllowedObjectiveCKeyPathValue>(_ lhs: Where<D>.Expression<T, C>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<Where<D>.CollectionTarget, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}


// MARK: - ~ where D: CoreStoreObject

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let owner = CoreStore.fetchOne(From<Pet>().where((\.master ~ \.name) == "John"))
 ```
 */
public func ~ <D: CoreStoreObject, O: CoreStoreObject, K: AllowedCoreStoreObjectKeyPathValue>(_ lhs: KeyPath<D, RelationshipContainer<D>.ToOne<O>>, _ rhs: KeyPath<O, K>) -> Where<D>.Expression<Where<D>.SingleTarget, K.ValueType> where K.ObjectType == O {

    return .init(
        D.meta[keyPath: lhs].cs_keyPathString, 
        O.meta[keyPath: rhs].cs_keyPathString
    )
}

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let owner = CoreStore.fetchOne(From<Pet>().where((\.master ~ \.name) == "John"))
 ```
 */
public func ~ <D: CoreStoreObject, O: CoreStoreObject, T, K: AllowedCoreStoreObjectKeyPathValue>(_ lhs: Where<D>.Expression<T, O>, _ rhs: KeyPath<O, K>) -> Where<D>.Expression<T, K.ValueType> where K.ObjectType == O {

    return .init(
        lhs.cs_keyPathString,
        O.meta[keyPath: rhs].cs_keyPathString
    )
}

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let owner = CoreStore.fetchOne(From<Pet>().where((\.master ~ \.name) == "John"))
 ```
 */
public func ~ <D: CoreStoreObject, O: CoreStoreObject, T, K: AllowedCoreStoreObjectKeyPathValue>(_ lhs: Where<D>.Expression<T, O?>, _ rhs: KeyPath<O, K>) -> Where<D>.Expression<T, K.ValueType> where K.ObjectType == O {

    return .init(
        lhs.cs_keyPathString,
        O.meta[keyPath: rhs].cs_keyPathString
    )
}

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let happyPets = CoreStore.fetchAll(From<Pet>().where((\.master ~ \.pets).count() > 1))
 ```
 */
public func ~ <D: CoreStoreObject, O: CoreStoreObject, K: AllowedCoreStoreObjectCollectionKeyPathValue>(_ lhs: KeyPath<D, RelationshipContainer<D>.ToOne<O>>, _ rhs: KeyPath<O, K>) -> Where<D>.Expression<Where<D>.CollectionTarget, K.ValueType> where K.ObjectType == O {

    return .init(
        D.meta[keyPath: lhs].cs_keyPathString,
        O.meta[keyPath: rhs].cs_keyPathString
    )
}

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let happyPets = CoreStore.fetchAll(From<Pet>().where((\.master ~ \.pets).count() > 1))
 ```
 */
public func ~ <D: CoreStoreObject, O: CoreStoreObject, T, K: AllowedCoreStoreObjectCollectionKeyPathValue>(_ lhs: Where<D>.Expression<T, O>, _ rhs: KeyPath<O, K>) -> Where<D>.Expression<Where<D>.CollectionTarget, K.ValueType> where K.ObjectType == O {

    return .init(
        lhs.cs_keyPathString,
        O.meta[keyPath: rhs].cs_keyPathString
    )
}

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let happyPets = CoreStore.fetchAll(From<Pet>().where((\.master ~ \.pets).count() > 1))
 ```
 */
public func ~ <D: CoreStoreObject, O: CoreStoreObject, T, K: AllowedCoreStoreObjectCollectionKeyPathValue>(_ lhs: Where<D>.Expression<T, O?>, _ rhs: KeyPath<O, K>) -> Where<D>.Expression<Where<D>.CollectionTarget, K.ValueType> where K.ObjectType == O {

    return .init(
        lhs.cs_keyPathString,
        O.meta[keyPath: rhs].cs_keyPathString
    )
}

/**
 Connects multiple `DynamicKeyPath`s to create a type-safe chain usable in query/fetch expressions
 ```
 let spousesWithBadNamingSense = CoreStore.fetchAll(From<Pet>().where((\.master ~ \.pets ~ \.name).any() == "Spot"))
 ```
 */
public func ~ <D: CoreStoreObject, O: CoreStoreObject, T, KC: AllowedCoreStoreObjectCollectionKeyPathValue, KV: AllowedCoreStoreObjectKeyPathValue>(_ lhs: Where<D>.Expression<T, KC>, _ rhs: KeyPath<O, KV>) -> Where<D>.Expression<Where<D>.CollectionTarget, KV.ValueType> where KC.ObjectType == D, KV.ObjectType == O {

    return .init(
        lhs.cs_keyPathString,
        O.meta[keyPath: rhs].cs_keyPathString
    )
}


// MARK: - Where.Expression where V: QueryableAttributeType

/**
 Creates a `Where` clause by comparing if an expression is equal to a value
 ```
 let dog = CoreStore.fetchOne(From<Dog>().where((\.master ~ \.name) == "John"))
 ```
 */
public func == <D, T, V: QueryableAttributeType>(_ lhs: Where<D>.Expression<T, V>, _ rhs: V) -> Where<D> {

    return Where<D>(lhs.cs_keyPathString, isEqualTo: rhs)
}

/**
 Creates a `Where` clause by comparing if an expression is not equal to a value
 ```
 let dog = CoreStore.fetchOne(From<Dog>().where((\.master ~ \.name) != "John"))
 ```
 */
public func != <D, T, V: QueryableAttributeType>(_ lhs: Where<D>.Expression<T, V>, _ rhs: V) -> Where<D> {

    return !Where<D>(lhs.cs_keyPathString, isEqualTo: rhs)
}

/**
 Creates a `Where` clause by checking if a sequence contains a value
 ```
 let dog = CoreStore.fetchOne(From<Dog>().where(["John", "Joe"] ~= (\.master ~ \.name))
 ```
 */
public func ~= <D, T, V: QueryableAttributeType, S: Sequence>(_ sequence: S, _ expression: Where<D>.Expression<T, V>) -> Where<D> where S.Iterator.Element == V {

    return Where<D>(expression.cs_keyPathString, isMemberOf: sequence)
}


// MARK: - Where.Expression where V: QueryableAttributeType & Comparable

/**
 Creates a `Where` clause by comparing if an expression is less than a value
 ```
 let lonelyDog = CoreStore.fetchOne(From<Dog>().where((\.master ~ \.pets).count() < 2))
 ```
 */
public func < <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V>, _ rhs: V) -> Where<D> {

    return  Where<D>(expression: lhs, function: "<", operand: rhs)
}

/**
 Creates a `Where` clause by comparing if an expression is less than or equal to a value
 ```
 let lonelyDog = CoreStore.fetchOne(From<Dog>().where((\.master ~ \.pets).count() <= 1)
 ```
 */
public func <= <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V>, _ rhs: V) -> Where<D> {

    return  Where<D>(expression: lhs, function: "<=", operand: rhs)
}

/**
 Creates a `Where` clause by comparing if an expression is greater than a value
 ```
 let happyDog = CoreStore.fetchOne(From<Dog>().where((\.master ~ \.pets).count() > 1)
 ```
 */
public func > <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V>, _ rhs: V) -> Where<D> {

    return  Where<D>(expression: lhs, function: ">", operand: rhs)
}

/**
 Creates a `Where` clause by comparing if an expression is greater than or equal to a value
 ```
 let happyDog = CoreStore.fetchOne(From<Dog>().where((\.master ~ \.pets).count() >= 2)
 ```
 */
public func >= <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V>, _ rhs: V) -> Where<D> {

    return  Where<D>(expression: lhs, function: ">=", operand: rhs)
}


// MARK: - Where.Expression where V: Optional<QueryableAttributeType>

/**
 Creates a `Where` clause by comparing if an expression is equal to a value
 ```
 let dog = CoreStore.fetchOne(From<Dog>().where((\.master ~ \.name) == "John"))
 ```
 */
public func == <D, T, V: QueryableAttributeType>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V) -> Where<D> {

    return Where<D>(lhs.cs_keyPathString, isEqualTo: rhs)
}

/**
 Creates a `Where` clause by comparing if an expression is equal to a value
 ```
 let dog = CoreStore.fetchOne(From<Dog>().where((\.master ~ \.name) == "John"))
 ```
 */
public func == <D, T, V: QueryableAttributeType>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V?) -> Where<D> {

    return Where<D>(lhs.cs_keyPathString, isEqualTo: rhs)
}

/**
 Creates a `Where` clause by comparing if an expression is equal to a value
 ```
 let dog = CoreStore.fetchOne(From<Dog>().where((\.master ~ \.name) != "John"))
 ```
 */
public func != <D, T, V: QueryableAttributeType>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V) -> Where<D> {

    return !Where<D>(lhs.cs_keyPathString, isEqualTo: rhs)
}

/**
 Creates a `Where` clause by comparing if an expression is equal to a value
 ```
 let dog = CoreStore.fetchOne(From<Dog>().where((\.master ~ \.name) != "John"))
 ```
 */
public func != <D, T, V: QueryableAttributeType>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V?) -> Where<D> {

    return !Where<D>(lhs.cs_keyPathString, isEqualTo: rhs)
}

/**
 Creates a `Where` clause by checking if a sequence contains a value
 ```
 let dog = CoreStore.fetchOne(From<Dog>().where(["John", "Joe"] ~= (\.master ~ \.name))
 ```
 */
public func ~= <D, T, V: QueryableAttributeType, S: Sequence>(_ sequence: S, _ expression: Where<D>.Expression<T, V?>) -> Where<D> where S.Iterator.Element == V {

    return Where<D>(expression.cs_keyPathString, isMemberOf: sequence)
}


// MARK: - Where.Expression where V: Optional<QueryableAttributeType & Comparable>

/**
 Creates a `Where` clause by comparing if an expression is less than a value
 ```
 let childsPet = CoreStore.fetchOne(From<Dog>().where((\.master ~ \.age) < 10))
 ```
 */
public func < <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V) -> Where<D> {

    return Where<D>(expression: lhs, function: "<", operand: rhs)
}

/**
 Creates a `Where` clause by comparing if an expression is less than or equal to a value
 ```
 let childsPet = CoreStore.fetchOne(From<Dog>().where((\.master ~ \.age) <= 10))
 ```
 */
public func <= <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V?) -> Where<D> {

    return Where<D>(expression: lhs, function: "<=", operand: rhs)
}

/**
 Creates a `Where` clause by comparing if an expression is greater than a value
 ```
 let teensPet = CoreStore.fetchOne(From<Dog>().where((\.master ~ \.age) > 10))
 ```
 */
public func > <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V) -> Where<D> {

    return Where<D>(expression: lhs, function: ">", operand: rhs)
}

/**
 Creates a `Where` clause by comparing if an expression is greater than or equal to a value
 ```
 let teensPet = CoreStore.fetchOne(From<Dog>().where((\.master ~ \.age) >= 10))
 ```
 */
public func >= <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V?) -> Where<D> {

    return Where<D>(expression: lhs, function: ">=", operand: rhs)
}


// MARK: - KeyPath where Root: NSManagedObject, Value: AllowedObjectiveCCollectionKeyPathValue

extension KeyPath where Root: NSManagedObject, Value: AllowedObjectiveCCollectionKeyPathValue {

    /**
     Creates a `Where.Expression` clause for COUNT
     ```
     let dogsWithPlaymates = CoreStore.fetchAll(From<Dog>().where((\.master ~ \.pets).count() > 1))
     ```
     */
    public func count() -> Where<Root>.Expression<Where<Root>.CollectionTarget, Int> {

        return .init(self.cs_keyPathString, "@count")
    }
}

// MARK: - Where.Expression where D: NSManagedObject, T == Where<D>.CollectionTarget, V: AllowedObjectiveCCollectionKeyPathValue

extension Where.Expression where D: NSManagedObject, T == Where<D>.CollectionTarget, V: AllowedObjectiveCCollectionKeyPathValue {

    /**
     Creates a `Where.Expression` clause for COUNT
     ```
     let dogsWithPlaymates = CoreStore.fetchAll(From<Dog>().where((\.master ~ \.pets).count() > 1))
     ```
     */
    public func count() -> Where<D>.Expression<T, Int> {

        return .init(self.cs_keyPathString, "@count")
    }
}


// MARK: - Where.Expression where D: NSManagedObject, T == Where<D>.CollectionTarget, V: AllowedObjectiveCKeyPathValue

extension Where.Expression where D: NSManagedObject, T == Where<D>.CollectionTarget, V: AllowedObjectiveCKeyPathValue {

    /**
     Creates a `Where.Expression` clause for ANY
     ```
     let dogsWithBadNamingSense = CoreStore.fetchAll(From<Dog>().where((\.master ~ \.pets ~ \.name).any() > "Spot"))
     ```
     */
    public func any() -> Where<D>.Expression<T, V> {

        return .init("ANY " + self.cs_keyPathString)
    }

    /**
     Creates a `Where.Expression` clause for ALL
     ```
     let allPlaymatePuppies = CoreStore.fetchAll(From<Dog>().where((\.master ~ \.pets ~ \.age).all() > 5))
     ```
     */
    public func all() -> Where<D>.Expression<T, V> {

        return .init("ALL " + self.cs_keyPathString)
    }

    /**
     Creates a `Where.Expression` clause for NONE
     ```
     let dogs = CoreStore.fetchAll(From<Dog>().where((\.master ~ \.pets ~ \.name).any() > "Spot"))
     ```
     */
    public func none() -> Where<D>.Expression<T, V> {

        return .init("NONE " + self.cs_keyPathString)
    }
}


// MARK: - KeyPath where Root: CoreStoreObject, Value: AllowedObjectiveCCollectionKeyPathValue

extension KeyPath where Root: CoreStoreObject, Value: AllowedCoreStoreObjectCollectionKeyPathValue {

    /**
     Creates a `Where.Expression` clause for COUNT
     ```
     let dogsWithPlaymates = CoreStore.fetchAll(From<Dog>().where((\.master ~ \.pets).count() > 1))
     ```
     */
    public func count() -> Where<Root>.Expression<Where<Root>.CollectionTarget, Int> {

        return .init(Root.meta[keyPath: self].cs_keyPathString, "@count")
    }
}


// MARK: - Where.Expression where D: CoreStoreObject, T == Where<D>.CollectionTarget

extension Where.Expression where D: CoreStoreObject, T == Where<D>.CollectionTarget {

    /**
     Creates a `Where.Expression` clause for COUNT
     ```
     let dogsWithPlaymates = CoreStore.fetchAll(From<Dog>().where((\.master ~ \.pets).count() > 1))
     ```
     */
    public func count() -> Where<D>.Expression<T, Int> {

        return .init(self.cs_keyPathString, "@count")
    }

    /**
     Creates a `Where.Expression` clause for ANY
     ```
     let dogsWithBadNamingSense = CoreStore.fetchAll(From<Dog>().where((\.master ~ \.pets ~ \.name).any() > "Spot"))
     ```
     */
    public func any() -> Where<D>.Expression<T, V> {

        return .init("ANY " + self.cs_keyPathString)
    }

    /**
     Creates a `Where.Expression` clause for ALL
     ```
     let allPlaymatePuppies = CoreStore.fetchAll(From<Dog>().where((\.master ~ \.pets ~ \.age).all() > 5))
     ```
     */
    public func all() -> Where<D>.Expression<T, V> {

        return .init("ALL " + self.cs_keyPathString)
    }

    /**
     Creates a `Where.Expression` clause for NONE
     ```
     let dogs = CoreStore.fetchAll(From<Dog>().where((\.master ~ \.pets ~ \.name).any() > "Spot"))
     ```
     */
    public func none() -> Where<D>.Expression<T, V> {

        return .init("NONE " + self.cs_keyPathString)
    }
}


// MARK: - Where

extension Where {

    // MARK: FilePrivate

    fileprivate init<T, V: QueryableAttributeType & Comparable>(expression: Where<D>.Expression<T, V>, function: String, operand: V) {

        self.init("\(expression.cs_keyPathString) \(function) %@", operand.cs_toQueryableNativeType())
    }

    fileprivate init<T, V: QueryableAttributeType & Comparable>(expression: Where<D>.Expression<T, V?>, function: String, operand: V) {

        self.init("\(expression.cs_keyPathString) \(function) %@", operand.cs_toQueryableNativeType())
    }

    fileprivate init<T, V: QueryableAttributeType & Comparable>(expression: Where<D>.Expression<T, V>, function: String, operand: V?) {

        if let operand = operand {

            self.init("\(expression.cs_keyPathString) \(function) %@", operand.cs_toQueryableNativeType())
        }
        else {

            self.init("\(expression.cs_keyPathString) \(function) nil")
        }
    }

    fileprivate init<T, V: QueryableAttributeType & Comparable>(expression: Where<D>.Expression<T, V?>, function: String, operand: V?) {

        if let operand = operand {

            self.init("\(expression.cs_keyPathString) \(function) %@", operand.cs_toQueryableNativeType())
        }
        else {

            self.init("\(expression.cs_keyPathString) \(function) nil")
        }
    }
}
