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
    
    var type: ManagedObject.Type { get }
    var entityName: EntityName { get }
}


// MARK: Entity

public struct Entity<O: ManagedObject>: EntityProtocol {
    
    public init(_ entityName: String) {
        
        self.type = O.self
        self.entityName = entityName
    }
    
    // MARK: EntityProtocol
    
    public let type: ManagedObject.Type
    public let entityName: EntityName
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
        
        if let entity = entityDescription.anyEntity {
            
            self.category = .coreStore
            self.interfacedClassName = NSStringFromClass(entity.type)
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
}


// MARK: - NSEntityDescription

internal extension NSEntityDescription {
    
    @nonobjc
    internal var anyEntity: ObjectModel.AnyEntity? {
        
        get {
            
            guard let userInfo = self.userInfo,
                let typeName = userInfo[UserInfoKey.CoreStoreManagedObjectTypeName] as! String?,
                let entityName = userInfo[UserInfoKey.CoreStoreManagedObjectEntityName] as! String? else {
                
                return nil
            }
            return ObjectModel.AnyEntity(
                type: NSClassFromString(typeName) as! ManagedObject.Type,
                entityName: entityName
            )
        }
        set {
         
            if let newValue = newValue {
                
                self.userInfo = [
                    UserInfoKey.CoreStoreManagedObjectTypeName: NSStringFromClass(newValue.type),
                    UserInfoKey.CoreStoreManagedObjectEntityName: newValue.entityName
                ]
            }
            else {
                
                self.userInfo = [:]
            }
        }
    }
    
    
    // MARK: Private
    
    // MARK: - UserInfoKey
    
    fileprivate enum UserInfoKey {
        
        fileprivate static let CoreStoreManagedObjectTypeName = "CoreStoreManagedObjectTypeName"
        fileprivate static let CoreStoreManagedObjectEntityName = "CoreStoreManagedObjectEntityName"
    }
}
