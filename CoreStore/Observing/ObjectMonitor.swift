//
//  ObjectMonitor.swift
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
import GCDKit


private let ObjectMonitorWillChangeObjectNotification = "ObjectMonitorWillChangeObjectNotification"
private let ObjectMonitorDidDeleteObjectNotification = "ObjectMonitorDidDeleteObjectNotification"
private let ObjectMonitorDidUpdateObjectNotification = "ObjectMonitorDidUpdateObjectNotification"

private let UserInfoKeyObject = "UserInfoKeyObject"

private struct NotificationKey {
    
    static var willChangeObject: Void?
    static var didDeleteObject: Void?
    static var didUpdateObject: Void?
}


// MARK: - ObjectMonitor

/**
The `ObjectMonitor` monitors changes to a single `NSManagedObject` instance. Observers that implement the `ObjectObserver` protocol may then register themselves to the `ObjectMonitor`'s `addObserver(_:)` method:

    let monitor = CoreStore.monitorObject(object)
    monitor.addObserver(self)

The created `ObjectMonitor` instance needs to be held on (retained) for as long as the object needs to be observed.

Observers registered via `addObserver(_:)` are not retained. `ObjectMonitor` only keeps a `weak` reference to all observers, thus keeping itself free from retain-cycles.
*/
public final class ObjectMonitor<T: NSManagedObject> {
    
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
    Registers an `ObjectObserver` to be notified when changes to the receiver's `object` are made.
    
    To prevent retain-cycles, `ObjectMonitor` only keeps `weak` references to its observers.
    
    For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
    
    Calling `addObserver(_:)` multiple times on the same observer is safe, as `ObjectMonitor` unregisters previous notifications to the observer before re-registering them.
    
    - parameter observer: an `ObjectObserver` to send change notifications to
    */
    public func addObserver<U: ObjectObserver where U.EntityType == T>(observer: U) {
        
        CoreStore.assert(
            NSThread.isMainThread(),
            "Attempted to add an observer of type \(typeName(observer)) outside the main thread."
        )
        
        self.removeObserver(observer)
        
        self.registerChangeNotification(
            &NotificationKey.willChangeObject,
            name: ObjectMonitorWillChangeObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor) -> Void in
                
                if let object = monitor.object, let observer = observer {
                    
                    observer.objectMonitor(monitor, willUpdateObject: object)
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didDeleteObject,
            name: ObjectMonitorDidDeleteObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor, object) -> Void in
                
                if let observer = observer {
                    
                    observer.objectMonitor(monitor, didDeleteObject: object)
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didUpdateObject,
            name: ObjectMonitorDidUpdateObjectNotification,
            toObserver: observer,
            callback: { [weak self, weak observer] (monitor, object) -> Void in
                
                if let strongSelf = self, let observer = observer {
                    
                    let previousCommitedAttributes = strongSelf.lastCommittedAttributes
                    let currentCommitedAttributes = object.committedValuesForKeys(nil) as! [String: NSObject]
                    
                    var changedKeys = Set<String>()
                    for key in currentCommitedAttributes.keys {
                        
                        if previousCommitedAttributes[key] != currentCommitedAttributes[key] {
                            
                            changedKeys.insert(key)
                        }
                    }
                    
                    strongSelf.lastCommittedAttributes = currentCommitedAttributes
                    observer.objectMonitor(
                        monitor,
                        didUpdateObject: object,
                        changedPersistentKeys: changedKeys
                    )
                }
            }
        )
    }
    
    /**
    Unregisters an `ObjectObserver` from receiving notifications for changes to the receiver's `object`.
    
    For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
    
    - parameter observer: an `ObjectObserver` to unregister notifications to
    */
    public func removeObserver<U: ObjectObserver where U.EntityType == T>(observer: U) {
        
        CoreStore.assert(
            NSThread.isMainThread(),
            "Attempted to remove an observer of type \(typeName(observer)) outside the main thread."
        )
        
        let nilValue: AnyObject? = nil
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.willChangeObject, inObject: observer)
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.didDeleteObject, inObject: observer)
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.didUpdateObject, inObject: observer)
    }
    
    
    // MARK: Internal
    
    internal init(dataStack: DataStack, object: T) {
        
        let context = dataStack.mainContext
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = object.entity
        
        fetchRequest.fetchLimit = 0
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
        
        self.fetchedResultsController = fetchedResultsController
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
        self.parentStack = dataStack
        
        fetchedResultsControllerDelegate.handler = self
        fetchedResultsControllerDelegate.fetchedResultsController = fetchedResultsController
        try! fetchedResultsController.performFetch()
        
        self.lastCommittedAttributes = (self.object?.committedValuesForKeys(nil) as? [String: NSObject]) ?? [:]
    }
    
    
    // MARK: Private
    
    private let fetchedResultsController: NSFetchedResultsController
    private let fetchedResultsControllerDelegate: FetchedResultsControllerDelegate
    private var lastCommittedAttributes = [String: NSObject]()
    private weak var parentStack: DataStack?
    
    private func registerChangeNotification(notificationKey: UnsafePointer<Void>, name: String, toObserver observer: AnyObject, callback: (monitor: ObjectMonitor<T>) -> Void) {
        
        setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: name,
                object: self,
                closure: { [weak self] (note) -> Void in
                    
                    if let strongSelf = self {
                        
                        callback(monitor: strongSelf)
                    }
                }
            ),
            forKey: notificationKey,
            inObject: observer
        )
    }
    
    private func registerObjectNotification(notificationKey: UnsafePointer<Void>, name: String, toObserver observer: AnyObject, callback: (monitor: ObjectMonitor<T>, object: T) -> Void) {
        
        setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: name,
                object: self,
                closure: { [weak self] (note) -> Void in
                    
                    if let strongSelf = self,
                        let userInfo = note.userInfo,
                        let object = userInfo[UserInfoKeyObject] as? T {
                            
                            callback(
                                monitor: strongSelf,
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


// MARK: - ObjectMonitor: Equatable

public func ==<T: NSManagedObject>(lhs: ObjectMonitor<T>, rhs: ObjectMonitor<T>) -> Bool {
    
    return lhs === rhs
}

extension ObjectMonitor: Equatable { }


// MARK: - ObjectMonitor: FetchedResultsControllerHandler

extension ObjectMonitor: FetchedResultsControllerHandler {
    
    // MARK: FetchedResultsControllerHandler
    
    private func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Delete:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ObjectMonitorDidDeleteObjectNotification,
                object: self,
                userInfo: [UserInfoKeyObject: anObject]
            )
            
        case .Update, .Move where indexPath == newIndexPath:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ObjectMonitorDidUpdateObjectNotification,
                object: self,
                userInfo: [UserInfoKeyObject: anObject]
            )
            
        default:
            break
        }
    }
    
    private func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            ObjectMonitorWillChangeObjectNotification,
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

private final class FetchedResultsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: NSFetchedResultsControllerDelegate
    
    @objc dynamic func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        self.handler?.controllerWillChangeContent(controller)
    }
    
    @objc dynamic func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
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
