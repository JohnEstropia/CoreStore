//
//  Select.swift
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
import CoreGraphics
import CoreData


// MARK: - SelectResultType

/**
 The `SelectResultType` protocol is implemented by return types supported by the `Select` clause.
 */
public protocol SelectResultType {}


// MARK: - SelectAttributesResultType

/**
 The `SelectAttributesResultType` protocol is implemented by return types supported by the `queryAttributes(...)` methods.
 */
public protocol SelectAttributesResultType: SelectResultType {
    
    static func cs_fromQueryResultsNativeType(_ result: [Any]) -> [[String: Any]]
}


// MARK: - SelectTerm

/**
 The `SelectTerm` is passed to the `Select` clause to indicate the attributes/aggregate keys to be queried.
 */
public enum SelectTerm<D: DynamicObject>: ExpressibleByStringLiteral, Hashable {
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying an entity attribute. A shorter way to do the same is to assign from the string keypath directly:
     ```
     let fullName = CoreStore.queryValue(
         From<MyPersonEntity>(),
         Select<String>(.attribute("fullName")),
         Where("employeeID", isEqualTo: 1111)
     )
     ```
     is equivalent to:
     ```
     let fullName = CoreStore.queryValue(
         From<MyPersonEntity>(),
         Select<String>("fullName"),
         Where("employeeID", isEqualTo: 1111)
     )
     ```
     - parameter keyPath: the attribute name
     - returns: a `SelectTerm` to a `Select` clause for querying an entity attribute
     */
    public static func attribute(_ keyPath: KeyPathString) -> SelectTerm<D> {
        
        return ._attribute(keyPath)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the average value of an attribute.
     ```
     let averageAge = CoreStore.queryValue(
         From<MyPersonEntity>(),
         Select<Int>(.average("age"))
     )
     ```
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "average(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the average value of an attribute
     */
    public static func average(_ keyPath: KeyPathString, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return ._aggregate(
            function: "average:",
            keyPath: keyPath,
            alias: alias ?? "average(\(keyPath))",
            nativeType: .decimalAttributeType
        )
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for a count query.
     ```
     let numberOfEmployees = CoreStore.queryValue(
         From<MyPersonEntity>(),
         Select<Int>(.count("employeeID"))
     )
     ```
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "count(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for a count query
     */
    public static func count(_ keyPath: KeyPathString, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return ._aggregate(
            function: "count:",
            keyPath: keyPath,
            alias: alias ?? "count(\(keyPath))",
            nativeType: .integer64AttributeType
        )
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the maximum value for an attribute.
     ```
     let maximumAge = CoreStore.queryValue(
         From<MyPersonEntity>(),
         Select<Int>(.maximum("age"))
     )
     ```
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "max(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the maximum value for an attribute
     */
    public static func maximum(_ keyPath: KeyPathString, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return ._aggregate(
            function: "max:",
            keyPath: keyPath,
            alias: alias ?? "max(\(keyPath))",
            nativeType: .undefinedAttributeType
        )
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the minimum value for an attribute.
     ```
     let minimumAge = CoreStore.queryValue(
         From<MyPersonEntity>(),
         Select<Int>(.minimum("age"))
     )
     ```
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "min(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the minimum value for an attribute
     */
    public static func minimum(_ keyPath: KeyPathString, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return ._aggregate(
            function: "min:",
            keyPath: keyPath,
            alias: alias ?? "min(\(keyPath))",
            nativeType: .undefinedAttributeType
        )
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the sum value for an attribute.
     ```
     let totalAge = CoreStore.queryValue(
         From<MyPersonEntity>(),
         Select<Int>(.sum("age"))
     )
     ```
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "sum(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the sum value for an attribute
     */
    public static func sum(_ keyPath: KeyPathString, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return ._aggregate(
            function: "sum:",
            keyPath: keyPath,
            alias: alias ?? "sum(\(keyPath))",
            nativeType: .decimalAttributeType
        )
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the `NSManagedObjectID`.
     ```
     let objectID = CoreStore.queryValue(
         From<MyPersonEntity>(),
         Select<NSManagedObjectID>(),
         Where("employeeID", isEqualTo: 1111)
     )
     ```
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "objecID" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the sum value for an attribute
     */
    public static func objectID(as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return ._identity(
            alias: alias ?? "objectID",
            nativeType: .objectIDAttributeType
        )
    }
    
    
    // MARK: ExpressibleByStringLiteral
    
    public init(stringLiteral value: KeyPathString) {
        
        self = ._attribute(value)
    }
    
    public init(unicodeScalarLiteral value: KeyPathString) {
        
        self = ._attribute(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: KeyPathString) {
        
        self = ._attribute(value)
    }
    
    
    // MARK: Equatable
    
    public static func == (lhs: SelectTerm<D>, rhs: SelectTerm<D>) -> Bool {
        
        switch (lhs, rhs) {
            
        case (._attribute(let keyPath1), ._attribute(let keyPath2)):
            return keyPath1 == keyPath2
            
        case (._aggregate(let function1, let keyPath1, let alias1, let nativeType1),
              ._aggregate(let function2, let keyPath2, let alias2, let nativeType2)):
            return function1 == function2
                && keyPath1 == keyPath2
                && alias1 == alias2
                && nativeType1 == nativeType2
            
        case (._identity(let alias1, let nativeType1), ._identity(let alias2, let nativeType2)):
            return alias1 == alias2 && nativeType1 == nativeType2
            
        case (._attribute, _),
             (._aggregate, _),
             (._identity, _):
            return false
        }
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        switch self {
            
        case ._attribute(let keyPath):
            return 0 ^ keyPath.hashValue
            
        case ._aggregate(let function, let keyPath, let alias, let nativeType):
            return 1 ^ function.hashValue ^ keyPath.hashValue ^ alias.hashValue ^ nativeType.hashValue
            
        case ._identity(let alias, let nativeType):
            return 3 ^ alias.hashValue ^ nativeType.hashValue
        }
    }
    
    
    // MARK: Internal
    
    case _attribute(KeyPathString)
    case _aggregate(function: String, keyPath: KeyPathString, alias: String, nativeType: NSAttributeType)
    case _identity(alias: String, nativeType: NSAttributeType)
    
    internal var keyPathString: String {
        
        switch self {
            
        case ._attribute(let keyPath):          return keyPath
        case ._aggregate(_, _, let alias, _):   return alias
        case ._identity(let alias, _):          return alias
        }
    }
}

extension SelectTerm where D: NSManagedObject {
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying an entity attribute.
     - parameter keyPath: the attribute name
     - returns: a `SelectTerm` to a `Select` clause for querying an entity attribute
     */
    public static func attribute<V>(_ keyPath: KeyPath<D, V>) -> SelectTerm<D> {
        
        return self.attribute(keyPath._kvcKeyPathString!)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the average value of an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "average(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the average value of an attribute
     */
    public static func average<V>(_ keyPath: KeyPath<D, V>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.average(keyPath._kvcKeyPathString!, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for a count query.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "count(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for a count query
     */
    public static func count<V>(_ keyPath: KeyPath<D, V>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.count(keyPath._kvcKeyPathString!, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the maximum value for an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "max(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the maximum value for an attribute
     */
    public static func maximum<V>(_ keyPath: KeyPath<D, V>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.maximum(keyPath._kvcKeyPathString!, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the minimum value for an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "min(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the minimum value for an attribute
     */
    public static func minimum<V>(_ keyPath: KeyPath<D, V>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.minimum(keyPath._kvcKeyPathString!, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the sum value for an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "sum(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the sum value for an attribute
     */
    public static func sum<V>(_ keyPath: KeyPath<D, V>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.sum(keyPath._kvcKeyPathString!, as: alias)
    }
}

extension SelectTerm where D: CoreStoreObject {
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying an entity attribute.
     - parameter keyPath: the attribute name
     - returns: a `SelectTerm` to a `Select` clause for querying an entity attribute
     */
    public static func attribute<V>(_ keyPath: KeyPath<D, ValueContainer<D>.Required<V>>) -> SelectTerm<D> {
        
        return self.attribute(D.meta[keyPath: keyPath].keyPath)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying an entity attribute.
     - parameter keyPath: the attribute name
     - returns: a `SelectTerm` to a `Select` clause for querying an entity attribute
     */
    public static func attribute<V>(_ keyPath: KeyPath<D, ValueContainer<D>.Optional<V>>) -> SelectTerm<D> {
        
        return self.attribute(D.meta[keyPath: keyPath].keyPath)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying an entity attribute.
     - parameter keyPath: the attribute name
     - returns: a `SelectTerm` to a `Select` clause for querying an entity attribute
     */
    public static func attribute<V>(_ keyPath: KeyPath<D, TransformableContainer<D>.Required<V>>) -> SelectTerm<D> {
        
        return self.attribute(D.meta[keyPath: keyPath].keyPath)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying an entity attribute.
     - parameter keyPath: the attribute name
     - returns: a `SelectTerm` to a `Select` clause for querying an entity attribute
     */
    public static func attribute<V>(_ keyPath: KeyPath<D, TransformableContainer<D>.Optional<V>>) -> SelectTerm<D> {
        
        return self.attribute(D.meta[keyPath: keyPath].keyPath)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the average value of an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "average(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the average value of an attribute
     */
    public static func average<V>(_ keyPath: KeyPath<D, ValueContainer<D>.Required<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.average(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the average value of an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "average(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the average value of an attribute
     */
    public static func average<V>(_ keyPath: KeyPath<D, ValueContainer<D>.Optional<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.average(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the average value of an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "average(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the average value of an attribute
     */
    public static func average<V>(_ keyPath: KeyPath<D, TransformableContainer<D>.Required<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.average(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the average value of an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "average(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the average value of an attribute
     */
    public static func average<V>(_ keyPath: KeyPath<D, TransformableContainer<D>.Optional<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.average(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for a count query.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "count(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for a count query
     */
    public static func count<V>(_ keyPath: KeyPath<D,
        ValueContainer<D>.Required<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.count(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for a count query.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "count(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for a count query
     */
    public static func count<V>(_ keyPath: KeyPath<D,
        ValueContainer<D>.Optional<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.count(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for a count query.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "count(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for a count query
     */
    public static func count<V>(_ keyPath: KeyPath<D,
        TransformableContainer<D>.Required<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.count(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for a count query.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "count(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for a count query
     */
    public static func count<V>(_ keyPath: KeyPath<D,
        TransformableContainer<D>.Optional<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.count(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the maximum value for an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "max(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the maximum value for an attribute
     */
    public static func maximum<V>(_ keyPath: KeyPath<D,
        ValueContainer<D>.Required<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.maximum(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the maximum value for an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "max(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the maximum value for an attribute
     */
    public static func maximum<V>(_ keyPath: KeyPath<D,
        ValueContainer<D>.Optional<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.maximum(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the maximum value for an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "max(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the maximum value for an attribute
     */
    public static func maximum<V>(_ keyPath: KeyPath<D,
        TransformableContainer<D>.Required<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.maximum(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the maximum value for an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "max(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the maximum value for an attribute
     */
    public static func maximum<V>(_ keyPath: KeyPath<D,
        TransformableContainer<D>.Optional<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.maximum(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the minimum value for an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "min(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the minimum value for an attribute
     */
    public static func minimum<V>(_ keyPath: KeyPath<D, ValueContainer<D>.Required<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.minimum(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the minimum value for an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "min(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the minimum value for an attribute
     */
    public static func minimum<V>(_ keyPath: KeyPath<D, ValueContainer<D>.Optional<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.minimum(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the minimum value for an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "min(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the minimum value for an attribute
     */
    public static func minimum<V>(_ keyPath: KeyPath<D, TransformableContainer<D>.Required<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.minimum(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the minimum value for an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "min(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the minimum value for an attribute
     */
    public static func minimum<V>(_ keyPath: KeyPath<D, TransformableContainer<D>.Optional<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.minimum(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the sum value for an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "sum(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the sum value for an attribute
     */
    public static func sum<V>(_ keyPath: KeyPath<D, ValueContainer<D>.Required<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.sum(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the sum value for an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "sum(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the sum value for an attribute
     */
    public static func sum<V>(_ keyPath: KeyPath<D, ValueContainer<D>.Optional<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.sum(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the sum value for an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "sum(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the sum value for an attribute
     */
    public static func sum<V>(_ keyPath: KeyPath<D, TransformableContainer<D>.Required<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.sum(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the sum value for an attribute.
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "sum(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the sum value for an attribute
     */
    public static func sum<V>(_ keyPath: KeyPath<D, TransformableContainer<D>.Optional<V>>, as alias: KeyPathString? = nil) -> SelectTerm<D> {
        
        return self.sum(D.meta[keyPath: keyPath].keyPath, as: alias)
    }
}


// MARK: - Select

/**
 The `Select` clause indicates the attribute / aggregate value to be queried. The generic type is a `SelectResultType`, and will be used as the return type for the query.
 
 You can bind the return type by specializing the initializer:
 ```
 let maximumAge = CoreStore.queryValue(
     From<MyPersonEntity>(),
     Select<Int>(.maximum("age"))
 )
 ```
 or by casting the type of the return value:
 ```
 let maximumAge: Int = CoreStore.queryValue(
     From<MyPersonEntity>(),
     Select(.maximum("age"))
 )
 ```
 Valid return types depend on the query:
 
 - for `queryValue(...)` methods:
     - all types that conform to `QueryableAttributeType` protocol
 - for `queryAttributes(...)` methods:
     - `NSDictionary`
 
 - parameter sortDescriptors: a series of `NSSortDescriptor`s
 */
public struct Select<D: DynamicObject, T: SelectResultType>: SelectClause, Hashable {
    
    /**
     Initializes a `Select` clause with a list of `SelectTerm`s
     
     - parameter selectTerm: a `SelectTerm`
     - parameter selectTerms: a series of `SelectTerm`s
     */
    public init(_ selectTerm: SelectTerm<D>, _ selectTerms: SelectTerm<D>...) {
        
        self.selectTerms = [selectTerm] + selectTerms
    }
    
    /**
     Initializes a `Select` clause with a list of `SelectTerm`s
     
     - parameter selectTerms: a series of `SelectTerm`s
     */
    public init(_ selectTerms: [SelectTerm<D>]) {
        
        self.selectTerms = selectTerms
    }
    
    
    // MARK: Equatable
    
    public static func == <T, U>(lhs: Select<D, T>, rhs: Select<D, U>) -> Bool {
        
        return lhs.selectTerms == rhs.selectTerms
    }
    
    
    // MARK: SelectClause
    
    public typealias ObjectType = D
    public typealias ReturnType = T
    
    public let selectTerms: [SelectTerm<D>]
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        return self.selectTerms.map { $0.hashValue }.reduce(0, ^)
    }
    
    
    // MARK: Internal
    
    internal func applyToFetchRequest(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        
        fetchRequest.includesPendingChanges = false
        fetchRequest.resultType = .dictionaryResultType
        
        func attributeDescription(for keyPath: String, in entity: NSEntityDescription) -> NSAttributeDescription? {
            
            let components = keyPath.components(separatedBy: ".")
            switch components.count {
                
            case 0:
                return nil
                
            case 1:
                return entity.attributesByName[components[0]]
                
            default:
                guard let relationship = entity.relationshipsByName[components[0]],
                    let destinationEntity = relationship.destinationEntity else {
                        
                        return nil
                }
                return attributeDescription(
                    for: components.dropFirst().joined(separator: "."),
                    in: destinationEntity
                )
            }
        }
        
        var propertiesToFetch = [Any]()
        for term in self.selectTerms {
            
            switch term {
                
            case ._attribute(let keyPath):
                propertiesToFetch.append(keyPath)
                
            case ._aggregate(let function, let keyPath, let alias, let nativeType):
                let entityDescription = fetchRequest.entity!
                if let attributeDescription = attributeDescription(for: keyPath, in: entityDescription) {
                    
                    let expressionDescription = NSExpressionDescription()
                    expressionDescription.name = alias
                    if nativeType == .undefinedAttributeType {
                        
                        expressionDescription.expressionResultType = attributeDescription.attributeType
                    }
                    else {
                        
                        expressionDescription.expressionResultType = nativeType
                    }
                    expressionDescription.expression = NSExpression(
                        forFunction: function,
                        arguments: [NSExpression(forKeyPath: keyPath)]
                    )
                    propertiesToFetch.append(expressionDescription)
                }
                else {
                    
                    CoreStore.log(
                        .warning,
                        message: "The key path \"\(keyPath)\" could not be resolved in entity \(cs_typeName(entityDescription.managedObjectClassName)) as an attribute and will be ignored by \(cs_typeName(self)) query clause."
                    )
                }
                
            case ._identity(let alias, let nativeType):
                let expressionDescription = NSExpressionDescription()
                expressionDescription.name = alias
                if nativeType == .undefinedAttributeType {
                    
                    expressionDescription.expressionResultType = .objectIDAttributeType
                }
                else {
                    
                    expressionDescription.expressionResultType = nativeType
                }
                expressionDescription.expression = NSExpression.expressionForEvaluatedObject()
                
                propertiesToFetch.append(expressionDescription)
            }
        }
        
        fetchRequest.propertiesToFetch = propertiesToFetch
    }
}

public extension Select where T: NSManagedObjectID {
    
    /**
     Initializes a `Select` that queries for `NSManagedObjectID` results
     */
    public init() {
        
        self.init(.objectID())
    }
}

public extension Select where D: NSManagedObject {
    
    /**
     Initializes a `Select` that queries the value of an attribute pertained by a keyPath
     - parameter keyPath: the keyPath for the attribute
     */
    public init(_ keyPath: KeyPath<D, T>) {
        
        self.init(.attribute(keyPath))
    }
}

public extension Select where D: CoreStoreObject, T: ImportableAttributeType {
    
    /**
     Initializes a `Select` that queries the value of an attribute pertained by a keyPath
     - parameter keyPath: the keyPath for the attribute
     */
    public init(_ keyPath: KeyPath<D, ValueContainer<D>.Required<T>>) {
        
        self.init(.attribute(keyPath))
    }
    
    /**
     Initializes a `Select` that queries the value of an attribute pertained by a keyPath
     - parameter keyPath: the keyPath for the attribute
     */
    public init(_ keyPath: KeyPath<D, ValueContainer<D>.Optional<T>>) {
        
        self.init(.attribute(keyPath))
    }
}

public extension Select where D: CoreStoreObject, T: ImportableAttributeType & NSCoding & NSCopying {
    
    /**
     Initializes a `Select` that queries the value of an attribute pertained by a keyPath
     - parameter keyPath: the keyPath for the attribute
     */
    public init(_ keyPath: KeyPath<D, TransformableContainer<D>.Required<T>>) {
        
        self.init(.attribute(keyPath))
    }
    
    /**
     Initializes a `Select` that queries the value of an attribute pertained by a keyPath
     - parameter keyPath: the keyPath for the attribute
     */
    public init(_ keyPath: KeyPath<D, TransformableContainer<D>.Optional<T>>) {
        
        self.init(.attribute(keyPath))
    }
}


// MARK: - SelectClause

/**
 Abstracts the `Select` clause for protocol utilities.
 */
public protocol SelectClause {
    
    /**
     The `DynamicObject` type associated with the clause
     */
    associatedtype ObjectType: DynamicObject
    
    /**
     The `SelectResultType` type associated with the clause
     */
    associatedtype ReturnType: SelectResultType
    
    /**
     The `SelectTerm`s for the query
     */
    var selectTerms: [SelectTerm<ObjectType>] { get }
}


// MARK: - NSDictionary: SelectAttributesResultType

extension NSDictionary: SelectAttributesResultType {
    
    // MARK: SelectAttributesResultType
    
    public static func cs_fromQueryResultsNativeType(_ result: [Any]) -> [[String : Any]] {
        
        return result as! [[String: Any]]
    }
}
