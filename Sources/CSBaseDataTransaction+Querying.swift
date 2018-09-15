//
//  CSBaseDataTransaction+Querying.swift
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


// MARK: - CSBaseDataTransaction

public extension CSBaseDataTransaction {
    
    /**
     Fetches the `NSManagedObject` instance in the transaction's context from a reference created from a transaction or from a different managed object context.
     
     - parameter object: a reference to the object created/fetched outside the transaction
     - returns: the `NSManagedObject` instance if the object exists in the transaction, or `nil` if not found.
     */
    @objc
    public func fetchExistingObject(_ object: NSManagedObject) -> Any? {
        
        return self.swiftTransaction.context.fetchExisting(object) as NSManagedObject?
    }
    
    /**
     Fetches the `NSManagedObject` instance in the transaction's context from an `NSManagedObjectID`.
     
     - parameter objectID: the `NSManagedObjectID` for the object
     - returns: the `NSManagedObject` instance if the object exists in the transaction, or `nil` if not found.
     */
    @objc
    public func fetchExistingObjectWithID(_ objectID: NSManagedObjectID) -> Any? {
        
        return self.swiftTransaction.context.fetchExisting(objectID) as NSManagedObject?
    }
    
    /**
     Fetches the `NSManagedObject` instances in the transaction's context from references created from a transaction or from a different managed object context.
     
     - parameter objects: an array of `NSManagedObject`s created/fetched outside the transaction
     - returns: the `NSManagedObject` array for objects that exists in the transaction
     */
    @objc
    public func fetchExistingObjects(_ objects: [NSManagedObject]) -> [Any] {
        
        return self.swiftTransaction.context.fetchExisting(objects) as [NSManagedObject]
    }
    
    /**
     Fetches the `NSManagedObject` instances in the transaction's context from a list of `NSManagedObjectID`.
     
     - parameter objectIDs: the `NSManagedObjectID` array for the objects
     - returns: the `NSManagedObject` array for objects that exists in the transaction
     */
    @objc
    public func fetchExistingObjectsWithIDs(_ objectIDs: [NSManagedObjectID]) -> [Any] {
        
        return self.swiftTransaction.context.fetchExisting(objectIDs) as [NSManagedObject]
    }
    
    /**
     Fetches the first `NSManagedObject` instance that satisfies the specified `CSFetchClause`s. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `CSFetchClause` instances for the fetch request. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: the first `NSManagedObject` instance that satisfies the specified `CSFetchClause`s
     */
    @objc
    public func fetchOneFrom(_ from: CSFrom, fetchClauses: [CSFetchClause]) -> Any? {
        
        CoreStore.assert(
            self.swiftTransaction.isRunningInAllowedQueue(),
            "Attempted to fetch from a \(cs_typeName(self)) outside its designated queue."
        )
        return self.swiftTransaction.context.fetchOne(from, fetchClauses)
    }
    
    /**
     Fetches all `NSManagedObject` instances that satisfy the specified `CSFetchClause`s. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter fetchClauses: a series of `CSFetchClause` instances for the fetch request. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: all `NSManagedObject` instances that satisfy the specified `CSFetchClause`s
     */
    @objc
    public func fetchAllFrom(_ from: CSFrom, fetchClauses: [CSFetchClause]) -> [Any]? {
        
        CoreStore.assert(
            self.swiftTransaction.isRunningInAllowedQueue(),
            "Attempted to fetch from a \(cs_typeName(self)) outside its designated queue."
        )
        return self.swiftTransaction.context.fetchAll(from, fetchClauses)
    }
    
    /**
     Fetches the number of `NSManagedObject`s that satisfy the specified `CSFetchClause`s. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter fetchClauses: a series of `CSFetchClause` instances for the fetch request. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: the number `NSManagedObject`s that satisfy the specified `CSFetchClause`s
     */
    @objc
    public func fetchCountFrom(_ from: CSFrom, fetchClauses: [CSFetchClause]) -> NSNumber? {
        
        CoreStore.assert(
            self.swiftTransaction.isRunningInAllowedQueue(),
            "Attempted to fetch from a \(cs_typeName(self)) outside its designated queue."
        )
        return self.swiftTransaction.context
            .fetchCount(from, fetchClauses)
            .flatMap { NSNumber(value: $0) }
    }
    
    /**
     Fetches the `NSManagedObjectID` for the first `NSManagedObject` that satisfies the specified `CSFetchClause`s. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter fetchClauses: a series of `CSFetchClause` instances for the fetch request. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: the `NSManagedObjectID` for the first `NSManagedObject` that satisfies the specified `CSFetchClause`s
     */
    @objc
    public func fetchObjectIDFrom(_ from: CSFrom, fetchClauses: [CSFetchClause]) -> NSManagedObjectID? {
        
        CoreStore.assert(
            self.swiftTransaction.isRunningInAllowedQueue(),
            "Attempted to fetch from a \(cs_typeName(self)) outside its designated queue."
        )
        return self.swiftTransaction.context.fetchObjectID(from, fetchClauses)
    }
    
    /**
     Queries aggregate values as specified by the `CSQueryClause`s. Requires at least a `CSSelect` clause, and optional `CSWhere`, `CSOrderBy`, `CSGroupBy`, and `CSTweak` clauses.
     
     A "query" differs from a "fetch" in that it only retrieves values already stored in the persistent store. As such, values from unsaved transactions or contexts will not be incorporated in the query result.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter selectClause: a `CSSelect` clause indicating the properties to fetch, and with the generic type indicating the return type.
     - parameter queryClauses: a series of `CSQueryClause` instances for the query request. Accepts `CSWhere`, `CSOrderBy`, `CSGroupBy`, and `CSTweak` clauses.
     - returns: the result of the the query. The type of the return value is specified by the generic type of the `CSSelect` parameter.
     */
    @objc
    public func queryValueFrom(_ from: CSFrom, selectClause: CSSelect, queryClauses: [CSQueryClause]) -> Any? {
        
        CoreStore.assert(
            self.swiftTransaction.isRunningInAllowedQueue(),
            "Attempted to query from a \(cs_typeName(self)) outside its designated queue."
        )
        return self.swiftTransaction.context.queryValue(from, selectClause, queryClauses)
    }
    
    /**
     Queries a dictionary of attribute values as specified by the `CSQueryClause`s. Requires at least a `CSSelect` clause, and optional `CSWhere`, `CSOrderBy`, `CSGroupBy`, and `CSTweak` clauses.
     
     A "query" differs from a "fetch" in that it only retrieves values already stored in the persistent store. As such, values from unsaved transactions or contexts will not be incorporated in the query result.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter selectClause: a `CSSelect` clause indicating the properties to fetch, and with the generic type indicating the return type.
     - parameter queryClauses: a series of `CSQueryClause` instances for the query request. Accepts `CSWhere`, `CSOrderBy`, `CSGroupBy`, and `CSTweak` clauses.
     - returns: the result of the the query. The type of the return value is specified by the generic type of the `CSSelect` parameter.
     */
    @objc
    public func queryAttributesFrom(_ from: CSFrom, selectClause: CSSelect, queryClauses: [CSQueryClause]) -> [[String: Any]]? {
        
        CoreStore.assert(
            self.swiftTransaction.isRunningInAllowedQueue(),
            "Attempted to query from a \(cs_typeName(self)) outside its designated queue."
        )
        return self.swiftTransaction.context.queryAttributes(from, selectClause, queryClauses)
    }
}
