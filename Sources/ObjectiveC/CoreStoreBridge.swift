//
//  CoreStoreBridge.swift
//  CoreStore
//
//  Copyright © 2016 John Rommel Estropia
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


// MARK: - CoreStoreBridge

internal protocol CoreStoreBridge: class, AnyObject {
    
    associatedtype SwiftType
    
    var swift: SwiftType { get }
    
    init(_ swiftObject: SwiftType)
}


// MARK: - CoreStoreBridgeable

internal protocol CoreStoreBridgeable {
    
    associatedtype ObjCType: CoreStoreBridge
    
    var objc: ObjCType { get }
}

internal extension CoreStoreBridgeable where Self == ObjCType.SwiftType {
    
    var objc: ObjCType {
        
        return ObjCType(self)
    }
}


// MARK: - Internal

internal func bridge<T: CoreStoreBridgeable where T == T.ObjCType.SwiftType>(@noescape closure: () -> T) -> T.ObjCType {
    
    return closure().objc
}

internal func bridge<T: CoreStoreBridgeable where T == T.ObjCType.SwiftType>(@noescape closure: () throws -> T) throws -> T.ObjCType {
    
    do {
        
        return try closure().objc
    }
    catch {
        
        throw error.objc
    }
}

internal func bridge(@noescape closure: () throws -> Void) throws {
    
    do {
        
        try closure()
    }
    catch {
        
        throw error.objc
    }
}


