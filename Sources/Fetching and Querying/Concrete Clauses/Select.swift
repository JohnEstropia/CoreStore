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
import CoreData


// MARK: - SelectResultType

/**
 The `SelectResultType` protocol is implemented by return types supported by the `Select` clause.
 */
public protocol SelectResultType {}


// MARK: - SelectValueResultType

/**
 The `SelectValueResultType` protocol is implemented by return types supported by the `queryValue(...)` methods.
 */
public protocol SelectValueResultType: SelectResultType {
    
    static var attributeType: NSAttributeType { get }
    
    static func fromResultObject(result: AnyObject) -> Self?
}


// MARK: - SelectAttributesResultType

/**
 The `SelectValueResultType` protocol is implemented by return types supported by the `queryAttributes(...)` methods.
 */
public protocol SelectAttributesResultType: SelectResultType {
    
    static func fromResultObjects(result: [AnyObject]) -> [[NSString: AnyObject]]
}


// MARK: - SelectTerm

/**
 The `SelectTerm` is passed to the `Select` clause to indicate the attributes/aggregate keys to be queried.
 */
public enum SelectTerm: StringLiteralConvertible, Hashable {
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying an entity attribute. A shorter way to do the same is to assign from the string keypath directly:
     ```
     let fullName = CoreStore.queryValue(
         From(MyPersonEntity),
         Select<String>(.Attribute("fullName")),
         Where("employeeID", isEqualTo: 1111)
     )
     ```
     is equivalent to:
     ```
     let fullName = CoreStore.queryValue(
         From(MyPersonEntity),
         Select<String>("fullName"),
         Where("employeeID", isEqualTo: 1111)
     )
     ```
     
