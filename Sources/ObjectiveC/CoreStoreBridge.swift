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


// MARK: - CoreStoreObjectiveCType

/**
 `CoreStoreObjectiveCType`s are Objective-C accessible classes that represent CoreStore's Swift types.
 */
public protocol CoreStoreObjectiveCType: class, AnyObject {
    
    /**
     The corresponding Swift type
     */
    associatedtype SwiftType
    
    /**
     The bridged Swift instance
     */
    var bridgeToSwift: SwiftType { get }
    
    /**
     Initializes this instance with the Swift instance to bridge from
     */
    init(_ swiftValue: SwiftType)
}


// MARK: - CoreStoreSwiftType

/**
 `CoreStoreSwiftType`s are CoreStore's Swift types that are bridgeable to Objective-C.
 */
public protocol CoreStoreSwiftType {
    
    /**
     The corresponding Objective-C type
     */
    associatedtype ObjectiveCType
    
    /**
     The bridged Objective-C instance
     */
    var bridgeToObjectiveC: ObjectiveCType { get }
}

public extension CoreStoreSwiftType where ObjectiveCType: CoreStoreObjectiveCType, Self == ObjectiveCType.SwiftType {
    
    public var bridgeToObjectiveC: ObjectiveCType {
        
        return ObjectiveCType(self)
    }
}


// MARK: - Internal

internal func bridge<T: CoreStoreSwiftType where T.ObjectiveCType: CoreStoreObjectiveCType, T == T.ObjectiveCType.SwiftType>(@noescape closure: () -> T) -> T.ObjectiveCType {
    
    return closure().bridgeToObjectiveC
}

internal func bridge<T: CoreStoreSwiftType where T.ObjectiveCType: CoreStoreObjectiveCType, T == T.ObjectiveCType.SwiftType>(@noescape closure: () -> T?) -> T.ObjectiveCType? {
    
    return closure()?.bridgeToObjectiveC
}

internal func bridge<T: CoreStoreSwiftType where T.ObjectiveCType: CoreStoreObjectiveCType, T == T.ObjectiveCType.SwiftType>(@noescape closure: () throws -> T) throws -> T.ObjectiveCType {
    
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

internal func bridge(error: NSErrorPointer, @noescape _ closure: () throws -> Void) -> Bool {
    
    do {
        
        try closure()
        error.memory = nil
        return true
    }
    catch let swiftError {
        
        error.memory = swiftError.bridgeToObjectiveC
        return false
    }
}

internal func bridge<T>(error: NSErrorPointer, @noescape _ closure: () throws -> T?) -> T? {
    
    do {
        
        let result = try closure()
        error.memory = nil
        return result
    }
    catch let swiftError {
        
        error.memory = swiftError.bridgeToObjectiveC
        return nil
    }
}

internal func bridge<T: CoreStoreSwiftType>(error: NSErrorPointer, @noescape _ closure: () throws -> [T]) -> [T.ObjectiveCType]? {
    
    do {
        
        let result = try closure()
        error.memory = nil
        return result.map { $0.bridgeToObjectiveC }
    }
    catch let swiftError {
        
        error.memory = swiftError.bridgeToObjectiveC
        return nil
    }
}


