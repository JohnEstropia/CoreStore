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
public struct GroupBy: QueryClause, Hashable {
    
    /**
     The list of key path strings to group results with
     */
    public let keyPaths: [KeyPath]
    
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
    public init(_ keyPath: KeyPath, _ keyPaths: KeyPath...) {
        
        self.init([keyPath] + keyPaths)
    }
    
    /**
     Initializes a `GroupBy` clause with a list of key path strings
     
     - parameter keyPaths: a list of key path strings to group results with
     */
    public init(_ keyPaths: [KeyPath]) {
        
        self.keyPaths = keyPaths
    }
    
    
    // MARK: QueryClause
    
    public func applyToFetchRequest(fetchRequest: NSFetchRequest) {
        
        if let keyPaths = fetchRequest.propertiesToGroupBy as? [String] where keyPaths != self.keyPaths {
            
            CoreStore.log(
                .Warning,
                message: "An existing \"propertiesToGroupBy\" for the \(cs_typeName(NSFetchRequest)) was overwritten by \(cs_typeName(self)) query clause."
            )
        }
        
        fetchRequest.propertiesToGroupBy = self.keyPaths
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        return (self.keyPaths as NSArray).hashValue
    }
}


// MARK: - GroupBy: Equatable

@warn_unused_result
public func == (lhs: GroupBy, rhs: GroupBy) -> Bool {
    
    return lhs.keyPaths == rhs.keyPaths
}
