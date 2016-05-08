//
//  CSWhere.swift
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


// MARK: - CSWhere

/**
 The `CSWhere` serves as the Objective-C bridging type for `Where`.
 
 - SeeAlso: `Where`
 */
@objc
public final class CSWhere: NSObject, CSFetchClause, CSQueryClause, CSDeleteClause, CoreStoreObjectiveCType {
    
    /**
     Initializes a `CSWhere` clause with an `NSPredicate`
     
     - parameter predicate: the `NSPredicate` for the fetch or query
     - returns: a `CSWhere` clause with an `NSPredicate`
     */
    @objc
    public static func predicate(predicate: NSPredicate) -> CSWhere {
        
        return self.init(Where(predicate))
    }

    /**
     Initializes a `CSWhere` clause with a predicate that always evaluates to the specified boolean value
     
     - parameter value: the boolean value for the predicate
     - returns: a `CSWhere` clause with a predicate that always evaluates to the specified boolean value
     */
    @objc
    public static func value(value: Bool) -> CSWhere {
        
        return self.init(Where(value))
    }
    
    /**
     Initializes a `CSWhere` clause with a predicate using the specified string format and arguments
     
     - parameter format: the format string for the predicate
     - parameter argumentArray: the arguments for `format`
     - returns: a `CSWhere` clause with a predicate using the specified string format and arguments
     */
    @objc
    public static func format(format: String, argumentArray: [NSObject]?) -> CSWhere {
        
        return self.init(Where(format, argumentArray: argumentArray))
    }
    
    /**
     Initializes a `CSWhere` clause that compares equality
     
     - parameter keyPath: the keyPath to compare with
     - parameter value: the arguments for the `==` operator
     - returns: a `CSWhere` clause that compares equality
     */
    @objc
    public static func keyPath(keyPath: KeyPath, isEqualTo value: NSObject?) -> CSWhere {
        
        return self.init(Where(keyPath, isEqualTo: value))
    }
    
    /**
     Initializes a `CSWhere` clause that compares membership
     
     - parameter keyPath: the keyPath to compare with
     - parameter list: the array to check membership of
     - returns: a `CSWhere` clause that compares membership
     */
    @objc
    public static func keyPath(keyPath: KeyPath, isMemberOf list: [NSObject]) -> CSWhere {
        
        return self.init(Where(keyPath, isMemberOf: list))
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.bridgeToSwift.hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSWhere else {
            
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
    
    public let bridgeToSwift: Where
    
    public init(_ swiftValue: Where) {
        
        self.bridgeToSwift = swiftValue
        super.init()
    }
}


// MARK: - Where

extension Where: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public typealias ObjectiveCType = CSWhere
}
