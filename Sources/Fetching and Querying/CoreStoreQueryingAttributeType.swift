//
//  CoreStoreQueryingAttributeType.swift
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
import CoreGraphics
import CoreData


// MARK: - CoreStoreQueryingAttributeType

public protocol CoreStoreQueryingAttributeType: Hashable {
    
    associatedtype NativeTypeForQuerying: CoreDataNativeType
    
    func cs_toQueryingNativeType() -> NativeTypeForQuerying
}


// MARK: - NSManagedObject

extension NSManagedObject: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSManagedObjectID
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self.objectID
    }
}


// MARK: - NSManagedObjectID

extension NSManagedObjectID: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSManagedObjectID
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self
    }
}


// MARK: - NSNumber

extension NSNumber: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSNumber
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self
    }
}


// MARK: - NSString

extension NSString: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSString
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self
    }
}


// MARK: - NSDate

extension NSDate: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSDate
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self
    }
}


// MARK: - NSData

extension NSData: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSData
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self
    }
}


// MARK: - Bool

extension Bool: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSNumber
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self as NSNumber
    }
}


// MARK: - Int16

extension Int16: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSNumber
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self as NSNumber
    }
}


// MARK: - Int32

extension Int32: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSNumber
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self as NSNumber
    }
}


// MARK: - Int64

extension Int64: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSNumber
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self as NSNumber
    }
}


// MARK: - Int

extension Int: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSNumber
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self as NSNumber
    }
}


// MARK: - Double

extension Double: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSNumber
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self as NSNumber
    }
}


// MARK: - Float

extension Float: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSNumber
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self as NSNumber
    }
}


// MARK: - CGFloat

extension CGFloat: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSNumber
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self as NSNumber
    }
}


// MARK: - Date

extension Date: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSDate
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self as NSDate
    }
}


// MARK: - String

extension String: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSString
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self as NSString
    }
}


// MARK: - Data

extension Data: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSData
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self as NSData
    }
}


// MARK: - NSNull

extension NSNull: CoreStoreQueryingAttributeType {
    
    public typealias NativeTypeForQuerying = NSNull
    
    public func cs_toQueryingNativeType() -> NativeTypeForQuerying {
        
        return self
    }
}
