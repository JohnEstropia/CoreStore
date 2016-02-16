//
//  Where.swift
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


public func &&(left: Where, right: Where) -> Where {
    
    return Where(NSCompoundPredicate(type: .AndPredicateType, subpredicates: [left.predicate, right.predicate]))
}

public func ||(left: Where, right: Where) -> Where {
    
    return Where(NSCompoundPredicate(type: .OrPredicateType, subpredicates: [left.predicate, right.predicate]))
}

public prefix func !(clause: Where) -> Where {
    
    return Where(NSCompoundPredicate(type: .NotPredicateType, subpredicates: [clause.predicate]))
}


// MARK: - Where

/**
 The `Where` clause specifies the conditions for a fetch or a query.
 */
public struct Where: FetchClause, QueryClause, DeleteClause {
    
    /**
     Initializes a `Where` clause with an `NSPredicate`
     
     - parameter predicate: the `NSPredicate` for the fetch or query
     */
    public init(_ predicate: NSPredicate) {
        
        self.predicate = predicate
    }
    
    /**
     Initializes a `Where` clause with a predicate that always evaluates to `true`
     */
    public init() {
        
        self.init(true)
    }
    
    /**
     Initializes a `Where` clause with a predicate that always evaluates to the specified boolean value
     
     - parameter value: the boolean value for the predicate
     */
    public init(_ value: Bool) {
        
        self.init(NSPredicate(value: value))
    }
    
    /**
     Initializes a `Where` clause with a predicate using the specified string format and arguments
     
     - parameter format: the format string for the predicate
     - parameter args: the arguments for `format`
     */
    public init(_ format: String, _ args: NSObject...) {
        
        self.init(NSPredicate(format: format, argumentArray: args))
    }
    
    /**
     Initializes a `Where` clause with a predicate using the specified string format and arguments
     
     - parameter format: the format string for the predicate
     - parameter argumentArray: the arguments for `format`
     */
    public init(_ format: String, argumentArray: [NSObject]?) {
        
        self.init(NSPredicate(format: format, argumentArray: argumentArray))
    }
    
    /**
     Initializes a `Where` clause that compares equality
     
     - parameter keyPath: the keyPath to compare with
     - parameter value: the arguments for the `==` operator
     */
    public init(_ keyPath: KeyPath, isEqualTo value: NSObject?) {
        
        self.init(value == nil
            ? NSPredicate(format: "\(keyPath) == nil")
            : NSPredicate(format: "\(keyPath) == %@", argumentArray: [value!]))
    }
    
    /**
     Initializes a `Where` clause that compares membership
     
     - parameter keyPath: the keyPath to compare with
     - parameter list: the array to check membership of
     */
    public init(_ keyPath: KeyPath, isMemberOf list: NSArray) {
        
        self.init(NSPredicate(format: "\(keyPath) IN %@", list))
    }
    
    /**
     Initializes a `Where` clause that compares membership
     
     - parameter keyPath: the keyPath to compare with
     - parameter list: the sequence to check membership of
     */
    public init<S: SequenceType where S.Generator.Element: NSObject>(_ keyPath: KeyPath, isMemberOf list: S) {
        
        self.init(NSPredicate(format: "\(keyPath) IN %@", Array(list) as NSArray))
    }
    
    public let predicate: NSPredicate
    
    
    // MARK: FetchClause, QueryClause, DeleteClause
    
    public func applyToFetchRequest(fetchRequest: NSFetchRequest) {
        
        if let predicate = fetchRequest.predicate where predicate != self.predicate {
            
            CoreStore.log(
                .Warning,
                message: "An existing predicate for the \(typeName(NSFetchRequest)) was overwritten by \(typeName(self)) query clause."
            )
        }
        
        fetchRequest.predicate = self.predicate
    }
}
