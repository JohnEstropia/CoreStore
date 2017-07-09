//
//  Where+NSManagedObject.swift
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


// MARK: - KeyPath where Root: NSManagedObject, Value: QueryableAttributeType & Equatable

public extension KeyPath where Root: NSManagedObject, Value: QueryableAttributeType & Equatable {
    
    public static func == (_ keyPath: KeyPath<Root, Value>, _ value: Value) -> Where<Root> {
        
        return Where(keyPath._kvcKeyPathString!, isEqualTo: value)
    }
    
    public static func != (_ keyPath: KeyPath<Root, Value>, _ value: Value) -> Where<Root> {
        
        return !Where(keyPath._kvcKeyPathString!, isEqualTo: value)
    }
    
    public static func ~= <S: Sequence>(_ sequence: S, _ keyPath: KeyPath<Root, Value>) -> Where<Root> where S.Iterator.Element == Value {
        
        return Where(keyPath._kvcKeyPathString!, isMemberOf: sequence)
    }
}

// MARK: - KeyPath where Root: NSManagedObject, Value: Optional<QueryableAttributeType & Equatable>

public extension KeyPath where Root: NSManagedObject {
    
    public static func == <V: QueryableAttributeType & Equatable> (_ keyPath: KeyPath<Root, Value>, _ value: Value) -> Where<Root> where Value == Optional<V> {
        
        return Where(keyPath._kvcKeyPathString!, isEqualTo: value)
    }
    
    public static func != <V: QueryableAttributeType & Equatable> (_ keyPath: KeyPath<Root, Value>, _ value: Value) -> Where<Root> where Value == Optional<V> {
        
        return !Where(keyPath._kvcKeyPathString!, isEqualTo: value)
    }
    
    public static func ~= <S: Sequence, V: QueryableAttributeType & Equatable>(_ sequence: S, _ keyPath: KeyPath<Root, Value>) -> Where<Root> where Value == Optional<V>, S.Iterator.Element == V {
        
        return Where(keyPath._kvcKeyPathString!, isMemberOf: sequence)
    }
}


// MARK: - KeyPath where Root: NSManagedObject, Value: QueryableAttributeType

public extension KeyPath where Root: NSManagedObject, Value: QueryableAttributeType {
    
    public static func < (_ keyPath: KeyPath<Root, Value>, _ value: Value) -> Where<Root> {
        
        return Where("%K < %@", keyPath._kvcKeyPathString!, value)
    }
    
    public static func > (_ keyPath: KeyPath<Root, Value>, _ value: Value) -> Where<Root> {
        
        return Where("%K > %@", keyPath._kvcKeyPathString!, value)
    }
    
    public static func <= (_ keyPath: KeyPath<Root, Value>, _ value: Value) -> Where<Root> {
        
        return Where("%K <= %@", keyPath._kvcKeyPathString!, value)
    }
    
    public static func >= (_ keyPath: KeyPath<Root, Value>, _ value: Value) -> Where<Root> {
        
        return Where("%K >= %@", keyPath._kvcKeyPathString!, value)
    }
}


// MARK: - KeyPath where Root: NSManagedObject, Value: Optional<QueryableAttributeType>

public extension KeyPath where Root: NSManagedObject {
    
    public static func < <V: QueryableAttributeType> (_ keyPath: KeyPath<Root, Value>, _ value: Value) -> Where<Root> where Value == Optional<V> {
        
        if let value = value {
            
            return Where("%K < %@", keyPath._kvcKeyPathString!, value)
        }
        else {
            
            return Where("%K < nil", keyPath._kvcKeyPathString!)
        }
    }
    
    public static func > <V: QueryableAttributeType> (_ keyPath: KeyPath<Root, Value>, _ value: Value) -> Where<Root> where Value == Optional<V> {
        
        if let value = value {
            
            return Where("%K > %@", keyPath._kvcKeyPathString!, value)
        }
        else {
            
            return Where("%K > nil", keyPath._kvcKeyPathString!)
        }
    }
    
