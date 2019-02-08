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

infix operator ~ : AdditionPrecedence


// MARK: - WhereExpressionTrait

public protocol WhereExpressionTrait {}


// MARK: - Where

extension Where {

    // MARK: - Expression

    public struct Expression<T: WhereExpressionTrait, V>: CustomStringConvertible, DynamicKeyPath {

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

    public enum SingleTarget: WhereExpressionTrait {}

    // MARK: - CollectionTarget

    public enum CollectionTarget: WhereExpressionTrait {}
}


// MARK: - ~ (Where.Expression Creation Operators)

// MARK: ~ where D: NSManagedObject

public func ~<D: NSManagedObject, O: NSManagedObject, V: AllowedObjectiveCKeyPathValue>(_ lhs: KeyPath<D, O>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<Where<D>.SingleTarget, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

public func ~<D: NSManagedObject, O: NSManagedObject, V: AllowedObjectiveCKeyPathValue>(_ lhs: KeyPath<D, O?>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<Where<D>.SingleTarget, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

public func ~<D: NSManagedObject, O: NSManagedObject, V: AllowedObjectiveCCollectionKeyPathValue>(_ lhs: KeyPath<D, O>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<Where<D>.CollectionTarget, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

public func ~<D: NSManagedObject, O: NSManagedObject, V: AllowedObjectiveCCollectionKeyPathValue>(_ lhs: KeyPath<D, O?>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<Where<D>.CollectionTarget, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

public func ~<D: NSManagedObject, O: NSManagedObject, T, V: AllowedObjectiveCKeyPathValue>(_ lhs: Where<D>.Expression<T, O>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<T, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

public func ~<D: NSManagedObject, O: NSManagedObject, T, V: AllowedObjectiveCCollectionKeyPathValue>(_ lhs: Where<D>.Expression<T, O>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<Where<D>.CollectionTarget, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

public func ~<D: NSManagedObject, O: NSManagedObject, T, V: AllowedObjectiveCKeyPathValue>(_ lhs: Where<D>.Expression<T, O?>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<T, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

public func ~<D: NSManagedObject, O: NSManagedObject, T, V: AllowedObjectiveCCollectionKeyPathValue>(_ lhs: Where<D>.Expression<T, O?>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<Where<D>.CollectionTarget, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}

public func ~<D: NSManagedObject, O: NSManagedObject, T, C: AllowedObjectiveCCollectionKeyPathValue, V: AllowedObjectiveCKeyPathValue>(_ lhs: Where<D>.Expression<T, C>, _ rhs: KeyPath<O, V>) -> Where<D>.Expression<Where<D>.CollectionTarget, V> {

    return .init(lhs.cs_keyPathString, rhs.cs_keyPathString)
}


// MARK: - ~ where D: CoreStoreObject

public func ~<D: CoreStoreObject, O: CoreStoreObject, K: AllowedCoreStoreObjectKeyPathValue>(_ lhs: KeyPath<D, RelationshipContainer<D>.ToOne<O>>, _ rhs: KeyPath<O, K>) -> Where<D>.Expression<Where<D>.SingleTarget, K.ValueType> where K.ObjectType == O {

    return .init(
        D.meta[keyPath: lhs].cs_keyPathString, 
        O.meta[keyPath: rhs].cs_keyPathString
    )
}

public func ~<D: CoreStoreObject, O: CoreStoreObject, K: AllowedCoreStoreObjectCollectionKeyPathValue>(_ lhs: KeyPath<D, RelationshipContainer<D>.ToOne<O>>, _ rhs: KeyPath<O, K>) -> Where<D>.Expression<Where<D>.CollectionTarget, K.ValueType> where K.ObjectType == O {

    return .init(
        D.meta[keyPath: lhs].cs_keyPathString,
        O.meta[keyPath: rhs].cs_keyPathString
    )
}

public func ~<D: CoreStoreObject, O: CoreStoreObject, T, K: AllowedCoreStoreObjectKeyPathValue>(_ lhs: Where<D>.Expression<T, O>, _ rhs: KeyPath<O, K>) -> Where<D>.Expression<T, K.ValueType> where K.ObjectType == O {

    return .init(
        lhs.cs_keyPathString,
        O.meta[keyPath: rhs].cs_keyPathString
    )
}

public func ~<D: CoreStoreObject, O: CoreStoreObject, T, K: AllowedCoreStoreObjectCollectionKeyPathValue>(_ lhs: Where<D>.Expression<T, O>, _ rhs: KeyPath<O, K>) -> Where<D>.Expression<Where<D>.CollectionTarget, K.ValueType> where K.ObjectType == O {

    return .init(
        lhs.cs_keyPathString,
        O.meta[keyPath: rhs].cs_keyPathString
    )
}

public func ~<D: CoreStoreObject, O: CoreStoreObject, T, K: AllowedCoreStoreObjectKeyPathValue>(_ lhs: Where<D>.Expression<T, O?>, _ rhs: KeyPath<O, K>) -> Where<D>.Expression<T, K.ValueType> where K.ObjectType == O {

    return .init(
        lhs.cs_keyPathString,
        O.meta[keyPath: rhs].cs_keyPathString
    )
}

public func ~<D: CoreStoreObject, O: CoreStoreObject, T, K: AllowedCoreStoreObjectCollectionKeyPathValue>(_ lhs: Where<D>.Expression<T, O?>, _ rhs: KeyPath<O, K>) -> Where<D>.Expression<Where<D>.CollectionTarget, K.ValueType> where K.ObjectType == O {

    return .init(
        lhs.cs_keyPathString,
        O.meta[keyPath: rhs].cs_keyPathString
    )
}

public func ~<D: CoreStoreObject, O: CoreStoreObject, T, KC: AllowedCoreStoreObjectCollectionKeyPathValue, KV: AllowedCoreStoreObjectKeyPathValue>(_ lhs: Where<D>.Expression<T, KC>, _ rhs: KeyPath<O, KV>) -> Where<D>.Expression<Where<D>.CollectionTarget, KV.ValueType> where KC.ObjectType == D, KV.ObjectType == O {

    return .init(
        lhs.cs_keyPathString,
        O.meta[keyPath: rhs].cs_keyPathString
    )
}


// MARK: - Where.Expression where V: QueryableAttributeType

public func == <D, T, V: QueryableAttributeType>(_ lhs: Where<D>.Expression<T, V>, _ rhs: V) -> Where<D> {

    return Where<D>(lhs.cs_keyPathString, isEqualTo: rhs)
}

public func != <D, T, V: QueryableAttributeType>(_ lhs: Where<D>.Expression<T, V>, _ rhs: V) -> Where<D> {

    return !Where<D>(lhs.cs_keyPathString, isEqualTo: rhs)
}

public func ~= <D, T, V: QueryableAttributeType, S: Sequence>(_ sequence: S, _ expression: Where<D>.Expression<T, V>) -> Where<D> where S.Iterator.Element == V {

    return Where<D>(expression.cs_keyPathString, isMemberOf: sequence)
}


// MARK: - Where.Expression where V: QueryableAttributeType & Comparable

public func < <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V>, _ rhs: V) -> Where<D> {

    return  Where<D>(expression: lhs, function: "<", operand: rhs)
}

public func <= <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V>, _ rhs: V) -> Where<D> {

    return  Where<D>(expression: lhs, function: "<=", operand: rhs)
}

public func > <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V>, _ rhs: V) -> Where<D> {

    return  Where<D>(expression: lhs, function: ">", operand: rhs)
}

public func >= <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V>, _ rhs: V) -> Where<D> {

    return  Where<D>(expression: lhs, function: ">=", operand: rhs)
}


// MARK: - Where.Expression where V: Optional<QueryableAttributeType>

public func == <D, T, V: QueryableAttributeType>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V) -> Where<D> {

    return Where<D>(lhs.cs_keyPathString, isEqualTo: rhs)
}

public func == <D, T, V: QueryableAttributeType>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V?) -> Where<D> {

    return Where<D>(lhs.cs_keyPathString, isEqualTo: rhs)
}

public func != <D, T, V: QueryableAttributeType>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V) -> Where<D> {

    return !Where<D>(lhs.cs_keyPathString, isEqualTo: rhs)
}

public func != <D, T, V: QueryableAttributeType>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V?) -> Where<D> {

    return !Where<D>(lhs.cs_keyPathString, isEqualTo: rhs)
}

