//
//  ManagedObjectListObserver.swift
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


// MARK: - ManagedObjectListChangeObserver

/**
Implement the `ManagedObjectListChangeObserver` protocol to observe changes to a list of `NSManagedObject`'s. `ManagedObjectListChangeObserver`'s may register themselves to a `ManagedObjectListController`'s `addObserver(_:)` method:

    let listController = CoreStore.observeObjectList(
        From(MyPersonEntity),
        OrderBy(.Ascending("lastName"))
    )
    listController.addObserver(self)
*/
public protocol ManagedObjectListChangeObserver: class {
    
    /**
    The `NSManagedObject` type for the observed list
    */
    typealias EntityType: NSManagedObject
    
    /**
    Handles processing just before a change to the observed list occurs
    
    :param: listController the `ManagedObjectListController` monitoring the list being observed
    */
    func managedObjectListWillChange(listController: ManagedObjectListController<EntityType>)
    
    /**
    Handles processing right after a change to the observed list occurs
    
    :param: listController the `ManagedObjectListController` monitoring the object being observed
    */
    func managedObjectListDidChange(listController: ManagedObjectListController<EntityType>)
}


// MARK: - ManagedObjectListObjectObserver

/**
Implement the `ManagedObjectListObjectObserver` protocol to observe detailed changes to a list's object. `ManagedObjectListObjectObserver`'s may register themselves to a `ManagedObjectListController`'s `addObserver(_:)` method:

    let listController = CoreStore.observeObjectList(
        From(MyPersonEntity),
        OrderBy(.Ascending("lastName"))
    )
    listController.addObserver(self)
*/
public protocol ManagedObjectListObjectObserver: ManagedObjectListChangeObserver {
    
    /**
    Notifies that an object was inserted to the specified `NSIndexPath` in the list
    
    :param: listController the `ManagedObjectListController` monitoring the list being observed
    :param: object the entity type for the inserted object
    :param: indexPath the new `NSIndexPath` for the inserted object
    */
    func managedObjectList(listController: ManagedObjectListController<EntityType>, didInsertObject object: EntityType, toIndexPath indexPath: NSIndexPath)
    
    /**
    Notifies that an object was deleted from the specified `NSIndexPath` in the list
    
    :param: listController the `ManagedObjectListController` monitoring the list being observed
    :param: object the entity type for the deleted object
    :param: indexPath the `NSIndexPath` for the deleted object
    */
    func managedObjectList(listController: ManagedObjectListController<EntityType>, didDeleteObject object: EntityType, fromIndexPath indexPath: NSIndexPath)
    
    /**
    Notifies that an object at the specified `NSIndexPath` was updated
    
    :param: listController the `ManagedObjectListController` monitoring the list being observed
    :param: object the entity type for the updated object
    :param: indexPath the `NSIndexPath` for the updated object
    */
    func managedObjectList(listController: ManagedObjectListController<EntityType>, didUpdateObject object: EntityType, atIndexPath indexPath: NSIndexPath)
    
    /**
    Notifies that an object's index changed
    
    :param: listController the `ManagedObjectListController` monitoring the list being observed
    :param: object the entity type for the moved object
    :param: fromIndexPath the previous `NSIndexPath` for the moved object
    :param: toIndexPath the new `NSIndexPath` for the moved object
    */
    func managedObjectList(listController: ManagedObjectListController<EntityType>, didMoveObject object: EntityType, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
}


// MARK: - ManagedObjectListSectionObserver

/**
Implement the `ManagedObjectListSectionObserver` protocol to observe changes to a list's section info. `ManagedObjectListSectionObserver`'s may register themselves to a `ManagedObjectListController`'s `addObserver(_:)` method:

    let listController = CoreStore.observeSectionedList(
        From(MyPersonEntity),
        SectionedBy("age") { "Age \($0)" },
        OrderBy(.Ascending("lastName"))
    )
    listController.addObserver(self)
*/
public protocol ManagedObjectListSectionObserver: ManagedObjectListObjectObserver {
    
    /**
    Notifies that a section was inserted at the specified index
    
    :param: listController the `ManagedObjectListController` monitoring the list being observed
    :param: sectionInfo the `NSFetchedResultsSectionInfo` for the inserted section
    :param: sectionIndex the new section index for the new section
    */
    func managedObjectList(listController: ManagedObjectListController<EntityType>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int)
    
    /**
    Notifies that a section was inserted at the specified index
    
    :param: listController the `ManagedObjectListController` monitoring the list being observed
    :param: sectionInfo the `NSFetchedResultsSectionInfo` for the deleted section
    :param: sectionIndex the previous section index for the deleted section
    */
    func managedObjectList(listController: ManagedObjectListController<EntityType>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int)
}
