//
//  DataStack+Querying.swift
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


// MARK: - DataStack

extension DataStack: FetchableSource, QueryableSource {
    
    // MARK: FetchableSource
    
    /**
     Fetches the `DynamicObject` instance in the `DataStack`'s context from a reference created from a transaction or from a different managed object context.
     
     - parameter object: a reference to the object created/fetched outside the `DataStack`
     - returns: the `DynamicObject` instance if the object exists in the `DataStack`, or `nil` if not found.
     */
    public func fetchExisting<T: DynamicObject>(_ object: T) -> T? {
        
        return self.mainContext.fetchExisting(object)
    }
    
    /**
     Fetches the `DynamicObject` instance in the `DataStack`'s context from an `NSManagedObjectID`.
     
     - parameter objectID: the `NSManagedObjectID` for the object
     - returns: the `DynamicObject` instance if the object exists in the `DataStack`, or `nil` if not found.
     */
    public func fetchExisting<T: DynamicObject>(_ objectID: NSManagedObjectID) -> T? {
        
        return self.mainContext.fetchExisting(objectID)
    }
    
    /**
     Fetches the `DynamicObject` instances in the `DataStack`'s context from references created from a transaction or from a different managed object context.
     
     - parameter objects: an array of `DynamicObject`s created/fetched outside the `DataStack`
     - returns: the `DynamicObject` array for objects that exists in the `DataStack`
     */
    public func fetchExisting<T: DynamicObject, S: Sequence>(_ objects: S) -> [T] where S.Iterator.Element == T {
        
        return self.mainContext.fetchExisting(objects)
    }
    
    /**
     Fetches the `DynamicObject` instances in the `DataStack`'s context from a list of `NSManagedObjectID`.
     
     - parameter objectIDs: the `NSManagedObjectID` array for the objects
     - returns: the `DynamicObject` array for objects that exists in the `DataStack`
     */
    public func fetchExisting<T: DynamicObject, S: Sequence>(_ objectIDs: S) -> [T] where S.Iterator.Element == NSManagedObjectID {
        
        return self.mainContext.fetchExisting(objectIDs)
    }
    
