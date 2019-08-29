//
//  CSCoreStore+Observing.swift
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


// MARK: - CSCoreStore

@available(*, deprecated, message: "Call methods directly from the CSDataStack instead")
@available(macOS 10.12, *)
extension CSCoreStore {
    
    /**
     Using the `defaultStack`, creates an `CSObjectMonitor` for the specified `NSManagedObject`. Multiple `CSObjectObserver`s may then register themselves to be notified when changes are made to the `NSManagedObject`.
     
     - parameter object: the `NSManagedObject` to observe changes from
     - returns: a `CSObjectMonitor` that monitors changes to `object`
     */
    @objc
    public static func monitorObject(_ object: NSManagedObject) -> CSObjectMonitor {
        
        return self.defaultStack.monitorObject(object)
    }
    
    /**
     Using the `defaultStack`, creates a `CSListMonitor` for a list of `NSManagedObject`s that satisfy the specified fetch clauses. Multiple `CSListObserver`s may then register themselves to be notified when changes are made to the list.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter fetchClauses: a series of `CSFetchClause` instances for fetching the object list. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: a `CSListMonitor` instance that monitors changes to the list
     */
    @objc
    public static func monitorListFrom(_ from: CSFrom, fetchClauses: [CSFetchClause]) -> CSListMonitor {
        
        return self.defaultStack.monitorListFrom(from, fetchClauses: fetchClauses)
    }
    
    /**
     Using the `defaultStack`, asynchronously creates a `CSListMonitor` for a list of `NSManagedObject`s that satisfy the specified fetch clauses. Multiple `CSListObserver`s may then register themselves to be notified when changes are made to the list. Since `NSFetchedResultsController` greedily locks the persistent store on initial fetch, you may prefer this method instead of the synchronous counterpart to avoid deadlocks while background updates/saves are being executed.
     
     - parameter createAsynchronously: the closure that receives the created `CSListMonitor` instance
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter fetchClauses: a series of `CSFetchClause` instances for fetching the object list. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     */
    @objc
    public static func monitorListByCreatingAsynchronously(_ createAsynchronously: @escaping (CSListMonitor) -> Void, from: CSFrom, fetchClauses: [CSFetchClause])  {
        
        return self.defaultStack.monitorListByCreatingAsynchronously(
            createAsynchronously,
            from: from,
            fetchClauses: fetchClauses
        )
    }
    
    /**
     Using the `defaultStack`, creates a `CSListMonitor` for a sectioned list of `NSManagedObject`s that satisfy the specified fetch clauses. Multiple `CSListObserver`s may then register themselves to be notified when changes are made to the list.
     
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter sectionBy: a `CSSectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
     - parameter fetchClauses: a series of `CSFetchClause` instances for fetching the object list. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     - returns: a `CSListMonitor` instance that monitors changes to the list
     */
    @objc
    public static func monitorSectionedListFrom(_ from: CSFrom, sectionBy: CSSectionBy, fetchClauses: [CSFetchClause]) -> CSListMonitor {
        
        return self.defaultStack.monitorSectionedListFrom(
            from,
            sectionBy: sectionBy,
            fetchClauses: fetchClauses
        )
    }
    
    /**
     Using the `defaultStack`, asynchronously creates a `CSListMonitor` for a sectioned list of `NSManagedObject`s that satisfy the specified fetch clauses. Multiple `CSListObserver`s may then register themselves to be notified when changes are made to the list. Since `NSFetchedResultsController` greedily locks the persistent store on initial fetch, you may prefer this method instead of the synchronous counterpart to avoid deadlocks while background updates/saves are being executed.
     
     - parameter createAsynchronously: the closure that receives the created `CSListMonitor` instance
     - parameter from: a `CSFrom` clause indicating the entity type
     - parameter sectionBy: a `CSSectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
     - parameter fetchClauses: a series of `CSFetchClause` instances for fetching the object list. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     */
    @objc
    public static func monitorSectionedListByCreatingAsynchronously(_ createAsynchronously: @escaping (CSListMonitor) -> Void, from: CSFrom, sectionBy: CSSectionBy, fetchClauses: [CSFetchClause]) {
        
        self.defaultStack.monitorSectionedListByCreatingAsynchronously(
            createAsynchronously,
            from: from,
            sectionBy: sectionBy,
            fetchClauses: fetchClauses
        )
    }
}