     - parameter keyPath: the attribute name
     - returns: a `SelectTerm` to a `Select` clause for querying an entity attribute
     */
    public static func Attribute(keyPath: KeyPath) -> SelectTerm {
        
        return ._Attribute(keyPath)
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the average value of an attribute.
     ```
     let averageAge = CoreStore.queryValue(
         From(MyPersonEntity),
         Select<Int>(.Average("age"))
     )
     ```
     
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "average(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the average value of an attribute
     */
    public static func Average(keyPath: KeyPath, As alias: KeyPath? = nil) -> SelectTerm {
        
        return ._Aggregate(
            function: "average:",
            keyPath: keyPath,
            alias: alias ?? "average(\(keyPath))",
            nativeType: .DecimalAttributeType
        )
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for a count query.
     ```
     let numberOfEmployees = CoreStore.queryValue(
         From(MyPersonEntity),
         Select<Int>(.Count("employeeID"))
     )
     ```
     
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "count(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for a count query
     */
    public static func Count(keyPath: KeyPath, As alias: KeyPath? = nil) -> SelectTerm {
        
        return ._Aggregate(
            function: "count:",
            keyPath: keyPath,
            alias: alias ?? "count(\(keyPath))",
            nativeType: .Integer64AttributeType
        )
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the maximum value for an attribute.
     ```
     let maximumAge = CoreStore.queryValue(
         From(MyPersonEntity),
         Select<Int>(.Maximum("age"))
     )
     ```
     
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "max(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the maximum value for an attribute
     */
    public static func Maximum(keyPath: KeyPath, As alias: KeyPath? = nil) -> SelectTerm {
        
        return ._Aggregate(
            function: "max:",
            keyPath: keyPath,
            alias: alias ?? "max(\(keyPath))",
            nativeType: .UndefinedAttributeType
        )
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the minimum value for an attribute.
     ```
     let minimumAge = CoreStore.queryValue(
         From(MyPersonEntity),
         Select<Int>(.Minimum("age"))
     )
     ```
     
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "min(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the minimum value for an attribute
     */
    public static func Minimum(keyPath: KeyPath, As alias: KeyPath? = nil) -> SelectTerm {
        
        return ._Aggregate(
            function: "min:",
            keyPath: keyPath,
            alias: alias ?? "min(\(keyPath))",
            nativeType: .UndefinedAttributeType
        )
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the sum value for an attribute.
     ```
     let totalAge = CoreStore.queryValue(
         From(MyPersonEntity),
         Select<Int>(.Sum("age"))
     )
     ```
     
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "sum(<attributeName>)" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the sum value for an attribute
     */
    public static func Sum(keyPath: KeyPath, As alias: KeyPath? = nil) -> SelectTerm {
        
        return ._Aggregate(
            function: "sum:",
            keyPath: keyPath,
            alias: alias ?? "sum(\(keyPath))",
            nativeType: .DecimalAttributeType
        )
    }
    
    /**
     Provides a `SelectTerm` to a `Select` clause for querying the `NSManagedObjectID`.
     ```
     let objectID = CoreStore.queryValue(
         From(MyPersonEntity),
         Select<NSManagedObjectID>(),
         Where("employeeID", isEqualTo: 1111)
     )
     ```
     
     - parameter keyPath: the attribute name
     - parameter alias: the dictionary key to use to access the result. Ignored when the query return value is not an `NSDictionary`. If `nil`, the default key "objecID" is used
     - returns: a `SelectTerm` to a `Select` clause for querying the sum value for an attribute
     */
    public static func ObjectID(As alias: KeyPath? = nil) -> SelectTerm {
        
        return ._Identity(
            alias: alias ?? "objectID",
            nativeType: .ObjectIDAttributeType
        )
    }
    
    
    // MARK: StringLiteralConvertible
    
    public init(stringLiteral value: KeyPath) {
        
        self = ._Attribute(value)
    }
    
    public init(unicodeScalarLiteral value: KeyPath) {
        
        self = ._Attribute(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: KeyPath) {
        
        self = ._Attribute(value)
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        switch self {
            
        case ._Attribute(let keyPath):
            return 0 ^ keyPath.hashValue
            
        case ._Aggregate(let function, let keyPath, let alias, let nativeType):
            return 1 ^ function.hashValue ^ keyPath.hashValue ^ alias.hashValue ^ nativeType.hashValue
            
        case ._Identity(let alias, let nativeType):
            return 3 ^ alias.hashValue ^ nativeType.hashValue
        }
    }
    
    
    // MARK: Internal
    
    case _Attribute(KeyPath)
    case _Aggregate(function: String, keyPath: KeyPath, alias: String, nativeType: NSAttributeType)
    case _Identity(alias: String, nativeType: NSAttributeType)
}


// MARK: - SelectTerm: Equatable

@warn_unused_result
public func == (lhs: SelectTerm, rhs: SelectTerm) -> Bool {
    
    switch (lhs, rhs) {
        
    case (._Attribute(let keyPath1), ._Attribute(let keyPath2)):
        return keyPath1 == keyPath2
        
    case (._Aggregate(let function1, let keyPath1, let alias1, let nativeType1),
        ._Aggregate(let function2, let keyPath2, let alias2, let nativeType2)):
        return function1 == function2
            && keyPath1 == keyPath2
            && alias1 == alias2
            && nativeType1 == nativeType2
        
    case (._Identity(let alias1, let nativeType1), ._Identity(let alias2, let nativeType2)):
        return alias1 == alias2 && nativeType1 == nativeType2
        
    default:
        return false
    }
}


// MARK: - Select

/**
 The `Select` clause indicates the attribute / aggregate value to be queried. The generic type is a `SelectResultType`, and will be used as the return type for the query.
 
 You can bind the return type by specializing the initializer:
 ```
 let maximumAge = CoreStore.queryValue(
     From(MyPersonEntity),
     Select<Int>(.Maximum("age"))
 )
 ```
 or by casting the type of the return value:
 ```
 let maximumAge: Int = CoreStore.queryValue(
     From(MyPersonEntity),
     Select(.Maximum("age"))
 )
 ```
 Valid return types depend on the query:
 
 - for `queryValue(...)` methods:
     - `Bool`
     - `Int8`
     - `Int16`
     - `Int32`
     - `Int64`
     - `Double`
     - `Float`
     - `String`
     - `NSNumber`
     - `NSString`
     - `NSDecimalNumber`
     - `NSDate`
     - `NSData`
     - `NSManagedObjectID`
     - `NSString`
 - for `queryAttributes(...)` methods:
     - `NSDictionary`
 
 - parameter sortDescriptors: a series of `NSSortDescriptor`s
 */
public struct Select<T: SelectResultType>: Hashable {
    
    /**
     The `SelectResultType` type for the query's return value
     */
    public typealias ReturnType = T
    
    /**
     Initializes a `Select` clause with a list of `SelectTerm`s
     
     - parameter selectTerm: a `SelectTerm`
     - parameter selectTerms: a series of `SelectTerm`s
     */
    public init(_ selectTerm: SelectTerm, _ selectTerms: SelectTerm...) {
        
        self.selectTerms = [selectTerm] + selectTerms
    }
    
    /**
     Initializes a `Select` clause with a list of `SelectTerm`s
     
     - parameter selectTerms: a series of `SelectTerm`s
     */
    public init(_ selectTerms: [SelectTerm]) {
        
        self.selectTerms = selectTerms
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        return self.selectTerms.map { $0.hashValue }.reduce(0, combine: ^)
    }
    
    
    // MARK: Internal
    
    internal let selectTerms: [SelectTerm]
}

public extension Select where T: NSManagedObjectID {
    
    public init() {
        
        self.init(.ObjectID())
    }
}


// MARK: - Select: Equatable

@warn_unused_result
public func == <T: SelectResultType, U: SelectResultType>(lhs: Select<T>, rhs: Select<U>) -> Bool {
    
    return lhs.selectTerms == rhs.selectTerms
}


// MARK: - Bool: SelectValueResultType

extension Bool: SelectValueResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .BooleanAttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Bool? {
        switch result {
            
        case let decimal as NSDecimalNumber:
            // iOS: NSDecimalNumber(string: "0.5").boolValue // true
            // OSX: NSDecimalNumber(string: "0.5").boolValue // false
            return NSNumber(double: decimal.doubleValue).boolValue
            
        case let number as NSNumber:
            return number.boolValue
            
        default:
            return nil
        }
    }
}


// MARK: - Int8: SelectValueResultType

extension Int8: SelectValueResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Int8? {
        
        guard let value = (result as? NSNumber)?.longLongValue else {
            
            return nil
        }
        return numericCast(value) as Int8
    }
}


// MARK: - Int16: SelectValueResultType

extension Int16: SelectValueResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Int16? {
        
        guard let value = (result as? NSNumber)?.longLongValue else {
            
            return nil
        }
        return numericCast(value) as Int16
    }
}


// MARK: - Int32: SelectValueResultType

extension Int32: SelectValueResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Int32? {
        
        guard let value = (result as? NSNumber)?.longLongValue else {
            
            return nil
        }
        return numericCast(value) as Int32
    }
}


// MARK: - Int64: SelectValueResultType

extension Int64: SelectValueResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Int64? {
        
        return (result as? NSNumber)?.longLongValue
    }
}


// MARK: - Int: SelectValueResultType

extension Int: SelectValueResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Int? {
        
