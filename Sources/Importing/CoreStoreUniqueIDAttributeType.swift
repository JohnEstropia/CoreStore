//
//  CoreStoreUniqueIDAttributeType.swift
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


// MARK: - CoreStoreUniqueIDAttributeType

public protocol CoreStoreUniqueIDAttributeType: CoreStoreQueryingAttributeType {
    
    associatedtype NativeTypeForUniqueID: CoreDataNativeType
    
    static func cs_fromUniqueIDNativeType(_ value: NativeTypeForUniqueID) -> Self?
    func cs_toUniqueIDNativeType() -> NativeTypeForUniqueID
}


// MARK: - NSNumber

extension NSNumber: CoreStoreUniqueIDAttributeType {
    
    public typealias NativeTypeForUniqueID = NSNumber
    
    public class func cs_fromUniqueIDNativeType(_ value: NativeTypeForUniqueID) -> Self? {
        
        func forceCast<T: NSNumber>(_ value: Any) -> T? {
            
            return value as? T
        }
        return forceCast(value)
    }
    
    public func cs_toUniqueIDNativeType() -> NativeTypeForUniqueID {
        
        return self
    }
}


// MARK: - NSString

extension NSString: CoreStoreUniqueIDAttributeType {
    
    public typealias NativeTypeForUniqueID = NSString
    
    public class func cs_fromUniqueIDNativeType(_ value: NativeTypeForUniqueID) -> Self? {
        
        func forceCast<T: NSString>(_ value: Any) -> T? {
            
            return value as? T
        }
        return forceCast(value)
    }
    
    public func cs_toUniqueIDNativeType() -> NativeTypeForUniqueID {
        
        return self
    }
}


// MARK: - NSDate

extension NSDate: CoreStoreUniqueIDAttributeType {
    
    public typealias NativeTypeForUniqueID = NSDate
    
    public class func cs_fromUniqueIDNativeType(_ value: NativeTypeForUniqueID) -> Self? {
        
        func forceCast<T: NSDate>(_ value: Any) -> T? {
            
            return value as? T
        }
        return forceCast(value)
    }
    
    public func cs_toUniqueIDNativeType() -> NativeTypeForUniqueID {
        
        return self
    }
}


// MARK: - NSData

extension NSData: CoreStoreUniqueIDAttributeType {
    
    public typealias NativeTypeForUniqueID = NSData
    
    public class func cs_fromUniqueIDNativeType(_ value: NativeTypeForUniqueID) -> Self? {
        
        func forceCast<T: NSData>(_ value: Any) -> T? {
            
            return value as? T
        }
        return forceCast(value)
    }
    
    public func cs_toUniqueIDNativeType() -> NativeTypeForUniqueID {
        
        return self
    }
}


// MARK: - Bool

extension Bool: CoreStoreUniqueIDAttributeType {
    
    public typealias NativeTypeForUniqueID = NSNumber
    
    public static func cs_fromUniqueIDNativeType(_ value: NativeTypeForUniqueID) -> Bool? {
        
        return value.boolValue
    }
    
    public func cs_toUniqueIDNativeType() -> NativeTypeForUniqueID {
        
        return self as NSNumber
    }
}


// MARK: - Int16

extension Int16: CoreStoreUniqueIDAttributeType {
    
    public typealias NativeTypeForUniqueID = NSNumber
    
    public static func cs_fromUniqueIDNativeType(_ value: NativeTypeForUniqueID) -> Int16? {
        
        return value.int16Value
    }
    
    public func cs_toUniqueIDNativeType() -> NativeTypeForUniqueID {
        
        return self as NSNumber
    }
}


// MARK: - Int32

extension Int32: CoreStoreUniqueIDAttributeType {
    
    public typealias NativeTypeForUniqueID = NSNumber
    
    public static func cs_fromUniqueIDNativeType(_ value: NativeTypeForUniqueID) -> Int32? {
        
        return value.int32Value
    }
    
    public func cs_toUniqueIDNativeType() -> NativeTypeForUniqueID {
        
        return self as NSNumber
    }
}


// MARK: - Int64

extension Int64: CoreStoreUniqueIDAttributeType {
    
    public typealias NativeTypeForUniqueID = NSNumber
    
    public static func cs_fromUniqueIDNativeType(_ value: NativeTypeForUniqueID) -> Int64? {
        
        return value.int64Value
    }
    
    public func cs_toUniqueIDNativeType() -> NativeTypeForUniqueID {
        
        return self as NSNumber
    }
}


// MARK: - Double

extension Double: CoreStoreUniqueIDAttributeType {
    
    public typealias NativeTypeForUniqueID = NSNumber
    
    public static func cs_fromUniqueIDNativeType(_ value: NativeTypeForUniqueID) -> Double? {
        
        return value.doubleValue
    }
    
    public func cs_toUniqueIDNativeType() -> NativeTypeForUniqueID {
        
        return self as NSNumber
    }
}


// MARK: - Float

extension Float: CoreStoreUniqueIDAttributeType {
    
    public typealias NativeTypeForUniqueID = NSNumber
    
    public static func cs_fromUniqueIDNativeType(_ value: NativeTypeForUniqueID) -> Float? {
        
        return value.floatValue
    }
    
    public func cs_toUniqueIDNativeType() -> NativeTypeForUniqueID {
        
        return self as NSNumber
    }
}


// MARK: - Date

extension Date: CoreStoreUniqueIDAttributeType {
    
    public typealias NativeTypeForUniqueID = NSDate
    
    public static func cs_fromUniqueIDNativeType(_ value: NativeTypeForUniqueID) -> Date? {
        
        return value as Date
    }
    
    public func cs_toUniqueIDNativeType() -> NativeTypeForUniqueID {
        
        return self as NSDate
    }
}


// MARK: - String

extension String: CoreStoreUniqueIDAttributeType {
    
    public typealias NativeTypeForUniqueID = NSString
    
    public static func cs_fromUniqueIDNativeType(_ value: NativeTypeForUniqueID) -> String? {
        
        return value as String
    }
    
    public func cs_toUniqueIDNativeType() -> NativeTypeForUniqueID {
        
        return self as NSString
    }
}


// MARK: - Data

extension Data: CoreStoreUniqueIDAttributeType {
    
    public typealias NativeTypeForUniqueID = NSData
    
    public static func cs_fromUniqueIDNativeType(_ value: NativeTypeForUniqueID) -> Data? {
        
        return value as Data
    }
    
    public func cs_toUniqueIDNativeType() -> NativeTypeForUniqueID {
        
        return self as NSData
    }
}
