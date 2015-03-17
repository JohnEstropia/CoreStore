//
//  Select.swift
//  HardcoreData
//
//  Copyright (c) 2015 John Rommel Estropia
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

public protocol SelectResultType { }


// MARK: - SelectValueResultType

public protocol SelectValueResultType: SelectResultType {
    
    static func fromResultObject(result: AnyObject) -> Self?
}


// MARK: - SelectAttributesResultType

public protocol SelectAttributesResultType: SelectResultType {
    
    static func fromResultObjects(result: [AnyObject]) -> [[NSString: AnyObject]]
}


// MARK: - SelectTerm

public enum SelectTerm: StringLiteralConvertible {
    
    case Attribute(KeyPath)
    case Aggregate(function: String, KeyPath, As: String)
    
    public static func Average(keyPath: KeyPath, As alias: KeyPath? = nil) -> SelectTerm {
        
        return .Aggregate(
            function: "average:",
            keyPath,
            As: alias ?? "average(\(keyPath))"
        )
    }
    
    public static func Count(keyPath: KeyPath, As alias: KeyPath? = nil) -> SelectTerm {
        
        return .Aggregate(
            function: "count:",
            keyPath,
            As: alias ?? "count(\(keyPath))"
        )
    }
    
    public static func Maximum(keyPath: KeyPath, As alias: KeyPath? = nil) -> SelectTerm {
        
        return .Aggregate(
            function: "max:",
            keyPath,
            As: alias ?? "max(\(keyPath))"
        )
    }
    
    public static func Median(keyPath: KeyPath, As alias: KeyPath? = nil) -> SelectTerm {
        
        return .Aggregate(
            function: "median:",
            keyPath, As:
            alias ?? "median(\(keyPath))"
        )
    }
    
    public static func Minimum(keyPath: KeyPath, As alias: KeyPath? = nil) -> SelectTerm {
        
        return .Aggregate(
            function: "min:",
            keyPath,
            As: alias ?? "min(\(keyPath))"
        )
    }
    
    public static func StandardDeviation(keyPath: KeyPath, As alias: KeyPath? = nil) -> SelectTerm {
        
        return .Aggregate(
            function: "stddev:",
            keyPath,
            As: alias ?? "stddev(\(keyPath))"
        )
    }
    
    public static func Sum(keyPath: KeyPath, As alias: KeyPath? = nil) -> SelectTerm {
        
        return .Aggregate(
            function: "sum:",
            keyPath,
            As: alias ?? "sum(\(keyPath))"
        )
    }
    
    public init(stringLiteral value: KeyPath) {
        
        self = .Attribute(value)
    }
    
    public init(unicodeScalarLiteral value: KeyPath) {
        
        self = .Attribute(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: KeyPath) {
        
        self = .Attribute(value)
    }
}


// MARK: - Select

public struct Select<T: SelectResultType> {
    
    // MARK: Public
    
    public typealias ReturnType = T
    
    public init(_ selectTerm: SelectTerm, _ selectTerms: SelectTerm...) {
        
        self.selectTerms = [selectTerm] + selectTerms
    }


    // MARK: Internal

    internal func applyToFetchRequest(fetchRequest: NSFetchRequest) {
        
        if fetchRequest.propertiesToFetch != nil {
            
            HardcoreData.log(.Warning, message: "An existing \"propertiesToFetch\" for the <\(NSFetchRequest.self)> was overwritten by <\(self.dynamicType)> query clause.")
        }
        
        fetchRequest.includesPendingChanges = false
        fetchRequest.resultType = .DictionaryResultType
        
        let entityDescription = fetchRequest.entity!
        let propertiesByName = entityDescription.propertiesByName
        let attributesByName = entityDescription.attributesByName
        
        var propertiesToFetch = [AnyObject]()
        for term in self.selectTerms {
            
            switch term {
                
            case .Attribute(let keyPath):
                if let propertyDescription = propertiesByName[keyPath] as? NSPropertyDescription {
                    
                    propertiesToFetch.append(propertyDescription)
                }
                else {
                    
                    HardcoreData.log(.Warning, message: "The property \"\(keyPath)\" does not exist in entity <\(entityDescription.managedObjectClassName)> and will be ignored by <\(self.dynamicType)> query clause.")
                }
                
            case .Aggregate(let function, let keyPath, let alias):
                if let attributeDescription = attributesByName[keyPath] as? NSAttributeDescription {
                    
                    let expressionDescription = NSExpressionDescription()
                    expressionDescription.name = alias
                    expressionDescription.expressionResultType = attributeDescription.attributeType
                    expressionDescription.expression = NSExpression(
                        forFunction: function,
                        arguments: [NSExpression(forKeyPath: keyPath)]
                    )
                    
                    propertiesToFetch.append(expressionDescription)
                }
                else {
                    
                    HardcoreData.log(.Warning, message: "The attribute \"\(keyPath)\" does not exist in entity <\(entityDescription.managedObjectClassName)> and will be ignored by <\(self.dynamicType)> query clause.")
                }
            }
        }
        
        fetchRequest.propertiesToFetch = propertiesToFetch
    }
    
    internal func keyPathForFirstSelectTerm() -> KeyPath {
        
        switch self.selectTerms.first! {
            
        case .Attribute(let keyPath):
            return keyPath
            
        case .Aggregate(_, _, let alias):
            return alias
        }
    }
    
    
    // MARK: Private
    
    private let selectTerms: [SelectTerm]
}


// MARK: - Bool: SelectValueResultType

extension Bool: SelectValueResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .BooleanAttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Bool? {
        
        return (result as? NSNumber)?.boolValue
    }
}


// MARK: - Int8: SelectValueResultType

extension Int8: SelectValueResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Int8? {
        
        if let value = (result as? NSNumber)?.longLongValue {
            
            return numericCast(value) as Int8
        }
        return nil
    }
}


// MARK: - Int16: SelectValueResultType

extension Int16: SelectValueResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Int16? {
        
        if let value = (result as? NSNumber)?.longLongValue {
            
            return numericCast(value) as Int16
        }
        return nil
    }
}


// MARK: - Int32: SelectValueResultType

extension Int32: SelectValueResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Int32? {
        
        if let value = (result as? NSNumber)?.longLongValue {
            
            return numericCast(value) as Int32
        }
        return nil
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
        
        if let value = (result as? NSNumber)?.longLongValue {
            
            return numericCast(value) as Int
        }
        return nil
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

extension NSDecimalNumber: SelectValueResultType {
    
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
