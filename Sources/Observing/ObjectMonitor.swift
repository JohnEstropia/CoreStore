//
//  ObjectMonitor.swift
//  CoreStore
//
//  Copyright © 2015 John Rommel Estropia
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
#if USE_FRAMEWORKS
    import GCDKit
#endif


#if os(iOS) || os(watchOS) || os(tvOS)

// MARK: - ObjectMonitor

/**
 The `ObjectMonitor` monitors changes to a single `NSManagedObject` instance. Observers that implement the `ObjectObserver` protocol may then register themselves to the `ObjectMonitor`'s `addObserver(_:)` method:
 ```
 let monitor = CoreStore.monitorObject(object)
 monitor.addObserver(self)
 ```
 The created `ObjectMonitor` instance needs to be held on (retained) for as long as the object needs to be observed.
 
 Observers registered via `addObserver(_:)` are not retained. `ObjectMonitor` only keeps a `weak` reference to all observers, thus keeping itself free from retain-cycles.
 */
public final class ObjectMonitor<T: NSManagedObject> {
    
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
    public func addObserver<U: ObjectObserver where U.ObjectEntityType == T>(observer: U) {
        
        self.unregisterObserver(observer)
        self.registerObserver(
            observer,
            willChangeObject: { (observer, monitor, object) in
                
                observer.objectMonitor(monitor, willUpdateObject: object)
            },
            didDeleteObject: { (observer, monitor, object) in
                
                observer.objectMonitor(monitor, didDeleteObject: object)
            },
            didUpdateObject: { (observer, monitor, object, changedPersistentKeys) in
                
                observer.objectMonitor(monitor, didUpdateObject: object, changedPersistentKeys: changedPersistentKeys)
            }
        )
    }
    
    /**
     Unregisters an `ObjectObserver` from receiving notifications for changes to the receiver's `object`.
     
     For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
     
     - parameter observer: an `ObjectObserver` to unregister notifications to
     */
    public func removeObserver<U: ObjectObserver where U.ObjectEntityType == T>(observer: U) {
        
        self.unregisterObserver(observer)
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        return ObjectIdentifier(self).hashValue
    }
    
    
    // MARK: Internal
    
    internal convenience init(dataStack: DataStack, object: T) {
        
        self.init(context: dataStack.mainContext, object: object)
    }
    
    internal convenience init(unsafeTransaction: UnsafeDataTransaction, object: T) {
        
        self.init(context: unsafeTransaction.context, object: object)
    }
    
