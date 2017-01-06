//
//  FetchableSource.swift
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


// MARK: - FetchableSource

/**
 Encapsulates containers which manages an internal `NSManagedObjectContext`, such as `DataStack`s and transactions, that can be used for fetching objects. CoreStore provides implementations for this protocol and should be used as a read-only abstraction.
 */
public protocol FetchableSource: class {
    
    /**
     Fetches the `NSManagedObject` instance in the `FetchableSource`'s context from a reference created from another managed object context.
     
     - parameter object: a reference to the object created/fetched outside the `FetchableSource`'s context
     - returns: the `NSManagedObject` instance if the object exists in the `FetchableSource`'s context, or `nil` if not found.
     */
    func fetchExisting<T: NSManagedObject>(_ object: T) -> T?
    
    /**
     Fetches the `NSManagedObject` instance in the `FetchableSource`'s context from an `NSManagedObjectID`.
     
     - parameter objectID: the `NSManagedObjectID` for the object
     - returns: the `NSManagedObject` instance if the object exists in the `FetchableSource`, or `nil` if not found.
     */
    func fetchExisting<T: NSManagedObject>(_ objectID: NSManagedObjectID) -> T?
    
    /**
     Fetches the `NSManagedObject` instances in the `FetchableSource`'s context from references created from another managed object context.

     - parameter objects: an array of `NSManagedObject`s created/fetched outside the `FetchableSource`'s context
     - returns: the `NSManagedObject` array for objects that exists in the `FetchableSource`
     */
    func fetchExisting<T: NSManagedObject, S: Sequence>(_ objects: S) -> [T] where S.Iterator.Element == T

    /**
     Fetches the `NSManagedObject` instances in the `FetchableSource`'s context from a list of `NSManagedObjectID`.

     - parameter objectIDs: the `NSManagedObjectID` array for the objects
     - returns: the `NSManagedObject` array for objects that exists in the `FetchableSource`'s context
     */
    func fetchExisting<T: NSManagedObject, S: Sequence>(_ objectIDs: S) -> [T] where S.Iterator.Element == NSManagedObjectID

    /**
     Fetches the first `NSManagedObject` instance that satisfies the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.

     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the first `NSManagedObject` instance that satisfies the specified `FetchClause`s
     */
    func fetchOne<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: FetchClause...) -> T?

    /**
     Fetches the first `NSManagedObject` instance that satisfies the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.

     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the first `NSManagedObject` instance that satisfies the specified `FetchClause`s
     */
    func fetchOne<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> T?

    /**
     Fetches all `NSManagedObject` instances that satisfy the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.

     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: all `NSManagedObject` instances that satisfy the specified `FetchClause`s
     */
    func fetchAll<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: FetchClause...) -> [T]?

    /**
     Fetches all `NSManagedObject` instances that satisfy the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.

     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: all `NSManagedObject` instances that satisfy the specified `FetchClause`s
     */
    func fetchAll<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> [T]?

    /**
     Fetches the number of `NSManagedObject`s that satisfy the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.

     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the number `NSManagedObject`s that satisfy the specified `FetchClause`s
     */
    func fetchCount<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: FetchClause...) -> Int?

    /**
     Fetches the number of `NSManagedObject`s that satisfy the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.

     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the number `NSManagedObject`s that satisfy the specified `FetchClause`s
     */
    func fetchCount<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> Int?

    /**
     Fetches the `NSManagedObjectID` for the first `NSManagedObject` that satisfies the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.

     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the `NSManagedObjectID` for the first `NSManagedObject` that satisfies the specified `FetchClause`s
     */
    func fetchObjectID<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: FetchClause...) -> NSManagedObjectID?

    /**
     Fetches the `NSManagedObjectID` for the first `NSManagedObject` that satisfies the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.

     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the `NSManagedObjectID` for the first `NSManagedObject` that satisfies the specified `FetchClause`s
     */
    func fetchObjectID<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> NSManagedObjectID?

    /**
     Fetches the `NSManagedObjectID` for all `NSManagedObject`s that satisfy the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.

     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the `NSManagedObjectID` for all `NSManagedObject`s that satisfy the specified `FetchClause`s
     */
    func fetchObjectIDs<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: FetchClause...) -> [NSManagedObjectID]?

    /**
     Fetches the `NSManagedObjectID` for all `NSManagedObject`s that satisfy the specified `FetchClause`s. Accepts `Where`, `OrderBy`, and `Tweak` clauses.

     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for the fetch request. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: the `NSManagedObjectID` for all `NSManagedObject`s that satisfy the specified `FetchClause`s
     */
    func fetchObjectIDs<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> [NSManagedObjectID]?
    
    /**
     The internal `NSManagedObjectContext` managed by this `FetchableSource`. Using this context directly should typically be avoided, and is provided by CoreStore only for extremely specialized cases.
     */
    func internalContext() -> NSManagedObjectContext
}
