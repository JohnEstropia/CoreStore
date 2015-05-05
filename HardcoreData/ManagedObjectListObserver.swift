//
//  ManagedObjectListObserver.swift
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


// MARK: - ManagedObjectListChangeObserver

public protocol ManagedObjectListChangeObserver: class {
    
    typealias EntityType: NSManagedObject
    
    func managedObjectListWillChange(listController: ManagedObjectListController<EntityType>)
    
    func managedObjectListDidChange(listController: ManagedObjectListController<EntityType>)
}


// MARK: - ManagedObjectListObjectObserver

public protocol ManagedObjectListObjectObserver: ManagedObjectListChangeObserver {
    
    func managedObjectList(listController: ManagedObjectListController<EntityType>, didInsertObject object: EntityType, toIndexPath indexPath: NSIndexPath)
    
    func managedObjectList(listController: ManagedObjectListController<EntityType>, didDeleteObject object: EntityType, fromIndexPath indexPath: NSIndexPath)
    
    func managedObjectList(listController: ManagedObjectListController<EntityType>, didUpdateObject object: EntityType, atIndexPath indexPath: NSIndexPath)
    
    func managedObjectList(listController: ManagedObjectListController<EntityType>, didMoveObject object: EntityType, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    
    
//    
//    private func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String?) -> String? {
//    
//    return nil
//    }
}


// MARK: - ManagedObjectListSectionObserver

public protocol ManagedObjectListSectionObserver: ManagedObjectListObjectObserver {
    
    func managedObjectList(listController: ManagedObjectListController<EntityType>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int)

    func managedObjectList(listController: ManagedObjectListController<EntityType>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int)
}
