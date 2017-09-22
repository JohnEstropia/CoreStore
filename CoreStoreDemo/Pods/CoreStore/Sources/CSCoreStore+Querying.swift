//
//  CSCoreStore+Querying.swift
//  CoreStore
//
//  Copyright © 2016 John Rommel Estropia
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


// MARK: - CSCoreStore

public extension CSCoreStore {
    
    /**
     Using the `defaultStack`, fetches the `NSManagedObject` instance in the transaction's context from a reference created from a transaction or from a different managed object context.
     
     - parameter object: a reference to the object created/fetched outside the transaction
     - returns: the `NSManagedObject` instance if the object exists in the transaction, or `nil` if not found.
     */
    @objc
    public static func fetchExistingObject(_ object: NSManagedObject) -> Any? {
        
        return self.defaultStack.fetchExistingObject(object)
    }
    
    /**
     Using the `defaultStack`, fetches the `NSManagedObject` instance in the transaction's context from an `NSManagedObjectID`.
     
     - parameter objectID: the `NSManagedObjectID` for the object
     - returns: the `NSManagedObject` instance if the object exists in the transaction, or `nil` if not found.
     */
    @objc
    public static func fetchExistingObjectWithID(_ objectID: NSManagedObjectID) -> Any? {
        
        return self.defaultStack.fetchExistingObjectWithID(objectID)
    }
    
    /**
     Using the `defaultStack`, fetches the `NSManagedObject` instances in the transaction's context from references created from a transaction or from a different managed object context.
     
     - parameter objects: an array of `NSManagedObject`s created/fetched outside the transaction
     - returns: the `NSManagedObject` array for objects that exists in the transaction
     */
    @objc
    public static func fetchExistingObjects(_ objects: [NSManagedObject]) -> [Any] {
        
        return self.defaultStack.fetchExistingObjects(objects)
    }
    
    /**
     Using the `defaultStack`, fetches the `NSManagedObject` instances in the transaction's context from a list of `NSManagedObjectID`.
     
     - parameter objectIDs: the `NSManagedObjectID` array for the objects
     - returns: the `NSManagedObject` array for objects that exists in the transaction
     */
    @objc
    public static func fetchExistingObjectsWithIDs(_ objectIDs: [NSManagedObjectID]) -> [Any] {
        
        return self.defaultStack.fetchExistingObjectsWithIDs(objectIDs)
    }
    
    /**
     Using the `defaultStack`, fetches the first `NSManagedObject` instance that satisfies the specified `CSFetchClause`s. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `CSFetchClause` instances for the fetch request. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: the first `NSManagedObject` instance that satisfies the specified `CSFetchClause`s
     */
    @objc
    public static func fetchOneFrom(_ from: CSFrom, fetchClauses: [CSFetchClause]) -> Any? {
        
        return self.defaultStack.fetchOneFrom(from, fetchClauses: fetchClauses)
    }
    
    /**
     Using the `defaultStack`, fetches all `NSManagedObject` instances that satisfy the specified `CSFetchClause`s. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter fetchClauses: a series of `CSFetchClause` instances for the fetch request. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: all `NSManagedObject` instances that satisfy the specified `CSFetchClause`s
     */
    @objc
    public static func fetchAllFrom(_ from: CSFrom, fetchClauses: [CSFetchClause]) -> [Any]? {
        
        return self.defaultStack.fetchAllFrom(from, fetchClauses: fetchClauses)
    }
    
    /**
     Using the `defaultStack`, fetches the number of `NSManagedObject`s that satisfy the specified `CSFetchClause`s. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter fetchClauses: a series of `CSFetchClause` instances for the fetch request. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: the number `NSManagedObject`s that satisfy the specified `CSFetchClause`s
     */
    @objc
    public static func fetchCountFrom(_ from: CSFrom, fetchClauses: [CSFetchClause]) -> NSNumber? {
        
        return self.defaultStack.fetchCountFrom(from, fetchClauses: fetchClauses)
    }
    
    /**
     Using the `defaultStack`, fetches the `NSManagedObjectID` for the first `NSManagedObject` that satisfies the specified `CSFetchClause`s. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter fetchClauses: a series of `CSFetchClause` instances for the fetch request. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: the `NSManagedObjectID` for the first `NSManagedObject` that satisfies the specified `CSFetchClause`s
     */
    @objc
    public static func fetchObjectIDFrom(_ from: CSFrom, fetchClauses: [CSFetchClause]) -> NSManagedObjectID? {
        
        return self.defaultStack.fetchObjectIDFrom(from, fetchClauses: fetchClauses)
    }
    
    /**
     Using the `defaultStack`, fetches the `NSManagedObjectID` for all `NSManagedObject`s that satisfy the specified `CSFetchClause`s. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: the `NSManagedObjectID` for all `NSManagedObject`s that satisfy the specified `CSFetchClause`s
     */
    @objc
    public static func fetchObjectIDsFrom(_ from: CSFrom, fetchClauses: [CSFetchClause]) -> [NSManagedObjectID]? {
        
        return self.defaultStack.fetchObjectIDsFrom(from, fetchClauses: fetchClauses)
    }
    
    /**
     Using the `defaultStack`, queries aggregate values as specified by the `CSQueryClause`s. Requires at least a `CSSelect` clause, and optional `CSWhere`, `CSOrderBy`, `CSGroupBy`, and `CSTweak` clauses.
     
     A "query" differs from a "fetch" in that it only retrieves values already stored in the persistent store. As such, values from unsaved transactions or contexts will not be incorporated in the query result.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter selectClause: a `CSSelect` clause indicating the properties to fetch, and with the generic type indicating the return type.
     - parameter queryClauses: a series of `CSQueryClause` instances for the query request. Accepts `CSWhere`, `CSOrderBy`, `CSGroupBy`, and `CSTweak` clauses.
     - returns: the result of the the query. The type of the return value is specified by the generic type of the `CSSelect` parameter.
     */
    @objc
    public static func queryValueFrom(_ from: CSFrom, selectClause: CSSelect, queryClauses: [CSQueryClause]) -> Any? {
        
        return self.defaultStack.queryValueFrom(from, selectClause: selectClause, queryClauses: queryClauses)
    }
    
    /**
     Using the `defaultStack`, queries a dictionary of attribute values as specified by the `CSQueryClause`s. Requires at least a `CSSelect` clause, and optional `CSWhere`, `CSOrderBy`, `CSGroupBy`, and `CSTweak` clauses.
     
     A "query" differs from a "fetch" in that it only retrieves values already stored in the persistent store. As such, values from unsaved transactions or contexts will not be incorporated in the query result.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter selectClause: a `CSSelect` clause indicating the properties to fetch, and with the generic type indicating the return type.
     - parameter queryClauses: a series of `CSQueryClause` instances for the query request. Accepts `CSWhere`, `CSOrderBy`, `CSGroupBy`, and `CSTweak` clauses.
     - returns: the result of the the query. The type of the return value is specified by the generic type of the `CSSelect` parameter.
     */
    @objc
    public static func queryAttributesFrom(_ from: CSFrom, selectClause: CSSelect, queryClauses: [CSQueryClause]) -> [[String: Any]]? {
        
        return self.defaultStack.queryAttributesFrom(from, selectClause: selectClause, queryClauses: queryClauses)
    }
}
