//
//  NSManagedObjectContext+Querying.swift
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
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

extension NSManagedObjectContext: FetchableSource, QueryableSource {
    
    // MARK: FetchableSource
    
    @nonobjc
    public func fetchExisting<D: DynamicObject>(_ object: D) -> D? {
        
        let rawObject = object.cs_toRaw()
        if rawObject.objectID.isTemporaryID {
            
            do {
                
                try withExtendedLifetime(self) { (context: NSManagedObjectContext) -> Void in
                    
                    try context.obtainPermanentIDs(for: [rawObject])
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
            
            let existingRawObject = try self.existingObject(with: rawObject.objectID)
            if existingRawObject === rawObject {
                
                return object
            }
            return cs_dynamicType(of: object).cs_fromRaw(object: existingRawObject)
        }
        catch {
            
            CoreStore.log(
                CoreStoreError(error),
                "Failed to load existing \(cs_typeName(object)) in context."
            )
            return nil
        }
    }
    
    @nonobjc
    public func fetchExisting<D: DynamicObject>(_ objectID: NSManagedObjectID) -> D? {
        
        do {
            
            let existingObject = try self.existingObject(with: objectID)
            return D.cs_fromRaw(object: existingObject)
        }
        catch _ {
            
            return nil
        }
    }
    
    @nonobjc
    public func fetchExisting<D: DynamicObject, S: Sequence>(_ objects: S) -> [D] where S.Iterator.Element == D {
        
        return objects.compactMap({ self.fetchExisting($0.cs_id()) })
    }
    
    @nonobjc
    public func fetchExisting<D: DynamicObject, S: Sequence>(_ objectIDs: S) -> [D] where S.Iterator.Element == NSManagedObjectID {
        
        return objectIDs.compactMap({ self.fetchExisting($0) })
    }
    
    @nonobjc
    public func fetchOne<D>(_ from: From<D>, _ fetchClauses: FetchClause...) -> D? {
        
        return self.fetchOne(from, fetchClauses)
    }
    
    @nonobjc
    public func fetchOne<D>(_ from: From<D>, _ fetchClauses: [FetchClause]) -> D? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .managedObjectResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchOne(fetchRequest.dynamicCast()).flatMap(from.entityClass.cs_fromRaw)
    }
    
    @nonobjc
    public func fetchOne<B: FetchChainableBuilderType>(_ clauseChain: B) -> B.ObjectType? {
        
        return self.fetchOne(clauseChain.from, clauseChain.fetchClauses)
    }
    
    @nonobjc
    public func fetchAll<D>(_ from: From<D>, _ fetchClauses: FetchClause...) -> [D]? {
        
        return self.fetchAll(from, fetchClauses)
    }
    
    @nonobjc
    public func fetchAll<D>(_ from: From<D>, _ fetchClauses: [FetchClause]) -> [D]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .managedObjectResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        let entityClass = from.entityClass
        return self.fetchAll(fetchRequest.dynamicCast())?.map(entityClass.cs_fromRaw)
    }
    
    @nonobjc
    public func fetchAll<B: FetchChainableBuilderType>(_ clauseChain: B) -> [B.ObjectType]? {
        
        return self.fetchAll(clauseChain.from, clauseChain.fetchClauses)
    }
    
    @nonobjc
    public func fetchCount<D>(_ from: From<D>, _ fetchClauses: FetchClause...) -> Int? {
    
        return self.fetchCount(from, fetchClauses)
    }
    