    internal func registerObserver<U: AnyObject>(observer: U, willChangeObject: (observer: U, monitor: ObjectMonitor<T>, object: T) -> Void, didDeleteObject: (observer: U, monitor: ObjectMonitor<T>, object: T) -> Void, didUpdateObject: (observer: U, monitor: ObjectMonitor<T>, object: T, changedPersistentKeys: Set<String>) -> Void) {
        
        CoreStore.assert(
            NSThread.isMainThread(),
            "Attempted to add an observer of type \(cs_typeName(observer)) outside the main thread."
        )
        self.registerChangeNotification(
            &self.willChangeObjectKey,
            name: ObjectMonitorWillChangeObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor) -> Void in
                
                guard let object = monitor.object, let observer = observer else {
                    
                    return
                }
                willChangeObject(observer: observer, monitor: monitor, object: object)
            }
        )
        self.registerObjectNotification(
            &self.didDeleteObjectKey,
            name: ObjectMonitorDidDeleteObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor, object) -> Void in
                
                guard let observer = observer else {
                    
                    return
                }
                didDeleteObject(observer: observer, monitor: monitor, object: object)
            }
        )
        self.registerObjectNotification(
            &self.didUpdateObjectKey,
            name: ObjectMonitorDidUpdateObjectNotification,
            toObserver: observer,
            callback: { [weak self, weak observer] (monitor, object) -> Void in
                
                guard let `self` = self, let observer = observer else {
                    
                    return
                }
                
                let previousCommitedAttributes = self.lastCommittedAttributes
                let currentCommitedAttributes = object.committedValuesForKeys(nil) as! [String: NSObject]
                
                var changedKeys = Set<String>()
                for key in currentCommitedAttributes.keys {
                    
                    if previousCommitedAttributes[key] != currentCommitedAttributes[key] {
                        
                        changedKeys.insert(key)
                    }
                }
                
                self.lastCommittedAttributes = currentCommitedAttributes
                didUpdateObject(
                    observer: observer,
                    monitor: monitor,
                    object: object,
                    changedPersistentKeys: changedKeys
                )
            }
        )
    }
    
    internal func unregisterObserver(observer: AnyObject) {
        
        CoreStore.assert(
            NSThread.isMainThread(),
            "Attempted to remove an observer of type \(cs_typeName(observer)) outside the main thread."
        )
        
        let nilValue: AnyObject? = nil
        cs_setAssociatedRetainedObject(nilValue, forKey: &self.willChangeObjectKey, inObject: observer)
        cs_setAssociatedRetainedObject(nilValue, forKey: &self.didDeleteObjectKey, inObject: observer)
        cs_setAssociatedRetainedObject(nilValue, forKey: &self.didUpdateObjectKey, inObject: observer)
    }
    
    internal func upcast() -> ObjectMonitor<NSManagedObject> {
        
        return unsafeBitCast(self, ObjectMonitor<NSManagedObject>.self)
    }
    
    deinit {
        
        self.fetchedResultsControllerDelegate.fetchedResultsController = nil
    }
    
    
    // MARK: Private
    
    private let fetchedResultsController: CoreStoreFetchedResultsController
    private let fetchedResultsControllerDelegate: FetchedResultsControllerDelegate
    private var lastCommittedAttributes = [String: NSObject]()
    
    private var willChangeObjectKey: Void?
    private var didDeleteObjectKey: Void?
    private var didUpdateObjectKey: Void?
    
    private init(context: NSManagedObjectContext, object: T) {
        
        let fetchRequest = CoreStoreFetchRequest()
        fetchRequest.entity = object.entity
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectResultType
        fetchRequest.sortDescriptors = []
        fetchRequest.includesPendingChanges = false
        fetchRequest.shouldRefreshRefetchedObjects = true
        
        let objectID = object.objectID
        let fetchedResultsController = CoreStoreFetchedResultsController(
            context: context,
            fetchRequest: fetchRequest,
            applyFetchClauses: Where("SELF", isEqualTo: objectID).applyToFetchRequest
        )
        
        let fetchedResultsControllerDelegate = FetchedResultsControllerDelegate()
        
        self.fetchedResultsController = fetchedResultsController
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
        
        fetchedResultsControllerDelegate.handler = self
        fetchedResultsControllerDelegate.fetchedResultsController = fetchedResultsController
        try! fetchedResultsController.performFetchFromSpecifiedStores()
        
        self.lastCommittedAttributes = (self.object?.committedValuesForKeys(nil) as? [String: NSObject]) ?? [:]
    }
    
    private func registerChangeNotification(notificationKey: UnsafePointer<Void>, name: String, toObserver observer: AnyObject, callback: (monitor: ObjectMonitor<T>) -> Void) {
        
        cs_setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: name,
                object: self,
                closure: { [weak self] (note) -> Void in
                    
                    guard let `self` = self else {
                        
                        return
                    }
                    callback(monitor: self)
                }
            ),
            forKey: notificationKey,
            inObject: observer
        )
    }
    
    private func registerObjectNotification(notificationKey: UnsafePointer<Void>, name: String, toObserver observer: AnyObject, callback: (monitor: ObjectMonitor<T>, object: T) -> Void) {
        
        cs_setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: name,
                object: self,
                closure: { [weak self] (note) -> Void in
                    
                    guard let `self` = self,
                        let userInfo = note.userInfo,
                        let object = userInfo[UserInfoKeyObject] as? T else {
                            
                            return
                    }
                    callback(monitor: self, object: object)
                }
            ),
            forKey: notificationKey,
            inObject: observer
        )
    }
}


// MARK: - ObjectMonitor: Equatable

public func == <T: NSManagedObject>(lhs: ObjectMonitor<T>, rhs: ObjectMonitor<T>) -> Bool {
    
    return lhs === rhs
}

public func ~= <T: NSManagedObject>(lhs: ObjectMonitor<T>, rhs: ObjectMonitor<T>) -> Bool {
    
    return lhs === rhs
}

extension ObjectMonitor: Equatable { }


// MARK: - ObjectMonitor: FetchedResultsControllerHandler

extension ObjectMonitor: FetchedResultsControllerHandler {
    
    // MARK: FetchedResultsControllerHandler
    
    internal func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            ObjectMonitorWillChangeObjectNotification,
            object: self
        )
    }
    
    internal func controllerDidChangeContent(controller: NSFetchedResultsController) { }
    
    internal func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Delete:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ObjectMonitorDidDeleteObjectNotification,
                object: self,
                userInfo: [UserInfoKeyObject: anObject]
            )
            
        case .Update:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ObjectMonitorDidUpdateObjectNotification,
                object: self,
                userInfo: [UserInfoKeyObject: anObject]
            )
            
        default:
            break
        }
    }
    
    internal func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) { }
    
    internal func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String?) -> String? {
        
        return sectionName
    }
}


private let ObjectMonitorWillChangeObjectNotification = "ObjectMonitorWillChangeObjectNotification"
private let ObjectMonitorDidDeleteObjectNotification = "ObjectMonitorDidDeleteObjectNotification"
private let ObjectMonitorDidUpdateObjectNotification = "ObjectMonitorDidUpdateObjectNotification"

private let UserInfoKeyObject = "UserInfoKeyObject"

#endif
