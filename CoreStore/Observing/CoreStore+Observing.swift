//
//  CoreStore+Observing.swift
//  CoreStore
//
//  Copyright (c) 2015 John Rommel Estropia
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


// MARK: - CoreStore

public extension CoreStore {
    
    // MARK: Public
    
    /**
    Using the `defaultStack`, creates a `ObjectMonitor` for the specified `NSManagedObject`. Multiple `ObjectObserver`s may then register themselves to be notified when changes are made to the `NSManagedObject`.
    
    - parameter object: the `NSManagedObject` to observe changes from
    - returns: a `ObjectMonitor` that monitors changes to `object`
    */
    public static func monitorObject<T: NSManagedObject>(object: T) -> ObjectMonitor<T> {
        
        return self.defaultStack.monitorObject(object)
    }
    
    /**
    Using the `defaultStack`, creates a `ListMonitor` for a list of `NSManagedObject`s that satisfy the specified fetch clauses. Multiple `ListObserver`s may then register themselves to be notified when changes are made to the list.
    
    - parameter from: a `From` clause indicating the entity type
    - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
    - returns: a `ListMonitor` instance that monitors changes to the list
    */
    public static func monitorList<T: NSManagedObject>(from: From<T>, _ queryClauses: FetchClause...) -> ListMonitor<T> {
        
        return self.defaultStack.monitorList(from, queryClauses)
    }
    
    /**
    Using the `defaultStack`, creates a `ListMonitor` for a list of `NSManagedObject`s that satisfy the specified fetch clauses. Multiple `ListObserver`s may then register themselves to be notified when changes are made to the list.
    
    - parameter from: a `From` clause indicating the entity type
    - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
    - returns: a `ListMonitor` instance that monitors changes to the list
    */
    public static func monitorList<T: NSManagedObject>(from: From<T>, _ queryClauses: [FetchClause]) -> ListMonitor<T> {
        
        return self.defaultStack.monitorList(from, queryClauses)
    }
    
    /**
    Using the `defaultStack`, creates a `ListMonitor` for a sectioned list of `NSManagedObject`s that satisfy the specified fetch clauses. Multiple `ListObserver`s may then register themselves to be notified when changes are made to the list.
    
    - parameter from: a `From` clause indicating the entity type
    - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
    - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
    - returns: a `ListMonitor` instance that monitors changes to the list
    */
    public static func monitorSectionedList<T: NSManagedObject>(from: From<T>, _ sectionBy: SectionBy, _ fetchClauses: FetchClause...) -> ListMonitor<T> {
        
        return self.defaultStack.monitorSectionedList(from, sectionBy, fetchClauses)
    }
    
    /**
    Using the `defaultStack`, creates a `ListMonitor` for a sectioned list of `NSManagedObject`s that satisfy the specified fetch clauses. Multiple `ListObserver`s may then register themselves to be notified when changes are made to the list.
    
    - parameter from: a `From` clause indicating the entity type
    - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
    - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
    - returns: a `ListMonitor` instance that monitors changes to the list
    */
    public static func monitorSectionedList<T: NSManagedObject>(from: From<T>, _ sectionBy: SectionBy, _ fetchClauses: [FetchClause]) -> ListMonitor<T> {
        
        return self.defaultStack.monitorSectionedList(from, sectionBy, fetchClauses)
    }
}
