//
//  GroupBy.swift
//  CoreStore
//
//  Copyright © 2015 John Rommel Estropia
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
import CoreData


// MARK: - GroupBy

/**
 The `GroupBy` clause specifies that the result of a query be grouped accoording to the specified key path.
 */
public struct GroupBy<D: DynamicObject>: GroupByClause, QueryClause, Hashable {
    
    /**
     Initializes a `GroupBy` clause with an empty list of key path strings
     */
    public init() {
        
        self.init([])
    }
    
    /**
     Initializes a `GroupBy` clause with a list of key path strings
     
     - parameter keyPath: a key path string to group results with
     - parameter keyPaths: a series of key path strings to group results with
     */
    public init(_ keyPath: KeyPathString, _ keyPaths: KeyPathString...) {
        
        self.init([keyPath] + keyPaths)
    }
    
    /**
     Initializes a `GroupBy` clause with a list of key path strings
     
     - parameter keyPaths: a list of key path strings to group results with
     */
    public init(_ keyPaths: [KeyPathString]) {
        
        self.keyPaths = keyPaths
    }
    
    
    // MARK: GroupByClause
    
    public typealias ObjectType = D
    
    public let keyPaths: [KeyPathString]
    
    
    // MARK: QueryClause
    
    public func applyToFetchRequest<ResultType>(_ fetchRequest: NSFetchRequest<ResultType>) {
        
        if let keyPaths = fetchRequest.propertiesToGroupBy as? [String], keyPaths != self.keyPaths {
            
            CoreStore.log(
                .warning,
                message: "An existing \"propertiesToGroupBy\" for the \(cs_typeName(NSFetchRequest<ResultType>.self)) was overwritten by \(cs_typeName(self)) query clause."
            )
        }
        
        fetchRequest.propertiesToGroupBy = self.keyPaths
    }
    
    
    // MARK: Equatable
    
    public static func == (lhs: GroupBy, rhs: GroupBy) -> Bool {
        
        return lhs.keyPaths == rhs.keyPaths
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        return (self.keyPaths as NSArray).hashValue
    }
}

public extension GroupBy where D: NSManagedObject {
    
    /**
     Initializes a `GroupBy` clause with a key path
     
     - parameter keyPath: a key path to group results with
     */
    public init<T>(_ keyPath: KeyPath<D, T>) {
        
        self.init([keyPath._kvcKeyPathString!])
    }
}

public extension GroupBy where D: CoreStoreObject {
    
    /**
     Initializes a `GroupBy` clause with a key path
     
     - parameter keyPath: a key path to group results with
     */
    public init<T>(_ keyPath: KeyPath<D, ValueContainer<D>.Required<T>>) {
        
        self.init([D.meta[keyPath: keyPath].keyPath])
    }
    
    /**
     Initializes a `GroupBy` clause with a key path
     
     - parameter keyPath: a key path to group results with
     */
    public init<T>(_ keyPath: KeyPath<D, ValueContainer<D>.Optional<T>>) {
        
        self.init([D.meta[keyPath: keyPath].keyPath])
    }
    
    /**
     Initializes a `GroupBy` clause with a key path
     
     - parameter keyPath: a key path to group results with
     */
    public init<T>(_ keyPath: KeyPath<D, TransformableContainer<D>.Required<T>>) {
        
        self.init([D.meta[keyPath: keyPath].keyPath])
    }
    
    /**
     Initializes a `GroupBy` clause with a key path
     
     - parameter keyPath: a key path to group results with
     */
    public init<T>(_ keyPath: KeyPath<D, TransformableContainer<D>.Optional<T>>) {
        
        self.init([D.meta[keyPath: keyPath].keyPath])
    }
}


// MARK: - GroupByClause

/**
 Abstracts the `GroupBy` clause for protocol utilities.
 */
public protocol GroupByClause {
    
    /**
     The `DynamicObject` type associated with the clause
     */
    associatedtype ObjectType: DynamicObject
    
    /**
     The list of key path strings to group results with
     */
    var keyPaths: [KeyPathString] { get }
}
