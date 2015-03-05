//
//  AggregateResultType.swift
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


// MARK: - AggregateResultType

public protocol AggregateResultType {
    
    static var attributeType: NSAttributeType { get }
    static func fromResultObject(result: AnyObject) -> Self
}


extension Bool: AggregateResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .BooleanAttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Bool {
        
        return (result as! NSNumber).boolValue
    }
}

extension Int8: AggregateResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Int8 {
        
        return numericCast((result as! NSNumber).longLongValue)
    }
}

extension Int16: AggregateResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Int16 {
        
        return numericCast((result as! NSNumber).longLongValue)
    }
}

extension Int32: AggregateResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Int32 {
        
        return numericCast((result as! NSNumber).longLongValue)
    }
}

extension Int64: AggregateResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Int64 {
        
        return numericCast((result as! NSNumber).longLongValue)
    }
}

extension Int: AggregateResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Int {
        
        return numericCast((result as! NSNumber).longLongValue)
    }
}

extension UInt8: AggregateResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> UInt8 {
        
        return numericCast((result as! NSNumber).longLongValue)
    }
}

extension UInt16: AggregateResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> UInt16 {
        
        return numericCast((result as! NSNumber).longLongValue)
    }
}

extension UInt32: AggregateResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> UInt32 {
        
        return numericCast((result as! NSNumber).longLongValue)
    }
}

extension UInt64: AggregateResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> UInt64 {
        
        return numericCast((result as! NSNumber).longLongValue)
    }
}

extension UInt: AggregateResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> UInt {
        
        return numericCast((result as! NSNumber).longLongValue)
    }
}

extension Double: AggregateResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .DoubleAttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Double {
        
        return (result as! NSNumber).doubleValue
    }
}

extension Float: AggregateResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .FloatAttributeType
    }
    
    public static func fromResultObject(result: AnyObject) -> Float {
        
        return (result as! NSNumber).floatValue
    }
}

extension NSNumber: AggregateResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .Integer64AttributeType
    }
    
    public class func fromResultObject(result: AnyObject) -> Self {
        
        return self(bytes: result.bytes, objCType: result.objCType)
    }
}

extension NSDate: AggregateResultType {
    
    public static var attributeType: NSAttributeType {
        
        return .DateAttributeType
    }
    
    public class func fromResultObject(result: AnyObject) -> Self {
        
        return self(timeInterval: 0.0, sinceDate: result as! NSDate)
    }
}
