//
//  NSEntityDescription+DynamicModel.swift
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


// MARK: - NSEntityDescription

internal extension NSEntityDescription {
    
    @nonobjc
    internal var dynamicObjectType: DynamicObject.Type? {
        
        guard let userInfo = self.userInfo,
            let typeName = userInfo[UserInfoKey.CoreStoreManagedObjectTypeName] as! String? else {
                
                return nil
        }
        return (NSClassFromString(typeName) as! DynamicObject.Type)
    }
    
    @nonobjc
    internal var coreStoreEntity: DynamicEntity? {
        
        get {
            
            guard let userInfo = self.userInfo,
                let typeName = userInfo[UserInfoKey.CoreStoreManagedObjectTypeName] as! String?,
                let entityName = userInfo[UserInfoKey.CoreStoreManagedObjectEntityName] as! String?,
                let isAbstract = userInfo[UserInfoKey.CoreStoreManagedObjectIsAbstract] as! Bool? else {
                    
                    return nil
            }
            return DynamicEntity(
                type: NSClassFromString(typeName) as! CoreStoreObject.Type,
                entityName: entityName,
                isAbstract: isAbstract,
                versionHashModifier: userInfo[UserInfoKey.CoreStoreManagedObjectVersionHashModifier] as! String?
            )
        }
        set {
            
            if let newValue = newValue {
                
                cs_setUserInfo { (userInfo) in
                    
                    userInfo[UserInfoKey.CoreStoreManagedObjectTypeName] = NSStringFromClass(newValue.type)
                    userInfo[UserInfoKey.CoreStoreManagedObjectEntityName] = newValue.entityName
                    userInfo[UserInfoKey.CoreStoreManagedObjectIsAbstract] = newValue.isAbstract
                    userInfo[UserInfoKey.CoreStoreManagedObjectVersionHashModifier] = newValue.versionHashModifier
                }
            }
            else {
                
                cs_setUserInfo { (userInfo) in
                    
                    userInfo[UserInfoKey.CoreStoreManagedObjectTypeName] = nil
                    userInfo[UserInfoKey.CoreStoreManagedObjectEntityName] = nil
                    userInfo[UserInfoKey.CoreStoreManagedObjectIsAbstract] = nil
                    userInfo[UserInfoKey.CoreStoreManagedObjectVersionHashModifier] = nil
                }
            }
        }
    }
    
    @nonobjc
    internal var keyPathsByAffectedKeyPaths: [KeyPathString: Set<KeyPathString>] {
        
        get {
            
            if let userInfo = self.userInfo,
                let value = userInfo[UserInfoKey.CoreStoreManagedObjectKeyPathsByAffectedKeyPaths] {
                
                return value as! [KeyPathString: Set<KeyPathString>]
            }
            return [:]
        }
        set {
            
            cs_setUserInfo { (userInfo) in
                
                userInfo[UserInfoKey.CoreStoreManagedObjectKeyPathsByAffectedKeyPaths] = newValue
            }
        }
    }
    
    @nonobjc
    internal var customGetterSetterByKeyPaths: [KeyPathString: CoreStoreManagedObject.CustomGetterSetter] {
        
        get {
            
            if let userInfo = self.userInfo,
                let value = userInfo[UserInfoKey.CoreStoreManagedObjectCustomGetterSetterByKeyPaths] {
                
                return value as! [KeyPathString: CoreStoreManagedObject.CustomGetterSetter]
            }
            return [:]
        }
        set {
            
            cs_setUserInfo { (userInfo) in
                
                userInfo[UserInfoKey.CoreStoreManagedObjectCustomGetterSetterByKeyPaths] = newValue
            }
        }
    }
    
    
    // MARK: Private
    
    // MARK: - UserInfoKey
    
    private enum UserInfoKey {
        
        fileprivate static let CoreStoreManagedObjectTypeName = "CoreStoreManagedObjectTypeName"
        fileprivate static let CoreStoreManagedObjectEntityName = "CoreStoreManagedObjectEntityName"
        fileprivate static let CoreStoreManagedObjectIsAbstract = "CoreStoreManagedObjectIsAbstract"
        fileprivate static let CoreStoreManagedObjectVersionHashModifier = "CoreStoreManagedObjectVersionHashModifier"
        
        fileprivate static let CoreStoreManagedObjectKeyPathsByAffectedKeyPaths = "CoreStoreManagedObjectKeyPathsByAffectedKeyPaths"
        fileprivate static let CoreStoreManagedObjectCustomGetterSetterByKeyPaths = "CoreStoreManagedObjectCustomGetterSetterByKeyPaths"
        
    }
    
    private func cs_setUserInfo(_ closure: (_ userInfo: inout [AnyHashable: Any]) -> Void) {
        
        var userInfo = self.userInfo ?? [:]
        closure(&userInfo)
        self.userInfo = userInfo
    }
}
