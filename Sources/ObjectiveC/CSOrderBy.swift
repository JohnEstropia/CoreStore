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
 */
@objc
public final class CSOrderBy: NSObject, CSFetchClause, CSQueryClause, CSDeleteClause, CoreStoreBridge {
    
    /**
     Initializes a `CSOrderBy` clause with a list of sort descriptors
     
     - parameter sortDescriptors: a series of `NSSortDescriptor`s
     - returns: a `CSOrderBy` clause with a list of sort descriptors
     */
    @objc
    public static func sortDescriptors(sortDescriptors: [NSSortDescriptor]) -> CSOrderBy {
        
        return self.init(OrderBy(sortDescriptors))
    }
    
    /**
     Initializes a `CSOrderBy` clause with a single sort descriptor
     
     - parameter sortDescriptor: a `NSSortDescriptor`
     - returns: a `CSOrderBy` clause with a single sort descriptor
     */
    @objc
    public static func sortDescriptor(sortDescriptor: NSSortDescriptor) -> CSOrderBy {
        
        return self.init(OrderBy(sortDescriptor))
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.swift.hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSOrderBy else {
            
            return false
        }
        return self.swift == object.swift
    }
    
    
    // MARK: CSFetchClause, CSQueryClause, CSDeleteClause
    
    @objc
    public func applyToFetchRequest(fetchRequest: NSFetchRequest) {
        
        self.swift.applyToFetchRequest(fetchRequest)
    }
    
    
    // MARK: CoreStoreBridge
    
    internal let swift: OrderBy
    
    internal init(_ swiftObject: OrderBy) {
        
        self.swift = swiftObject
        super.init()
    }
}


// MARK: - OrderBy

extension OrderBy: CoreStoreBridgeable {
    
    // MARK: CoreStoreBridgeable
    
    internal typealias ObjCType = CSOrderBy
}
