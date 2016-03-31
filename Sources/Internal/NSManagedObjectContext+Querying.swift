//
//  NSManagedObjectContext+Querying.swift
//  CoreStore
//
//  Copyright © 2015 John Rommel Estropia
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
    
    // MARK: Internal
    
    internal func fetchExisting<T: NSManagedObject>(object: T) -> T? {
        
        if object.objectID.temporaryID {
            
            do {
                
                try withExtendedLifetime(self) { (context: NSManagedObjectContext) -> Void in
                    
                    try context.obtainPermanentIDsForObjects([object])
                }
            }
            catch {
                
                CoreStore.log(
                    CoreStoreError(error),
                    "Failed to obtain permanent ID for object."
                )
                return nil
            }
        }
        
        do {
            
            let existingObject = try self.existingObjectWithID(object.objectID)
            return (existingObject as! T)
        }
        catch {
            
            CoreStore.log(
                CoreStoreError(error),
                "Failed to load existing \(typeName(object)) in context."
            )
            return nil
        }
    }
    
    internal func fetchOne<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> T? {
        
        return self.fetchOne(from, fetchClauses)
    }
    
    internal func fetchOne<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> T? {
        
        let fetchRequest = CoreStoreFetchRequest()
        from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .ManagedObjectResultType
        
        for clause in fetchClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var fetchResults: [T]?
        var fetchError: ErrorType?
        self.performBlockAndWait {
            
            do {
                
                fetchResults = try self.executeFetchRequest(fetchRequest) as? [T]
            }
            catch {
                
                fetchError = error
            }
        }
        if fetchResults == nil {
            
            CoreStore.log(
                CoreStoreError(fetchError),
                "Failed executing fetch request."
            )
            return nil
        }
        
        return fetchResults?.first
    }
    
    internal func fetchAll<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> [T]? {
        
        return self.fetchAll(from, fetchClauses)
    }
    
    internal func fetchAll<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> [T]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectResultType
        
        for clause in fetchClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var fetchResults: [T]?
        var fetchError: ErrorType?
        self.performBlockAndWait {
            
            do {
                
                fetchResults = try self.executeFetchRequest(fetchRequest) as? [T]
            }
            catch {
                
                fetchError = error
            }
        }
        if fetchResults == nil {
            
            CoreStore.log(
                CoreStoreError(fetchError),
                "Failed executing fetch request."
            )
            return nil
        }
        
        return fetchResults
    }
    
    internal func fetchCount<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> Int? {
    
        return self.fetchCount(from, fetchClauses)
    }
    
    internal func fetchCount<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> Int? {
        
        let fetchRequest = CoreStoreFetchRequest()
        from.applyToFetchRequest(fetchRequest, context: self)
        
        for clause in fetchClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var count = 0
        var error: NSError?
        self.performBlockAndWait {
            
            count = self.countForFetchRequest(fetchRequest, error: &error)
        }
        if count == NSNotFound {
            
            CoreStore.log(
                CoreStoreError(error),
                "Failed executing fetch request."
            )
            return nil
        }
        
        return count
    }
    
    internal func fetchObjectID<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> NSManagedObjectID? {
        
        return self.fetchObjectID(from, fetchClauses)
    }
    
    internal func fetchObjectID<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> NSManagedObjectID? {
        
        let fetchRequest = CoreStoreFetchRequest()
        from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .ManagedObjectIDResultType
        
        for clause in fetchClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var fetchResults: [NSManagedObjectID]?
        var fetchError: ErrorType?
        self.performBlockAndWait {
            
            do {
                
                fetchResults = try self.executeFetchRequest(fetchRequest) as? [NSManagedObjectID]
            }
            catch {
                
                fetchError = error
            }
        }
        if fetchResults == nil {
            
            CoreStore.log(
                CoreStoreError(fetchError),
                "Failed executing fetch request."
            )
            return nil
        }
        
        return fetchResults?.first
    }
    
    internal func fetchObjectIDs<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> [NSManagedObjectID]? {
        
        return self.fetchObjectIDs(from, fetchClauses)
    }
    
    internal func fetchObjectIDs<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> [NSManagedObjectID]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectIDResultType
        
        for clause in fetchClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var fetchResults: [NSManagedObjectID]?
        var fetchError: ErrorType?
        self.performBlockAndWait {
            
            do {
                
                fetchResults = try self.executeFetchRequest(fetchRequest) as? [NSManagedObjectID]
            }
            catch {
                
                fetchError = error
            }
        }
        if fetchResults == nil {
            
            CoreStore.log(
                CoreStoreError(fetchError),
                "Failed executing fetch request."
            )
            return nil
        }
        
        return fetchResults
    }
    
    internal func deleteAll<T: NSManagedObject>(from: From<T>, _ deleteClauses: DeleteClause...) -> Int? {
        
        return self.deleteAll(from, deleteClauses)
    }
    
    internal func deleteAll<T: NSManagedObject>(from: From<T>, _ deleteClauses: [DeleteClause]) -> Int? {
        
        let fetchRequest = CoreStoreFetchRequest()
        from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectResultType
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.includesPropertyValues = false
        
        for clause in deleteClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var numberOfDeletedObjects: Int?
        var fetchError: ErrorType?
        self.performBlockAndWait {
            
            autoreleasepool {
                
                do {
                    
                    let fetchResults = try self.executeFetchRequest(fetchRequest) as? [T] ?? []
                    for object in fetchResults {
                        
                        self.deleteObject(object)
                    }
                    numberOfDeletedObjects = fetchResults.count
                }
                catch {
                    
                    fetchError = error
                }
            }
        }
        if numberOfDeletedObjects == nil {
            
            CoreStore.log(
                CoreStoreError(fetchError),
                "Failed executing fetch request."
            )
            return nil
        }
        
        return numberOfDeletedObjects
    }
    
    internal func queryValue<T: NSManagedObject, U: SelectValueResultType>(from: From<T>, _ selectClause: Select<U>, _ queryClauses: QueryClause...) -> U? {
        
        return self.queryValue(from, selectClause, queryClauses)
    }
    
    internal func queryValue<T: NSManagedObject, U: SelectValueResultType>(from: From<T>, _ selectClause: Select<U>, _ queryClauses: [QueryClause]) -> U? {
        
        let fetchRequest = CoreStoreFetchRequest()
        from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        
        selectClause.applyToFetchRequest(fetchRequest)
        
        for clause in queryClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var fetchResults: [AnyObject]?
        var fetchError: ErrorType?
        self.performBlockAndWait {
            
            do {
                
                fetchResults = try self.executeFetchRequest(fetchRequest)
            }
            catch {
                
                fetchError = error
            }
        }
        if let fetchResults = fetchResults {
            
            if let rawResult = fetchResults.first as? NSDictionary,
                let rawObject: AnyObject = rawResult[selectClause.keyPathForFirstSelectTerm()] {
                    
                    return Select<U>.ReturnType.fromResultObject(rawObject)
            }
            return nil
        }
        
        CoreStore.log(
            CoreStoreError(fetchError),
            "Failed executing fetch request."
        )
        return nil
    }
    
    internal func queryAttributes<T: NSManagedObject>(from: From<T>, _ selectClause: Select<NSDictionary>, _ queryClauses: QueryClause...) -> [[NSString: AnyObject]]? {
        
        return self.queryAttributes(from, selectClause, queryClauses)
    }
    
    internal func queryAttributes<T: NSManagedObject>(from: From<T>, _ selectClause: Select<NSDictionary>, _ queryClauses: [QueryClause]) -> [[NSString: AnyObject]]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        
        selectClause.applyToFetchRequest(fetchRequest)
        
        for clause in queryClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        var fetchResults: [AnyObject]?
        var fetchError: ErrorType?
        self.performBlockAndWait {
            
            do {
                
                fetchResults = try self.executeFetchRequest(fetchRequest)
            }
            catch {
                
                fetchError = error
            }
        }
        if let fetchResults = fetchResults {
            
            return Select<NSDictionary>.ReturnType.fromResultObjects(fetchResults)
        }
        
        CoreStore.log(
            CoreStoreError(fetchError),
            "Failed executing fetch request."
        )
        return nil
    }
}
