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


public protocol FetchChainableBuilderType {
    
    associatedtype ObjectType: DynamicObject
    
    var from: From<ObjectType> { get set }
    var fetchClauses: [FetchClause] { get set }
}

public protocol QueryChainableBuilderType {
    
    associatedtype ObjectType: DynamicObject
    associatedtype ResultType: SelectResultType
    
    var from: From<ObjectType> { get set }
    var select: Select<ObjectType, ResultType> { get set }
    var queryClauses: [QueryClause] { get set }
}

@available(OSX 10.12, *)
public protocol SectionMonitorBuilderType {
    
    associatedtype ObjectType: DynamicObject
    
    var from: From<ObjectType> { get set }
    var sectionBy: SectionBy<ObjectType> { get set }
    var fetchClauses: [FetchClause] { get set }
}


// MARK: - FetchChainBuilder

public struct FetchChainBuilder<D: DynamicObject>: FetchChainableBuilderType {
    
    // MARK: FetchChainableBuilderType
    
    public typealias ObjectType = D
    
    public var from: From<D>
    public var fetchClauses: [FetchClause] = []
}


// MARK: - QueryChainBuilder

public struct QueryChainBuilder<D: DynamicObject, R: SelectResultType>: QueryChainableBuilderType {
    
    // MARK: QueryChainableBuilderType
    
    public typealias ObjectType = D
    public typealias ResultType = R
    
    public var from: From<D>
    public var select: Select<D, R>
    public var queryClauses: [QueryClause] = []
}


// MARK: - SectionMonitorChainBuilder

@available(OSX 10.12, *)
public struct SectionMonitorChainBuilder<D: DynamicObject>: SectionMonitorBuilderType {
    
    // MARK: SectionMonitorBuilderType
    
    public var from: From<D>
    public var sectionBy: SectionBy<D>
    public var fetchClauses: [FetchClause] = []
}


// MARK: - From

public extension From {
    
    public func select<R>(_ clause: Select<D, R>) -> QueryChainBuilder<D, R> {
        
        return .init(
            from: self,
            select: clause,
            queryClauses: []
        )
    }
    
    public func select<R>(_ resultType: R.Type, _ selectTerm: SelectTerm<D>, _ selectTerms: SelectTerm<D>...) -> QueryChainBuilder<D, R> {
        
        return self.select(resultType, [selectTerm] + selectTerms)
    }
    
    public func select<R>(_ resultType: R.Type, _ selectTerms: [SelectTerm<D>]) -> QueryChainBuilder<D, R> {
        
        return .init(
            from: self,
            select: .init(selectTerms),
            queryClauses: []
        )
    }
    
    @available(OSX 10.12, *)
    public func sectionBy(_ clause: SectionBy<D>) -> SectionMonitorChainBuilder<D> {
        
        return .init(
            from: self,
            sectionBy: clause,
            fetchClauses: []
        )
    }
    
    @available(OSX 10.12, *)
    public func sectionBy(_ sectionKeyPath: KeyPathString) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionBy(sectionKeyPath, { $0 })
    }
    
    @available(OSX 10.12, *)
    public func sectionBy(_ sectionKeyPath: KeyPathString, _ sectionIndexTransformer: @escaping (_ sectionName: String?) -> String?) -> SectionMonitorChainBuilder<D> {
        
        return .init(
            from: self,
            sectionBy: .init(sectionKeyPath, sectionIndexTransformer),
            fetchClauses: []
        )
    }
    
    public func `where`(_ clause: Where<D>) -> FetchChainBuilder<D> {
        
        return self.fetchChain(appending: clause)
    }
    
    public func `where`(format: String, _ args: Any...) -> FetchChainBuilder<D> {
        
        return self.fetchChain(appending: Where<D>(format, argumentArray: args))
    }
    
    public func `where`(format: String, argumentArray: [Any]?) -> FetchChainBuilder<D> {
        
        return self.fetchChain(appending: Where<D>(format, argumentArray: argumentArray))
    }
    
    public func orderBy(_ sortKey: OrderBy<D>.SortKey, _ sortKeys: OrderBy<D>.SortKey...) -> FetchChainBuilder<D> {
        
        return self.fetchChain(appending: OrderBy<D>([sortKey] + sortKeys))
    }
    
    public func tweak(_ fetchRequest: @escaping (NSFetchRequest<NSFetchRequestResult>) -> Void) -> FetchChainBuilder<D> {
        
        return self.fetchChain(appending: Tweak(fetchRequest))
    }
    
    public func appending(_ clause: FetchClause) -> FetchChainBuilder<D> {
        
        return self.fetchChain(appending: clause)
    }
    
    public func appending<S: Sequence>(contentsOf clauses: S) -> FetchChainBuilder<D> where S.Element == FetchClause {
        
        return self.fetchChain(appending: clauses)
    }
    
    
    // MARK: Private
    
    private func fetchChain(appending clause: FetchClause) -> FetchChainBuilder<D> {
        
        return .init(from: self, fetchClauses: [clause])
    }
    
    private func fetchChain<S: Sequence>(appending clauses: S) -> FetchChainBuilder<D> where S.Element == FetchClause {
        
        return .init(from: self, fetchClauses: Array(clauses))
    }
}

