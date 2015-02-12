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


extension NSManagedObjectContext {
    
    public func fetchOne<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> T? {
        
        return self.fetchOne(entity, queryClauses)
    }
    
    public func fetchOne<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> T? {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(
            entity.entityName,
            inManagedObjectContext: self)
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
            
            HardcoreData.handleError(error!, "Failed executing fetch request.")
            return nil
        }
        
        return fetchResults?.first
    }
    
    public func fetchAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> [T]? {
        
        return self.fetchAll(entity, queryClauses)
    }
    
    public func fetchAll<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> [T]? {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(
            entity.entityName,
            inManagedObjectContext: self)
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
            
            HardcoreData.handleError(error!, "Failed executing fetch request.")
            return nil
        }
        
        return fetchResults
    }
    
    public func queryCount<T: NSManagedObject>(entity: T.Type, _ queryClauses: FetchClause...) -> Int {
    
        return self.queryCount(entity, queryClauses)
    }
    
    public func queryCount<T: NSManagedObject>(entity: T.Type, _ queryClauses: [FetchClause]) -> Int {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(
            entity.entityName,
            inManagedObjectContext: self)
        
        for clause in queryClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var count = 0
        var error: NSError?
        self.performBlockAndWait {
            
            count = self.countForFetchRequest(fetchRequest, error: &error)
        }
        if count == NSNotFound {
            
            HardcoreData.handleError(error!, "Failed executing fetch request.")
            return 0
        }
        
        return count
    }
    
    
//    public func queryCount<T: NSManagedObject, U: IntegerType>(entity: T.Type, _ queryClauses: [FetchClause]) -> U? {
//        
////        let expressionDescription = NSExpressionDescription()
////        expressionDescription.name = "queryCount"
////        expressionDescription.expressionResultType = .Integer32AttributeType
////        expressionDescription.expression = NSExpression(
////            forFunction: "min:",
////            arguments: [NSExpression(forKeyPath: attribute)])
//        
//        let request = NSFetchRequest(entityName: entity.entityName)
//        request.resultType = .DictionaryResultType
//        request.predicate = predicate
//        request.propertiesToFetch = [expressionDescription]
//        
//        var error: NSError?
//        let results = NSManagedObjectContext.context()?.executeFetchRequest(request, error: &error)
//        if results == nil {
//            
//            JEDumpAlert(error, "error")
//            return nil
//        }
//        
//        return (results?.first as? [String: NSDate])?[expressionDescription.name]
//    }
}