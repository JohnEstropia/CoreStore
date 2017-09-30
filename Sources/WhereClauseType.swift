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
