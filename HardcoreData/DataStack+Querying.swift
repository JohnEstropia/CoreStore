//
//  DataStack+Querying.swift
//  HardcoreData
//
//  Copyright (c) 2015 John Rommel Estropia
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


// MARK: - DataStack

public extension DataStack {
    
    // MARK: Public
    
    public func fetchOne<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> T? {
        
        return self.mainContext.fetchOne(entity, queryClauses)
    }
    
    public func fetchOne<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> T? {
        
        return self.mainContext.fetchOne(entity, queryClauses)
    }
    
    public func fetchAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> [T]? {
        
        return self.mainContext.fetchAll(entity, queryClauses)
    }
    
    public func fetchAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> [T]? {
        
        return self.mainContext.fetchAll(entity, queryClauses)
    }
    
    public func fetchCount<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> Int? {
        
        return self.mainContext.fetchCount(entity, queryClauses)
    }
    
    public func fetchCount<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> Int? {
        
        return self.mainContext.fetchCount(entity, queryClauses)
    }
    
    public func deleteAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> Int? {
        
        return self.mainContext.deleteAll(entity, queryClauses)
    }
    
    public func deleteAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> Int? {
        
        return self.mainContext.deleteAll(entity, queryClauses)
    }
    
    public func queryAggregate<T: NSManagedObject>(entity: T.Type, function: AggregateFunction, _ queryClauses: FetchClause...) -> Int? {
        
        let result = self.mainContext.queryAggregate(entity, function: function, queryClauses)
        return result
    }
    
    public func queryAggregate<T: NSManagedObject>(entity: T.Type, function: AggregateFunction, _ queryClauses: [FetchClause]) -> Int? {
        
        let result = self.mainContext.queryAggregate(entity, function: function, queryClauses)
        return result
    }
    
    public func queryAggregate<T: NSManagedObject, U: AggregateResultType>(entity: T.Type, function: AggregateFunction, _ queryClauses: FetchClause...) -> U? {
        
        return self.mainContext.queryAggregate(entity, function: function, queryClauses)
    }
    
    public func queryAggregate<T: NSManagedObject, U: AggregateResultType>(entity: T.Type, function: AggregateFunction, _ queryClauses: [FetchClause]) -> U? {
        
        return self.mainContext.queryAggregate(entity, function: function, queryClauses)
    }
}
