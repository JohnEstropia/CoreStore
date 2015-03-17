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
    
    public func fetchOne<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> T? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.fetchOne(entity, queryClauses)
    }
    
    public func fetchOne<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> T? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.fetchOne(entity, queryClauses)
    }
    
    public func fetchAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> [T]? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.fetchAll(entity, queryClauses)
    }
    
    public func fetchAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> [T]? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.fetchAll(entity, queryClauses)
    }
    
    public func fetchCount<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> Int? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.fetchCount(entity, queryClauses)
    }
    
    public func fetchCount<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> Int? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.fetchCount(entity, queryClauses)
    }
    
    public func fetchObjectID<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> NSManagedObjectID? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.fetchObjectID(entity, queryClauses)
    }
    
    public func fetchObjectID<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> NSManagedObjectID? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.fetchObjectID(entity, queryClauses)
    }
    
    public func fetchObjectIDs<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> [NSManagedObjectID]? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.fetchObjectIDs(entity, queryClauses)
    }
    
    public func fetchObjectIDs<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> [NSManagedObjectID]? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.fetchObjectIDs(entity, queryClauses)
    }
    
    public func deleteAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> Int? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to delete from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.deleteAll(entity, queryClauses)
    }
    
    public func deleteAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> Int? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to delete from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.deleteAll(entity, queryClauses)
    }
    
    public func queryValue<T: NSManagedObject, U: SelectValueResultType>(entity: T.Type, _ selectClause: Select<U>, _ queryClauses: FetchClause...) -> U? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to query from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.queryValue(entity, selectClause, queryClauses)
    }
    
    public func queryValue<T: NSManagedObject, U: SelectValueResultType>(entity: T.Type, _ selectClause: Select<U>, _ queryClauses: [FetchClause]) -> U? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to query from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.queryValue(entity, selectClause, queryClauses)
    }
    
    public func queryAttributes<T: NSManagedObject>(entity: T.Type, _ selectClause: Select<NSDictionary>, _ queryClauses: QueryClause...) -> [[NSString: AnyObject]]? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to query from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.queryAttributes(entity, selectClause, queryClauses)
    }
    
    public func queryAttributes<T: NSManagedObject>(entity: T.Type, _ selectClause: Select<NSDictionary>, _ queryClauses: [QueryClause]) -> [[NSString: AnyObject]]? {
        
        HardcoreData.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to query from a <\(self.dynamicType)> outside its designated queue.")
        
        return self.context.queryAttributes(entity, selectClause, queryClauses)
    }
}