        guard let value = (result as? NSNumber)?.longLongValue else {
            
            return nil
        }
        return numericCast(value) as Int
    }
}


// MARK: - Double : SelectValueResultType

extension Double: SelectValueResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .DoubleAttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Double? {
        
        return (result as? NSNumber)?.doubleValue
    }
}


// MARK: - Float: SelectValueResultType

extension Float: SelectValueResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .FloatAttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Float? {
        
        return (result as? NSNumber)?.floatValue
    }
}


// MARK: - String: SelectValueResultType

extension String: SelectValueResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .StringAttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> String? {
        
        return result as? NSString as? String
    }
}


// MARK: - NSNumber: SelectValueResultType

extension NSNumber: SelectValueResultType {
    
    public class var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public class func fromResultObject(result: AnyObject) -> Self? {
        
        func forceCast<T: NSNumber>(object: AnyObject) -> T? {
            
            return (object as? T)
        }
        return forceCast(result)
    }
}


// MARK: - NSString: SelectValueResultType

extension NSString: SelectValueResultType {
    
    public class var attributeType: NSAttributeType {
        
        return .StringAttributeType
    }
    
    public class func fromResultObject(result: AnyObject) -> Self? {
        
        func forceCast<T: NSString>(object: AnyObject) -> T? {
            
            return (object as? T)
        }
        return forceCast(result)
    }
}


// MARK: - NSDecimalNumber: SelectValueResultType

extension NSDecimalNumber {
    
    public override class var attributeType: NSAttributeType {
        
        return .DecimalAttributeType
    }
    
    public override class func fromResultObject(result: AnyObject) -> Self? {
        
        func forceCast<T: NSDecimalNumber>(object: AnyObject) -> T? {
            
            return (object as? T)
        }
        return forceCast(result)
    }
}


// MARK: - NSDate: SelectValueResultType