public extension From where D: NSManagedObject {
    
    public func select<R>(_ keyPath: KeyPath<D, R>) -> QueryChainBuilder<D, R> {
        
        return self.select(R.self, [SelectTerm<D>.attribute(keyPath)])
    }
    
    @available(OSX 10.12, *)
    public func sectionBy<T>(_ sectionKeyPath: KeyPath<D, T>) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionBy(sectionKeyPath._kvcKeyPathString!, { $0 })
    }
    
    @available(OSX 10.12, *)
    public func sectionBy<T>(_ sectionKeyPath: KeyPath<D, T>, _ sectionIndexTransformer: @escaping (_ sectionName: String?) -> String?) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionBy(sectionKeyPath._kvcKeyPathString!, sectionIndexTransformer)
    }
}

public extension From where D: CoreStoreObject {
    
    public func `where`<T: AnyWhereClause>(_ clause: (D) -> T) -> FetchChainBuilder<D> {
        
        return self.fetchChain(appending: clause(D.meta))
    }
    
    public func select<R>(_ keyPath: KeyPath<D, ValueContainer<D>.Required<R>>) -> QueryChainBuilder<D, R> {
        
        return self.select(R.self, [SelectTerm<D>.attribute(keyPath)])
    }
    
    public func select<R>(_ keyPath: KeyPath<D, ValueContainer<D>.Optional<R>>) -> QueryChainBuilder<D, R> {
        
        return self.select(R.self, [SelectTerm<D>.attribute(keyPath)])
    }
    
    public func select<R>(_ keyPath: KeyPath<D, TransformableContainer<D>.Required<R>>) -> QueryChainBuilder<D, R> {
        
        return self.select(R.self, [SelectTerm<D>.attribute(keyPath)])
    }
    
    public func select<R>(_ keyPath: KeyPath<D, TransformableContainer<D>.Optional<R>>) -> QueryChainBuilder<D, R> {
        
        return self.select(R.self, [SelectTerm<D>.attribute(keyPath)])
    }
    
    @available(OSX 10.12, *)
    public func sectionBy<T>(_ sectionKeyPath: KeyPath<D, ValueContainer<D>.Required<T>>) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionBy(D.meta[keyPath: sectionKeyPath].keyPath, { $0 })
    }
    
    @available(OSX 10.12, *)
    public func sectionBy<T>(_ sectionKeyPath: KeyPath<D, ValueContainer<D>.Optional<T>>) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionBy(D.meta[keyPath: sectionKeyPath].keyPath, { $0 })
    }
    
    @available(OSX 10.12, *)
    public func sectionBy<T>(_ sectionKeyPath: KeyPath<D, TransformableContainer<D>.Required<T>>) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionBy(D.meta[keyPath: sectionKeyPath].keyPath, { $0 })
    }
    
    @available(OSX 10.12, *)
    public func sectionBy<T>(_ sectionKeyPath: KeyPath<D, TransformableContainer<D>.Optional<T>>) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionBy(D.meta[keyPath: sectionKeyPath].keyPath, { $0 })
    }
    
    @available(OSX 10.12, *)
    public func sectionBy<T>(_ sectionKeyPath: KeyPath<D, ValueContainer<D>.Required<T>>, _ sectionIndexTransformer: @escaping (_ sectionName: String?) -> String?) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionBy(D.meta[keyPath: sectionKeyPath].keyPath, sectionIndexTransformer)
    }
    
    @available(OSX 10.12, *)
    public func sectionBy<T>(_ sectionKeyPath: KeyPath<D, ValueContainer<D>.Optional<T>>, _ sectionIndexTransformer: @escaping (_ sectionName: String?) -> String?) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionBy(D.meta[keyPath: sectionKeyPath].keyPath, sectionIndexTransformer)
    }
    
    @available(OSX 10.12, *)
    public func sectionBy<T>(_ sectionKeyPath: KeyPath<D, TransformableContainer<D>.Required<T>>, _ sectionIndexTransformer: @escaping (_ sectionName: String?) -> String?) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionBy(D.meta[keyPath: sectionKeyPath].keyPath, sectionIndexTransformer)
    }
    
    @available(OSX 10.12, *)
    public func sectionBy<T>(_ sectionKeyPath: KeyPath<D, TransformableContainer<D>.Optional<T>>, _ sectionIndexTransformer: @escaping (_ sectionName: String?) -> String?) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionBy(D.meta[keyPath: sectionKeyPath].keyPath, sectionIndexTransformer)
    }
}

