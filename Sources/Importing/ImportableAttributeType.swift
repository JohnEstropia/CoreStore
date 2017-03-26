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


// MARK: - ImportableAttributeType

public protocol ImportableAttributeType: QueryableAttributeType {
    
    associatedtype ImportableNativeType: QueryableNativeType
    
    @inline(__always)
    static func cs_emptyValue() -> Self
    
    @inline(__always)
    static func cs_fromImportableNativeType(_ value: ImportableNativeType) -> Self?
    
    @inline(__always)
    func cs_toImportableNativeType() -> ImportableNativeType
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
