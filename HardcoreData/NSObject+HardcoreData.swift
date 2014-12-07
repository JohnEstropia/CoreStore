//
//  NSObject+HardcoreData.swift
//  HardcoreData
//
//  Copyright (c) 2014 John Rommel Estropia
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

internal extension NSObject {
    
    internal func getAssociatedObjectForKey<T: AnyObject>(key: UnsafePointer<Void>) -> T? {
        
        return objc_getAssociatedObject(self, key) as? T
    }
    
    internal func setAssociatedRetainedObject<T: AnyObject>(object: T?, forKey key: UnsafePointer<Void>) {
        
        objc_setAssociatedObject(self, key, object, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
    }
    
    internal func setAssociatedCopiedObject<T: AnyObject>(object: T?, forKey key: UnsafePointer<Void>) {
        
        objc_setAssociatedObject(self, key, object, UInt(OBJC_ASSOCIATION_COPY_NONATOMIC))
    }
    
    internal func setAssociatedAssignedObject<T: AnyObject>(object: T?, forKey key: UnsafePointer<Void>) {
        
        objc_setAssociatedObject(self, key, object, UInt(OBJC_ASSOCIATION_ASSIGN))
    }
}