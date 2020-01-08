//
//  CoreStoreBridge.swift
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
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
@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
public protocol CoreStoreObjectiveCType: AnyObject {
    
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
@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
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


// MARK: - Internal

@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
internal func bridge<T: CoreStoreSwiftType>(_ closure: () -> T) -> T.ObjectiveCType {
    
    return closure().bridgeToObjectiveC
}

@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
internal func bridge<T: CoreStoreSwiftType>(_ closure: () -> [T]) -> [T.ObjectiveCType] {
    
    return closure().map { $0.bridgeToObjectiveC }
}

@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
internal func bridge<T: CoreStoreSwiftType>(_ closure: () -> T?) -> T.ObjectiveCType? {
    
    return closure()?.bridgeToObjectiveC
}

@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
internal func bridge<T: CoreStoreSwiftType>(_ closure: () throws -> T) throws -> T.ObjectiveCType {
    
    do {
        
        return try closure().bridgeToObjectiveC
    }
    catch {
        
        throw error.bridgeToObjectiveC
    }
}

@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
internal func bridge(_ closure: () throws -> Void) throws {
    
    do {
        
        try closure()
    }
    catch {
        
        throw error.bridgeToObjectiveC
    }
}

@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
internal func bridge<T: CoreStoreSwiftType>(_ error: NSErrorPointer, _ closure: () throws -> T) -> T.ObjectiveCType? {
    
    do {
        
        let result = try closure()
        error?.pointee = nil
        return result.bridgeToObjectiveC
    }
    catch let swiftError {
        
        error?.pointee = swiftError.bridgeToObjectiveC
        return nil
    }
}

@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
internal func bridge(_ error: NSErrorPointer, _ closure: () throws -> Void) -> Bool {
    
    do {
        
        try closure()
        error?.pointee = nil
        return true
    }
    catch let swiftError {
        
        error?.pointee = swiftError.bridgeToObjectiveC
        return false
    }
}

@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
internal func bridge<T>(_ error: NSErrorPointer, _ closure: () throws -> T?) -> T? {
    
    do {
        
        let result = try closure()
        error?.pointee = nil
        return result
    }
    catch let swiftError {
        
        error?.pointee = swiftError.bridgeToObjectiveC
        return nil
    }
}

@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
internal func bridge<T: CoreStoreSwiftType>(_ error: NSErrorPointer, _ closure: () throws -> [T]) -> [T.ObjectiveCType]? {
    
    do {
        
        let result = try closure()
        error?.pointee = nil
        return result.map { $0.bridgeToObjectiveC }
    }
    catch let swiftError {
        
        error?.pointee = swiftError.bridgeToObjectiveC
        return nil
    }
}


