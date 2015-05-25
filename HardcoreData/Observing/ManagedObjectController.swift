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

/**
The `ManagedObjectController` monitors changes to a single `NSManagedObject` instance. Observers that implement the `ManagedObjectObserver` protocol may then register themselves to the `ManagedObjectController`'s `addObserver(_:)` method:

    let objectController = HardcoreData.observeObject(object)
    objectController.addObserver(self)

The created `ManagedObjectController` instance needs to be held on (retained) for as long as the object needs to be observed.

Observers registered via `addObserver(_:)` are not retained. `ManagedObjectController` only keeps a `weak` reference to all observers, thus keeping itself free from retain-cycles.
*/
public final class ManagedObjectController<T: NSManagedObject> {
    
    // MARK: Public
    
    /**
    Returns the `NSManagedObject` instance being observed, or `nil` if the object was already deleted.
    */
    public var object: T? {
        
        return self.fetchedResultsController.fetchedObjects?.first as? T
    }
    
    /**
    Returns `true` if the `NSManagedObject` instance being observed still exists, or `false` if the object was already deleted.
    */
    public var isObjectDeleted: Bool {
        
        return self.object?.managedObjectContext == nil
    }
    
    /**
    Registers a `ManagedObjectObserver` to be notified when changes to the receiver's `object` are made.
    
    To prevent retain-cycles, `ManagedObjectController` only keeps `weak` references to its observers.
    
    For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
    
    Calling `addObserver(_:)` multiple times on the same observer is safe, as `ManagedObjectController` unregisters previous notifications to the observer before re-registering them.
    
    :param: observer a `ManagedObjectObserver` to send change notifications to
    */
    public func addObserver<U: ManagedObjectObserver where U.EntityType == T>(observer: U) {
        
        HardcoreData.assert(NSThread.isMainThread(), "Attempted to add an observer of type \(typeName(observer)) outside the main thread.")
        
        self.removeObserver(observer)
        
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
    
    /**
    Unregisters a `ManagedObjectObserver` from receiving notifications for changes to the receiver's `object`.
    
    For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
    
    :param: observer a `ManagedObjectObserver` to unregister notifications to
    */
    public func removeObserver<U: ManagedObjectObserver where U.EntityType == T>(observer: U) {
        
        HardcoreData.assert(NSThread.isMainThread(), "Attempted to remove an observer of type \(typeName(observer)) outside the main thread.")
        
        let nilValue: AnyObject? = nil
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.willChangeObject, inObject: observer)
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.didDeleteObject, inObject: observer)
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.didUpdateObject, inObject: observer)
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


// MARK: - ManagedObjectController: FetchedResultsControllerHandler

extension ManagedObjectController: FetchedResultsControllerHandler {
    
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
