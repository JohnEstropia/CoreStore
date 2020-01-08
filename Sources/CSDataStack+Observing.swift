//
//  CSDataStack+Observing.swift
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


// MARK: - CSDataStack

@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
@available(macOS 10.12, *)
extension CSDataStack {
    
    /**
     Creates a `CSObjectMonitor` for the specified `NSManagedObject`. Multiple `ObjectObserver`s may then register themselves to be notified when changes are made to the `NSManagedObject`.
     
     - parameter object: the `NSManagedObject` to observe changes from
     - returns: an `ObjectMonitor` that monitors changes to `object`
     */
    @objc
    public func monitorObject(_ object: NSManagedObject) -> CSObjectMonitor {
        
        return self.bridgeToSwift.monitorObject(object).bridgeToObjectiveC
    }
    
    /**
     Creates a `CSListMonitor` for a list of `NSManagedObject`s that satisfy the specified fetch clauses. Multiple `CSListObserver`s may then register themselves to be notified when changes are made to the list.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: a `CSListMonitor` instance that monitors changes to the list
     */
    @objc
    public func monitorListFrom(_ from: CSFrom, fetchClauses: [CSFetchClause]) -> CSListMonitor {
        
        Internals.assert(
            Thread.isMainThread,
            "Attempted to observe objects from \(Internals.typeName(self)) outside the main thread."
        )
        Internals.assert(
            fetchClauses.contains { $0 is CSOrderBy },
            "A CSListMonitor requires a CSOrderBy clause."
        )
        return ListMonitor(
            dataStack: self.bridgeToSwift,
            from: from.bridgeToSwift,
            sectionBy: nil,
            applyFetchClauses: { (fetchRequest) in
                
                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
            }
        ).bridgeToObjectiveC
    }
    
    /**
     Asynchronously creates a `CSListMonitor` for a list of `NSManagedObject`s that satisfy the specified fetch clauses. Multiple `CSListObserver`s may then register themselves to be notified when changes are made to the list. Since `NSFetchedResultsController` greedily locks the persistent store on initial fetch, you may prefer this method instead of the synchronous counterpart to avoid deadlocks while background updates/saves are being executed.
     
     - parameter createAsynchronously: the closure that receives the created `CSListMonitor` instance
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter fetchClauses: a series of `CSFetchClause` instances for fetching the object list. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     */
    @objc
    public func monitorListByCreatingAsynchronously(_ createAsynchronously: @escaping (CSListMonitor) -> Void, from: CSFrom, fetchClauses: [CSFetchClause]) {
        
        Internals.assert(
            Thread.isMainThread,
            "Attempted to observe objects from \(Internals.typeName(self)) outside the main thread."
        )
        Internals.assert(
            fetchClauses.contains { $0 is CSOrderBy },
            "A CSListMonitor requires an CSOrderBy clause."
        )
        _ = ListMonitor(
            dataStack: self.bridgeToSwift,
            from: from.bridgeToSwift,
            sectionBy: nil,
            applyFetchClauses: { (fetchRequest) in
                
                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
            },
            createAsynchronously: {
                
                createAsynchronously($0.bridgeToObjectiveC)
            }
        )
    }
    
    /**
     Creates a `CSListMonitor` for a sectioned list of `NSManagedObject`s that satisfy the specified fetch clauses. Multiple `ListObserver`s may then register themselves to be notified when changes are made to the list.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter sectionBy: a `CSSectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: a `CSListMonitor` instance that monitors changes to the list
     */
    @objc
    public func monitorSectionedListFrom(_ from: CSFrom, sectionBy: CSSectionBy, fetchClauses: [CSFetchClause]) -> CSListMonitor {
        
        Internals.assert(
            Thread.isMainThread,
            "Attempted to observe objects from \(Internals.typeName(self)) outside the main thread."
        )
        Internals.assert(
            fetchClauses.contains { $0 is CSOrderBy },
            "A CSListMonitor requires an CSOrderBy clause."
        )
        return ListMonitor(
            dataStack: self.bridgeToSwift,
            from: from.bridgeToSwift,
            sectionBy: sectionBy.bridgeToSwift,
            applyFetchClauses: { (fetchRequest) in
                
                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
            }
        ).bridgeToObjectiveC
    }
    
    /**
     Asynchronously creates a `CSListMonitor` for a sectioned list of `NSManagedObject`s that satisfy the specified fetch clauses. Multiple `CSListObserver`s may then register themselves to be notified when changes are made to the list. Since `NSFetchedResultsController` greedily locks the persistent store on initial fetch, you may prefer this method instead of the synchronous counterpart to avoid deadlocks while background updates/saves are being executed.
     
     - parameter createAsynchronously: the closure that receives the created `CSListMonitor` instance
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter sectionBy: a `CSSectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
     - parameter fetchClauses: a series of `CSFetchClause` instances for fetching the object list. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     */
    public func monitorSectionedListByCreatingAsynchronously(_ createAsynchronously: @escaping (CSListMonitor) -> Void, from: CSFrom, sectionBy: CSSectionBy, fetchClauses: [CSFetchClause]) {
        
        Internals.assert(
            Thread.isMainThread,
            "Attempted to observe objects from \(Internals.typeName(self)) outside the main thread."
        )
        Internals.assert(
            fetchClauses.contains { $0 is CSOrderBy },
            "A CSListMonitor requires an CSOrderBy clause."
        )
        _ = ListMonitor(
            dataStack: self.bridgeToSwift,
            from: from.bridgeToSwift,
            sectionBy: sectionBy.bridgeToSwift,
            applyFetchClauses: { (fetchRequest) in
                
                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
            },
            createAsynchronously: {
                
                createAsynchronously($0.bridgeToObjectiveC)
            }
        )
    }
}
