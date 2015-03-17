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
import GCDKit


// MARK: - DataStack

public extension DataStack {
    
    // MARK: Public
    
    public func fetchOne<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> T? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.fetchOne(entity, queryClauses)
    }
    
    public func fetchOne<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> T? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.fetchOne(entity, queryClauses)
    }
    
    public func fetchAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> [T]? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.fetchAll(entity, queryClauses)
    }
    
    public func fetchAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> [T]? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.fetchAll(entity, queryClauses)
    }
    
    public func fetchCount<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> Int? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.fetchCount(entity, queryClauses)
    }
    
    public func fetchCount<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> Int? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.fetchCount(entity, queryClauses)
    }
    
    public func fetchObjectID<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> NSManagedObjectID? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.fetchObjectID(entity, queryClauses)
    }
    
    public func fetchObjectID<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> NSManagedObjectID? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.fetchObjectID(entity, queryClauses)
    }
    
    public func fetchObjectIDs<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> [NSManagedObjectID]? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.fetchObjectIDs(entity, queryClauses)
    }
    
    public func fetchObjectIDs<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> [NSManagedObjectID]? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to fetch from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.fetchObjectIDs(entity, queryClauses)
    }
    
    public func deleteAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> Int? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to delete from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.deleteAll(entity, queryClauses)
    }
    
    public func deleteAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> Int? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to delete from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.deleteAll(entity, queryClauses)
    }
    
    public func queryValue<T: NSManagedObject, U: SelectValueResultType>(entity: T.Type, _ selectClause: Select<U>, _ queryClauses: FetchClause...) -> U? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to query from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.queryValue(entity, selectClause, queryClauses)
    }
    
    public func queryValue<T: NSManagedObject, U: SelectValueResultType>(entity: T.Type, _ selectClause: Select<U>, _ queryClauses: [FetchClause]) -> U? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to query from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.queryValue(entity, selectClause, queryClauses)
    }
    
    public func queryAttributes<T: NSManagedObject>(entity: T.Type, _ selectClause: Select<NSDictionary>, _ queryClauses: QueryClause...) -> [[NSString: AnyObject]]? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to query from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.queryAttributes(entity, selectClause, queryClauses)
    }
    
    public func queryAttributes<T: NSManagedObject>(entity: T.Type, _ selectClause: Select<NSDictionary>, _ queryClauses: [QueryClause]) -> [[NSString: AnyObject]]? {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to query from a <\(self.dynamicType)> outside the main queue.")
        
        return self.mainContext.queryAttributes(entity, selectClause, queryClauses)
    }
}
