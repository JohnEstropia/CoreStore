//
//  Prototype.swift
//  CoreStore
//
//  Created by John Estropia on 2017/04/03.
//  Copyright © 2017 John Rommel Estropia. All rights reserved.
//

import CoreGraphics
import Foundation
import ObjectiveC


public protocol ManagedObjectProtocol: class {}

public protocol EntityProtocol {
    
    var entityDescription: NSEntityDescription { get }
}

internal protocol AttributeProtocol: class {
    
    static var attributeType: NSAttributeType { get }
    var keyPath: String { get }
    var defaultValue: Any? { get }
    var accessRawObject: () -> NSManagedObject { get set }
}

open class CoreStoreManagedObject: ManagedObjectProtocol {
    
    internal let rawObject: NSManagedObject?
    internal let isMeta: Bool
    
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
    internal var dynamicClass: AnyClass {
        
        return NSClassFromString(self.entityDescription.managedObjectClassName!)!
    }
    
    public init(_ entityName: String) {
        
        let dynamicClassName = String(reflecting: O.self)
            .appending("__\(entityName)")
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "<", with: "_")
            .replacingOccurrences(of: ">", with: "_")
        // TODO: assign entityName through ModelVersion and
        // TODO: set NSEntityDescription.userInfo AnyEntity
        let newClass: AnyClass?
            
        if NSClassFromString(dynamicClassName) == nil {
            
            newClass = objc_allocateClassPair(NSManagedObject.self, dynamicClassName, 0)
        }
        else {
            
            newClass = nil
        }
        
        defer {
            
            if let newClass = newClass {
                
                objc_registerClassPair(newClass)
            }
        }
        
        let entityDescription = NSEntityDescription()
        entityDescription.name = entityName
        entityDescription.managedObjectClassName = dynamicClassName // TODO: return to NSManagedObject
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
    
    internal static var meta: Self {
        
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
    
    @inline(__always)
    public static func `where`(_ condition: (Self) -> Where) -> Where  {
        
        return condition(self.meta)
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
    
    public static func == (_ attribute: AttributeContainer<O>.Required<V>, _ value: V) -> Where {
        
        return Where(attribute.keyPath, isEqualTo: value)
    }
    public static func < (_ attribute: AttributeContainer<O>.Required<V>, _ value: V) -> Where {
        
        return Where("%K < %@", attribute.keyPath, value)
    }
    public static func > (_ attribute: AttributeContainer<O>.Required<V>, _ value: V) -> Where {
        
        return Where("%K > %@", attribute.keyPath, value)
    }
    public static func <= (_ attribute: AttributeContainer<O>.Required<V>, _ value: V) -> Where {
        
        return Where("%K <= %@", attribute.keyPath, value)
    }
    public static func >= (_ attribute: AttributeContainer<O>.Required<V>, _ value: V) -> Where {
        
        return Where("%K >= %@", attribute.keyPath, value)
    }
    public static func != (_ attribute: AttributeContainer<O>.Required<V>, _ value: V) -> Where {
        
        return Where("%K != %@", attribute.keyPath, value)
    }
}
public extension AttributeContainer.Optional where V: CVarArg {
    
    public static func == (_ attribute: AttributeContainer<O>.Optional<V>, _ value: V?) -> Where {
        
        return Where(attribute.keyPath, isEqualTo: value)
    }
}

public final class ModelVersion {
    
    public let version: String
    internal let entities: Set<NSEntityDescription>
    internal let entityConfigurations: [String: Set<NSEntityDescription>]
    
    public convenience init(version: String, entities: [EntityProtocol]) {
        
        self.init(version: version, configurationEntities: [Into.defaultConfigurationName: entities])
    }
    
    public required init(version: String, configurationEntities: [String: [EntityProtocol]]) {
        
        self.version = version
        
        var entityConfigurations: [String: Set<NSEntityDescription>] = [:]
        for (configuration, entities) in configurationEntities {
            
            entityConfigurations[configuration] = Set(entities.map({ $0.entityDescription }))
        }
        let allEntities = Set(entityConfigurations.map({ $0.value }).joined())
        entityConfigurations[Into.defaultConfigurationName] = allEntities
        
        self.entityConfigurations = entityConfigurations
        self.entities = allEntities
    }
    
    internal func createModel() -> NSManagedObjectModel {
        
        let model = NSManagedObjectModel()
        model.entities = self.entities.sorted(by: { $0.name! < $1.name! })
        for (configuration, entities) in self.entityConfigurations {
            
            model.setEntities(
                entities.sorted(by: { $0.name! < $1.name! }),
                forConfigurationName: configuration
            )
        }
        return model
    }
}
