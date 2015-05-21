//
//  DataStack+Observing.swift
//  HardcoreData
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
import GCDKit


// MARK: - DataStack

public extension DataStack {
    
    // MARK: Public
    
    /**
    Creates a `ManagedObjectController` for the specified `NSManagedObject`. Multiple `ManagedObjectObserver`'s may then register themselves to be notified when changes are made to the `NSManagedObject`.
    
    :param: object the `NSManagedObject` to observe changes from
    :returns: a `ManagedObjectController` that monitors changes to `object`
    */
    public func observeObject<T: NSManagedObject>(object: T) -> ManagedObjectController<T> {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to observe objects from \(typeName(self)) outside the main queue.")
        
        return ManagedObjectController(
            dataStack: self,
            object: object
        )
    }
    
    /**
    Creates a `ManagedObjectListController` for a list of `NSManagedObject`'s that satisfy the specified fetch clauses. Multiple `ManagedObjectListObserver`'s may then register themselves to be notified when changes are made to the list.
    
    :param: from a `From` clause indicating the entity type
    :param: fetchClauses a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
    :returns: a `ManagedObjectListController` instance that monitors changes to the list
    */
    public func observeObjectList<T: NSManagedObject>(from: From<T>, _ fetchClauses: FetchClause...) -> ManagedObjectListController<T> {
        
        return self.observeObjectList(from, fetchClauses)
    }
    
    /**
    Creates a `ManagedObjectListController` for a list of `NSManagedObject`'s that satisfy the specified fetch clauses. Multiple `ManagedObjectListObserver`'s may then register themselves to be notified when changes are made to the list.
    
    :param: from a `From` clause indicating the entity type
    :param: fetchClauses a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
    :returns: a `ManagedObjectListController` instance that monitors changes to the list
    */
    public func observeObjectList<T: NSManagedObject>(from: From<T>, _ fetchClauses: [FetchClause]) -> ManagedObjectListController<T> {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to observe objects from \(typeName(self)) outside the main queue.")
        
        return ManagedObjectListController(
            dataStack: self,
            entity: T.self,
            sectionedBy: nil,
            fetchClauses: fetchClauses
        )
    }
    
    /**
    Creates a `ManagedObjectListController` for a sectioned list of `NSManagedObject`'s that satisfy the specified fetch clauses. Multiple `ManagedObjectListObserver`'s may then register themselves to be notified when changes are made to the list.
    
    :param: from a `From` clause indicating the entity type
    :param: sectionedBy a `SectionedBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
    :param: fetchClauses a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
    :returns: a `ManagedObjectListController` instance that monitors changes to the list
    */
    public func observeSectionedList<T: NSManagedObject>(from: From<T>, _ sectionedBy: SectionedBy, _ fetchClauses: FetchClause...) -> ManagedObjectListController<T> {
     
        return self.observeSectionedList(from, sectionedBy, fetchClauses)
    }
    
    /**
    Creates a `ManagedObjectListController` for a sectioned list of `NSManagedObject`'s that satisfy the specified fetch clauses. Multiple `ManagedObjectListObserver`'s may then register themselves to be notified when changes are made to the list.
    
    :param: from a `From` clause indicating the entity type
    :param: sectionedBy a `SectionedBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
    :param: fetchClauses a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
    :returns: a `ManagedObjectListController` instance that monitors changes to the list
    */
    public func observeSectionedList<T: NSManagedObject>(from: From<T>, _ sectionedBy: SectionedBy, _ fetchClauses: [FetchClause]) -> ManagedObjectListController<T> {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to observe objects from \(typeName(self)) outside the main queue.")
        
        return ManagedObjectListController(
            dataStack: self,
            entity: T.self,
            sectionedBy: sectionedBy,
            fetchClauses: fetchClauses
        )
    }
}
