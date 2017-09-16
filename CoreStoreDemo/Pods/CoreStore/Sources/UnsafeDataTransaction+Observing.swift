//
//  UnsafeDataTransaction+Observing.swift
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


// MARK: - UnsafeDataTransaction

@available(OSX 10.12, *)
public extension UnsafeDataTransaction {
    
    /**
     Creates a `ObjectMonitor` for the specified `DynamicObject`. Multiple `ObjectObserver`s may then register themselves to be notified when changes are made to the `DynamicObject`.
     
     - parameter object: the `DynamicObject` to observe changes from
     - returns: a `ObjectMonitor` that monitors changes to `object`
     */
    public func monitorObject<T: DynamicObject>(_ object: T) -> ObjectMonitor<T> {
        
        return ObjectMonitor(
            unsafeTransaction: self,
            object: object
        )
    }
    
    /**
     Creates a `ListMonitor` for a list of `DynamicObject`s that satisfy the specified fetch clauses. Multiple `ListObserver`s may then register themselves to be notified when changes are made to the list.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: a `ListMonitor` instance that monitors changes to the list
     */
    public func monitorList<T: DynamicObject>(_ from: From<T>, _ fetchClauses: FetchClause...) -> ListMonitor<T> {
        
        return self.monitorList(from, fetchClauses)
    }
    
    /**
     Creates a `ListMonitor` for a list of `DynamicObject`s that satisfy the specified fetch clauses. Multiple `ListObserver`s may then register themselves to be notified when changes are made to the list.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: a `ListMonitor` instance that monitors changes to the list
     */
    public func monitorList<T: DynamicObject>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> ListMonitor<T> {
        
        CoreStore.assert(
            fetchClauses.filter { $0 is OrderBy }.count > 0,
            "A ListMonitor requires an OrderBy clause."
        )
        
        return ListMonitor(
            unsafeTransaction: self,
            from: from,
            sectionBy: nil,
            applyFetchClauses: { fetchRequest in
                
                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
            }
        )
    }
    
    /**
     Asynchronously creates a `ListMonitor` for a list of `DynamicObject`s that satisfy the specified fetch clauses. Multiple `ListObserver`s may then register themselves to be notified when changes are made to the list. Since `NSFetchedResultsController` greedily locks the persistent store on initial fetch, you may prefer this method instead of the synchronous counterpart to avoid deadlocks while background updates/saves are being executed.
     
     - parameter createAsynchronously: the closure that receives the created `ListMonitor` instance
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     */
    public func monitorList<T: DynamicObject>(createAsynchronously: @escaping (ListMonitor<T>) -> Void, _ from: From<T>, _ fetchClauses: FetchClause...) {
        
        self.monitorList(createAsynchronously: createAsynchronously, from, fetchClauses)
    }
    
    /**
     Asynchronously creates a `ListMonitor` for a list of `DynamicObject`s that satisfy the specified fetch clauses. Multiple `ListObserver`s may then register themselves to be notified when changes are made to the list. Since `NSFetchedResultsController` greedily locks the persistent store on initial fetch, you may prefer this method instead of the synchronous counterpart to avoid deadlocks while background updates/saves are being executed.
     
     - parameter createAsynchronously: the closure that receives the created `ListMonitor` instance
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     */
    public func monitorList<T: DynamicObject>(createAsynchronously: @escaping (ListMonitor<T>) -> Void, _ from: From<T>, _ fetchClauses: [FetchClause])  {
        
        CoreStore.assert(
            fetchClauses.filter { $0 is OrderBy }.count > 0,
            "A ListMonitor requires an OrderBy clause."
        )
        
        _ = ListMonitor(
            unsafeTransaction: self,
            from: from,
            sectionBy: nil,
            applyFetchClauses: { fetchRequest in
                
                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
            },
            createAsynchronously: createAsynchronously
        )
    }
    
    /**
     Creates a `ListMonitor` for a sectioned list of `DynamicObject`s that satisfy the specified fetch clauses. Multiple `ListObserver`s may then register themselves to be notified when changes are made to the list.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: a `ListMonitor` instance that monitors changes to the list
     */
    public func monitorSectionedList<T: DynamicObject>(_ from: From<T>, _ sectionBy: SectionBy, _ fetchClauses: FetchClause...) -> ListMonitor<T> {
        
        return self.monitorSectionedList(from, sectionBy, fetchClauses)
    }
    
    /**
     Creates a `ListMonitor` for a sectioned list of `DynamicObject`s that satisfy the specified fetch clauses. Multiple `ListObserver`s may then register themselves to be notified when changes are made to the list.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: a `ListMonitor` instance that monitors changes to the list
     */
    public func monitorSectionedList<T: DynamicObject>(_ from: From<T>, _ sectionBy: SectionBy, _ fetchClauses: [FetchClause]) -> ListMonitor<T> {
        
        CoreStore.assert(
            fetchClauses.filter { $0 is OrderBy }.count > 0,
            "A ListMonitor requires an OrderBy clause."
        )
        
        return ListMonitor(
            unsafeTransaction: self,
            from: from,
            sectionBy: sectionBy,
            applyFetchClauses: { fetchRequest in
                
                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
            }
        )
    }
    
    /**
     Asynchronously creates a `ListMonitor` for a sectioned list of `DynamicObject`s that satisfy the specified fetch clauses. Multiple `ListObserver`s may then register themselves to be notified when changes are made to the list. Since `NSFetchedResultsController` greedily locks the persistent store on initial fetch, you may prefer this method instead of the synchronous counterpart to avoid deadlocks while background updates/saves are being executed.
     
     - parameter createAsynchronously: the closure that receives the created `ListMonitor` instance
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     */
    public func monitorSectionedList<T: DynamicObject>(createAsynchronously: @escaping (ListMonitor<T>) -> Void, _ from: From<T>, _ sectionBy: SectionBy, _ fetchClauses: FetchClause...) {
        
        self.monitorSectionedList(createAsynchronously: createAsynchronously, from, sectionBy, fetchClauses)
    }
    
    /**
     Asynchronously creates a `ListMonitor` for a sectioned list of `DynamicObject`s that satisfy the specified fetch clauses. Multiple `ListObserver`s may then register themselves to be notified when changes are made to the list. Since `NSFetchedResultsController` greedily locks the persistent store on initial fetch, you may prefer this method instead of the synchronous counterpart to avoid deadlocks while background updates/saves are being executed.
     
     - parameter createAsynchronously: the closure that receives the created `ListMonitor` instance
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     */
    public func monitorSectionedList<T: DynamicObject>(createAsynchronously: @escaping (ListMonitor<T>) -> Void, _ from: From<T>, _ sectionBy: SectionBy, _ fetchClauses: [FetchClause]) {
        
        CoreStore.assert(
            fetchClauses.filter { $0 is OrderBy }.count > 0,
            "A ListMonitor requires an OrderBy clause."
        )
        
        _ = ListMonitor(
            unsafeTransaction: self,
            from: from,
            sectionBy: sectionBy,
            applyFetchClauses: { fetchRequest in
                
                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
            },
            createAsynchronously: createAsynchronously
        )
    }
}
