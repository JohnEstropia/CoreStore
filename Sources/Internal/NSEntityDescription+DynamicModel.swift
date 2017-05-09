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
                
                var userInfo: [AnyHashable : Any] = [
                    UserInfoKey.CoreStoreManagedObjectTypeName: NSStringFromClass(newValue.type),
                    UserInfoKey.CoreStoreManagedObjectEntityName: newValue.entityName,
                    UserInfoKey.CoreStoreManagedObjectIsAbstract: newValue.isAbstract
                ]
                userInfo[UserInfoKey.CoreStoreManagedObjectVersionHashModifier] = newValue.versionHashModifier
                self.userInfo = userInfo
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
        fileprivate static let CoreStoreManagedObjectIsAbstract = "CoreStoreManagedObjectIsAbstract"
        fileprivate static let CoreStoreManagedObjectVersionHashModifier = "CoreStoreManagedObjectVersionHashModifier"
    }
}
