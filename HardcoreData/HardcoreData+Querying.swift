//
//  HardcoreData+Querying.swift
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

// MARK: - HardcoreData

public extension HardcoreData {
    
    // MARK: Public
    
    public static func fetchOne<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> T? {
        
        return self.defaultStack.fetchOne(entity, queryClauses)
    }
    
    public static func fetchOne<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> T? {
        
        return self.defaultStack.fetchOne(entity, queryClauses)
    }
    
    public static func fetchAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> [T]? {
        
        return self.defaultStack.fetchAll(entity, queryClauses)
    }
    
    public static func fetchAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> [T]? {
        
        return self.defaultStack.fetchAll(entity, queryClauses)
    }
    
    public static func fetchCount<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> Int? {
        
        return self.defaultStack.fetchCount(entity, queryClauses)
    }
    
    public static func fetchCount<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> Int? {
        
        return self.defaultStack.fetchCount(entity, queryClauses)
    }
    
    public static func fetchObjectID<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> NSManagedObjectID? {
        
        return self.defaultStack.fetchObjectID(entity, queryClauses)
    }
    
    public static func fetchObjectID<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> NSManagedObjectID? {
        
        return self.defaultStack.fetchObjectID(entity, queryClauses)
    }
    
    public static func fetchObjectIDs<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> [NSManagedObjectID]? {
        
        return self.defaultStack.fetchObjectIDs(entity, queryClauses)
    }
    
    public static func fetchObjectIDs<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> [NSManagedObjectID]? {
        
        return self.defaultStack.fetchObjectIDs(entity, queryClauses)
    }
    
    public static func deleteAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> Int? {
        
        return self.defaultStack.deleteAll(entity, queryClauses)
    }
    
    public static func deleteAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> Int? {
        
        return self.defaultStack.deleteAll(entity, queryClauses)
    }
    
    public static func queryValue<T: NSManagedObject, U: SelectValueResultType>(entity: T.Type, _ selectClause: Select<U>, _ queryClauses: FetchClause...) -> U? {
        
        return self.defaultStack.queryValue(entity, selectClause, queryClauses)
    }
    
    public static func queryValue<T: NSManagedObject, U: SelectValueResultType>(entity: T.Type, _ selectClause: Select<U>, _ queryClauses: [FetchClause]) -> U? {
        
        return self.defaultStack.queryValue(entity, selectClause, queryClauses)
    }
    
    public static func queryAttributes<T: NSManagedObject>(entity: T.Type, _ selectClause: Select<NSDictionary>, _ queryClauses: QueryClause...) -> [[NSString: AnyObject]]? {
        
        return self.defaultStack.queryAttributes(entity, selectClause, queryClauses)
    }
    
    public static func queryAttributes<T: NSManagedObject>(entity: T.Type, _ selectClause: Select<NSDictionary>, _ queryClauses: [QueryClause]) -> [[NSString: AnyObject]]? {
        
        return self.defaultStack.queryAttributes(entity, selectClause, queryClauses)
    }
}