public extension FetchChainBuilder {
    
    public func `where`(_ clause: Where<D>) -> FetchChainBuilder<D> {
        
        return self.fetchChain(appending: clause)
    }
    
    public func `where`(format: String, _ args: Any...) -> FetchChainBuilder<D> {
        
        return self.fetchChain(appending: Where<D>(format, argumentArray: args))
    }
    
    public func `where`(format: String, argumentArray: [Any]?) -> FetchChainBuilder<D> {
        
        return self.fetchChain(appending: Where<D>(format, argumentArray: argumentArray))
    }
    
    public func orderBy(_ sortKey: OrderBy<D>.SortKey, _ sortKeys: OrderBy<D>.SortKey...) -> FetchChainBuilder<D> {
        
        return self.fetchChain(appending: OrderBy<D>([sortKey] + sortKeys))
    }
    
    public func tweak(_ fetchRequest: @escaping (NSFetchRequest<NSFetchRequestResult>) -> Void) -> FetchChainBuilder<D> {
        
        return self.fetchChain(appending: Tweak(fetchRequest))
    }
    
    public func appending(_ clause: FetchClause) -> FetchChainBuilder<D> {
        
        return self.fetchChain(appending: clause)
    }
    
    public func appending<S: Sequence>(contentsOf clauses: S) -> FetchChainBuilder<D> where S.Element == FetchClause {
        
        return self.fetchChain(appending: clauses)
    }
    
    
    // MARK: Private
    
    private func fetchChain(appending clause: FetchClause) -> FetchChainBuilder<D> {
        
        return .init(
            from: self.from,
            fetchClauses: self.fetchClauses + [clause]
        )
    }
    
    private func fetchChain<S: Sequence>(appending clauses: S) -> FetchChainBuilder<D> where S.Element == FetchClause {
        
        return .init(
            from: self.from,
            fetchClauses: self.fetchClauses + Array(clauses)
        )
    }
}

public extension FetchChainBuilder where D: CoreStoreObject {
    
    public func `where`<T: AnyWhereClause>(_ clause: (D) -> T) -> FetchChainBuilder<D> {
        
        return self.fetchChain(appending: clause(D.meta))
    }
}

public extension QueryChainBuilder {
    
    public func groupBy(_ clause: GroupBy<D>) -> QueryChainBuilder<D, R> {
        
        return self.queryChain(appending: clause)
    }
    
    public func groupBy(_ keyPath: KeyPathString, _ keyPaths: KeyPathString...) -> QueryChainBuilder<D, R> {
        
        return self.groupBy(GroupBy<D>([keyPath] + keyPaths))
    }
    
    public func groupBy(_ keyPaths: [KeyPathString]) -> QueryChainBuilder<D, R> {
        
        return self.queryChain(appending: GroupBy<D>(keyPaths))
    }
    
    public func `where`(_ clause: Where<D>) -> QueryChainBuilder<D, R> {
        
        return self.queryChain(appending: clause)
    }
    
    public func `where`(format: String, _ args: Any...) -> QueryChainBuilder<D, R> {
        
        return self.queryChain(appending: Where<D>(format, argumentArray: args))
    }
    
    public func `where`(format: String, argumentArray: [Any]?) -> QueryChainBuilder<D, R> {
        
        return self.queryChain(appending: Where<D>(format, argumentArray: argumentArray))
    }
    
    public func orderBy(_ sortKey: OrderBy<D>.SortKey, _ sortKeys: OrderBy<D>.SortKey...) -> QueryChainBuilder<D, R> {
        
        return self.queryChain(appending: OrderBy<D>([sortKey] + sortKeys))
    }
    
    public func tweak(_ fetchRequest: @escaping (NSFetchRequest<NSFetchRequestResult>) -> Void) -> QueryChainBuilder<D, R> {
        
        return self.queryChain(appending: Tweak(fetchRequest))
    }
    
