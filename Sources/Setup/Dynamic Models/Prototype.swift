//
//  Prototype.swift
//  CoreStore
//
//  Created by John Estropia on 2017/04/03.
//  Copyright © 2017 John Rommel Estropia. All rights reserved.
//

import CoreGraphics
import Foundation


public protocol ManagedObjectProtocol: class {}

public protocol EntityProtocol {
    
    var entityDescription: NSEntityDescription { get }
}

protocol AttributeProtocol: class {
    
    static var attributeType: NSAttributeType { get }
    var keyPath: String { get }
    var defaultValue: Any? { get }
    var accessRawObject: () -> NSManagedObject { get set }
}

open class CoreStoreManagedObject: ManagedObjectProtocol {
    
    let rawObject: NSManagedObject?
    let isMeta: Bool
    
    public required init(_ object: NSManagedObject?) {
        
        self.isMeta = object == nil
        self.rawObject = object
        
        guard let object = object else {
            
            return
        }
        self.initializeAttributes(Mirror(reflecting: self), { [unowned object] in object })
    }
    
    private func initializeAttributes(_ mirror: Mirror, _ accessRawObject: @escaping () -> NSManagedObject) {
        
        _ = mirror.superclassMirror.flatMap({ self.initializeAttributes($0, accessRawObject) })
        for child in mirror.children {
            
            guard case let property as AttributeProtocol = child.value else {
                
                continue
            }
            property.accessRawObject = accessRawObject
        }
    }
}

public struct Entity<O: CoreStoreManagedObject>: EntityProtocol {
    
    public let entityDescription: NSEntityDescription
    
    public init(_ entityName: String) {
        
        let entityDescription = NSEntityDescription()
        entityDescription.name = entityName
        entityDescription.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        entityDescription.properties = type(of: self).initializeAttributes(Mirror(reflecting: O.meta))
        
        self.entityDescription = entityDescription
    }
    
    private static func initializeAttributes(_ mirror: Mirror) -> [NSAttributeDescription] {
        
        var attributeDescriptions: [NSAttributeDescription] = []
        for child in mirror.children {
            
            guard case let property as AttributeProtocol = child.value else {
                
                continue
            }
            let attributeDescription = NSAttributeDescription()
            attributeDescription.name = property.keyPath
            attributeDescription.attributeType = type(of: property).attributeType
            attributeDescription.isOptional = false
            attributeDescription.defaultValue = property.defaultValue
            attributeDescriptions.append(attributeDescription)
        }
        if let baseEntityAttributeDescriptions = mirror.superclassMirror.flatMap(self.initializeAttributes) {
            
            attributeDescriptions.append(contentsOf: baseEntityAttributeDescriptions)
        }
        return attributeDescriptions
    }
}

public enum AttributeContainer<O: ManagedObjectProtocol> {
    
    public final class Required<V: ImportableAttributeType>: AttributeProtocol {
        
        static var attributeType: NSAttributeType { return V.cs_rawAttributeType }
        
        let keyPath: String
        let defaultValue: Any?
        var accessRawObject: () -> NSManagedObject = { fatalError("\(O.self) property values should not be accessed") }
        
        var value: V {
            
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
        
        public init(_ keyPath: String, `default`: V = V.cs_emptyValue()) {
            
            self.keyPath = keyPath
            self.defaultValue = `default`
        }
    }
    
    public final class Optional<V: ImportableAttributeType>: AttributeProtocol {
        
        static var attributeType: NSAttributeType { return V.cs_rawAttributeType }
        
        let keyPath: String
        let defaultValue: Any?
        var accessRawObject: () -> NSManagedObject = { fatalError("\(O.self) property values should not be accessed") }
        
        var value: V? {
            
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
        
        public init(_ keyPath: String, `default`: V? = nil) {
            
            self.keyPath = keyPath
            self.defaultValue = `default`
        }
    }
}

public extension ManagedObjectProtocol where Self: CoreStoreManagedObject {
    
    public typealias Attribute = AttributeContainer<Self>
    
    public static var meta: Self {
        
        return self.init(nil)
    }
    
    @inline(__always)
    public static func keyPath<O: CoreStoreManagedObject, V: ImportableAttributeType>(_ attribute: (Self) -> AttributeContainer<O>.Required<V>) -> String  {
        
        return attribute(self.meta).keyPath
    }
    
    @inline(__always)
    public static func keyPath<O: CoreStoreManagedObject, V: ImportableAttributeType>(_ attribute: (Self) -> AttributeContainer<O>.Optional<V>) -> String  {
        
        return attribute(self.meta).keyPath
    }
}


//: ### Convenience Operators

infix operator .= : AssignmentPrecedence
public func .= <O: ManagedObjectProtocol, V: ImportableAttributeType>(_ attribute: AttributeContainer<O>.Required<V>, _ value: V) {
    
    attribute.value = value
}
public func .= <O: ManagedObjectProtocol, V: ImportableAttributeType>(_ attribute: AttributeContainer<O>.Optional<V>, _ value: V?) {
    
    attribute.value = value
}

postfix operator *
public postfix func * <O: ManagedObjectProtocol, V: ImportableAttributeType>(_ attribute: AttributeContainer<O>.Required<V>) -> V {
    
    return attribute.value
}
public postfix func * <O: ManagedObjectProtocol, V: ImportableAttributeType>(_ attribute: AttributeContainer<O>.Optional<V>) -> V? {
    
    return attribute.value
}

public extension AttributeContainer.Required where V: CVarArg {
    
    public static func == (_ attribute: AttributeContainer<O>.Required<V>, _ value: V) -> NSPredicate {
        
        return NSPredicate(format: "%K == %@", argumentArray: [attribute.keyPath, value])
    }
    public static func < (_ attribute: AttributeContainer<O>.Required<V>, _ value: V) -> NSPredicate {
        
        return NSPredicate(format: "%K < %@", argumentArray: [attribute.keyPath, value])
    }
    public static func > (_ attribute: AttributeContainer<O>.Required<V>, _ value: V) -> NSPredicate {
        
        return NSPredicate(format: "%K > %@", argumentArray: [attribute.keyPath, value])
    }
    public static func <= (_ attribute: AttributeContainer<O>.Required<V>, _ value: V) -> NSPredicate {
        
        return NSPredicate(format: "%K <= %@", argumentArray: [attribute.keyPath, value])
    }
    public static func >= (_ attribute: AttributeContainer<O>.Required<V>, _ value: V) -> NSPredicate {
        
        return NSPredicate(format: "%K >= %@", argumentArray: [attribute.keyPath, value])
    }
    public static func != (_ attribute: AttributeContainer<O>.Required<V>, _ value: V) -> NSPredicate {
        
        return NSPredicate(format: "%K != %@", argumentArray: [attribute.keyPath, value])
    }
}
public extension AttributeContainer.Optional where V: CVarArg {
    
    public static func == (_ attribute: AttributeContainer<O>.Optional<V>, _ value: V?) -> NSPredicate {
        
        if let value = value {
            
            return NSPredicate(format: "%K == %@", argumentArray: [attribute.keyPath, value])
        }
        else {
            
            return NSPredicate(format: "%K == nil", attribute.keyPath)
        }
    }
}

protocol ModelVersionProtocol: class {
    
    static var version: String { get }
    static var entities: [EntityProtocol] { get }
}

extension ModelVersionProtocol {
    
    static func entity<O: CoreStoreManagedObject>(for type: O.Type) -> Entity<O> {
        
        return self.entities.first(where: { $0 is Entity<O> })! as! Entity<O>
    }
}
