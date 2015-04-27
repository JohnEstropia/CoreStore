//
//  NSManagedObjectContext+Querying.swift
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


// MARK: - NSManagedObjectContext

internal extension NSManagedObjectContext {
    
    // MARK: Public
    
    internal func fetchOne<T: NSManagedObject>(from: From<T>, _ queryClauses: FetchClause...) -> T? {
        
        return self.fetchOne(from, queryClauses)
    }
    
    internal func fetchOne<T: NSManagedObject>(from: From<T>, _ queryClauses: [FetchClause]) -> T? {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = self.entityDescriptionForEntityClass(T)
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .ManagedObjectResultType
        
        for clause in queryClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var fetchResults: [T]?
        var error: NSError?
        self.performBlockAndWait {
            
            fetchResults = self.executeFetchRequest(fetchRequest, error: &error) as? [T]
        }
        if fetchResults == nil {
            
            HardcoreData.handleError(
                error ?? NSError(hardcoreDataErrorCode: .UnknownError),
                "Failed executing fetch request.")
            return nil
        }
        
        return fetchResults?.first
    }
    
    internal func fetchAll<T: NSManagedObject>(from: From<T>, _ queryClauses: FetchClause...) -> [T]? {
        
        return self.fetchAll(from, queryClauses)
    }
    
    internal func fetchAll<T: NSManagedObject>(from: From<T>, _ queryClauses: [FetchClause]) -> [T]? {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = self.entityDescriptionForEntityClass(T)
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectResultType
        
        for clause in queryClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var fetchResults: [T]?
        var error: NSError?
        self.performBlockAndWait {
            
            fetchResults = self.executeFetchRequest(fetchRequest, error: &error) as? [T]
        }
        if fetchResults == nil {
            
            HardcoreData.handleError(
                error ?? NSError(hardcoreDataErrorCode: .UnknownError),
                "Failed executing fetch request.")
            return nil
        }
        
        return fetchResults
    }
    
    internal func fetchCount<T: NSManagedObject>(from: From<T>, _ queryClauses: FetchClause...) -> Int? {
    
        return self.fetchCount(from, queryClauses)
    }
    
    internal func fetchCount<T: NSManagedObject>(from: From<T>, _ queryClauses: [FetchClause]) -> Int? {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = self.entityDescriptionForEntityClass(T)
        
        for clause in queryClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var count = 0
        var error: NSError?
        self.performBlockAndWait {
            
            count = self.countForFetchRequest(fetchRequest, error: &error)
        }
        if count == NSNotFound {
            
            HardcoreData.handleError(
                error ?? NSError(hardcoreDataErrorCode: .UnknownError),
                "Failed executing fetch request.")
            return nil
        }
        
        return count
    }
    
    internal func fetchObjectID<T: NSManagedObject>(from: From<T>, _ queryClauses: FetchClause...) -> NSManagedObjectID? {
        
        return self.fetchObjectID(from, queryClauses)
    }
    
    internal func fetchObjectID<T: NSManagedObject>(from: From<T>, _ queryClauses: [FetchClause]) -> NSManagedObjectID? {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = self.entityDescriptionForEntityClass(T)
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .ManagedObjectIDResultType
        
        for clause in queryClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var fetchResults: [NSManagedObjectID]?
        var error: NSError?
        self.performBlockAndWait {
            
            fetchResults = self.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObjectID]
        }
        if fetchResults == nil {
            
            HardcoreData.handleError(
                error ?? NSError(hardcoreDataErrorCode: .UnknownError),
                "Failed executing fetch request.")
            return nil
        }
        
