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
    Using the `defaultStack`, creates a `ManagedObjectController` for the specified `NSManagedObject`. Multiple `ManagedObjectObserver`'s may then register themselves to be notified when changes are made to the `NSManagedObject`.
    
    :param: object the `NSManagedObject` to observe changes from
    :returns: a `ManagedObjectController` that monitors changes to `object`
    */
    public static func observeObject<T: NSManagedObject>(object: T) -> ManagedObjectController<T> {
        
        return self.defaultStack.observeObject(object)
    }
    
    /**
    Using the `defaultStack`, creates a `ManagedObjectListController` for a list of `NSManagedObject`'s that satisfy the specified fetch clauses. Multiple `ManagedObjectListObserver`'s may then register themselves to be notified when changes are made to the list.
    
    :param: from a `From` clause indicating the entity type
    :param: fetchClauses a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
    :returns: a `ManagedObjectListController` instance that monitors changes to the list
    */
    public static func observeObjectList<T: NSManagedObject>(from: From<T>, _ groupBy: GroupBy? = nil, _ queryClauses: FetchClause...) -> ManagedObjectListController<T> {
        
        return self.defaultStack.observeObjectList(from, queryClauses)
    }
    
    /**
    Using the `defaultStack`, creates a `ManagedObjectListController` for a list of `NSManagedObject`'s that satisfy the specified fetch clauses. Multiple `ManagedObjectListObserver`'s may then register themselves to be notified when changes are made to the list.
    
    :param: from a `From` clause indicating the entity type
    :param: fetchClauses a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
    :returns: a `ManagedObjectListController` instance that monitors changes to the list
    */
    public static func observeObjectList<T: NSManagedObject>(from: From<T>, _ groupBy: GroupBy? = nil, _ queryClauses: [FetchClause]) -> ManagedObjectListController<T> {
        
        return self.defaultStack.observeObjectList(from, queryClauses)
    }
    
    /**
    Using the `defaultStack`, creates a `ManagedObjectListController` for a sectioned list of `NSManagedObject`'s that satisfy the specified fetch clauses. Multiple `ManagedObjectListObserver`'s may then register themselves to be notified when changes are made to the list.
    
    :param: from a `From` clause indicating the entity type
    :param: sectionedBy a `SectionedBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
    :param: fetchClauses a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
    :returns: a `ManagedObjectListController` instance that monitors changes to the list
    */
    public static func observeSectionedList<T: NSManagedObject>(from: From<T>, _ sectionedBy: SectionedBy, _ fetchClauses: FetchClause...) -> ManagedObjectListController<T> {
        
        return self.defaultStack.observeSectionedList(from, sectionedBy, fetchClauses)
    }
    
    /**
    Using the `defaultStack`, creates a `ManagedObjectListController` for a sectioned list of `NSManagedObject`'s that satisfy the specified fetch clauses. Multiple `ManagedObjectListObserver`'s may then register themselves to be notified when changes are made to the list.
    
    :param: from a `From` clause indicating the entity type
    :param: sectionedBy a `SectionedBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
    :param: fetchClauses a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
    :returns: a `ManagedObjectListController` instance that monitors changes to the list
    */
    public static func observeSectionedList<T: NSManagedObject>(from: From<T>, _ sectionedBy: SectionedBy, _ fetchClauses: [FetchClause]) -> ManagedObjectListController<T> {
        
        return self.defaultStack.observeSectionedList(from, sectionedBy, fetchClauses)
    }
}
