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


// MARK: - Where

/**
 The `Where` clause specifies the conditions for a fetch or a query.
 */
public struct Where: FetchClause, QueryClause, DeleteClause, Hashable {
    
    /**
     Combines two `Where` predicates together using `AND` operator
     */
    public static func && (left: Where, right: Where) -> Where {
        
        return Where(NSCompoundPredicate(type: .and, subpredicates: [left.predicate, right.predicate]))
    }
    
    /**
     Combines two `Where` predicates together using `AND` operator.
     - parameter left: the left hand side `Where` clause
     - parameter right: the right hand side `Where` clause
     - returns: Return `left` unchanged if `right` is nil
     */
    public static func && (left: Where, right: Where?) -> Where {
        
        if let right = right {
            
            return left && right
        }
        return left
    }
    
    /**
     Combines two `Where` predicates together using `AND` operator.
     - parameter left: the left hand side `Where` clause
     - parameter right: the right hand side `Where` clause
     - returns: Returns `right` unchanged if `left` is nil
     */
    public static func && (left: Where?, right: Where) -> Where {
        
        if let left = left {
            
            return left && right
        }
        return right
    }
    
    /**
     Combines two `Where` predicates together using `OR` operator
     */
    public static func || (left: Where, right: Where) -> Where {
        
        return Where(NSCompoundPredicate(type: .or, subpredicates: [left.predicate, right.predicate]))
    }
    
    /**
     Combines two `Where` predicates together using `OR` operator.
     - parameter left: the left hand side `Where` clause
     - parameter right: the right hand side `Where` clause
     - returns: Returns `left` unchanged if `right` is nil
     */
    public static func || (left: Where, right: Where?) -> Where {
        
        if let right = right {
            
            return left || right
        }
        return left
    }
    
    /**
     Combines two `Where` predicates together using `OR` operator.
     - parameter left: the left hand side `Where` clause
     - parameter right: the right hand side `Where` clause
     - returns: Return `right` unchanged if `left` is nil
     */
    public static func || (left: Where?, right: Where) -> Where {
        
        if let left = left {
            
            return left || right
        }
        return right
    }
    
    /**
     Inverts the predicate of a `Where` clause using `NOT` operator
     */
    public static prefix func ! (clause: Where) -> Where {
        
        return Where(NSCompoundPredicate(type: .not, subpredicates: [clause.predicate]))
    }
    
    /**
     The `NSPredicate` for the fetch or query
     */
    public let predicate: NSPredicate
    
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
    public init(_ format: String, _ args: Any...) {
        
        self.init(NSPredicate(format: format, argumentArray: args))
    }
    
    /**
     Initializes a `Where` clause with a predicate using the specified string format and arguments
     
     - parameter format: the format string for the predicate
     - parameter argumentArray: the arguments for `format`
     */
    public init(_ format: String, argumentArray: [Any]?) {
        
        self.init(NSPredicate(format: format, argumentArray: argumentArray))
    }
    
    /**
     Initializes a `Where` clause that compares equality to `nil`
     
     - parameter keyPath: the keyPath to compare with
     - parameter value: the arguments for the `==` operator
     */
    public init(_ keyPath: RawKeyPath, isEqualTo value: Void?) {
        
        self.init(NSPredicate(format: "\(keyPath) == nil"))
    }
    
    /**
     Initializes a `Where` clause that compares equality
     
     - parameter keyPath: the keyPath to compare with
     - parameter value: the arguments for the `==` operator
     */
    public init<T: QueryableAttributeType>(_ keyPath: RawKeyPath, isEqualTo value: T?) {
        
        switch value {
            
        case nil,
             is NSNull:
            self.init(NSPredicate(format: "\(keyPath) == nil"))
            
        case let value?:
            self.init(NSPredicate(format: "\(keyPath) == %@", argumentArray: [value.cs_toQueryableNativeType()]))
        }
    }
    
    /**
     Initializes a `Where` clause that compares equality
     
     - parameter keyPath: the keyPath to compare with
     - parameter object: the arguments for the `==` operator
     */
    public init<T: DynamicObject>(_ keyPath: RawKeyPath, isEqualTo object: T?) {
        
        switch object {
            
        case nil,
             is NSNull:
            self.init(NSPredicate(format: "\(keyPath) == nil"))
            
        case let object?:
            self.init(NSPredicate(format: "\(keyPath) == %@", argumentArray: [object.cs_id()]))
        }
    }
    
    /**
     Initializes a `Where` clause that compares membership
     
     - parameter keyPath: the keyPath to compare with
     - parameter list: the sequence to check membership of
     */
    public init<S: Sequence>(_ keyPath: RawKeyPath, isMemberOf list: S) where S.Iterator.Element: QueryableAttributeType {
        
        self.init(NSPredicate(format: "\(keyPath) IN %@", list.map({ $0.cs_toQueryableNativeType() }) as NSArray))
    }
    
    /**
     Initializes a `Where` clause that compares membership
     
     - parameter keyPath: the keyPath to compare with
     - parameter list: the sequence to check membership of
     */
    public init<S: Sequence>(_ keyPath: RawKeyPath, isMemberOf list: S) where S.Iterator.Element: DynamicObject {
        
        self.init(NSPredicate(format: "\(keyPath) IN %@", list.map({ $0.cs_id() }) as NSArray))
    }
    
    /**
     Initializes a `Where` clause with an `NSPredicate`
     
     - parameter predicate: the `NSPredicate` for the fetch or query
     */
    public init(_ predicate: NSPredicate) {
        
        self.predicate = predicate
    }
    
    
    // MARK: FetchClause, QueryClause, DeleteClause
    
    public func applyToFetchRequest<ResultType>(_ fetchRequest: NSFetchRequest<ResultType>) {
        
        if let predicate = fetchRequest.predicate, predicate != self.predicate {
            
            CoreStore.log(
                .warning,
                message: "An existing predicate for the \(cs_typeName(fetchRequest)) was overwritten by \(cs_typeName(self)) query clause."
            )
        }
        
        fetchRequest.predicate = self.predicate
    }
    
    
    // MARK: Equatable
    
    public static func == (lhs: Where, rhs: Where) -> Bool {
        
        return lhs.predicate == rhs.predicate
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        return self.predicate.hashValue
    }
}


// MARK: - Sequence where Element == Where

public extension Sequence where Iterator.Element == Where {
    
    /**
     Combines multiple `Where` predicates together using `AND` operator
     */
    public func combinedByAnd() -> Where {
        
        return Where(NSCompoundPredicate(type: .and, subpredicates: self.map({ $0.predicate })))
    }
    
    /**
     Combines multiple `Where` predicates together using `OR` operator
     */
    public func combinedByOr() -> Where {
        
        return Where(NSCompoundPredicate(type: .or, subpredicates: self.map({ $0.predicate })))
    }
}
