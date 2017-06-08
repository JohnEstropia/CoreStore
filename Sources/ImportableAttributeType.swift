//
//  ImportableAttributeType.swift
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
import CoreGraphics


// MARK: - ImportableAttributeType

/**
 Types supported by CoreStore as `NSManagedObject` and `CoreStoreObject` property types.
 Supported default types:
 - Bool
 - CGFloat
 - Data
 - Date
 - Double
 - Float
 - Int
 - Int8
 - Int16
 - Int32
 - Int64
 - NSData
 - NSDate
 - NSDecimalNumber
 - NSNumber
 - NSString
 - NSURL
 - NSUUID
 - String
 - URL
 - UUID
 
 In addition, `RawRepresentable` types whose `RawValue` already implements `ImportableAttributeType` only need to declare conformance to `ImportableAttributeType`.
 */
public protocol ImportableAttributeType: QueryableAttributeType {}


// MARK: - EmptyableAttributeType

/**
 `ImportableAttributeType`s that have a natural "empty" value. Example: `0` for `Int`, `""` for `String`.
 
 - Discussion: Not all `ImportableAttributeType`s can have empty values. `URL`s and `Date`s for example have no obvious empty values.
 */
public protocol EmptyableAttributeType: ImportableAttributeType {
    
    /**
     Returns the default "empty" value for this type.
     */
    @inline(__always)
    static func cs_emptyValue() -> Self
}


// MARK: - Bool

extension Bool: ImportableAttributeType, EmptyableAttributeType {
    
    
    // MARK: EmptyableAttributeType
    
    @inline(__always)
    public static func cs_emptyValue() -> Bool {
        
        return false
    }
}


// MARK: - CGFloat

extension CGFloat: ImportableAttributeType, EmptyableAttributeType {
    
    // MARK: EmptyableAttributeType
    
    @inline(__always)
    public static func cs_emptyValue() -> CGFloat {
        
        return 0
    }
}


// MARK: - Data

extension Data: ImportableAttributeType, EmptyableAttributeType {
    
    // MARK: EmptyableAttributeType
    
    @inline(__always)
    public static func cs_emptyValue() -> Data {
        
        return Data()
    }
}


// MARK: - Date

extension Date: ImportableAttributeType {}


// MARK: - Double

extension Double: ImportableAttributeType, EmptyableAttributeType {
    
    // MARK: EmptyableAttributeType
    
    @inline(__always)
    public static func cs_emptyValue() -> Double {
        
        return 0
    }
}


// MARK: - Float

extension Float: ImportableAttributeType, EmptyableAttributeType {
    
    // MARK: EmptyableAttributeType
    
    @inline(__always)
    public static func cs_emptyValue() -> Float {
        
        return 0
    }
}


// MARK: - Int

extension Int: ImportableAttributeType, EmptyableAttributeType {
    
    // MARK: EmptyableAttributeType
    
    @inline(__always)
    public static func cs_emptyValue() -> Int {
        
        return 0
    }
}


// MARK: - Int8

extension Int8: ImportableAttributeType, EmptyableAttributeType {
    
    // MARK: EmptyableAttributeType
    
    @inline(__always)
    public static func cs_emptyValue() -> Int8 {
        
        return 0
    }
}


// MARK: - Int16

extension Int16: ImportableAttributeType, EmptyableAttributeType {
    
    // MARK: EmptyableAttributeType
    
    @inline(__always)
    public static func cs_emptyValue() -> Int16 {
        
        return 0
    }
}


// MARK: - Int32

extension Int32: ImportableAttributeType, EmptyableAttributeType {
    
    // MARK: EmptyableAttributeType
    
    @inline(__always)
    public static func cs_emptyValue() -> Int32 {
        
        return 0
    }
}


// MARK: - Int64

extension Int64: ImportableAttributeType, EmptyableAttributeType {
    
    // MARK: EmptyableAttributeType
    
    @inline(__always)
    public static func cs_emptyValue() -> Int64 {
        
        return 0
    }
}


// MARK: - NSData

extension NSData: ImportableAttributeType, EmptyableAttributeType {
    
    // MARK: EmptyableAttributeType
    
    @nonobjc @inline(__always)
    public class func cs_emptyValue() -> Self {
        
        return self.init()
    }
}


// MARK: - NSDate

extension NSDate: ImportableAttributeType {}


// MARK: - NSNumber

extension NSNumber: ImportableAttributeType, EmptyableAttributeType {
    
    // MARK: EmptyableAttributeType
    
    @nonobjc @inline(__always)
    public class func cs_emptyValue() -> Self {
        
        return self.init()
    }
}


// MARK: - NSString

extension NSString: ImportableAttributeType, EmptyableAttributeType {
    
    // MARK: EmptyableAttributeType
    
    @nonobjc @inline(__always)
    public class func cs_emptyValue() -> Self {
        
        return self.init()
    }
}


// MARK: - NSURL

extension NSURL: ImportableAttributeType {}


// MARK: - NSUUID

extension NSUUID: ImportableAttributeType {}


// MARK: - String

extension String: ImportableAttributeType, EmptyableAttributeType {
    
    // MARK: EmptyableAttributeType
    
    @inline(__always)
    public static func cs_emptyValue() -> String {
        
        return ""
    }
}


// MARK: - URL

extension URL: ImportableAttributeType {}


// MARK: - UUID

extension UUID: ImportableAttributeType {}


// MARK: - RawRepresentable

extension RawRepresentable where RawValue: ImportableAttributeType {
    
    @inline(__always)
    public static func cs_fromQueryableNativeType(_ value: QueryableNativeType) -> Self? {
        
        return RawValue.cs_fromQueryableNativeType(value).flatMap({ self.init(rawValue: $0) })
    }
    
    @inline(__always)
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self.rawValue.cs_toQueryableNativeType()
    }
}