        return fetchResults?.first
    }
    
    internal func fetchObjectIDs<T: NSManagedObject>(from: From<T>, _ queryClauses: FetchClause...) -> [NSManagedObjectID]? {
        
        return self.fetchObjectIDs(from, queryClauses)
    }
    
    internal func fetchObjectIDs<T: NSManagedObject>(from: From<T>, _ queryClauses: [FetchClause]) -> [NSManagedObjectID]? {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = self.entityDescriptionForEntityClass(T)
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectIDResultType
        
        for clause in queryClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var fetchResults: [NSManagedObjectID]?
        var error: NSError?
        self.performBlockAndWait {
            
            fetchResults = self.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObjectID]
        }
        if fetchResults == nil {
            
            HardcoreData.handleError(
                error ?? NSError(hardcoreDataErrorCode: .UnknownError),
                "Failed executing fetch request.")
            return nil
        }
        
        return fetchResults
    }
    
    internal func deleteAll<T: NSManagedObject>(from: From<T>, _ queryClauses: FetchClause...) -> Int? {
        
        return self.deleteAll(from, queryClauses)
    }
    
    internal func deleteAll<T: NSManagedObject>(from: From<T>, _ queryClauses: [FetchClause]) -> Int? {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = self.entityDescriptionForEntityClass(T)
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectResultType
        fetchRequest.returnsObjectsAsFaults = true
        
        for clause in queryClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var numberOfDeletedObjects: Int?
        var error: NSError?
        self.performBlockAndWait {
            
            autoreleasepool {
                
                if let fetchResults = self.executeFetchRequest(fetchRequest, error: &error) as? [T] {
                    
                    numberOfDeletedObjects = fetchResults.count
                    for object in fetchResults {
                        
                        self.deleteObject(object)
                    }
                }
            }
        }
        if numberOfDeletedObjects == nil {
            
            HardcoreData.handleError(
                error ?? NSError(hardcoreDataErrorCode: .UnknownError),
                "Failed executing fetch request.")
            return nil
        }
        
        return numberOfDeletedObjects
    }
    
    internal func queryValue<T: NSManagedObject, U: SelectValueResultType>(from: From<T>, _ selectClause: Select<U>, _ queryClauses: FetchClause...) -> U? {
        
        return self.queryValue(from, selectClause, queryClauses)
    }
    
    internal func queryValue<T: NSManagedObject, U: SelectValueResultType>(from: From<T>, _ selectClause: Select<U>, _ queryClauses: [FetchClause]) -> U? {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = self.entityDescriptionForEntityClass(T)
        fetchRequest.fetchLimit = 0
        
        selectClause.applyToFetchRequest(fetchRequest)
        
        for clause in queryClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var fetchResults: [AnyObject]?
        var error: NSError?
        self.performBlockAndWait {
            
            fetchResults = self.executeFetchRequest(fetchRequest, error: &error)
        }
        if let fetchResults = fetchResults {
            
            if let rawResult = fetchResults.first as? NSDictionary,
                let rawObject: AnyObject = rawResult[selectClause.keyPathForFirstSelectTerm()] {
                    
                    return Select<U>.ReturnType.fromResultObject(rawObject)
            }
            return nil
        }
        
        HardcoreData.handleError(
            error ?? NSError(hardcoreDataErrorCode: .UnknownError),
            "Failed executing fetch request.")
        return nil
    }
    
    internal func queryAttributes<T: NSManagedObject>(from: From<T>, _ selectClause: Select<NSDictionary>, _ queryClauses: QueryClause...) -> [[NSString: AnyObject]]? {
        
        return self.queryAttributes(from, selectClause, queryClauses)
    }
    
    internal func queryAttributes<T: NSManagedObject>(from: From<T>, _ selectClause: Select<NSDictionary>, _ queryClauses: [QueryClause]) -> [[NSString: AnyObject]]? {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = self.entityDescriptionForEntityClass(T)
        fetchRequest.fetchLimit = 0
        
        selectClause.applyToFetchRequest(fetchRequest)
        
        for clause in queryClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var fetchResults: [AnyObject]?
        var error: NSError?
        self.performBlockAndWait {
            
            fetchResults = self.executeFetchRequest(fetchRequest, error: &error)
        }
        if let fetchResults = fetchResults {
            
            return Select<NSDictionary>.ReturnType.fromResultObjects(fetchResults)
        }
        
        HardcoreData.handleError(
            error ?? NSError(hardcoreDataErrorCode: .UnknownError),
            "Failed executing fetch request.")
        return nil
    }
}