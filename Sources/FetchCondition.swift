//
//  FetchCondition.swift
//  CoreStore
//
//  Copyright © 2017 John Rommel Estropia
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

public struct ChainedClauseBuilder<T: DynamicObject> {
    
    public let from: From<T>
    public let fetchClauses: [FetchClause] = []
    
    internal init(from: From<T>) {
        
        self.from = from
    }
}

extension From: ClauseChain {
    
    public typealias ObjectType = T
    public typealias TraitType = FetchTrait
    
    public var builder: ChainedClauseBuilder<T> {
        
        return .init(from: self)
    }
}

public struct ChainedWhere<D: DynamicObject, T: ClauseTrait>: ClauseChain {
    
    public typealias ObjectType = D
    public typealias TraitType = T
    
    public let builder: ChainedClauseBuilder<ObjectType>
    
    fileprivate init(builder: ChainedClauseBuilder<ObjectType>) {
        
        var newBuilder = builder
//        newBuilder.fetchClauses.append(Where())
        self.builder = newBuilder
    }
}

public struct ChainedOrderBy<D: DynamicObject, T: ClauseTrait>: ClauseChain {
    
    public typealias ObjectType = D
    public typealias TraitType = T
    
    public let builder: ChainedClauseBuilder<ObjectType>
    
    fileprivate init(builder: ChainedClauseBuilder<ObjectType>) {
        
        var newBuilder = builder
//        newBuilder.fetchClauses.append(Where())
        self.builder = newBuilder
    }
}

public struct ChainedSelect<D: DynamicObject, T: ClauseTrait>: ClauseChain {
    
    public typealias ObjectType = D
    public typealias TraitType = T
    
    public let builder: ChainedClauseBuilder<ObjectType>
    
    fileprivate init(builder: ChainedClauseBuilder<ObjectType>) {
        
        var newBuilder = builder
//        newBuilder.fetchClauses.append(Where())
        self.builder = newBuilder
    }
}





public protocol ClauseTrait {}
public enum FetchTrait: ClauseTrait {}
public enum QueryTrait: ClauseTrait {}
public enum SectionTrait: ClauseTrait {}


public protocol ClauseChain {
    
    associatedtype ObjectType: DynamicObject
    associatedtype TraitType: ClauseTrait
    
    var builder: ChainedClauseBuilder<ObjectType> { get }
}

public extension ClauseChain where Self.TraitType == FetchTrait {
    
    public func `where`() -> ChainedWhere<ObjectType, FetchTrait> {
        
        return .init(builder: self.builder)
    }
    
    public func orderBy() -> ChainedOrderBy<ObjectType, FetchTrait> {
        
        return .init(builder: self.builder)
    }
    
    public func select() -> ChainedSelect<ObjectType, QueryTrait> {
        
        return .init(builder: self.builder)
    }
}

public extension ClauseChain where Self.TraitType == QueryTrait {
    
    public func `where`() -> ChainedWhere<ObjectType, QueryTrait> {
        
        return .init(builder: self.builder)
    }
    
    public func orderBy() -> ChainedOrderBy<ObjectType, QueryTrait> {
        
        return .init(builder: self.builder)
    }
}
