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
 Types supported by CoreStore as `NSManagedObject` attribute types.
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
 */
public protocol ImportableAttributeType: QueryableAttributeType {
    
    associatedtype ImportableNativeType: QueryableNativeType
    
    @inline(__always)
    static func cs_emptyValue() -> Self
    
    @inline(__always)
    static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Self?
    
    @inline(__always)
    func cs_toImportableNativeType() -> ImportableNativeType
}


// MARK: - Bool

extension Bool: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @inline(__always)
    public static func cs_emptyValue() -> Bool {
        
        return false
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Bool? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - CGFloat

extension CGFloat: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @inline(__always)
    public static func cs_emptyValue() -> CGFloat {
        
        return 0
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> CGFloat? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - Data

extension Data: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSData
    
    @inline(__always)
    public static func cs_emptyValue() -> Data {
        
        return Data()
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Data? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - Date

extension Date: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSDate
    
    @inline(__always)
    public static func cs_emptyValue() -> Date {
        
        return Date(timeIntervalSinceReferenceDate: 0)
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Date? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - Double

extension Double: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @inline(__always)
    public static func cs_emptyValue() -> Double {
        
        return 0
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Double? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - Float

extension Float: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @inline(__always)
    public static func cs_emptyValue() -> Float {
        
        return 0
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Float? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - Int

extension Int: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @inline(__always)
    public static func cs_emptyValue() -> Int {
        
        return 0
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Int? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - Int8

extension Int8: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @inline(__always)
    public static func cs_emptyValue() -> Int8 {
        
        return 0
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Int8? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - Int16

extension Int16: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @inline(__always)
    public static func cs_emptyValue() -> Int16 {
        
        return 0
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Int16? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - Int32

extension Int32: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @inline(__always)
    public static func cs_emptyValue() -> Int32 {
        
        return 0
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Int32? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - Int64

extension Int64: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @inline(__always)
    public static func cs_emptyValue() -> Int64 {
        
        return 0
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Int64? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - NSData

extension NSData: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSData
    
    @nonobjc @inline(__always)
    public class func cs_emptyValue() -> Self {
        
        return self.init()
    }
    
    @nonobjc @inline(__always)
    public class func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Self? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @nonobjc @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - NSDate

extension NSDate: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSDate
    
    @nonobjc @inline(__always)
    public class func cs_emptyValue() -> Self {
        
        return self.init(timeIntervalSinceReferenceDate: 0)
    }
    
    @nonobjc @inline(__always)
    public class func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Self? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @nonobjc @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - NSNumber

extension NSNumber: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSNumber
    
    @nonobjc @inline(__always)
    public class func cs_emptyValue() -> Self {
        
        return self.init()
    }
    
    @nonobjc @inline(__always)
    public class func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Self? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @nonobjc @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - NSString

extension NSString: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSString
    
    @nonobjc @inline(__always)
    public class func cs_emptyValue() -> Self {
        
        return self.init()
    }
    
    @nonobjc @inline(__always)
    public class func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Self? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @nonobjc @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - NSURL

extension NSURL: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSString
    
    @nonobjc @inline(__always)
    public class func cs_emptyValue() -> Self {
        
        return self.init(string: "")!
    }
    
    @nonobjc @inline(__always)
    public class func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Self? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @nonobjc @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - NSUUID

extension NSUUID: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSString
    
    public class func cs_emptyValue() -> Self {
        
        enum Static {
            
            static var zero = Array<UInt8>(repeating: 0, count: 16)
        }
        return self.init(uuidBytes: &Static.zero)
    }
    
    @nonobjc @inline(__always)
    public class func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Self? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @nonobjc @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - String

extension String: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSString
    
    @inline(__always)
    public static func cs_emptyValue() -> String {
        
        return ""
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> String? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - URL

extension URL: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSString
    
    public static func cs_emptyValue() -> URL {
        
        enum Static {
            
            static let empty = URL(string: "")!
        }
        return Static.empty
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> URL? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}


// MARK: - UUID

extension UUID: ImportableAttributeType {
    
    public typealias ImportableNativeType = NSString
    
    public static func cs_emptyValue() -> UUID {
        
        enum Static {
            
            static let empty: UUID = cs_lazy {
                
                var zero = Array<UInt8>(repeating: 0, count: 16)
                return NSUUID(uuidBytes: &zero) as UUID
            }
        }
        return Static.empty
    }
    
    @inline(__always)
    public static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> UUID? {
        
        return self.cs_fromQueryableNativeType(value)
    }
    
    @inline(__always)
    public func cs_toImportableNativeType() -> ImportableNativeType {
        
        return self.cs_toQueryableNativeType()
    }
}