    @nonobjc
    public func fetchCount<D>(_ from: From<D>, _ fetchClauses: [FetchClause]) -> Int? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchCount(fetchRequest.dynamicCast())
    }
    
    @nonobjc
    public func fetchCount<B: FetchChainableBuilderType>(_ clauseChain: B) -> Int? {
        
        return self.fetchCount(clauseChain.from, clauseChain.fetchClauses)
    }
    
    @nonobjc
    public func fetchObjectID<D>(_ from: From<D>, _ fetchClauses: FetchClause...) -> NSManagedObjectID? {
        
        return self.fetchObjectID(from, fetchClauses)
    }
    
    @nonobjc
    public func fetchObjectID<D>(_ from: From<D>, _ fetchClauses: [FetchClause]) -> NSManagedObjectID? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .managedObjectIDResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchObjectID(fetchRequest.dynamicCast())
    }
    
    // TODO: docs
    @nonobjc
    public func fetchObjectID<B: FetchChainableBuilderType>(_ clauseChain: B) -> NSManagedObjectID? {
        
        return self.fetchObjectID(clauseChain.from, clauseChain.fetchClauses)
    }
    
    @nonobjc
    public func fetchObjectIDs<D>(_ from: From<D>, _ fetchClauses: FetchClause...) -> [NSManagedObjectID]? {
        
        return self.fetchObjectIDs(from, fetchClauses)
    }
    
    @nonobjc
    public func fetchObjectIDs<D>(_ from: From<D>, _ fetchClauses: [FetchClause]) -> [NSManagedObjectID]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .managedObjectIDResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchObjectIDs(fetchRequest.dynamicCast())
    }
    
    // TODO: docs
    @nonobjc
    public func fetchObjectIDs<B: FetchChainableBuilderType>(_ clauseChain: B) -> [NSManagedObjectID]? {
        
        return self.fetchObjectIDs(clauseChain.from, clauseChain.fetchClauses)
    }
    
    @nonobjc
    internal func fetchObjectIDs(_ fetchRequest: NSFetchRequest<NSManagedObjectID>) -> [NSManagedObjectID]? {
        
        var fetchResults: [NSManagedObjectID]?
        var fetchError: Error?
        self.performAndWait {
            
            do {
                
                fetchResults = try self.fetch(fetchRequest)
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
    
    
    // MARK: QueryableSource
    
    @nonobjc
    public func queryValue<D, U: QueryableAttributeType>(_ from: From<D>, _ selectClause: Select<D, U>, _ queryClauses: QueryClause...) -> U? {
        
        return self.queryValue(from, selectClause, queryClauses)
    }
    
    @nonobjc
    public func queryValue<D, U: QueryableAttributeType>(_ from: From<D>, _ selectClause: Select<D, U>, _ queryClauses: [QueryClause]) -> U? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        
        selectClause.applyToFetchRequest(fetchRequest)
        queryClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.queryValue(selectClause.selectTerms, fetchRequest: fetchRequest)
    }
    
    @nonobjc
    public func queryValue<B>(_ clauseChain: B) -> B.ResultType? where B: QueryChainableBuilderType, B.ResultType: QueryableAttributeType {
        
        return self.queryValue(clauseChain.from, clauseChain.select, clauseChain.queryClauses)
    }
    
    @nonobjc
    public func queryAttributes<D>(_ from: From<D>, _ selectClause: Select<D, NSDictionary>, _ queryClauses: QueryClause...) -> [[String: Any]]? {
        
        return self.queryAttributes(from, selectClause, queryClauses)
    }
    
    @nonobjc
    public func queryAttributes<D>(_ from: From<D>, _ selectClause: Select<D, NSDictionary>, _ queryClauses: [QueryClause]) -> [[String: Any]]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        
        selectClause.applyToFetchRequest(fetchRequest)
        queryClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.queryAttributes(fetchRequest)
    }
    
    public func queryAttributes<B>(_ clauseChain: B) -> [[String : Any]]? where B : QueryChainableBuilderType, B.ResultType == NSDictionary {
        
        return self.queryAttributes(clauseChain.from, clauseChain.select, clauseChain.queryClauses)
    }
    
    
    // MARK: FetchableSource, QueryableSource
    
    @nonobjc
    public func unsafeContext() -> NSManagedObjectContext {
        
        return self
    }
    
    
    // MARK: Deleting
    
    @nonobjc
    internal func deleteAll<D>(_ from: From<D>, _ deleteClauses: [FetchClause]) -> Int? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .managedObjectResultType
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.includesPropertyValues = false
        deleteClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.deleteAll(fetchRequest.dynamicCast())
    }
    
    
    // MARK: Deprecated
    
    @available(*, deprecated, renamed: "unsafeContext()")
    public func internalContext() -> NSManagedObjectContext {
        
        return self.unsafeContext()
    }
}


