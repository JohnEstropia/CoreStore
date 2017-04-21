//
//  CoreStoreObject+Querying.swift
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

import CoreData
import Foundation


// MARK: - DynamicObject

public extension DynamicObject where Self: CoreStoreObject {
    
    public static func keyPath<O: CoreStoreObject, V: ImportableAttributeType>(_ attribute: (Self) -> ValueContainer<O>.Required<V>) -> String  {
        
        return attribute(self.meta).keyPath
    }
    
    public static func keyPath<O: CoreStoreObject, V: ImportableAttributeType>(_ attribute: (Self) -> ValueContainer<O>.Optional<V>) -> String  {
        
        return attribute(self.meta).keyPath
    }
    
    public static func `where`(_ condition: (Self) -> Where) -> Where  {
        
        return condition(self.meta)
    }
    
    public static func ascending<O: CoreStoreObject, V: ImportableAttributeType>(_ attribute: (Self) -> ValueContainer<O>.Optional<V>) -> OrderBy  {
        
        return OrderBy(.ascending(attribute(self.meta).keyPath))
    }
    
    public static func descending<O: CoreStoreObject, V: ImportableAttributeType>(_ attribute: (Self) -> ValueContainer<O>.Optional<V>) -> OrderBy  {
        
        return OrderBy(.descending(attribute(self.meta).keyPath))
    }
}


// MARK: - ValueContainer.Required

public extension ValueContainer.Required {
    
    @inline(__always)
    public static func == (_ attribute: ValueContainer<O>.Required<V>, _ value: V) -> Where {
        
        return Where(attribute.keyPath, isEqualTo: value)
    }
    
    @inline(__always)
    public static func < (_ attribute: ValueContainer<O>.Required<V>, _ value: V) -> Where {
        
        return Where("%K < %@", attribute.keyPath, value)
    }
    
    @inline(__always)
    public static func > (_ attribute: ValueContainer<O>.Required<V>, _ value: V) -> Where {
        
        return Where("%K > %@", attribute.keyPath, value)
    }
    
    @inline(__always)
    public static func <= (_ attribute: ValueContainer<O>.Required<V>, _ value: V) -> Where {
        
        return Where("%K <= %@", attribute.keyPath, value)
    }
    
    @inline(__always)
    public static func >= (_ attribute: ValueContainer<O>.Required<V>, _ value: V) -> Where {
        
        return Where("%K >= %@", attribute.keyPath, value)
    }
    
    @inline(__always)
    public static func != (_ attribute: ValueContainer<O>.Required<V>, _ value: V) -> Where {
        
        return !Where(attribute.keyPath, isEqualTo: value)
    }
}


// MARK: - ValueContainer.Optional

public extension ValueContainer.Optional {
    
    @inline(__always)
    public static func == (_ attribute: ValueContainer<O>.Optional<V>, _ value: V?) -> Where {
        
        return Where(attribute.keyPath, isEqualTo: value)
    }
    
    @inline(__always)
    public static func != (_ attribute: ValueContainer<O>.Optional<V>, _ value: V?) -> Where {
        
        return !Where(attribute.keyPath, isEqualTo: value)
    }
}
