//
//  ManagedObjectListController.swift
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


private let ManagedObjectListControllerWillChangeListNotification = "ManagedObjectListControllerWillChangeListNotification"
private let ManagedObjectListControllerDidChangeListNotification = "ManagedObjectListControllerDidChangeListNotification"
private let ManagedObjectListControllerDidInsertObjectNotification = "ManagedObjectListControllerDidInsertObjectNotification"
private let ManagedObjectListControllerDidDeleteObjectNotification = "ManagedObjectListControllerDidDeleteObjectNotification"
private let ManagedObjectListControllerDidUpdateObjectNotification = "ManagedObjectListControllerDidUpdateObjectNotification"
private let ManagedObjectListControllerDidMoveObjectNotification = "ManagedObjectListControllerDidMoveObjectNotification"

private let UserInfoKeyObject = "UserInfoKeyObject"
private let UserInfoKeyIndexPath = "UserInfoKeyIndexPath"
private let UserInfoKeyNewIndexPath = "UserInfoKeyNewIndexPath"

private struct NotificationKey {
    
    static var willChangeList: Void?
    static var didChangeList: Void?
    static var didInsertObject: Void?
    static var didDeleteObject: Void?
    static var didUpdateObject: Void?
    static var didMoveObject: Void?
}

// MARK: - ManagedObjectListController

public final class ManagedObjectListController<T: NSManagedObject>: FetchedResultsControllerHandler {
    
    // MARK: Public
    
    public subscript(indexPath: NSIndexPath) -> T {
        
        return self.fetchedResultsController.objectAtIndexPath(indexPath) as! T
    }
    
