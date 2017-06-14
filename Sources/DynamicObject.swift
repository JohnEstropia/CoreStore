//
//  DynamicObject.swift
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


// MARK: - DynamicObject

/**
 All CoreStore's utilities are designed around `DynamicObject` instances. `NSManagedObject` and `CoreStoreObject` instances all conform to `DynamicObject`.
 */
public protocol DynamicObject: class {
    
    /**
     Used internally by CoreStore. Do not call directly.
     */
    static func cs_forceCreate(entityDescription: NSEntityDescription, into context: NSManagedObjectContext, assignTo store: NSPersistentStore) -> Self
    
    /**
     Used internally by CoreStore. Do not call directly.
     */
    static func cs_fromRaw(object: NSManagedObject) -> Self
    
    /**
     Used internally by CoreStore. Do not call directly.
     */
    static func cs_matches(object: NSManagedObject) -> Bool
    
    /**
     Used internally by CoreStore. Do not call directly.
     */
    func cs_id() -> NSManagedObjectID
    
    /**
     Used internally by CoreStore. Do not call directly.
     */
    func cs_toRaw() -> NSManagedObject
}


// MARK: - NSManagedObject

extension NSManagedObject: DynamicObject {
    
    // MARK: DynamicObject
    
    public class func cs_forceCreate(entityDescription: NSEntityDescription, into context: NSManagedObjectContext, assignTo store: NSPersistentStore) -> Self {
        
        let object = self.init(entity: entityDescription, insertInto: context)
        defer {
            
            context.assign(object, to: store)
        }
        return object
    }
    
    public class func cs_fromRaw(object: NSManagedObject) -> Self {
        
        @inline(__always)
        func forceCast<T: NSManagedObject>(_ value: Any) -> T {
            
            return value as! T
        }
        return forceCast(object)
    }
    
    public static func cs_matches(object: NSManagedObject) -> Bool {
        
        return object.isKind(of: self)
    }
    
    public func cs_id() -> NSManagedObjectID {
        
        return self.objectID
    }
    
    public func cs_toRaw() -> NSManagedObject {
        
        return self
    }
}


// MARK: - CoreStoreObject

extension CoreStoreObject {
    
    // MARK: DynamicObject
    
    public class func cs_forceCreate(entityDescription: NSEntityDescription, into context: NSManagedObjectContext, assignTo store: NSPersistentStore) -> Self {
        
        let type = NSClassFromString(entityDescription.managedObjectClassName!)! as! NSManagedObject.Type
        let object = type.init(entity: entityDescription, insertInto: context)
        defer {
            
            context.assign(object, to: store)
        }
        return self.cs_fromRaw(object: object)
    }
    
    public class func cs_fromRaw(object: NSManagedObject) -> Self {
        
        if let coreStoreObject = object.coreStoreObject {
            
            @inline(__always)
            func forceCast<T: CoreStoreObject>(_ value: CoreStoreObject) -> T {
                
                return value as! T
            }
            return forceCast(coreStoreObject)
        }
        let coreStoreObject = self.init(rawObject: object)
        object.coreStoreObject = coreStoreObject
        return coreStoreObject
    }
    
    public static func cs_matches(object: NSManagedObject) -> Bool {
        
        guard let type = object.entity.coreStoreEntity?.type else {
            
            return false
        }
        return (self as AnyClass).isSubclass(of: type as AnyClass)
    }
    
    public func cs_id() -> NSManagedObjectID {
        
        return self.rawObject!.objectID
    }
    
    public func cs_toRaw() -> NSManagedObject {
        
        return self.rawObject!
    }
}
