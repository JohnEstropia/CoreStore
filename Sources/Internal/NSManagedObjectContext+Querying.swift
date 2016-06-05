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
    
    // MARK: Internal: Fetch Existing
    
    @nonobjc
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
                "Failed to load existing \(cs_typeName(object)) in context."
            )
            return nil
        }
    }
    
    
    // MARK: Internal: Fetch One
    
    @nonobjc
    internal func fetchOne<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> T? {
        
        return self.fetchOne(from, fetchClauses)
    }
    
    @nonobjc
    internal func fetchOne<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> T? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .ManagedObjectResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchOne(fetchRequest)
    }
    
    @nonobjc
    internal func fetchOne<T: NSManagedObject>(fetchRequest: NSFetchRequest) -> T? {
        
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
    
    
    // MARK: Internal: Fetch All
    
    @nonobjc
    internal func fetchAll<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> [T]? {
        
        return self.fetchAll(from, fetchClauses)
    }
    
    @nonobjc
    internal func fetchAll<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> [T]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchAll(fetchRequest)
    }
    
    @nonobjc
    internal func fetchAll<T: NSManagedObject>(fetchRequest: NSFetchRequest) -> [T]? {
        
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
    
    
    // MARK: Internal: Count
    
    @nonobjc
    internal func fetchCount<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> Int? {
    
        return self.fetchCount(from, fetchClauses)
    }
    
    @nonobjc
    internal func fetchCount<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> Int? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchCount(fetchRequest)
    }
    
    @nonobjc
    internal func fetchCount(fetchRequest: NSFetchRequest) -> Int? {
        
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
    
    
    // MARK: Internal: Object ID
    
    @nonobjc
    internal func fetchObjectID<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> NSManagedObjectID? {
        
        return self.fetchObjectID(from, fetchClauses)
    }
    
    @nonobjc
    internal func fetchObjectID<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> NSManagedObjectID? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .ManagedObjectIDResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchObjectID(fetchRequest)
    }
    
    @nonobjc
    internal func fetchObjectID(fetchRequest: NSFetchRequest) -> NSManagedObjectID? {
        
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
    
    
    // MARK: Internal: Object IDs
    
    @nonobjc
    internal func fetchObjectIDs<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> [NSManagedObjectID]? {
        
        return self.fetchObjectIDs(from, fetchClauses)
    }
    
    @nonobjc
    internal func fetchObjectIDs<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> [NSManagedObjectID]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectIDResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchObjectIDs(fetchRequest)
    }
    
    @nonobjc
    internal func fetchObjectIDs(fetchRequest: NSFetchRequest) -> [NSManagedObjectID]? {
        
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
    
    
    // MARK: Internal: Delete All
    
    @nonobjc
    internal func deleteAll<T: NSManagedObject>(from: From<T>, _ deleteClauses: DeleteClause...) -> Int? {
        
        return self.deleteAll(from, deleteClauses)
    }
    
    @nonobjc
    internal func deleteAll<T: NSManagedObject>(from: From<T>, _ deleteClauses: [DeleteClause]) -> Int? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectResultType
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.includesPropertyValues = false
        deleteClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.deleteAll(fetchRequest)
    }
    
    @nonobjc
    internal func deleteAll(fetchRequest: NSFetchRequest) -> Int? {
        
        var numberOfDeletedObjects: Int?
        var fetchError: ErrorType?
        self.performBlockAndWait {
            
            cs_autoreleasepool {
                
                do {
                    
                    let fetchResults = try self.executeFetchRequest(fetchRequest) as? [NSManagedObject] ?? []
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
    
    
    // MARK: Internal: Value
    
    @nonobjc
    internal func queryValue<T: NSManagedObject, U: SelectValueResultType>(from: From<T>, _ selectClause: Select<U>, _ queryClauses: QueryClause...) -> U? {
        
        return self.queryValue(from, selectClause, queryClauses)
    }
    
    @nonobjc
    internal func queryValue<T: NSManagedObject, U: SelectValueResultType>(from: From<T>, _ selectClause: Select<U>, _ queryClauses: [QueryClause]) -> U? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        
        let selectTerms = selectClause.selectTerms
        selectTerms.applyToFetchRequest(fetchRequest, owner: selectClause)
        queryClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.queryValue(selectTerms, fetchRequest: fetchRequest)
    }
    
    @nonobjc
    internal func queryValue<U: SelectValueResultType>(selectTerms: [SelectTerm], fetchRequest: NSFetchRequest) -> U? {
        
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
                let rawObject: AnyObject = rawResult[selectTerms.keyPathForFirstSelectTerm()] {
                
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
    
    @nonobjc
    internal func queryValue(selectTerms: [SelectTerm], fetchRequest: NSFetchRequest) -> AnyObject? {
        
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
                let rawObject: AnyObject = rawResult[selectTerms.keyPathForFirstSelectTerm()] {
                
                return rawObject
            }
            return nil
        }
        
        CoreStore.log(
            CoreStoreError(fetchError),
            "Failed executing fetch request."
        )
        return nil
    }
    
    
    // MARK: Internal: Attributes
    
    @nonobjc
    internal func queryAttributes<T: NSManagedObject>(from: From<T>, _ selectClause: Select<NSDictionary>, _ queryClauses: QueryClause...) -> [[NSString: AnyObject]]? {
        
        return self.queryAttributes(from, selectClause, queryClauses)
    }
    
    @nonobjc
    internal func queryAttributes<T: NSManagedObject>(from: From<T>, _ selectClause: Select<NSDictionary>, _ queryClauses: [QueryClause]) -> [[NSString: AnyObject]]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        
        selectClause.selectTerms.applyToFetchRequest(fetchRequest, owner: selectClause)
        queryClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.queryAttributes(fetchRequest)
    }
    
    @nonobjc
    internal func queryAttributes(fetchRequest: NSFetchRequest) -> [[NSString: AnyObject]]? {
        
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
