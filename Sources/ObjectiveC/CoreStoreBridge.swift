//
//  CoreStoreObjectiveCType.swift
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


// MARK: - CoreStoreObjectiveCType

public protocol CoreStoreObjectiveCType: class, AnyObject {
    
    associatedtype SwiftType
    
    var bridgeToSwift: SwiftType { get }
    
    init(_ swiftValue: SwiftType)
}


// MARK: - CoreStoreSwiftType

public protocol CoreStoreSwiftType {
    
    associatedtype ObjectiveCType: CoreStoreObjectiveCType
    
    var bridgeToObjectiveC: ObjectiveCType { get }
}

public extension CoreStoreSwiftType where Self == ObjectiveCType.SwiftType {
    
    public var bridgeToObjectiveC: ObjectiveCType {
        
        return ObjectiveCType(self)
    }
}


// MARK: - Internal

internal func bridge<T: CoreStoreSwiftType where T == T.ObjectiveCType.SwiftType>(@noescape closure: () -> T) -> T.ObjectiveCType {
    
    return closure().bridgeToObjectiveC
}

internal func bridge<T: CoreStoreSwiftType where T == T.ObjectiveCType.SwiftType>(@noescape closure: () -> T?) -> T.ObjectiveCType? {
    
    return closure()?.bridgeToObjectiveC
}

internal func bridge<T: CoreStoreSwiftType where T == T.ObjectiveCType.SwiftType>(@noescape closure: () throws -> T) throws -> T.ObjectiveCType {
    
    do {
        
        return try closure().bridgeToObjectiveC
    }
    catch {
        
        throw error.bridgeToObjectiveC
    }
}

internal func bridge(@noescape closure: () throws -> Void) throws {
    
    do {
        
        try closure()
    }
    catch {
        
        throw error.bridgeToObjectiveC
    }
}

internal func bridge<T: CoreStoreSwiftType>(error: NSErrorPointer, @noescape _ closure: () throws -> T) -> T.ObjectiveCType? {
    
    do {
        
        let result = try closure()
        error.memory = nil
        return result.bridgeToObjectiveC
    }
    catch let swiftError {
        
        error.memory = swiftError.bridgeToObjectiveC
        return nil
    }
}