    public func numberOfSections() -> Int {
        
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    public func numberOfItemsInSection(section: Int) -> Int {
        
        return (self.fetchedResultsController.sections?[section] as? NSFetchedResultsSectionInfo)?.numberOfObjects ?? 0
    }
    
    public func addObserver<U: ManagedObjectListObserver where U.EntityType == T>(observer: U) {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to add a \(typeName(observer)) outside the main queue.")
        
        setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: ManagedObjectListControllerWillChangeListNotification,
                object: self,
                closure: { [weak self, weak observer] (note) -> Void in
                    
                    if let strongSelf = self, let strongObserver = observer {
                        
                        strongObserver.managedObjectListWillChange(strongSelf)
                    }
                }
            ),
            forKey: &NotificationKey.willChangeList,
            inObject: observer
        )
        setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: ManagedObjectListControllerDidChangeListNotification,
                object: self,
                closure: { [weak self, weak observer] (note) -> Void in
                    
                    if let strongSelf = self, let strongObserver = observer {
                        
                        strongObserver.managedObjectListDidChange(strongSelf)
                    }
                }
            ),
            forKey: &NotificationKey.willChangeList,
            inObject: observer
        )
        setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: ManagedObjectListControllerDidInsertObjectNotification,
                object: self,
                closure: { [weak self, weak observer] (note) -> Void in
                    
                    if let strongSelf = self,
                        let strongObserver = observer,
                        let userInfo = note.userInfo,
                        let object = userInfo[UserInfoKeyObject] as? T,
                        let newIndexPath = userInfo[UserInfoKeyNewIndexPath] as? NSIndexPath {
                            
                            strongObserver.managedObjectList(
                                strongSelf,
                                didInsertObject: object,
                                toIndexPath: newIndexPath
                            )
                    }
                }
            ),
            forKey: &NotificationKey.didInsertObject,
            inObject: observer
        )
        setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: ManagedObjectListControllerDidDeleteObjectNotification,
                object: self,
                closure: { [weak self, weak observer] (note) -> Void in
                    
                    if let strongSelf = self,
                        let strongObserver = observer,
                        let userInfo = note.userInfo,
                        let object = userInfo[UserInfoKeyObject] as? T,
                        let indexPath = userInfo[UserInfoKeyIndexPath] as? NSIndexPath {
                            
                            strongObserver.managedObjectList(
                                strongSelf,
                                didDeleteObject: object,
                                fromIndexPath: indexPath
                            )
                    }
                }
            ),
            forKey: &NotificationKey.didDeleteObject,
            inObject: observer
        )
        setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: ManagedObjectListControllerDidUpdateObjectNotification,
                object: self,
                closure: { [weak self, weak observer] (note) -> Void in
                    
                    if let strongSelf = self,
                        let strongObserver = observer,
                        let userInfo = note.userInfo,
                        let object = userInfo[UserInfoKeyObject] as? T,
                        let indexPath = userInfo[UserInfoKeyIndexPath] as? NSIndexPath {
                            
                            strongObserver.managedObjectList(
                                strongSelf,
                                didUpdateObject: object,
                                atIndexPath: indexPath
                            )
                    }
                }
            ),
            forKey: &NotificationKey.didUpdateObject,
            inObject: observer
        )
        setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: ManagedObjectListControllerDidMoveObjectNotification,
                object: self,
                closure: { [weak self, weak observer] (note) -> Void in
                    
                    if let strongSelf = self,
                        let strongObserver = observer,
                        let userInfo = note.userInfo,
                        let object = userInfo[UserInfoKeyObject] as? T,
                        let indexPath = userInfo[UserInfoKeyIndexPath] as? NSIndexPath ,
                        let newIndexPath = userInfo[UserInfoKeyNewIndexPath] as? NSIndexPath {
                            
                            strongObserver.managedObjectList(
                                strongSelf,
                                didMoveObject: object,
                                fromIndexPath: indexPath,
                                toIndexPath: newIndexPath
                            )
                    }
                }
            ),
            forKey: &NotificationKey.didMoveObject,
            inObject: observer
        )
    }
    
    public func removeObserver<U: ManagedObjectListObserver where U.EntityType == T>(observer: U) {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to remove a \(typeName(observer)) outside the main queue.")
        
        setAssociatedRetainedObject(nil as AnyObject?, forKey: &NotificationKey.willChangeList, inObject: observer)
        setAssociatedRetainedObject(nil as AnyObject?, forKey: &NotificationKey.didChangeList, inObject: observer)
        setAssociatedRetainedObject(nil as AnyObject?, forKey: &NotificationKey.didInsertObject, inObject: observer)
        setAssociatedRetainedObject(nil as AnyObject?, forKey: &NotificationKey.didDeleteObject, inObject: observer)
        setAssociatedRetainedObject(nil as AnyObject?, forKey: &NotificationKey.didUpdateObject, inObject: observer)
        setAssociatedRetainedObject(nil as AnyObject?, forKey: &NotificationKey.didMoveObject, inObject: observer)
    }
    
    // MARK: FetchedResultsControllerHandler
    
    private func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Insert:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ManagedObjectListControllerDidInsertObjectNotification,
                object: self,
                userInfo: [
                    UserInfoKeyObject: anObject,
                    UserInfoKeyNewIndexPath: newIndexPath!
                ]
            )
            
        case .Delete:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ManagedObjectListControllerDidDeleteObjectNotification,
                object: self,
                userInfo: [
                    UserInfoKeyObject: anObject,
                    UserInfoKeyIndexPath: indexPath!
                ]
            )
            
        case .Update:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ManagedObjectListControllerDidUpdateObjectNotification,
                object: self,
                userInfo: [
                    UserInfoKeyObject: anObject,
                    UserInfoKeyIndexPath: indexPath!
                ]
            )
            
        case .Move:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ManagedObjectListControllerDidMoveObjectNotification,
                object: self,
                userInfo: [
                    UserInfoKeyObject: anObject,
                    UserInfoKeyIndexPath: indexPath!,
                    UserInfoKeyNewIndexPath: newIndexPath!
                ]
            )
        }
    }
    
    private func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
    }
    
    private func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            ManagedObjectListControllerWillChangeListNotification,
            object: self
        )
    }
    
    private func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            ManagedObjectListControllerDidChangeListNotification,
            object: self
        )
    }
    
    private func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String?) -> String? {
        
        return nil
    }
    
    
    // MARK: Internal
    
    internal init(dataStack: DataStack, entity: T.Type, sectionNameKeyPath: KeyPath?, cacheResults: Bool, queryClauses: [FetchClause]) {
        
        let context = dataStack.mainContext
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = context.entityDescriptionForEntityClass(entity)
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectResultType
        
        for clause in queryClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: (cacheResults
                ? "\(self.dynamicType).\(NSUUID())"
                : nil)
        )
        
        let fetchedResultsControllerDelegate = FetchedResultsControllerDelegate()
        
        self.fetchedResultsController = fetchedResultsController
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
        self.parentStack = dataStack
        
        fetchedResultsControllerDelegate.handler = self
        fetchedResultsControllerDelegate.fetchedResultsController = fetchedResultsController
        
        var error: NSError?
        if !fetchedResultsController.performFetch(&error) {
            
            HardcoreData.handleError(
                error ?? NSError(hardcoreDataErrorCode: .UnknownError),
                "Failed to perform fetch on <\(NSFetchedResultsController.self)>.")
        }
    }
    
    
    // MARK: Private
    
    private let fetchedResultsController: NSFetchedResultsController
    private let fetchedResultsControllerDelegate: FetchedResultsControllerDelegate
    private weak var parentStack: DataStack?
}


// MARK: - FetchedResultsControllerHandler

private protocol FetchedResultsControllerHandler: class {
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    
    func controllerWillChangeContent(controller: NSFetchedResultsController)
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    
    func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String?) -> String?
}


// MARK: - FetchedResultsControllerDelegate

private final class FetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate {
    
    // MARK: NSFetchedResultsControllerDelegate
    
    @objc func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        self.handler?.controller(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
    }
    
    @objc func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        self.handler?.controller(controller, didChangeSection: sectionInfo, atIndex: sectionIndex, forChangeType: type)
    }
    
    @objc func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        self.handler?.controllerWillChangeContent(controller)
    }
    
    @objc func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        self.handler?.controllerDidChangeContent(controller)
    }
    
    @objc func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String?) -> String? {
        
        return self.handler?.controller(controller, sectionIndexTitleForSectionName: sectionName)
    }
    
    
    // MARK: Private
    
    weak var handler: FetchedResultsControllerHandler?
    weak var fetchedResultsController: NSFetchedResultsController? {
        
        didSet {
            
            oldValue?.delegate = nil
            self.fetchedResultsController?.delegate = self
        }
    }
    
    deinit {
        
        self.fetchedResultsController?.delegate = nil
    }
}