    /**
     Fetches the first `DynamicObject` instance that satisfies the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the first `DynamicObject` instance that satisfies the specified `FetchClause`s
     */
    public func fetchOne<T>(_ from: From<T>, _ fetchClauses: FetchClause...) -> T? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to fetch from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.fetchOne(from, fetchClauses)
    }
    
    /**
     Fetches the first `DynamicObject` instance that satisfies the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the first `DynamicObject` instance that satisfies the specified `FetchClause`s
     */
    public func fetchOne<T>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> T? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to fetch from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.fetchOne(from, fetchClauses)
    }
    
    /**
     Fetches all `DynamicObject` instances that satisfy the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: all `DynamicObject` instances that satisfy the specified `FetchClause`s
     */
    public func fetchAll<T>(_ from: From<T>, _ fetchClauses: FetchClause...) -> [T]? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to fetch from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.fetchAll(from, fetchClauses)
    }
    
    /**
     Fetches all `DynamicObject` instances that satisfy the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: all `DynamicObject` instances that satisfy the specified `FetchClause`s
     */
    public func fetchAll<T>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> [T]? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to fetch from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.fetchAll(from, fetchClauses)
    }
    
    /**
     Fetches the number of `DynamicObject`s that satisfy the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the number `DynamicObject`s that satisfy the specified `FetchClause`s
     */
    public func fetchCount<T>(_ from: From<T>, _ fetchClauses: FetchClause...) -> Int? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to fetch from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.fetchCount(from, fetchClauses)
    }
    
    /**
     Fetches the number of `DynamicObject`s that satisfy the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the number `DynamicObject`s that satisfy the specified `FetchClause`s
     */
    public func fetchCount<T>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> Int? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to fetch from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.fetchCount(from, fetchClauses)
    }
    
    /**
     Fetches the `NSManagedObjectID` for the first `DynamicObject` that satisfies the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the `NSManagedObjectID` for the first `DynamicObject` that satisfies the specified `FetchClause`s
     */
    public func fetchObjectID<T>(_ from: From<T>, _ fetchClauses: FetchClause...) -> NSManagedObjectID? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to fetch from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.fetchObjectID(from, fetchClauses)
    }
    
    /**
     Fetches the `NSManagedObjectID` for the first `DynamicObject` that satisfies the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the `NSManagedObjectID` for the first `DynamicObject` that satisfies the specified `FetchClause`s
     */
    public func fetchObjectID<T>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> NSManagedObjectID? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to fetch from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.fetchObjectID(from, fetchClauses)
    }
    
    /**
     Fetches the `NSManagedObjectID` for all `DynamicObject`s that satisfy the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the `NSManagedObjectID` for all `DynamicObject`s that satisfy the specified `FetchClause`s
     */
    public func fetchObjectIDs<T>(_ from: From<T>, _ fetchClauses: FetchClause...) -> [NSManagedObjectID]? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to fetch from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.fetchObjectIDs(from, fetchClauses)
    }
    
    /**
     Fetches the `NSManagedObjectID` for all `DynamicObject`s that satisfy the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the `NSManagedObjectID` for all `DynamicObject`s that satisfy the specified `FetchClause`s
     */
    public func fetchObjectIDs<T>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> [NSManagedObjectID]? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to fetch from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.fetchObjectIDs(from, fetchClauses)
    }
    
    
    // MARK: QueryableSource
    
    /**
     Queries aggregate values as specified by the `QueryClause`s. Requires at least a `Select` clause, and optional `Where`, `OrderBy`, `GroupBy`, and `Tweak` clauses.
     
     A "query" differs from a "fetch" in that it only retrieves values already stored in the persistent store. As such, values from unsaved transactions or contexts will not be incorporated in the query result.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter selectClause: a `Select<U>` clause indicating the properties to fetch, and with the generic type indicating the return type.
     - parameter queryClauses: a series of `QueryClause` instances for the query request. Accepts `Where`, `OrderBy`, `GroupBy`, and `Tweak` clauses.
     - returns: the result of the the query. The type of the return value is specified by the generic type of the `Select<U>` parameter.
     */
    public func queryValue<T, U: QueryableAttributeType>(_ from: From<T>, _ selectClause: Select<U>, _ queryClauses: QueryClause...) -> U? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to query from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.queryValue(from, selectClause, queryClauses)
    }
    
    /**
     Queries aggregate values as specified by the `QueryClause`s. Requires at least a `Select` clause, and optional `Where`, `OrderBy`, `GroupBy`, and `Tweak` clauses.
     
     A "query" differs from a "fetch" in that it only retrieves values already stored in the persistent store. As such, values from unsaved transactions or contexts will not be incorporated in the query result.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter selectClause: a `Select<U>` clause indicating the properties to fetch, and with the generic type indicating the return type.
     - parameter queryClauses: a series of `QueryClause` instances for the query request. Accepts `Where`, `OrderBy`, `GroupBy`, and `Tweak` clauses.
     - returns: the result of the the query. The type of the return value is specified by the generic type of the `Select<U>` parameter.
     */
    public func queryValue<T, U: QueryableAttributeType>(_ from: From<T>, _ selectClause: Select<U>, _ queryClauses: [QueryClause]) -> U? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to query from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.queryValue(from, selectClause, queryClauses)
    }
    
    /**
     Queries a dictionary of attribute values as specified by the `QueryClause`s. Requires at least a `Select` clause, and optional `Where`, `OrderBy`, `GroupBy`, and `Tweak` clauses.
     
     A "query" differs from a "fetch" in that it only retrieves values already stored in the persistent store. As such, values from unsaved transactions or contexts will not be incorporated in the query result.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter selectClause: a `Select<U>` clause indicating the properties to fetch, and with the generic type indicating the return type.
     - parameter queryClauses: a series of `QueryClause` instances for the query request. Accepts `Where`, `OrderBy`, `GroupBy`, and `Tweak` clauses.
     - returns: the result of the the query. The type of the return value is specified by the generic type of the `Select<U>` parameter.
     */
    public func queryAttributes<T>(_ from: From<T>, _ selectClause: Select<NSDictionary>, _ queryClauses: QueryClause...) -> [[String: Any]]? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to query from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.queryAttributes(from, selectClause, queryClauses)
    }
    
    /**
     Queries a dictionary of attribute values as specified by the `QueryClause`s. Requires at least a `Select` clause, and optional `Where`, `OrderBy`, `GroupBy`, and `Tweak` clauses.
     
     A "query" differs from a "fetch" in that it only retrieves values already stored in the persistent store. As such, values from unsaved transactions or contexts will not be incorporated in the query result.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter selectClause: a `Select<U>` clause indicating the properties to fetch, and with the generic type indicating the return type.
     - parameter queryClauses: a series of `QueryClause` instances for the query request. Accepts `Where`, `OrderBy`, `GroupBy`, and `Tweak` clauses.
     - returns: the result of the the query. The type of the return value is specified by the generic type of the `Select<U>` parameter.
     */
    public func queryAttributes<T>(_ from: From<T>, _ selectClause: Select<NSDictionary>, _ queryClauses: [QueryClause]) -> [[String: Any]]? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to query from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.queryAttributes(from, selectClause, queryClauses)
    }
    
    
    // MARK: FetchableSource, QueryableSource
    
    /**
     The internal `NSManagedObjectContext` managed by this instance. Using this context directly should typically be avoided, and is provided by CoreStore only for extremely specialized cases.
     */
    public func unsafeContext() -> NSManagedObjectContext {
        
        return self.mainContext
    }
    
    
    // MARK: Obsoleted
    
    @available(*, obsoleted: 3.1, renamed: "unsafeContext()")
    public func internalContext() -> NSManagedObjectContext {
        
        fatalError()
    }
}
