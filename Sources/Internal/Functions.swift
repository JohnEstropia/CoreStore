//
//  Functions.swift
//  CoreStore
//
//  Copyright © 2014 John Rommel Estropia
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


// MARK: - Custom AutoreleasePool

internal func cs_autoreleasepool(@noescape closure: () -> Void) {
    
    autoreleasepool(closure)
}

internal func cs_autoreleasepool<T>(@noescape closure: () -> T) -> T {
    
    var closureValue: T!
    autoreleasepool {
        
        closureValue = closure()
    }
    
    return closureValue
}

internal func cs_autoreleasepool<T>(@noescape closure: () throws -> T) throws -> T {
    
    var closureValue: T!
    var closureError: ErrorType?
    autoreleasepool {
        
        do {
            
            closureValue = try closure()
        }
        catch {
            
            closureError = error
        }
    }
    
    if let closureError = closureError {
        
        throw closureError
    }
    return closureValue
}

internal func cs_autoreleasepool(@noescape closure: () throws -> Void) throws {
    
    var closureError: ErrorType?
    autoreleasepool {
        
        do {
            
            try closure()
        }
        catch {
            
            closureError = error
        }
    }
    
    if let closureError = closureError {
        
        throw closureError
    }
}

internal func cs_getAssociatedObjectForKey<T: AnyObject>(key: UnsafePointer<Void>, inObject object: AnyObject) -> T? {
    
    switch objc_getAssociatedObject(object, key) {
        
    case let associatedObject as T:
        return associatedObject
        
    case let associatedObject as WeakObject:
        return associatedObject.object as? T
        
    default:
        return nil
    }
}

internal func cs_setAssociatedRetainedObject<T: AnyObject>(associatedObject: T?, forKey key: UnsafePointer<Void>, inObject object: AnyObject) {
    
    objc_setAssociatedObject(object, key, associatedObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

internal func cs_setAssociatedCopiedObject<T: AnyObject>(associatedObject: T?, forKey key: UnsafePointer<Void>, inObject object: AnyObject) {
    
    objc_setAssociatedObject(object, key, associatedObject, .OBJC_ASSOCIATION_COPY_NONATOMIC)
}

internal func cs_setAssociatedWeakObject<T: AnyObject>(associatedObject: T?, forKey key: UnsafePointer<Void>, inObject object: AnyObject) {
    
    if let associatedObject = associatedObject {
        
        objc_setAssociatedObject(object, key, WeakObject(associatedObject), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    else {
        
        objc_setAssociatedObject(object, key, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}


// MARK: Printing Utilities

internal func cs_typeName<T>(value: T) -> String {
    
    return "'\(String(reflecting: value.dynamicType))'"
}

internal func cs_typeName<T>(value: T.Type) -> String {
    
    return "'\(value)'"
}

internal func cs_typeName(value: AnyClass) -> String {
    
    return "'\(value)'"
}

internal func cs_typeName(name: String?) -> String {
    
    return "<\(name ?? "unknown")>"
}
