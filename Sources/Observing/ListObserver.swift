//
//  ListObserver.swift
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


#if os(iOS) || os(watchOS) || os(tvOS)

// MARK: - ListObserver

/**
 Implement the `ListObserver` protocol to observe changes to a list of `NSManagedObject`s. `ListObserver`s may register themselves to a `ListMonitor`'s `addObserver(_:)` method:
 ```
 let monitor = CoreStore.monitorList(
     From(MyPersonEntity),
     OrderBy(.Ascending("lastName"))
 )
 monitor.addObserver(self)
 ```
 */
public protocol ListObserver: class {
    
    /**
     The `NSManagedObject` type for the observed list
     */
    associatedtype ListEntityType: NSManagedObject
    
    /**
     Handles processing just before a change to the observed list occurs
     
     - parameter monitor: the `ListMonitor` monitoring the list being observed
     */
    func listMonitorWillChange(monitor: ListMonitor<ListEntityType>)
    
    /**
     Handles processing right after a change to the observed list occurs
     
     - parameter monitor: the `ListMonitor` monitoring the object being observed
     */
    func listMonitorDidChange(monitor: ListMonitor<ListEntityType>)
    
    /**
     This method is broadcast from within the `ListMonitor`'s `refetch(...)` method to let observers prepare for the internal `NSFetchedResultsController`'s pending change to its predicate, sort descriptors, etc. Note that the actual refetch will happen after the `NSFetchedResultsController`'s last `controllerDidChangeContent(_:)` notification completes.
     
     - parameter monitor: the `ListMonitor` monitoring the object being observed
     */
    func listMonitorWillRefetch(monitor: ListMonitor<ListEntityType>)
    
    /**
     After the `ListMonitor`'s `refetch(...)` method is called, this method is broadcast after the `NSFetchedResultsController`'s last `controllerDidChangeContent(_:)` notification completes.
     
     - parameter monitor: the `ListMonitor` monitoring the object being observed
     */
    func listMonitorDidRefetch(monitor: ListMonitor<ListEntityType>)
}


// MARK: - ListObserver (Default Implementations)

public extension ListObserver {
    
    /**
     The default implementation does nothing.
     */
    func listMonitorWillChange(monitor: ListMonitor<ListEntityType>) { }
    
    /**
     The default implementation does nothing.
     */
    func listMonitorDidChange(monitor: ListMonitor<ListEntityType>) { }
    
    /**
     The default implementation does nothing.
     */
    func listMonitorWillRefetch(monitor: ListMonitor<ListEntityType>) { }
    
    /**
     The default implementation does nothing.
     */
    func listMonitorDidRefetch(monitor: ListMonitor<ListEntityType>) { }
}


// MARK: - ListObjectObserver

/**
 Implement the `ListObjectObserver` protocol to observe detailed changes to a list's object. `ListObjectObserver`s may register themselves to a `ListMonitor`'s `addObserver(_:)` method:
 ```
 let monitor = CoreStore.monitorList(
     From(MyPersonEntity),
     OrderBy(.Ascending("lastName"))
 )
 monitor.addObserver(self)
 ```
 */
public protocol ListObjectObserver: ListObserver {
    
    /**
     Notifies that an object was inserted to the specified `NSIndexPath` in the list
     
     - parameter monitor: the `ListMonitor` monitoring the list being observed
     - parameter object: the entity type for the inserted object
     - parameter indexPath: the new `NSIndexPath` for the inserted object
     */
    func listMonitor(monitor: ListMonitor<ListEntityType>, didInsertObject object: ListEntityType, toIndexPath indexPath: NSIndexPath)
    
    /**
     Notifies that an object was deleted from the specified `NSIndexPath` in the list
     
     - parameter monitor: the `ListMonitor` monitoring the list being observed
     - parameter object: the entity type for the deleted object
     - parameter indexPath: the `NSIndexPath` for the deleted object
     */
    func listMonitor(monitor: ListMonitor<ListEntityType>, didDeleteObject object: ListEntityType, fromIndexPath indexPath: NSIndexPath)
    
    /**
     Notifies that an object at the specified `NSIndexPath` was updated
     
     - parameter monitor: the `ListMonitor` monitoring the list being observed
     - parameter object: the entity type for the updated object
     - parameter indexPath: the `NSIndexPath` for the updated object
     */
    func listMonitor(monitor: ListMonitor<ListEntityType>, didUpdateObject object: ListEntityType, atIndexPath indexPath: NSIndexPath)
    
    /**
     Notifies that an object's index changed
     
     - parameter monitor: the `ListMonitor` monitoring the list being observed
     - parameter object: the entity type for the moved object
     - parameter fromIndexPath: the previous `NSIndexPath` for the moved object
     - parameter toIndexPath: the new `NSIndexPath` for the moved object
     */
    func listMonitor(monitor: ListMonitor<ListEntityType>, didMoveObject object: ListEntityType, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
}


// MARK: - ListObjectObserver (Default Implementations)

public extension ListObjectObserver {
    
    /**
     The default implementation does nothing.
     */
    func listMonitor(monitor: ListMonitor<ListEntityType>, didInsertObject object: ListEntityType, toIndexPath indexPath: NSIndexPath) { }
    
    /**
     The default implementation does nothing.
     */
    func listMonitor(monitor: ListMonitor<ListEntityType>, didDeleteObject object: ListEntityType, fromIndexPath indexPath: NSIndexPath) { }
    
    /**
     The default implementation does nothing.
     */
    func listMonitor(monitor: ListMonitor<ListEntityType>, didUpdateObject object: ListEntityType, atIndexPath indexPath: NSIndexPath) { }
    
    /**
     The default implementation does nothing.
     */
    func listMonitor(monitor: ListMonitor<ListEntityType>, didMoveObject object: ListEntityType, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) { }
}


// MARK: - ListSectionObserver

/**
 Implement the `ListSectionObserver` protocol to observe changes to a list's section info. `ListSectionObserver`s may register themselves to a `ListMonitor`'s `addObserver(_:)` method:
 ```
 let monitor = CoreStore.monitorSectionedList(
     From(MyPersonEntity),
     SectionBy("age") { "Age \($0)" },
     OrderBy(.Ascending("lastName"))
 )
 monitor.addObserver(self)
 ```
 */
public protocol ListSectionObserver: ListObjectObserver {
    
    /**
     Notifies that a section was inserted at the specified index
     
     - parameter monitor: the `ListMonitor` monitoring the list being observed
     - parameter sectionInfo: the `NSFetchedResultsSectionInfo` for the inserted section
     - parameter sectionIndex: the new section index for the new section
     */
    func listMonitor(monitor: ListMonitor<ListEntityType>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int)
    
    /**
     Notifies that a section was inserted at the specified index
     
     - parameter monitor: the `ListMonitor` monitoring the list being observed
     - parameter sectionInfo: the `NSFetchedResultsSectionInfo` for the deleted section
     - parameter sectionIndex: the previous section index for the deleted section
     */
    func listMonitor(monitor: ListMonitor<ListEntityType>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int)
}


// MARK: - ListSectionObserver (Default Implementations)

public extension ListSectionObserver {
    
    /**
     The default implementation does nothing.
     */
    func listMonitor(monitor: ListMonitor<ListEntityType>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) { }
    
    /**
     The default implementation does nothing.
     */
    func listMonitor(monitor: ListMonitor<ListEntityType>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) { }
}

#endif
