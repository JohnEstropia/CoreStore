//
//  CSOrderBy.swift
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


// MARK: - CSOrderBy

/**
 The `CSOrderBy` serves as the Objective-C bridging type for `OrderBy`.
 
 - SeeAlso: `OrderBy`
 */
@objc
public final class CSOrderBy: NSObject, CSFetchClause, CSQueryClause, CSDeleteClause, CoreStoreObjectiveCType {
    
    /**
     The list of sort descriptors
     */
    @objc
    public var sortDescriptors: [NSSortDescriptor] {
        
        return self.bridgeToSwift.sortDescriptors
    }
    
    /**
     Initializes a `CSOrderBy` clause with a single sort descriptor
     ```
     MyPersonEntity *people = [transaction
        fetchAllFrom:CSFromClass([MyPersonEntity class])
        fetchClauses:@[CSOrderByKey(CSSortAscending(@"fullname"))]]];
     ```
     
     - parameter sortDescriptor: a `NSSortDescriptor`
     */
    @objc
    public convenience init(sortDescriptor: NSSortDescriptor) {
        
        self.init(OrderBy(sortDescriptor))
    }
    
    /**
     Initializes a `CSOrderBy` clause with a list of sort descriptors
     ```
     MyPersonEntity *people = [transaction
        fetchAllFrom:CSFromClass([MyPersonEntity class])
        fetchClauses:@[CSOrderByKeys(CSSortAscending(@"fullname"), CSSortDescending(@"age"), nil))]]];
     ```
     
     - parameter sortDescriptors: an array of `NSSortDescriptor`s
     */
    @objc
    public convenience init(sortDescriptors: [NSSortDescriptor]) {
        
        self.init(OrderBy(sortDescriptors))
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.bridgeToSwift.hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSOrderBy else {
            
            return false
        }
        return self.bridgeToSwift == object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: self.dynamicType))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CSFetchClause, CSQueryClause, CSDeleteClause
    
    @objc
    public func applyToFetchRequest(fetchRequest: NSFetchRequest) {
        
        self.bridgeToSwift.applyToFetchRequest(fetchRequest)
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: OrderBy
    
    public init(_ swiftValue: OrderBy) {
        
        self.bridgeToSwift = swiftValue
        super.init()
    }
}


// MARK: - OrderBy

extension OrderBy: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public typealias ObjectiveCType = CSOrderBy
}
