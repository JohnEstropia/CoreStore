//
//  Entity.swift
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
import ObjectiveC


// MARK: - EntityProtocol

public protocol EntityProtocol {
    
    var entityDescription: NSEntityDescription { get }
}


// MARK: Entity

public struct Entity<O: ManagedObject>: EntityProtocol {
    
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
        entityDescription.userInfo = [
            EntityIdentifier.UserInfoKey.CoreStoreManagedObjectName: String(reflecting: O.self)
        ]
        entityDescription.name = entityName
        entityDescription.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
//        entityDescription.managedObjectClassName = dynamicClassName // TODO: return to NSManagedObject
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
            attributeDescription.isOptional = property.isOptional
            attributeDescription.defaultValue = property.defaultValue
            attributeDescriptions.append(attributeDescription)
        }
        if let baseEntityAttributeDescriptions = mirror.superclassMirror.flatMap(self.initializeAttributes) {
            
            attributeDescriptions.append(contentsOf: baseEntityAttributeDescriptions)
        }
        return attributeDescriptions
    }
}


// MARK: - EntityIdentifier

internal struct EntityIdentifier: Hashable {
    
    // MARK: - Category
    
    internal enum Category: Int {
        
        case coreData
        case coreStore
    }
    
    
    // MARK: -
    
    internal let category: Category
    internal let interfacedClassName: String
    
    internal init(_ type: NSManagedObject.Type) {
        
        self.category = .coreData
        self.interfacedClassName = String(reflecting: type)
    }
    
    internal init(_ type: ManagedObject.Type) {
        
        self.category = .coreStore
        self.interfacedClassName = String(reflecting: type)
    }
    
    internal init(_ type: ManagedObjectProtocol.Type) {
        
        switch type {
            
        case let type as NSManagedObject.Type:
            self.init(type)
            
        case let type as ManagedObject.Type:
            self.init(type)
            
        default:
            CoreStore.abort("\(cs_typeName(ManagedObjectProtocol.self)) is not meant to be implemented by external types.")
        }
    }
    
    internal init(_ entityDescription: NSEntityDescription) {
        
        if let coreStoreManagedObjectName = entityDescription.userInfo?[EntityIdentifier.UserInfoKey.CoreStoreManagedObjectName] as! String? {
            
            self.category = .coreStore
            self.interfacedClassName = coreStoreManagedObjectName
        }
        else {
            
            self.category = .coreData
            self.interfacedClassName = entityDescription.managedObjectClassName!
        }
    }
    
    
    // MARK: Equatable
    
    static func == (lhs: EntityIdentifier, rhs: EntityIdentifier) -> Bool {
        
        return lhs.category == rhs.category
            && lhs.interfacedClassName == rhs.interfacedClassName
    }
    
    
    // MARK: Hashable
    
    var hashValue: Int {
    
        return self.category.hashValue
            ^ self.interfacedClassName.hashValue
    }
    
    
    // MARK: FilePrivate
    
    fileprivate enum UserInfoKey {
        
        fileprivate static let CoreStoreManagedObjectName = "CoreStoreManagedObjectName"
    }
}