extension NSDate: SelectValueResultType {
    
    public class var attributeType: NSAttributeType {
        
        return .DateAttributeType
    }
    
    public class func fromResultObject(result: AnyObject) -> Self? {
        
        func forceCast<T: NSDate>(object: AnyObject) -> T? {
            
            return (object as? T)
        }
        return forceCast(result)
    }
}


// MARK: - NSData: SelectValueResultType

extension NSData: SelectValueResultType {
    
    public class var attributeType: NSAttributeType {
        
        return .BinaryDataAttributeType
    }
    
    public class func fromResultObject(result: AnyObject) -> Self? {
        
        func forceCast<T: NSData>(object: AnyObject) -> T? {
            
            return (object as? T)
        }
        return forceCast(result)
    }
}


// MARK: - NSManagedObjectID: SelectValueResultType

extension NSManagedObjectID: SelectValueResultType {
    
    public class var attributeType: NSAttributeType {
        
        return .ObjectIDAttributeType
    }
    
    public class func fromResultObject(result: AnyObject) -> Self? {
        
        func forceCast<T: NSManagedObjectID>(object: AnyObject) -> T? {
            
            return (object as? T)
        }
        return forceCast(result)
    }
}


// MARK: - NSManagedObjectID: SelectAttributesResultType

extension NSDictionary: SelectAttributesResultType {
    
    // MARK: SelectAttributesResultType
    
    public class func fromResultObjects(result: [AnyObject]) -> [[NSString: AnyObject]] {
        
        return result as! [[NSString: AnyObject]]
    }
}


// MARK: - Internal

internal extension CollectionType where Generator.Element == SelectTerm {
    
    internal func applyToFetchRequest<T>(fetchRequest: NSFetchRequest, owner: T) {
        
        fetchRequest.includesPendingChanges = false
        fetchRequest.resultType = .DictionaryResultType
        
        func attributeDescriptionForKeyPath(keyPath: String, inEntity entity: NSEntityDescription) -> NSAttributeDescription? {
            
            let components = keyPath.componentsSeparatedByString(".")
            switch components.count {
                
            case 0:
                return nil
                
            case 1:
                return entity.attributesByName[components[0]]
                
            default:
                guard let relationship = entity.relationshipsByName[components[0]] else {
                    
                    return nil
                }
                return attributeDescriptionForKeyPath(
                    components.dropFirst().joinWithSeparator("."),
                    inEntity: relationship.entity
                )
            }
        }
        
        var propertiesToFetch = [AnyObject]()
        for term in self {
            
            switch term {
                
            case ._Attribute(let keyPath):
                let entityDescription = fetchRequest.entity!
                if let attributeDescription = attributeDescriptionForKeyPath(keyPath, inEntity: entityDescription) {
                    
                    propertiesToFetch.append(attributeDescription)
                }
                else {
                    
                    CoreStore.log(
                        .Warning,
                        message: "The key path \"\(keyPath)\" could not be resolved in entity \(cs_typeName(entityDescription.managedObjectClassName)) as an attribute and will be ignored by \(cs_typeName(owner)) query clause."
                    )
                }
                
            case ._Aggregate(let function, let keyPath, let alias, let nativeType):
                let entityDescription = fetchRequest.entity!
                if let attributeDescription = attributeDescriptionForKeyPath(keyPath, inEntity: entityDescription) {
                    
                    let expressionDescription = NSExpressionDescription()
                    expressionDescription.name = alias
                    if nativeType == .UndefinedAttributeType {
                        
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
                        .Warning,
                        message: "The key path \"\(keyPath)\" could not be resolved in entity \(cs_typeName(entityDescription.managedObjectClassName)) as an attribute and will be ignored by \(cs_typeName(owner)) query clause."
                    )
                }
                
            case ._Identity(let alias, let nativeType):
                let expressionDescription = NSExpressionDescription()
                expressionDescription.name = alias
                if nativeType == .UndefinedAttributeType {
                    
                    expressionDescription.expressionResultType = .ObjectIDAttributeType
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
    
    internal func keyPathForFirstSelectTerm() -> KeyPath {
        
        switch self.first! {
            
        case ._Attribute(let keyPath):
            return keyPath
            
        case ._Aggregate(_, _, let alias, _):
            return alias
            
        case ._Identity(let alias, _):
            return alias
        }
    }
}
