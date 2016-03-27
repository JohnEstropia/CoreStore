//
//  CSGroupBy.swift
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


// MARK: - CSGroupBy

/**
 The `CSGroupBy` serves as the Objective-C bridging type for `GroupBy`.
 */
@objc
public final class CSGroupBy: NSObject, CSQueryClause, CoreStoreBridge {
    
    /**
     Initializes a `CSGroupBy` clause with a list of key path strings
     
     - parameter keyPaths: a list of key path strings to group results with
     - returns: a `CSGroupBy` clause with a list of key path strings
     */
    @objc
    public static func keyPaths(keyPaths: [KeyPath]) -> CSGroupBy {
        
        return self.init(GroupBy(keyPaths))
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.swift.hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSGroupBy else {
            
            return false
        }
        return self.swift == object.swift
    }
    
    
    // MARK: CSQueryClause
    
    @objc
    public func applyToFetchRequest(fetchRequest: NSFetchRequest) {
        
        self.swift.applyToFetchRequest(fetchRequest)
    }
    
    
    // MARK: CoreStoreBridge
    
    internal let swift: GroupBy
    
    internal init(_ swiftObject: GroupBy) {
        
        self.swift = swiftObject
        super.init()
    }
}


// MARK: - GroupBy

extension GroupBy: CoreStoreBridgeable {
    
    // MARK: CoreStoreBridgeable
    
    internal typealias ObjCType = CSGroupBy
}
