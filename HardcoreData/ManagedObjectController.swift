//
//  ManagedObjectController.swift
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


private let ManagedObjectListControllerWillChangeObjectNotification = "ManagedObjectListControllerWillChangeObjectNotification"
private let ManagedObjectListControllerDidDeleteObjectNotification = "ManagedObjectListControllerDidDeleteObjectNotification"
private let ManagedObjectListControllerDidUpdateObjectNotification = "ManagedObjectListControllerDidUpdateObjectNotification"

private let UserInfoKeyObject = "UserInfoKeyObject"

private struct NotificationKey {
    
    static var willChangeObject: Void?
    static var didDeleteObject: Void?
    static var didUpdateObject: Void?
}


// MARK: - ManagedObjectController

public final class ManagedObjectController<T: NSManagedObject>: FetchedResultsControllerHandler {
    
    // MARK: Public
    
    public var object: T? {
        
        return self.fetchedResultsController.fetchedObjects?.first as? T
    }
    
    public var isObjectDeleted: Bool {
        
        return self.object?.managedObjectContext == nil
    }
    
    public func addObserver<U: ManagedObjectObserver where U.EntityType == T>(observer: U) {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to add a \(typeName(observer)) outside the main queue.")
        
        self.registerChangeNotification(
            &NotificationKey.willChangeObject,
            name: ManagedObjectListControllerWillChangeObjectNotification,
            toObserver: observer,
            callback: { [weak self, weak observer] (objectController) -> Void in
                
                if let strongSelf = self, let object = strongSelf.object, let observer = observer {
                    
                    observer.managedObjectWillUpdate(objectController, object: object)
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didDeleteObject,
            name: ManagedObjectListControllerDidDeleteObjectNotification,
            toObserver: observer,
            callback: { [weak self, weak observer] (objectController, object) -> Void in
                
                if let strongSelf = self, let observer = observer {
                    
                    observer.managedObjectWasDeleted(objectController, object: object)
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didUpdateObject,
            name: ManagedObjectListControllerDidUpdateObjectNotification,
            toObserver: observer,
            callback: { [weak self, weak observer] (objectController, object) -> Void in
                
                if let strongSelf = self, let observer = observer {
                    
                    let previousCommitedAttributes = strongSelf.lastCommittedAttributes
                    let currentCommitedAttributes = object.committedValuesForKeys(nil) as! [NSString: NSObject]
                    
                    var changedKeys = Set<String>()
                    for key in currentCommitedAttributes.keys {
                        
                        if previousCommitedAttributes[key] != currentCommitedAttributes[key] {
                            
                            changedKeys.insert(key as String)
                        }
                    }
                    
                    strongSelf.lastCommittedAttributes = currentCommitedAttributes
                    observer.managedObjectWasUpdated(
                        objectController,
                        object: object,
                        changedPersistentKeys: changedKeys
                    )
                }
            }
        )
    }
    
    public func removeObserver<U: ManagedObjectObserver where U.EntityType == T>(observer: U) {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to remove a \(typeName(observer)) outside the main queue.")
        
        let nilValue: AnyObject? = nil
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.willChangeObject, inObject: observer)
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.didDeleteObject, inObject: observer)
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.didUpdateObject, inObject: observer)
    }
    
    
    // MARK: FetchedResultsControllerHandler
    
    private func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Delete:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ManagedObjectListControllerDidDeleteObjectNotification,
                object: self,
                userInfo: [UserInfoKeyObject: anObject]
            )
            
        case .Update:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ManagedObjectListControllerDidUpdateObjectNotification,
                object: self,
                userInfo: [UserInfoKeyObject: anObject]
            )
            
        default:
            break
        }
    }
    
    private func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            ManagedObjectListControllerWillChangeObjectNotification,
            object: self
        )
    }
    
    
    // MARK: Internal
    
    internal init(dataStack: DataStack, object: T) {
        
        let context = dataStack.mainContext
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = context.entityDescriptionForEntityClass(T.self)
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .ManagedObjectResultType
        fetchRequest.sortDescriptors = []
        
        let originalObjectID = object.objectID
        Where("SELF", isEqualTo: originalObjectID).applyToFetchRequest(fetchRequest)
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        let fetchedResultsControllerDelegate = FetchedResultsControllerDelegate()
        
        self.originalObjectID = originalObjectID
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
        
        self.lastCommittedAttributes = (self.object?.committedValuesForKeys(nil) as? [NSString: NSObject]) ?? [:]
    }
    
    
    // MARK: Private
    
    private let originalObjectID: NSManagedObjectID
    private let fetchedResultsController: NSFetchedResultsController
    private let fetchedResultsControllerDelegate: FetchedResultsControllerDelegate
    private var lastCommittedAttributes = [NSString: NSObject]()
    private weak var parentStack: DataStack?
    
    private func registerChangeNotification(notificationKey: UnsafePointer<Void>, name: String, toObserver observer: AnyObject, callback: (objectController: ManagedObjectController<T>) -> Void) {
        
        setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: name,
                object: self,
                closure: { [weak self] (note) -> Void in
                    
                    if let strongSelf = self {
                        
                        callback(objectController: strongSelf)
                    }
                }
            ),
            forKey: notificationKey,
            inObject: observer
        )
    }
    
    private func registerObjectNotification(notificationKey: UnsafePointer<Void>, name: String, toObserver observer: AnyObject, callback: (objectController: ManagedObjectController<T>, object: T) -> Void) {
        
        setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: name,
                object: self,
                closure: { [weak self] (note) -> Void in
                    
                    if let strongSelf = self,
                        let userInfo = note.userInfo,
                        let object = userInfo[UserInfoKeyObject] as? T {
                            
                            callback(
                                objectController: strongSelf,
                                object: object
                            )
                    }
                }
            ),
            forKey: notificationKey,
            inObject: observer
        )
    }
}


// MARK: - FetchedResultsControllerHandler

private protocol FetchedResultsControllerHandler: class {
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    
    func controllerWillChangeContent(controller: NSFetchedResultsController)
}


// MARK: - FetchedResultsControllerDelegate

private final class FetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate {
    
    // MARK: NSFetchedResultsControllerDelegate
    
    @objc func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        self.handler?.controllerWillChangeContent(controller)
    }
    
    @objc func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        self.handler?.controller(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
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
