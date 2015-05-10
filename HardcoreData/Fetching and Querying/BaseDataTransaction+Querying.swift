//
//  BaseDataTransaction+Querying.swift
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


// MARK: - DataTransaction

public extension BaseDataTransaction {
    
    // MARK: Public
    
    public func fetchOne<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> T? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a \(typeName(self)) outside its designated queue.")
        
        return self.context.fetchOne(from, fetchClauses)
    }
    
    public func fetchOne<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> T? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a \(typeName(self)) outside its designated queue.")
        
        return self.context.fetchOne(from, fetchClauses)
    }
    
    public func fetchAll<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> [T]? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a \(typeName(self)) outside its designated queue.")
        
        return self.context.fetchAll(from, fetchClauses)
    }
    
    public func fetchAll<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> [T]? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a \(typeName(self)) outside its designated queue.")
        
        return self.context.fetchAll(from, fetchClauses)
    }
    
    public func fetchCount<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> Int? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a \(typeName(self)) outside its designated queue.")
        
        return self.context.fetchCount(from, fetchClauses)
    }
    
    public func fetchCount<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> Int? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a \(typeName(self)) outside its designated queue.")
        
        return self.context.fetchCount(from, fetchClauses)
    }
    
    public func fetchObjectID<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> NSManagedObjectID? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a \(typeName(self)) outside its designated queue.")
        
        return self.context.fetchObjectID(from, fetchClauses)
    }
    
    public func fetchObjectID<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> NSManagedObjectID? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a \(typeName(self)) outside its designated queue.")
        
        return self.context.fetchObjectID(from, fetchClauses)
    }
    
    public func fetchObjectIDs<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> [NSManagedObjectID]? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a \(typeName(self)) outside its designated queue.")
        
        return self.context.fetchObjectIDs(from, fetchClauses)
    }
    
    public func fetchObjectIDs<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> [NSManagedObjectID]? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a \(typeName(self)) outside its designated queue.")
        
        return self.context.fetchObjectIDs(from, fetchClauses)
    }
    
    public func deleteAll<T: NSManagedObject>(from: From<T>, _ deleteClauses: DeleteClause...) -> Int? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to delete from a \(typeName(self)) outside its designated queue.")
        
        return self.context.deleteAll(from, deleteClauses)
    }
    
    public func deleteAll<T: NSManagedObject>(from: From<T>, _ deleteClauses: [DeleteClause]) -> Int? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to delete from a \(typeName(self)) outside its designated queue.")
        
        return self.context.deleteAll(from, deleteClauses)
    }
    
    public func queryValue<T: NSManagedObject, U: SelectValueResultType>(from: From<T>, _ selectClause: Select<U>, _ queryClauses: QueryClause...) -> U? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to query from a \(typeName(self)) outside its designated queue.")
        
        return self.context.queryValue(from, selectClause, queryClauses)
    }
    
    public func queryValue<T: NSManagedObject, U: SelectValueResultType>(from: From<T>, _ selectClause: Select<U>, _ queryClauses: [QueryClause]) -> U? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to query from a \(typeName(self)) outside its designated queue.")
        
        return self.context.queryValue(from, selectClause, queryClauses)
    }
    
    public func queryAttributes<T: NSManagedObject>(from: From<T>, _ selectClause: Select<NSDictionary>, _ queryClauses: QueryClause...) -> [[NSString: AnyObject]]? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to query from a \(typeName(self)) outside its designated queue.")
        
        return self.context.queryAttributes(from, selectClause, queryClauses)
    }
    
    public func queryAttributes<T: NSManagedObject>(from: From<T>, _ selectClause: Select<NSDictionary>, _ queryClauses: [QueryClause]) -> [[NSString: AnyObject]]? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to query from a \(typeName(self)) outside its designated queue.")
        
        return self.context.queryAttributes(from, selectClause, queryClauses)
    }
}