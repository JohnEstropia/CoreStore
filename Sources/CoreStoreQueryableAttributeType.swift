//
//  CoreStoreQueryableAttributeType.swift
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


// MARK: - CoreStoreQueryableAttributeType

public protocol CoreStoreQueryableAttributeType: Hashable {
    
    associatedtype QueryableNativeType: CoreDataNativeType
    
    func cs_toQueryableNativeType() -> QueryableNativeType
}


// MARK: - NSManagedObject

extension NSManagedObject: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSManagedObjectID
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self.objectID
    }
}


// MARK: - NSManagedObjectID

extension NSManagedObjectID: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSManagedObjectID
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self
    }
}


// MARK: - NSNumber

extension NSNumber: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSNumber
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self
    }
}


// MARK: - NSString

extension NSString: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSString
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self
    }
}


// MARK: - NSDate

extension NSDate: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSDate
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self
    }
}


// MARK: - NSData

extension NSData: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSData
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self
    }
}


// MARK: - Bool

extension Bool: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSNumber
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self as NSNumber
    }
}


// MARK: - Int16

extension Int16: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSNumber
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self as NSNumber
    }
}


// MARK: - Int32

extension Int32: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSNumber
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self as NSNumber
    }
}


// MARK: - Int64

extension Int64: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSNumber
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self as NSNumber
    }
}


// MARK: - Int

extension Int: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSNumber
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self as NSNumber
    }
}


// MARK: - Double

extension Double: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSNumber
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self as NSNumber
    }
}


// MARK: - Float

extension Float: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSNumber
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self as NSNumber
    }
}


// MARK: - CGFloat

extension CGFloat: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSNumber
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self as NSNumber
    }
}


// MARK: - Date

extension Date: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSDate
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self as NSDate
    }
}


// MARK: - String

extension String: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSString
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self as NSString
    }
}


// MARK: - Data

extension Data: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSData
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self as NSData
    }
}


// MARK: - NSNull

extension NSNull: CoreStoreQueryableAttributeType {
    
    public typealias QueryableNativeType = NSNull
    
    public func cs_toQueryableNativeType() -> QueryableNativeType {
        
        return self
    }
}
