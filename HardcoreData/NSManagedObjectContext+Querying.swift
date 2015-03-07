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
    
    internal func fetchOne<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> T? {
        
        return self.fetchOne(entity, queryClauses)
    }
    
    internal func fetchOne<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> T? {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = self.entityDescriptionForEntityClass(entity)
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
    
    internal func fetchAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> [T]? {
        
        return self.fetchAll(entity, queryClauses)
    }
    
    internal func fetchAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> [T]? {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = self.entityDescriptionForEntityClass(entity)
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
    
    internal func fetchCount<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> Int? {
    
        return self.fetchCount(entity, queryClauses)
    }
    
    internal func fetchCount<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> Int? {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = self.entityDescriptionForEntityClass(entity)
        
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
    
    internal func deleteAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> Int? {
        
        return self.deleteAll(entity, queryClauses)
    }
    
    internal func deleteAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> Int? {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = self.entityDescriptionForEntityClass(entity)
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
    
    internal func queryAggregate<T: NSManagedObject>(entity: T.Type, function: AggregateFunction, _ queryClauses: FetchClause...) -> Int? {
        
        return self.queryAggregateImplementation(entity, function: function, queryClauses)
    }
    
    internal func queryAggregate<T: NSManagedObject>(entity: T.Type, function: AggregateFunction, _ queryClauses: [FetchClause]) -> Int? {
        
        return self.queryAggregateImplementation(entity, function: function, queryClauses)
    }
    
    internal func queryAggregate<T: NSManagedObject, U: AggregateResultType>(entity: T.Type, function: AggregateFunction, _ queryClauses: FetchClause...) -> U? {
        
        return self.queryAggregateImplementation(entity, function: function, queryClauses)
    }
    
    internal func queryAggregate<T: NSManagedObject, U: AggregateResultType>(entity: T.Type, function: AggregateFunction, _ queryClauses: [FetchClause]) -> U? {
        
        return self.queryAggregateImplementation(entity, function: function, queryClauses)
    }
    
    internal func queryAggregateImplementation<T: NSManagedObject, U: AggregateResultType>(entity: T.Type, function: AggregateFunction, _ queryClauses: [FetchClause]) -> U? {
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "queryAggregate"
        expressionDescription.expressionResultType = U.attributeType
        expressionDescription.expression = function.createExpression()
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = self.entityDescriptionForEntityClass(entity)
        fetchRequest.resultType = .DictionaryResultType
        fetchRequest.propertiesToFetch = [expressionDescription]
        fetchRequest.includesPendingChanges = false
        
        for clause in queryClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var fetchResults: [AnyObject]?
        var error: NSError?
        self.performBlockAndWait {
            
            fetchResults = self.executeFetchRequest(fetchRequest, error: &error)
        }
        if fetchResults == nil {
            
            HardcoreData.handleError(
                error ?? NSError(hardcoreDataErrorCode: .UnknownError),
                "Failed executing fetch request.")
            return nil
        }
        
        if let result: AnyObject = (fetchResults?.first as! [String: AnyObject])[expressionDescription.name] {
            
            return U.fromResultObject(result)
        }
        
        return nil
    }
}