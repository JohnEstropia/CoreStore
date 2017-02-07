//
//  CoreDataNativeType.swift
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

import Foundation
import CoreData


// MARK: - CoreDataNativeType

public protocol CoreDataNativeType: class, NSObjectProtocol, AnyObject {}

extension NSNumber: CoreDataNativeType {}
extension NSString: CoreDataNativeType {}
extension NSDate: CoreDataNativeType {}
extension NSData: CoreDataNativeType {}
extension NSSet: CoreDataNativeType {}
extension NSOrderedSet: CoreDataNativeType {}


public protocol CoreStoreSupportedAttributeType {
    
    associatedtype CoreStoreNativeType: CoreDataNativeType
    
    static func cs_fromNativeType(_ value: CoreStoreNativeType) -> Self?
    func cs_toNativeType() -> CoreStoreNativeType
}

extension NSNumber: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSNumber
    
    public class func cs_fromNativeType(_ value: CoreStoreNativeType) -> Self? {
        
        func forceCast<T: NSNumber>(_ value: Any) -> T? {
            
            return value as? T
        }
        return forceCast(value)
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self
    }
}

extension NSString: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSString
    
    public class func cs_fromNativeType(_ value: CoreStoreNativeType) -> Self? {
        
        func forceCast<T: NSString>(_ value: Any) -> T? {
            
            return value as? T
        }
        return forceCast(value)
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self
    }
}

extension NSDate: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSDate
    
    public class func cs_fromNativeType(_ value: CoreStoreNativeType) -> Self? {
        
        func forceCast<T: NSDate>(_ value: Any) -> T? {
            
            return value as? T
        }
        return forceCast(value)
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self
    }
}

extension NSData: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSData
    
    public class func cs_fromNativeType(_ value: CoreStoreNativeType) -> Self? {
        
        func forceCast<T: NSData>(_ value: Any) -> T? {
            
            return value as? T
        }
        return forceCast(value)
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self
    }
}

extension NSSet: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSSet
    
    public class func cs_fromNativeType(_ value: CoreStoreNativeType) -> Self? {
        
        func forceCast<T: NSSet>(_ value: Any) -> T? {
            
            return value as? T
        }
        return forceCast(value)
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self
    }
}

extension NSOrderedSet: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSOrderedSet
    
    public class func cs_fromNativeType(_ value: CoreStoreNativeType) -> Self? {
        
        func forceCast<T: NSOrderedSet>(_ value: Any) -> T? {
            
            return value as? T
        }
        return forceCast(value)
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self
    }
}



extension Bool: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSNumber
    
    public static func cs_fromNativeType(_ value: CoreStoreNativeType) -> Bool? {
        
        return value.boolValue
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self as NSNumber
    }
}

extension Int16: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSNumber
    
    public static func cs_fromNativeType(_ value: CoreStoreNativeType) -> Int16? {
        
        return value.int16Value
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self as NSNumber
    }
}

extension Int32: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSNumber
    
    public static func cs_fromNativeType(_ value: CoreStoreNativeType) -> Int32? {
        
        return value.int32Value
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self as NSNumber
    }
}

extension Int64: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSNumber
    
    public static func cs_fromNativeType(_ value: CoreStoreNativeType) -> Int64? {
        
        return value.int64Value
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self as NSNumber
    }
}

extension Double: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSNumber
    
    public static func cs_fromNativeType(_ value: CoreStoreNativeType) -> Double? {
        
        return value.doubleValue
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self as NSNumber
    }
}

extension Float: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSNumber
    
    public static func cs_fromNativeType(_ value: CoreStoreNativeType) -> Float? {
        
        return value.floatValue
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self as NSNumber
    }
}

extension Date: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSDate
    
    public static func cs_fromNativeType(_ value: CoreStoreNativeType) -> Date? {
        
        return value as Date
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self as NSDate
    }
}

extension String: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSString
    
    public static func cs_fromNativeType(_ value: CoreStoreNativeType) -> String? {
        
        return value as String
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self as NSString
    }
}

extension Data: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSData
    
    public static func cs_fromNativeType(_ value: CoreStoreNativeType) -> Data? {
        
        return value as Data
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self as NSData
    }
}

extension Set: CoreStoreSupportedAttributeType {
    
    public typealias CoreStoreNativeType = NSSet
    
    public static func cs_fromNativeType(_ value: CoreStoreNativeType) -> Set? {
        
        return value as? Set
    }
    
    public func cs_toNativeType() -> CoreStoreNativeType {
        
        return self as NSSet
    }
}


