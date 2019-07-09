//
//  ObjectSnapshot.swift
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
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


// MARK: - ObjectSnapshot

/**
 An `ObjectSnapshot` contains "snapshot" values from a `DynamicObject` instance copied at a specific point in time.
 */
@dynamicMemberLookup
public struct ObjectSnapshot<O: DynamicObject> {
    
    // MARK: FilePrivate
    
    fileprivate var attributes: [KeyPathString: Any]
    
    // MARK: Private
    
    private init() {
        
        self.attributes = [:]
    }
}

// MARK: - ObjectSnapshot where O: NSManagedObject

extension ObjectSnapshot where O: NSManagedObject {
    
    /**
     Initializes an `ObjectSnapshot` instance by copying all attribute values from the given `NSManagedObject`.
     */
    public init(from object: O) {
        
        self.attributes = object.dictionaryWithValues(
            forKeys: Array(object.entity.attributesByName.keys)
        )
    }
    
    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<V: AllowedObjectiveCKeyPathValue>(dynamicMember member: KeyPath<O, V>) -> V {
        
        get {
            
            let key = String(keyPath: member)
            return self.attributes[key]! as! V
        }
        set {
            
            let key = String(keyPath: member)
            self.attributes[key] = newValue
        }
    }
}


// MARK: - ObjectSnapshot where O: CoreStoreObject

extension ObjectSnapshot where O: CoreStoreObject {
    
    /**
     Initializes an `ObjectSnapshot` instance by copying all attribute values from the given `CoreStoreObject`.
     */
    public init(from object: O) {
    
        var attributes: [KeyPathString: Any] = [:]
        Self.initializeAttributes(
            mirror: Mirror(reflecting: object),
            object: object,
            into: &attributes
        )
        self.attributes = attributes
    }
    
    /**
     Returns the value for the property identified by a given key.
     */
    public subscript<K: AttributeKeyPathStringConvertible>(dynamicMember member: KeyPath<O, K>) -> K.ReturnValueType {
        
        get {
            
            let key = String(keyPath: member)
            return self.attributes[key]! as! K.ReturnValueType
        }
        set {
            
            let key = String(keyPath: member)
            self.attributes[key] = newValue
        }
    }
    
    
    // MARK: Private
    
    private static func initializeAttributes(mirror: Mirror, object: CoreStoreObject, into attributes: inout [KeyPathString: Any]) {
        
        if let superClassMirror = mirror.superclassMirror {
            
            self.initializeAttributes(
                mirror: superClassMirror,
                object: object,
                into: &attributes
            )
        }
        for child in mirror.children {
            
            switch child.value {
                
            case let property as AttributeProtocol:
                attributes[property.keyPath] = property.valueForSnapshot
                
            default:
                continue
            }
        }
    }
}