    public static func <= <V: QueryableAttributeType> (_ keyPath: KeyPath<Root, Value>, _ value: Value) -> Where<Root> where Value == Optional<V> {
        
        if let value = value {
            
            return Where("%K <= %@", keyPath._kvcKeyPathString!, value)
        }
        else {
            
            return Where("%K <= nil", keyPath._kvcKeyPathString!)
        }
    }
    
    public static func >= <V: QueryableAttributeType> (_ keyPath: KeyPath<Root, Value>, _ value: Value) -> Where<Root> where Value == Optional<V> {
        
        if let value = value {
            
            return Where("%K >= %@", keyPath._kvcKeyPathString!, value)
        }
        else {
            
            return Where("%K >= nil", keyPath._kvcKeyPathString!)
        }
    }
}


// MARK: - KeyPath where Root: NSManagedObject, Value: NSManagedObject

public extension KeyPath where Root: NSManagedObject, Value: NSManagedObject {
    
    public static func == (_ keyPath: KeyPath<Root, Value>, _ object: Value) -> Where<Root> {
        
        return Where(keyPath._kvcKeyPathString!, isEqualTo: object)
    }
    
    public static func != (_ keyPath: KeyPath<Root, Value>, _ object: Value) -> Where<Root> {
        
        return !Where(keyPath._kvcKeyPathString!, isEqualTo: object)
    }
    
    public static func ~= <S: Sequence>(_ sequence: S, _ keyPath: KeyPath<Root, Value>) -> Where<Root> where S.Iterator.Element == Value {
        
        return Where(keyPath._kvcKeyPathString!, isMemberOf: sequence)
    }
    
    public static func == (_ keyPath: KeyPath<Root, Value>, _ objectID: NSManagedObjectID?) -> Where<Root> {
        
        return Where(keyPath._kvcKeyPathString!, isEqualTo: objectID)
    }
    
    public static func != (_ keyPath: KeyPath<Root, Value>, _ objectID: NSManagedObjectID?) -> Where<Root> {
        
        return !Where(keyPath._kvcKeyPathString!, isEqualTo: objectID)
    }
    
    public static func ~= <S: Sequence>(_ sequence: S, _ keyPath: KeyPath<Root, Value>) -> Where<Root> where S.Iterator.Element == NSManagedObjectID {
        
        return Where(keyPath._kvcKeyPathString!, isMemberOf: sequence)
    }
}


// MARK: - KeyPath where Root: NSManagedObject, Value: Optional<NSManagedObject>

public extension KeyPath where Root: NSManagedObject {
    
    public static func == <V: NSManagedObject> (_ keyPath: KeyPath<Root, Value>, _ object: Value) -> Where<Root> where Value == Optional<V> {
        
        return Where(keyPath._kvcKeyPathString!, isEqualTo: object)
    }
    
    public static func != <V: NSManagedObject> (_ keyPath: KeyPath<Root, Value>, _ object: Value) -> Where<Root> where Value == Optional<V> {
        
        return !Where(keyPath._kvcKeyPathString!, isEqualTo: object)
    }
    
    public static func ~= <S: Sequence, V: NSManagedObject>(_ sequence: S, _ keyPath: KeyPath<Root, Value>) -> Where<Root> where Value == Optional<V>, S.Iterator.Element == V {
        
        return Where(keyPath._kvcKeyPathString!, isMemberOf: sequence)
    }
    
    public static func == <V: NSManagedObject> (_ keyPath: KeyPath<Root, Value>, _ objectID: NSManagedObjectID?) -> Where<Root> where Value == Optional<V> {
        
        return Where(keyPath._kvcKeyPathString!, isEqualTo: objectID)
    }
    
    public static func != <V: NSManagedObject> (_ keyPath: KeyPath<Root, Value>, _ objectID: NSManagedObjectID?) -> Where<Root> where Value == Optional<V> {
        
        return !Where(keyPath._kvcKeyPathString!, isEqualTo: objectID)
    }
    
    public static func ~= <S: Sequence, V: NSManagedObject>(_ sequence: S, _ keyPath: KeyPath<Root, Value>) -> Where<Root> where Value == Optional<V>, S.Iterator.Element == NSManagedObjectID {
        
        return Where(keyPath._kvcKeyPathString!, isMemberOf: sequence)
    }
}
