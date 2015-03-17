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


// MARK: - ManagedObjectListObserver

public protocol ManagedObjectListObserver: class {
    
    typealias EntityType: NSManagedObject

    func managedObjectListWillChange(listController: ManagedObjectListController<EntityType>)
    
    
//    func managedObjectList(listController: ManagedObjectListController<EntityType>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int)
//    
//    func managedObjectList(listController: ManagedObjectListController<EntityType>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int)
//    
//    func managedObjectList(listController: ManagedObjectListController<EntityType>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int)
//    
//    func managedObjectList(listController: ManagedObjectListController<EntityType>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int)
    
    
    func managedObjectList(listController: ManagedObjectListController<EntityType>, didInsertObject object: EntityType, toItemIndex itemIndex: Int)
    
    func managedObjectList(listController: ManagedObjectListController<EntityType>, didDeleteObject object: EntityType, fromItemIndex itemIndex: Int)
    
    func managedObjectList(listController: ManagedObjectListController<EntityType>, didUpdateObject object: EntityType, atItemIndex itemIndex: Int)
    
    func managedObjectList(listController: ManagedObjectListController<EntityType>, didMoveObject object: EntityType, fromItemIndex: Int, toItemIndex: Int)
    
    
    func managedObjectListDidChange(listController: ManagedObjectListController<EntityType>)
    
    
//    private func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//    
//    }
//    
//    private func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//    
//    }
//    
//    private func controllerWillChangeContent(controller: NSFetchedResultsController) {
//    
//    }
//    
//    private func controllerDidChangeContent(controller: NSFetchedResultsController) {
//    
//    }
//    
//    private func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String?) -> String? {
//    
//    return nil
//    }
}