public func ~= <D, T, V: QueryableAttributeType, S: Sequence>(_ sequence: S, _ expression: Where<D>.Expression<T, V?>) -> Where<D> where S.Iterator.Element == V {

    return Where<D>(expression.cs_keyPathString, isMemberOf: sequence)
}


// MARK: - Where.Expression where V: Optional<QueryableAttributeType & Comparable>

public func < <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V) -> Where<D> {

    return Where<D>(expression: lhs, function: "<", operand: rhs)
}

public func <= <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V?) -> Where<D> {

    return Where<D>(expression: lhs, function: "<=", operand: rhs)
}

public func > <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V) -> Where<D> {

    return Where<D>(expression: lhs, function: ">", operand: rhs)
}

public func >= <D, T, V: QueryableAttributeType & Comparable>(_ lhs: Where<D>.Expression<T, V?>, _ rhs: V?) -> Where<D> {

    return Where<D>(expression: lhs, function: ">=", operand: rhs)
}


// MARK: - KeyPath where Root: NSManagedObject, Value: AllowedObjectiveCCollectionKeyPathValue

extension KeyPath where Root: NSManagedObject, Value: AllowedObjectiveCCollectionKeyPathValue {

    public func count() -> Where<Root>.Expression<Where<Root>.CollectionTarget, Int> {

        return .init(self.cs_keyPathString, "@count")
    }
}

