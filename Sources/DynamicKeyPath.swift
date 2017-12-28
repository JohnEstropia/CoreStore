//
//  DynamicKeyPath.swift
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


// MARK: - DynamicKeyPath

/**
 Used only for utility methods.
 */
public protocol DynamicKeyPath {
    
    /**
     The DynamicObject type
     */
    associatedtype ObjectType
    
    /**
     The Value type
     */
    associatedtype ValueType
    
    /**
     The keyPath string
     */
    var cs_keyPathString: String { get }
}


// MARK: - KeyPathString

public extension KeyPathString {
    
    /**
     Extracts the keyPath string from the property.
     ```
     let keyPath = String(keyPath: \Person.nickname)
     ```
     */
    public init<O: NSManagedObject, V>(keyPath: KeyPath<O, V>) {
        
        self = keyPath.cs_keyPathString
    }
    
    /**
     Extracts the keyPath string from the property.
     ```
     let keyPath = String(keyPath: \Person.nickname)
     ```
     */
    public init<O: CoreStoreObject, K: DynamicKeyPath>(keyPath: KeyPath<O, K>) {
        
        self = O.meta[keyPath: keyPath].cs_keyPathString
    }
}


// MARK: - KeyPath: DynamicKeyPath

// TODO: SE-0143 is not implemented: https://github.com/apple/swift-evolution/blob/master/proposals/0143-conditional-conformances.md
//extension KeyPath: DynamicKeyPath where Root: NSManagedObject, Value: ImportableAttributeType {
extension KeyPath: DynamicKeyPath {

    public typealias ObjectType = Root
    public typealias ValueType = Value
    
    public var cs_keyPathString: String {
        
        return self._kvcKeyPathString!
    }
}


// MARK: - ValueContainer.Required: DynamicKeyPath

extension ValueContainer.Required: DynamicKeyPath {
    
    public typealias ObjectType = O
    public typealias ValueType = V
    
    public var cs_keyPathString: String {
        
        return self.keyPath
    }
}


// MARK: - ValueContainer.Optional: DynamicKeyPath

extension ValueContainer.Optional: DynamicKeyPath {
    
    public typealias ObjectType = O
    public typealias ValueType = V
    
    public var cs_keyPathString: String {
        
        return self.keyPath
    }
}


// MARK: - TransformableContainer.Required: DynamicKeyPath

extension TransformableContainer.Required: DynamicKeyPath {
    
    public typealias ObjectType = O
    public typealias ValueType = V
    
    public var cs_keyPathString: String {
        
        return self.keyPath
    }
}


// MARK: - TransformableContainer.Optional: DynamicKeyPath

extension TransformableContainer.Optional: DynamicKeyPath {
    
    public typealias ObjectType = O
    public typealias ValueType = V
    
    public var cs_keyPathString: String {
        
        return self.keyPath
    }
}


// MARK: - RelationshipContainer.ToOne: DynamicKeyPath

extension RelationshipContainer.ToOne: DynamicKeyPath {
    
    public typealias ObjectType = O
    public typealias ValueType = D
    
    public var cs_keyPathString: String {
        
        return self.keyPath
    }
}


// MARK: - RelationshipContainer.ToManyOrdered: DynamicKeyPath

extension RelationshipContainer.ToManyOrdered: DynamicKeyPath {
    
    public typealias ObjectType = O
    public typealias ValueType = D
    
    public var cs_keyPathString: String {
        
        return self.keyPath
    }
}


// MARK: - RelationshipContainer.ToManyUnordered: DynamicKeyPath

extension RelationshipContainer.ToManyUnordered: DynamicKeyPath {
    
    public typealias ObjectType = O
    public typealias ValueType = D
    
    public var cs_keyPathString: String {
        
        return self.keyPath
    }
}

