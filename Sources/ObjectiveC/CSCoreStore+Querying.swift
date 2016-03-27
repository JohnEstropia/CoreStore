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
    @warn_unused_result
    public static func fetchExistingObject(object: NSManagedObject) -> NSManagedObject? {
        
        return self.defaultStack.fetchExistingObject(object)
    }
    
    /**
     Using the `defaultStack`, fetches the `NSManagedObject` instance in the transaction's context from an `NSManagedObjectID`.
     
     - parameter objectID: the `NSManagedObjectID` for the object
     - returns: the `NSManagedObject` instance if the object exists in the transaction, or `nil` if not found.
     */
    @objc
    @warn_unused_result
    public static func fetchExistingObjectWithID(objectID: NSManagedObjectID) -> NSManagedObject? {
        
        return self.defaultStack.fetchExistingObjectWithID(objectID)
    }
    
    /**
     Using the `defaultStack`, fetches the `NSManagedObject` instances in the transaction's context from references created from a transaction or from a different managed object context.
     
     - parameter objects: an array of `NSManagedObject`s created/fetched outside the transaction
     - returns: the `NSManagedObject` array for objects that exists in the transaction
     */
    @objc
    @warn_unused_result
    public static func fetchExistingObjects(objects: [NSManagedObject]) -> [NSManagedObject] {
        
        return self.defaultStack.fetchExistingObjects(objects)
    }
    
    /**
     Using the `defaultStack`, fetches the `NSManagedObject` instances in the transaction's context from a list of `NSManagedObjectID`.
     
     - parameter objectIDs: the `NSManagedObjectID` array for the objects
     - returns: the `NSManagedObject` array for objects that exists in the transaction
     */
    @objc
    @warn_unused_result
    public static func fetchExistingObjectsWithIDs(objectIDs: [NSManagedObjectID]) -> [NSManagedObject] {
        
        return self.defaultStack.fetchExistingObjectsWithIDs(objectIDs)
    }
    
    /**
     Using the `defaultStack`, fetches the first `NSManagedObject` instance that satisfies the specified `CSFetchClause`s. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `CSFetchClause` instances for the fetch request. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: the first `NSManagedObject` instance that satisfies the specified `CSFetchClause`s
     */
    @objc
    @warn_unused_result
    public static func fetchOneFrom(from: CSFrom, fetchClauses: [CSFetchClause]) -> NSManagedObject? {
        
        return self.defaultStack.fetchOneFrom(from, fetchClauses: fetchClauses)
    }
    
    /**
     Using the `defaultStack`, fetches all `NSManagedObject` instances that satisfy the specified `CSFetchClause`s. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter fetchClauses: a series of `CSFetchClause` instances for the fetch request. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: all `NSManagedObject` instances that satisfy the specified `CSFetchClause`s
     */
    @objc
    @warn_unused_result
    public static func fetchAllFrom(from: CSFrom, fetchClauses: [CSFetchClause]) -> [NSManagedObject]? {
        
        return self.defaultStack.fetchAllFrom(from, fetchClauses: fetchClauses)
    }
    
    /**
     Using the `defaultStack`, fetches the number of `NSManagedObject`s that satisfy the specified `CSFetchClause`s. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter fetchClauses: a series of `CSFetchClause` instances for the fetch request. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: the number `NSManagedObject`s that satisfy the specified `CSFetchClause`s
     */
    @objc
    @warn_unused_result
    public static func fetchCountFrom(from: CSFrom, fetchClauses: [CSFetchClause]) -> NSNumber? {
        
        return self.defaultStack.fetchCountFrom(from, fetchClauses: fetchClauses)
    }
    
    /**
     Using the `defaultStack`, fetches the `NSManagedObjectID` for the first `NSManagedObject` that satisfies the specified `CSFetchClause`s. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter fetchClauses: a series of `CSFetchClause` instances for the fetch request. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: the `NSManagedObjectID` for the first `NSManagedObject` that satisfies the specified `CSFetchClause`s
     */
    @objc
    @warn_unused_result
    public static func fetchObjectIDFrom(from: CSFrom, fetchClauses: [CSFetchClause]) -> NSManagedObjectID? {
        
        return self.defaultStack.fetchObjectIDFrom(from, fetchClauses: fetchClauses)
    }
    
    /**
     Using the `defaultStack`, fetches the `NSManagedObjectID` for all `NSManagedObject`s that satisfy the specified `CSFetchClause`s. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: the `NSManagedObjectID` for all `NSManagedObject`s that satisfy the specified `CSFetchClause`s
     */
    @objc
    @warn_unused_result
    public static func fetchObjectIDsFrom(from: CSFrom, fetchClauses: [CSFetchClause]) -> [NSManagedObjectID]? {
        
        return self.defaultStack.fetchObjectIDsFrom(from, fetchClauses: fetchClauses)
    }
    
    /**
     Using the `defaultStack`, deletes all `NSManagedObject`s that satisfy the specified `DeleteClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter deleteClauses: a series of `DeleteClause` instances for the delete request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the number of `NSManagedObject`s deleted
     */
    @objc
    public static func deleteAllFrom(from: CSFrom, deleteClauses: [CSDeleteClause]) -> NSNumber? {
        
        return self.defaultStack.deleteAllFrom(from, deleteClauses: deleteClauses)
    }
}
