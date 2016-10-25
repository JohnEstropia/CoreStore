//
//  CSLimit.swift
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
import CoreData


// MARK: - CSLimit

/**
 The `CSLimit` serves as the Objective-C bridging type for `Limit`.
 
 - SeeAlso: `Limit`
 */
@objc
public final class CSLimit: NSObject, CSFetchClause, CSQueryClause, CSDeleteClause, CoreStoreObjectiveCType {
    
    /**
     The fetch limit
     */
    @objc
    public var fetchLimit: Int {
        
        return self.bridgeToSwift.fetchLimit
    }
    
    /**
     Initializes a `CSLimit` clause with and int limit
     ```
     MyPersonEntity *people = [transaction
     fetchAllFrom:CSFromClass([MyPersonEntity class])
     fetchClauses:@[CSLimit(5)]]];
     ```
     - parameter limit: an `Int`
     */
    @objc
    public convenience init(limit: Int) {
        
        self.init(Limit(limit))
    }    
    
    // MARK: CSFetchClause, CSQueryClause, CSDeleteClause
    
    @objc
    public func applyToFetchRequest(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        
        self.bridgeToSwift.applyToFetchRequest(fetchRequest)
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: Limit
    
    public init(_ swiftValue: Limit) {
        
        self.bridgeToSwift = swiftValue
        super.init()
    }
}


// MARK: - Limit

extension Limit: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public typealias ObjectiveCType = CSLimit
}
