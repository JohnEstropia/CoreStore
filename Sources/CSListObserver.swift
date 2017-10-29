//
//  CSListObserver.swift
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


// MARK: - CSListObserver

/**
 Implement the `CSListObserver` protocol to observe changes to a list of `NSManagedObject`s. `CSListObserver`s may register themselves to a `CSListMonitor`'s `-addListObserver:` method:
 ```
 CSListMonitor *monitor = [CSCoreStore 
     monitorListFrom:[CSFrom entityClass:[MyPersonEntity class]]
     fetchClauses:@[[CSOrderBy sortDescriptor:[CSSortKey withKeyPath:@"lastName" ascending:YES]]]];
 [monitor addListObserver:self];
 ```
 
 - SeeAlso: `ListObserver`
 */
@available(OSX 10.12, *)
@objc
public protocol CSListObserver: class {
    
    /**
     Handles processing just before a change to the observed list occurs
     
     - parameter monitor: the `CSListMonitor` monitoring the list being observed
     */
    @objc
    optional func listMonitorWillChange(_ monitor: CSListMonitor)
    
    /**
     Handles processing right after a change to the observed list occurs
     
     - parameter monitor: the `CSListMonitor` monitoring the object being observed
     */
    @objc
    optional func listMonitorDidChange(_ monitor: CSListMonitor)
    
    /**
     This method is broadcast from within the `CSListMonitor`'s `-refetchWithFetchClauses:` method to let observers prepare for the internal `NSFetchedResultsController`'s pending change to its predicate, sort descriptors, etc. Note that the actual refetch will happen after the `NSFetchedResultsController`'s last `-controllerDidChangeContent:` notification completes.
     
     - parameter monitor: the `CSListMonitor` monitoring the object being observed
     */
    @objc
    optional func listMonitorWillRefetch(_ monitor: CSListMonitor)
    
    /**
     After the `CSListMonitor`'s `-refetchWithFetchClauses:` method is called, this method is broadcast after the `NSFetchedResultsController`'s last `-controllerDidChangeContent:` notification completes.
     
     - parameter monitor: the `CSListMonitor` monitoring the object being observed
     */
    @objc
    optional func listMonitorDidRefetch(_ monitor: CSListMonitor)
}


// MARK: - ListObjectObserver

/**
 Implement the `CSListObjectObserver` protocol to observe detailed changes to a list's object. `CSListObjectObserver`s may register themselves to a `CSListMonitor`'s `-addListObjectObserver(_:)` method:
 ```
 CSListMonitor *monitor = [CSCoreStore
     monitorListFrom:[CSFrom entityClass:[MyPersonEntity class]]
     fetchClauses:@[[CSOrderBy sortDescriptor:[CSSortKey withKeyPath:@"lastName" ascending:YES]]]];
 [monitor addListObjectObserver:self];
 ```
 
 - SeeAlso: `ListObjectObserver`
 */
@available(OSX 10.12, *)
@objc
public protocol CSListObjectObserver: CSListObserver {
    
    /**
     Notifies that an object was inserted to the specified `NSIndexPath` in the list
     
     - parameter monitor: the `CSListMonitor` monitoring the list being observed
     - parameter object: the entity type for the inserted object
     - parameter indexPath: the new `NSIndexPath` for the inserted object
     */
    @objc
    optional func listMonitor(_ monitor: CSListMonitor, didInsertObject object: Any, toIndexPath indexPath: IndexPath)
    
    /**
     Notifies that an object was deleted from the specified `NSIndexPath` in the list
     
     - parameter monitor: the `CSListMonitor` monitoring the list being observed
     - parameter object: the entity type for the deleted object
     - parameter indexPath: the `NSIndexPath` for the deleted object
     */
    @objc
    optional func listMonitor(_ monitor: CSListMonitor, didDeleteObject object: Any, fromIndexPath indexPath: IndexPath)
    
    /**
     Notifies that an object at the specified `NSIndexPath` was updated
     
     - parameter monitor: the `CSListMonitor` monitoring the list being observed
     - parameter object: the entity type for the updated object
     - parameter indexPath: the `NSIndexPath` for the updated object
     */
    @objc
    optional func listMonitor(_ monitor: CSListMonitor, didUpdateObject object: Any, atIndexPath indexPath: IndexPath)
    
    /**
     Notifies that an object's index changed
     
     - parameter monitor: the `CSListMonitor` monitoring the list being observed
     - parameter object: the entity type for the moved object
     - parameter fromIndexPath: the previous `NSIndexPath` for the moved object
     - parameter toIndexPath: the new `NSIndexPath` for the moved object
     */
    @objc
    optional func listMonitor(_ monitor: CSListMonitor, didMoveObject object: Any, fromIndexPath: IndexPath, toIndexPath: IndexPath)
}


// MARK: - CSListSectionObserver

/**
 Implement the `CSListSectionObserver` protocol to observe changes to a list's section info. `CSListSectionObserver`s may register themselves to a `CSListMonitor`'s `-addListSectionObserver:` method:
 ```
 CSListMonitor *monitor = [CSCoreStore
     monitorSectionedListFrom:[CSFrom entityClass:[MyPersonEntity class]]
     sectionBy:[CSSectionBy keyPath:@"age"]
     fetchClauses:@[[CSOrderBy sortDescriptor:[CSSortKey withKeyPath:@"lastName" ascending:YES]]]];
 [monitor addListSectionObserver:self];
 ```
 
 - SeeAlso: `ListSectionObserver`
 */
@available(OSX 10.12, *)
@objc
public protocol CSListSectionObserver: CSListObjectObserver {
    
    /**
     Notifies that a section was inserted at the specified index
     
     - parameter monitor: the `CSListMonitor` monitoring the list being observed
     - parameter sectionInfo: the `NSFetchedResultsSectionInfo` for the inserted section
     - parameter sectionIndex: the new section index for the new section
     */
    @objc
    optional func listMonitor(_ monitor: CSListMonitor, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int)
    
    /**
     Notifies that a section was inserted at the specified index
     
     - parameter monitor: the `CSListMonitor` monitoring the list being observed
     - parameter sectionInfo: the `NSFetchedResultsSectionInfo` for the deleted section
     - parameter sectionIndex: the previous section index for the deleted section
     */
    @objc
    optional func listMonitor(_ monitor: CSListMonitor, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int)
}
