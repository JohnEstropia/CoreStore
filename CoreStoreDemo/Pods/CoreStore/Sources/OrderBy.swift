//
//  OrderBy.swift
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


// MARK: - KeyPath
    
public typealias KeyPath = String


// MARK: - SortKey

/**
 The `SortKey` is passed to the `OrderBy` clause to indicate the sort keys and their sort direction.
 */
public enum SortKey {
    
    /**
     Indicates that the `KeyPath` should be sorted in ascending order
     */
    case ascending(KeyPath)
    
    /**
     Indicates that the `KeyPath` should be sorted in descending order
     */
    case descending(KeyPath)
}


// MARK: - OrderBy

/**
 The `OrderBy` clause specifies the sort order for results for a fetch or a query.
 */
public struct OrderBy: FetchClause, QueryClause, DeleteClause, Hashable {
    
    /**
     Combines two `OrderBy` sort descriptors together
     */
    public static func + (left: OrderBy, right: OrderBy) -> OrderBy {
        
        return OrderBy(left.sortDescriptors + right.sortDescriptors)
    }
    
    /**
     Combines two `OrderBy` sort descriptors together and stores the result to the left operand
     */
    public static func += (left: inout OrderBy, right: OrderBy) {
        
        left = left + right
    }
    
    /**
     The list of sort descriptors
     */
    public let sortDescriptors: [NSSortDescriptor]
    
    /**
     Initializes a `OrderBy` clause with an empty list of sort descriptors
     */
    public init() {
        
        self.init([NSSortDescriptor]())
    }
    
    /**
     Initializes a `OrderBy` clause with a single sort descriptor
     
     - parameter sortDescriptor: a `NSSortDescriptor`
     */
    public init(_ sortDescriptor: NSSortDescriptor) {
        
        self.init([sortDescriptor])
    }
    
    /**
     Initializes a `OrderBy` clause with a list of sort descriptors
     
     - parameter sortDescriptors: a series of `NSSortDescriptor`s
     */
    public init(_ sortDescriptors: [NSSortDescriptor]) {
        
        self.sortDescriptors = sortDescriptors
    }
    
    /**
     Initializes a `OrderBy` clause with a series of `SortKey`s
     
     - parameter sortKey: a series of `SortKey`s
     */
    public init(_ sortKey: [SortKey]) {
        
        self.init(
            sortKey.map { sortKey -> NSSortDescriptor in
                
                switch sortKey {
                    
                case .ascending(let keyPath):
                    return NSSortDescriptor(key: keyPath, ascending: true)
                    
                case .descending(let keyPath):
                    return NSSortDescriptor(key: keyPath, ascending: false)
                }
            }
        )
    }
    
    /**
     Initializes a `OrderBy` clause with a series of `SortKey`s
     
     - parameter sortKey: a single `SortKey`
     - parameter sortKeys: a series of `SortKey`s
     */
    public init(_ sortKey: SortKey, _ sortKeys: SortKey...) {
        
        self.init([sortKey] + sortKeys)
    }
    
    
    // MARK: FetchClause, QueryClause, DeleteClause
    
    public func applyToFetchRequest<ResultType: NSFetchRequestResult>(_ fetchRequest: NSFetchRequest<ResultType>) {
        
        if let sortDescriptors = fetchRequest.sortDescriptors, sortDescriptors != self.sortDescriptors {
            
            CoreStore.log(
                .warning,
                message: "Existing sortDescriptors for the \(cs_typeName(fetchRequest)) was overwritten by \(cs_typeName(self)) query clause."
            )
        }
        
        fetchRequest.sortDescriptors = self.sortDescriptors
    }
    
    
    // MARK: Equatable
    
    public static func == (lhs: OrderBy, rhs: OrderBy) -> Bool {
        
        return lhs.sortDescriptors == rhs.sortDescriptors
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        return (self.sortDescriptors as NSArray).hashValue
    }
}


// MARK: - Sequence where Element == OrderBy

public extension Sequence where Iterator.Element == OrderBy {
    
    /**
     Combines multiple `OrderBy` predicates together
     */
    public func combined() -> OrderBy {
        
        return OrderBy(self.flatMap({ $0.sortDescriptors }))
    }
}
