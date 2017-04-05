//
//  Attribute.swift
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
postfix operator *


// MARK: - AttributeContainer

public enum AttributeContainer<O: ManagedObjectProtocol> {
    
    // MARK: - Required
    
    public final class Required<V: ImportableAttributeType>: AttributeProtocol {
        
        public static func .= (_ attribute: AttributeContainer<O>.Required<V>, _ value: V) {
            
            attribute.value = value
        }
        
        public static postfix func * (_ attribute: AttributeContainer<O>.Required<V>) -> V {
            
            return attribute.value
        }
        
        public let keyPath: String
        
        public init(_ keyPath: String, `default`: V = V.cs_emptyValue()) {
            
            self.keyPath = keyPath
            self.defaultValue = `default`.cs_toImportableNativeType()
        }
        
        public var value: V {
            
            get {
                
                let object = self.accessRawObject()
                let key = self.keyPath
                let value = object.value(forKey: key)! as! V.ImportableNativeType
                return V.cs_fromImportableNativeType(value)!
            }
            set {
                
                let object = self.accessRawObject()
                let key = self.keyPath
                object.setValue(newValue.cs_toImportableNativeType(), forKey: key)
            }
        }
        
        // MARK: Internal
        
        internal static var attributeType: NSAttributeType {
            
            return V.cs_rawAttributeType
        }
        
        internal let defaultValue: Any?
        internal let isOptional = false
        
        internal var accessRawObject: () -> NSManagedObject = {
            
            fatalError("\(O.self) property values should not be accessed")
        }
    }
    
    
    // MARK: - Optional
    
    public final class Optional<V: ImportableAttributeType>: AttributeProtocol {
        
        public static func .= (_ attribute: AttributeContainer<O>.Optional<V>, _ value: V?) {
            
            attribute.value = value
        }
        
        public static postfix func * (_ attribute: AttributeContainer<O>.Optional<V>) -> V? {
            
            return attribute.value
        }
        
        public let keyPath: String
        
        public init(_ keyPath: String, `default`: V? = nil) {
            
            self.keyPath = keyPath
            self.defaultValue = `default`?.cs_toImportableNativeType()
        }
        
        public var value: V? {
            
            get {
                
                let object = self.accessRawObject()
                let key = self.keyPath
                guard let value = object.value(forKey: key) as! V.ImportableNativeType? else {
                    
                    return nil
                }
                return V.cs_fromImportableNativeType(value)
            }
            set {
                
                let object = self.accessRawObject()
                let key = self.keyPath
                object.setValue(newValue?.cs_toImportableNativeType(), forKey: key)
            }
        }
        
        
        // MARK: Internal
        
        internal static var attributeType: NSAttributeType {
            
            return V.cs_rawAttributeType
        }
        
        internal let defaultValue: Any?
        internal let isOptional = true
        internal var accessRawObject: () -> NSManagedObject = {
            
            fatalError("\(O.self) property values should not be accessed")
        }
    }
}


// MARK: - AttributeProtocol

internal protocol AttributeProtocol: class {
    
    static var attributeType: NSAttributeType { get }
    
    var keyPath: String { get }
    var isOptional: Bool { get }
    var defaultValue: Any? { get }
    var accessRawObject: () -> NSManagedObject { get set }
}
