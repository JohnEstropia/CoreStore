//
//  CoreStoreImportableAttributeType.swift
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


// MARK: - CoreStoreImportableAttributeType

public protocol CoreStoreImportableAttributeType: CoreStoreQueryableAttributeType {
    
    associatedtype ImportableNativeType: QueryableNativeType
    
    @inline(__always)
    static func cs_emptyValue() -> Self
    
    @inline(__always)
    static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Self?
}


// MARK: - NSNumber

extension NSNumber: CoreStoreImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @nonobjc @inline(__always)
    public class func cs_emptyValue() -> Self {
        
        return self.init()
    }
    
    @nonobjc @inline(__always)
    public class func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Self? {
        
        func forceCast<T: NSNumber>(_ value: Any) -> T? {
            
            return value as? T
        }
        return forceCast(value)
    }
}


// MARK: - NSString

extension NSString: CoreStoreImportableAttributeType {
    
    public typealias ImportableNativeType = NSString
    
    @nonobjc @inline(__always)
    public class func cs_emptyValue() -> Self {
        
        return self.init()
    }
    
    @nonobjc @inline(__always)
    public class func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Self? {
        
        func forceCast<T: NSString>(_ value: Any) -> T? {
            
            return value as? T
        }
        return forceCast(value)
    }
}


// MARK: - NSDate

extension NSDate: CoreStoreImportableAttributeType {
    
    public typealias ImportableNativeType = NSDate
    
    @nonobjc @inline(__always)
    public class func cs_emptyValue() -> Self {
        
        return self.init(timeIntervalSinceReferenceDate: 0)
    }
    
    @nonobjc @inline(__always)
    public class func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Self? {
        
        func forceCast<T: NSDate>(_ value: Any) -> T? {
            
            return value as? T
        }
        return forceCast(value)
    }
}


// MARK: - NSData

extension NSData: CoreStoreImportableAttributeType {
    
    public typealias ImportableNativeType = NSData
    
    @nonobjc @inline(__always)
    public class func cs_emptyValue() -> Self {
        
        return self.init()
    }
    
    @nonobjc @inline(__always)
    public class func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Self? {
        
        func forceCast<T: NSData>(_ value: Any) -> T? {
            
            return value as? T
        }
        return forceCast(value)
    }
}


// MARK: - Bool

extension Bool: CoreStoreImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @inline(__always)
    public static func cs_emptyValue() -> Bool {
        
        return false
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Bool? {
        
        return value.boolValue
    }
}


// MARK: - Int16

extension Int16: CoreStoreImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @inline(__always)
    public static func cs_emptyValue() -> Int16 {
        
        return 0
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Int16? {
        
        return value.int16Value
    }
}


// MARK: - Int32

extension Int32: CoreStoreImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @inline(__always)
    public static func cs_emptyValue() -> Int32 {
        
        return 0
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Int32? {
        
        return value.int32Value
    }
}


// MARK: - Int64

extension Int64: CoreStoreImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @inline(__always)
    public static func cs_emptyValue() -> Int64 {
        
        return 0
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Int64? {
        
        return value.int64Value
    }
}


// MARK: - Double

extension Double: CoreStoreImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @inline(__always)
    public static func cs_emptyValue() -> Double {
        
        return 0
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Double? {
        
        return value.doubleValue
    }
}


// MARK: - Float

extension Float: CoreStoreImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @inline(__always)
    public static func cs_emptyValue() -> Float {
        
        return 0
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Float? {
        
        return value.floatValue
    }
}


// MARK: - Date

extension Date: CoreStoreImportableAttributeType {
    
    public typealias ImportableNativeType = NSDate
    
    @inline(__always)
    public static func cs_emptyValue() -> Date {
        
        return Date(timeIntervalSinceReferenceDate: 0)
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Date? {
        
        return value as Date
    }
}


// MARK: - String

extension String: CoreStoreImportableAttributeType {
    
    public typealias ImportableNativeType = NSString
    
    @inline(__always)
    public static func cs_emptyValue() -> String {
        
        return ""
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> String? {
        
        return value as String
    }
}


// MARK: - Data

extension Data: CoreStoreImportableAttributeType {
    
    public typealias ImportableNativeType = NSData
    
    @inline(__always)
    public static func cs_emptyValue() -> Data {
        
        return Data()
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Data? {
        
        return value as Data
    }
}