// MARK: - Where.Expression where D: NSManagedObject, T == Where<D>.CollectionTarget, V: AllowedObjectiveCCollectionKeyPathValue

extension Where.Expression where D: NSManagedObject, T == Where<D>.CollectionTarget, V: AllowedObjectiveCCollectionKeyPathValue {

    public func count() -> Where<D>.Expression<T, Int> {

        return .init(self.cs_keyPathString, "@count")
    }
}


// MARK: - Where.Expression where D: NSManagedObject, T == Where<D>.CollectionTarget, V: AllowedObjectiveCKeyPathValue

extension Where.Expression where D: NSManagedObject, T == Where<D>.CollectionTarget, V: AllowedObjectiveCKeyPathValue {

    public func any() -> Where<D>.Expression<T, V> {

        return .init("ANY " + self.cs_keyPathString)
    }

    public func all() -> Where<D>.Expression<T, V> {

        return .init("ALL " + self.cs_keyPathString)
    }

    public func none() -> Where<D>.Expression<T, V> {

        return .init("NONE " + self.cs_keyPathString)
    }
}


// MARK: - KeyPath where Root: CoreStoreObject, Value: AllowedObjectiveCCollectionKeyPathValue

extension KeyPath where Root: CoreStoreObject, Value: AllowedCoreStoreObjectCollectionKeyPathValue {

    public func count() -> Where<Root>.Expression<Where<Root>.CollectionTarget, Int> {

        return .init(Root.meta[keyPath: self].cs_keyPathString, "@count")
    }
}


// MARK: - Where.Expression where D: CoreStoreObject, T == Where<D>.CollectionTarget

extension Where.Expression where D: CoreStoreObject, T == Where<D>.CollectionTarget {

    public func count() -> Where<D>.Expression<T, Int> {

        return .init(self.cs_keyPathString, "@count")
    }

    public func any() -> Where<D>.Expression<T, V> {

        return .init("ANY " + self.cs_keyPathString)
    }

    public func all() -> Where<D>.Expression<T, V> {

        return .init("ALL " + self.cs_keyPathString)
    }

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