// MARK: - NSManagedObjectContext (Internal)

internal extension NSManagedObjectContext {
    
    // MARK: Fetching
    
    @nonobjc
    internal func fetchOne<D: NSManagedObject>(_ fetchRequest: NSFetchRequest<D>) -> D? {
        
        var fetchResults: [D]?
        var fetchError: Error?
        self.performAndWait {
            
            do {
                
                fetchResults = try self.fetch(fetchRequest)
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
    
    @nonobjc
    internal func fetchAll<D: NSManagedObject>(_ fetchRequest: NSFetchRequest<D>) -> [D]? {
        
        var fetchResults: [D]?
        var fetchError: Error?
        self.performAndWait {
            
            do {
                
                fetchResults = try self.fetch(fetchRequest)
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
    
    @nonobjc
    internal func fetchCount(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> Int? {
        
        var count = 0
        var countError: Error?
        self.performAndWait {
            
            do {
                
                count = try self.count(for: fetchRequest)
            }
            catch {
                
                countError = error
            }
        }
        if count == NSNotFound {
            
            CoreStore.log(
                CoreStoreError(countError),
                "Failed executing count request."
            )
            return nil
        }
        return count
    }
    
    @nonobjc
    internal func fetchObjectID(_ fetchRequest: NSFetchRequest<NSManagedObjectID>) -> NSManagedObjectID? {
        
        var fetchResults: [NSManagedObjectID]?
        var fetchError: Error?
        self.performAndWait {
            
            do {
                
                fetchResults = try self.fetch(fetchRequest)
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
    
    
    // MARK: Querying
    
    @nonobjc
    internal func queryValue<D, U: QueryableAttributeType>(_ selectTerms: [SelectTerm<D>], fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> U? {
        
        var fetchResults: [Any]?
        var fetchError: Error?
        self.performAndWait {
            
            do {
                
                fetchResults = try self.fetch(fetchRequest)
            }
            catch {
                
                fetchError = error
            }
        }
        if let fetchResults = fetchResults {
            
            if let rawResult = fetchResults.first as? NSDictionary,
                let rawObject = rawResult[selectTerms.first!.keyPathString] as? U.QueryableNativeType {
                
                return Select<D, U>.ReturnType.cs_fromQueryableNativeType(rawObject)
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
    internal func queryValue<D>(_ selectTerms: [SelectTerm<D>], fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> Any? {
        
        var fetchResults: [Any]?
        var fetchError: Error?
        self.performAndWait {
            
            do {
                
                fetchResults = try self.fetch(fetchRequest)
            }
            catch {
                
                fetchError = error
            }
        }
        if let fetchResults = fetchResults {
            
            if let rawResult = fetchResults.first as? NSDictionary,
                let rawObject = rawResult[selectTerms.first!.keyPathString] {
                
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
    
    @nonobjc
    internal func queryAttributes(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [[String: Any]]? {
        
        var fetchResults: [Any]?
        var fetchError: Error?
        self.performAndWait {
            
            do {
                
                fetchResults = try self.fetch(fetchRequest)
            }
            catch {
                
                fetchError = error
            }
        }
        if let fetchResults = fetchResults {
            
            return NSDictionary.cs_fromQueryResultsNativeType(fetchResults)
        }
        
        CoreStore.log(
            CoreStoreError(fetchError),
            "Failed executing fetch request."
        )
        return nil
    }
    
    
    // MARK: Deleting
    
    @nonobjc
    internal func deleteAll<D: NSManagedObject>(_ fetchRequest: NSFetchRequest<D>) -> Int? {
        
        var numberOfDeletedObjects: Int?
        var fetchError: Error?
        self.performAndWait {
            
            autoreleasepool {
                
                do {
                    
                    let fetchResults = try self.fetch(fetchRequest)
                    for object in fetchResults {
                        
                        self.delete(object)
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
}
