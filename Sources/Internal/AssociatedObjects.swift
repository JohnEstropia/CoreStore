//
//  NSObject+CoreStore.swift
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

internal func getAssociatedObjectForKey<T: AnyObject>(key: UnsafePointer<Void>, inObject object: AnyObject) -> T? {
    
    switch objc_getAssociatedObject(object, key) {
        
    case let associatedObject as T:
        return associatedObject
        
    case let associatedObject as WeakObject:
        return associatedObject.object as? T
        
    default:
        return nil
    }
}

internal func setAssociatedRetainedObject<T: AnyObject>(associatedObject: T?, forKey key: UnsafePointer<Void>, inObject object: AnyObject) {
    
    objc_setAssociatedObject(object, key, associatedObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

internal func setAssociatedCopiedObject<T: AnyObject>(associatedObject: T?, forKey key: UnsafePointer<Void>, inObject object: AnyObject) {
    
    objc_setAssociatedObject(object, key, associatedObject, .OBJC_ASSOCIATION_COPY_NONATOMIC)
}

internal func setAssociatedAssignedObject<T: AnyObject>(associatedObject: T?, forKey key: UnsafePointer<Void>, inObject object: AnyObject) {
    
    objc_setAssociatedObject(object, key, associatedObject, .OBJC_ASSOCIATION_ASSIGN)
}

internal func setAssociatedWeakObject<T: AnyObject>(associatedObject: T?, forKey key: UnsafePointer<Void>, inObject object: AnyObject) {
    
    if let associatedObject = associatedObject {
        
        objc_setAssociatedObject(object, key, WeakObject(associatedObject), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    else {
        
        objc_setAssociatedObject(object, key, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
