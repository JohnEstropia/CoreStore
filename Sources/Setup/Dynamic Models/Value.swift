//
//  Value.swift
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


// MARK: Operators

infix operator .= : AssignmentPrecedence


// MARK: - DynamicObject

public extension DynamicObject where Self: CoreStoreObject {
    
    public typealias Value = ValueContainer<Self>
}


// MARK: - ValueContainer

public enum ValueContainer<O: CoreStoreObject> {
    
    // MARK: - Required
    
    public final class Required<V: ImportableAttributeType>: AttributeProtocol {
        
        public static func .= (_ attribute: ValueContainer<O>.Required<V>, _ value: V) {
            
            attribute.value = value
        }
        
        public static func .=<O2: CoreStoreObject> (_ attribute: ValueContainer<O>.Required<V>, _ attribute2: ValueContainer<O2>.Required<V>) {
            
            attribute.value = attribute2.value
        }
        
        public init(_ keyPath: KeyPath, `default`: V = V.cs_emptyValue(), isIndexed: Bool = false, isTransient: Bool = false) {
            
            self.keyPath = keyPath
            self.isIndexed = isIndexed
            self.isTransient = isTransient
            self.defaultValue = `default`.cs_toImportableNativeType()
        }
        
        public var value: V {
            
            get {
                
                return self.accessRawObject()
                    .getValue(
                        forKvcKey: self.keyPath,
                        didGetValue: { V.cs_fromImportableNativeType($0 as! V.ImportableNativeType)! }
                    )
            }
            set {
                
                self.accessRawObject()
                    .setValue(
                        newValue,
                        forKvcKey: self.keyPath,
                        willSetValue: { $0.cs_toImportableNativeType() }
                    )
            }
        }
        
        
        // MARK: AttributeProtocol
        
        internal static var attributeType: NSAttributeType {
            
            return V.cs_rawAttributeType
        }
        
        public let keyPath: KeyPath
        
        internal let isOptional = false
        internal let isIndexed: Bool
        internal let isTransient: Bool
        internal let defaultValue: Any?
        
        internal var accessRawObject: () -> NSManagedObject = {
            
            CoreStore.abort("Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types.")
        }
    }
    
    
    // MARK: - Optional
    
    public final class Optional<V: ImportableAttributeType>: AttributeProtocol {
        
        public static func .= (_ attribute: ValueContainer<O>.Optional<V>, _ value: V?) {
            
            attribute.value = value
        }
        
        public static func .=<O2: CoreStoreObject> (_ attribute: ValueContainer<O>.Optional<V>, _ attribute2: ValueContainer<O2>.Optional<V>) {
            
            attribute.value = attribute2.value
        }
        
        public static func .=<O2: CoreStoreObject> (_ attribute: ValueContainer<O>.Optional<V>, _ attribute2: ValueContainer<O2>.Required<V>) {
            
            attribute.value = attribute2.value
        }
        
        public init(_ keyPath: KeyPath, `default`: V? = nil, isTransient: Bool = false) {
            
            self.keyPath = keyPath
            self.isTransient = isTransient
            self.defaultValue = `default`?.cs_toImportableNativeType()
        }
        
        public var value: V? {
            
            get {
                
                return self.accessRawObject()
                    .getValue(
                        forKvcKey: self.keyPath,
                        didGetValue: { ($0 as! V.ImportableNativeType?).flatMap(V.cs_fromImportableNativeType) }
                    )
            }
            set {
                
                self.accessRawObject()
                    .setValue(
                        newValue,
                        forKvcKey: self.keyPath,
                        willSetValue: { $0?.cs_toImportableNativeType() }
                    )
            }
        }
        
        
        // MARK: AttributeProtocol
        
        internal static var attributeType: NSAttributeType {
            
            return V.cs_rawAttributeType
        }
        
        public let keyPath: KeyPath
        internal let isOptional = true
        internal let isIndexed = false
        internal let isTransient: Bool
        internal let defaultValue: Any?
        
        internal var accessRawObject: () -> NSManagedObject = {
            
            CoreStore.abort("Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types.")
        }
    }
}


// MARK: - AttributeProtocol

internal protocol AttributeProtocol: class {
    
    static var attributeType: NSAttributeType { get }
    
    var keyPath: KeyPath { get }
    var isOptional: Bool { get }
    var isIndexed: Bool { get }
    var isTransient: Bool { get }
    var defaultValue: Any? { get }
    var accessRawObject: () -> NSManagedObject { get set }
}