    public func appending(_ clause: QueryClause) -> QueryChainBuilder<D, R> {
        
        return self.queryChain(appending: clause)
    }
    
    public func appending<S: Sequence>(contentsOf clauses: S) -> QueryChainBuilder<D, R> where S.Element == QueryClause {
        
        return self.queryChain(appending: clauses)
    }
    
    
    // MARK: Private
    
    private func queryChain(appending clause: QueryClause) -> QueryChainBuilder<D, R> {
        
        return .init(
            from: self.from,
            select: self.select,
            queryClauses: self.queryClauses + [clause]
        )
    }
    
    private func queryChain<S: Sequence>(appending clauses: S) -> QueryChainBuilder<D, R> where S.Element == QueryClause {
        
        return .init(
            from: self.from,
            select: self.select,
            queryClauses: self.queryClauses + Array(clauses)
        )
    }
}

public extension QueryChainBuilder where D: NSManagedObject {
    
    public func groupBy<T>(_ keyPath: KeyPath<D, T>) -> QueryChainBuilder<D, R> {
        
        return self.groupBy(GroupBy<D>(keyPath))
    }
}

public extension QueryChainBuilder where D: CoreStoreObject {
    
    public func `where`<T: AnyWhereClause>(_ clause: (D) -> T) -> QueryChainBuilder<D, R> {
        
        return self.queryChain(appending: clause(D.meta))
    }
    
    public func groupBy<T>(_ keyPath: KeyPath<D, ValueContainer<D>.Required<T>>) -> QueryChainBuilder<D, R> {
        
        return self.groupBy(GroupBy<D>(keyPath))
    }
    
    public func groupBy<T>(_ keyPath: KeyPath<D, ValueContainer<D>.Optional<T>>) -> QueryChainBuilder<D, R> {
        
        return self.groupBy(GroupBy<D>(keyPath))
    }
    
    public func groupBy<T>(_ keyPath: KeyPath<D, TransformableContainer<D>.Required<T>>) -> QueryChainBuilder<D, R> {
        
        return self.groupBy(GroupBy<D>(keyPath))
    }
    
    public func groupBy<T>(_ keyPath: KeyPath<D, TransformableContainer<D>.Optional<T>>) -> QueryChainBuilder<D, R> {
        
        return self.groupBy(GroupBy<D>(keyPath))
    }
}

@available(OSX 10.12, *)
public extension SectionMonitorChainBuilder {
    
    public func `where`(_ clause: Where<D>) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionMonitorChain(appending: clause)
    }
    
    public func `where`(format: String, _ args: Any...) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionMonitorChain(appending: Where<D>(format, argumentArray: args))
    }
    
    public func `where`(format: String, argumentArray: [Any]?) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionMonitorChain(appending: Where<D>(format, argumentArray: argumentArray))
    }
    
    public func orderBy(_ sortKey: OrderBy<D>.SortKey, _ sortKeys: OrderBy<D>.SortKey...) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionMonitorChain(appending: OrderBy<D>([sortKey] + sortKeys))
    }
    
    public func tweak(_ fetchRequest: @escaping (NSFetchRequest<NSFetchRequestResult>) -> Void) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionMonitorChain(appending: Tweak(fetchRequest))
    }
    
    public func appending(_ clause: FetchClause) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionMonitorChain(appending: clause)
    }
    
    public func appending<S: Sequence>(contentsOf clauses: S) -> SectionMonitorChainBuilder<D> where S.Element == FetchClause {
        
        return self.sectionMonitorChain(appending: clauses)
    }
    
    
    // MARK: Private
    
    private func sectionMonitorChain(appending clause: FetchClause) -> SectionMonitorChainBuilder<D> {
        
        return .init(
            from: self.from,
            sectionBy: self.sectionBy,
            fetchClauses: self.fetchClauses + [clause]
        )
    }
    
    private func sectionMonitorChain<S: Sequence>(appending clauses: S) -> SectionMonitorChainBuilder<D> where S.Element == FetchClause {
        
        return .init(
            from: self.from,
            sectionBy: self.sectionBy,
            fetchClauses: self.fetchClauses + Array(clauses)
        )
    }
}

@available(OSX 10.12, *)
public extension SectionMonitorChainBuilder where D: CoreStoreObject {
    
    public func `where`<T: AnyWhereClause>(_ clause: (D) -> T) -> SectionMonitorChainBuilder<D> {
        
        return self.sectionMonitorChain(appending: clause(D.meta))
    }
}
