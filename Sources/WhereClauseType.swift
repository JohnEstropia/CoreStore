//
//  WhereClauseType.swift
//  CoreStore
//
//  Created by John Estropia on 2017/09/29.
//  Copyright © 2017 John Rommel Estropia. All rights reserved.
//

import Foundation


// MARK: - WhereClauseType

/**
 Abstracts the `Where` clause for protocol utilities.
 */
public protocol WhereClauseType: AnyWhereClause {
    
    /**
     The `DynamicObject` type associated with the clause
     */
    associatedtype ObjectType: DynamicObject
}

public extension WhereClauseType {
    
    /**
     Combines two `Where` predicates together using `AND` operator.
     - Warning: This operator overload is a workaround for Swift generics' inability to constrain by inheritance (https://bugs.swift.org/browse/SR-5213). In effect, this is less type-safe than other overloads because it allows AND'ing clauses of unrelated `DynamicObject` types.
     */
    public static func && <TWhere: WhereClauseType>(left: Self, right: TWhere) -> Self {
        
        return Self.init(NSCompoundPredicate(type: .and, subpredicates: [left.predicate, right.predicate]))
    }
    
    /**
     Combines two `Where` predicates together using `AND` operator.
     - Warning: This operator overload is a workaround for Swift generics' inability to constrain by inheritance (https://bugs.swift.org/browse/SR-5213). In effect, this is less type-safe than other overloads because it allows AND'ing clauses of unrelated `DynamicObject` types.
     */
    public static func && <TWhere: WhereClauseType>(left: TWhere, right: Self) -> Self {
        
        return Self.init(NSCompoundPredicate(type: .and, subpredicates: [left.predicate, right.predicate]))
    }
    
    /**
     Combines two `Where` predicates together using `OR` operator.
     - Warning: This operator overload is a workaround for Swift generics' inability to constrain by inheritance (https://bugs.swift.org/browse/SR-5213). In effect, this is less type-safe than other overloads because it allows OR'ing clauses of unrelated `DynamicObject` types.
     */
    public static func || <TWhere: WhereClauseType>(left: Self, right: TWhere) -> Self {
        
        return Self.init(NSCompoundPredicate(type: .or, subpredicates: [left.predicate, right.predicate]))
    }
    
    /**
     Combines two `Where` predicates together using `OR` operator.
     - Warning: This operator overload is a workaround for Swift generics' inability to constrain by inheritance (https://bugs.swift.org/browse/SR-5213). In effect, this is less type-safe than other overloads because it allows OR'ing clauses of unrelated `DynamicObject` types.
     */
    public static func || <TWhere: WhereClauseType>(left: TWhere, right: Self) -> Self {
        
        return Self.init(NSCompoundPredicate(type: .or, subpredicates: [left.predicate, right.predicate]))
    }
}
