//
//  ObjectMonitor.swift
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
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


// MARK: - ObjectMonitor

/**
 The `ObjectMonitor` monitors changes to a single `DynamicObject` instance. Observers that implement the `ObjectObserver` protocol may then register themselves to the `ObjectMonitor`'s `addObserver(_:)` method:
 ```
 let monitor = CoreStore.monitorObject(object)
 monitor.addObserver(self)
 ```
 The created `ObjectMonitor` instance needs to be held on (retained) for as long as the object needs to be observed.
 
 Observers registered via `addObserver(_:)` are not retained. `ObjectMonitor` only keeps a `weak` reference to all observers, thus keeping itself free from retain-cycles.
 */
@available(macOS 10.12, *)
public final class ObjectMonitor<D: DynamicObject>: ObjectRepresentation, Equatable {
    
    /**
     Returns the `DynamicObject` instance being observed, or `nil` if the object was already deleted.
     */
    public var object: ObjectType? {
        
        return self.fetchedResultsController
            .fetchedObjects?
            .first
            .flatMap({ ObjectType.cs_fromRaw(object: $0) })
    }
    
    /**
     Returns `true` if the `DynamicObject` instance being observed still exists, or `false` if the object was already deleted.
     */
    public var isObjectDeleted: Bool {
        
        return self.object?.cs_toRaw().managedObjectContext == nil
    }
    
    /**
     Registers an `ObjectObserver` to be notified when changes to the receiver's `object` are made.
     
     To prevent retain-cycles, `ObjectMonitor` only keeps `weak` references to its observers.
     
     For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
     
     Calling `addObserver(_:)` multiple times on the same observer is safe, as `ObjectMonitor` unregisters previous notifications to the observer before re-registering them.
     
     - parameter observer: an `ObjectObserver` to send change notifications to
     */
    public func addObserver<U: ObjectObserver>(_ observer: U) where U.ObjectEntityType == ObjectType {
        
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
    public func removeObserver<U: ObjectObserver>(_ observer: U) where U.ObjectEntityType == ObjectType {
        
        self.unregisterObserver(observer)
    }
    
    
    // MARK: Public (3rd Party Utilities)
    
    /**
     Allow external libraries to store custom data in the `ObjectMonitor`. App code should rarely have a need for this.
     ```
     enum Static {
         static var myDataKey: Void?
     }
     monitor.userInfo[&Static.myDataKey] = myObject
     ```
     - Important: Do not use this method to store thread-sensitive data.
     */
    public let userInfo = UserInfo()
    
    
    // MARK: ObjectRepresentation
    
    public func objectID() -> D.ObjectID {
        
        return self.id
    }
    
    public func asLiveObject(in dataStack: DataStack) -> LiveObject<D>? {
        
        let context = dataStack.unsafeContext()
        return .init(objectID: self.id, context: context)
    }
    
    public func asEditable(in transaction: BaseDataTransaction) -> D? {
        
        return self.context.fetchExisting(self.id)
    }
    
    public func asSnapshot(in dataStack: DataStack) -> ObjectSnapshot<D>? {
        
        let context = dataStack.unsafeContext()
        return .init(id: self.id, context: context)
    }
    
    public func asSnapshot(in transaction: BaseDataTransaction) -> ObjectSnapshot<D>? {
        
        let context = transaction.unsafeContext()
        return .init(id: self.id, context: context)
    }
    
    public func asObjectMonitor(in dataStack: DataStack) -> ObjectMonitor<D>? {
        
        let context = dataStack.unsafeContext()
        if self.context == context {
            
            return self
        }
        return .init(objectID: self.id, context: dataStack.unsafeContext())
    }
    
    public typealias ObjectType = D
    
    public static func cs_fromRaw(object: NSManagedObject) -> Self {
        
        return self.init(
            context: object.managedObjectContext!,
            objectID: object.objectID
        )
    }
    
    public func cs_id() -> ObjectType.ObjectID {
        
        return self.objectID
    }
    
    public func cs_object() -> D? {
        
        return self.object
    }
    
    public func cs_rawObject(in context: NSManagedObjectContext) -> NSManagedObject? {
     
        return context.fetchExisting(self.objectID)
    }
    
    
    // MARK: Equatable
    
    public static func == (lhs: ObjectMonitor<ObjectType>, rhs: ObjectMonitor<ObjectType>) -> Bool {
        
        return lhs === rhs
    }
    
    public static func == <T, U>(lhs: ObjectMonitor<T>, rhs: ObjectMonitor<U>) -> Bool {
        
        return lhs.fetchedResultsController === rhs.fetchedResultsController
    }
    
    public static func ~= (lhs: ObjectMonitor<ObjectType>, rhs: ObjectMonitor<ObjectType>) -> Bool {
        
        return lhs === rhs
    }
    
    public static func ~= <T, U>(lhs: ObjectMonitor<T>, rhs: ObjectMonitor<U>) -> Bool {
        
        return lhs.fetchedResultsController === rhs.fetchedResultsController
    }
    
    
    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {

        hasher.combine(ObjectIdentifier(self))
    }
    
    
    // MARK: Internal
    
    internal init(objectID: ObjectType.ObjectID, context: NSManagedObjectContext) {
        
        let fetchRequest = Internals.CoreStoreFetchRequest<NSManagedObject>()
        fetchRequest.entity = objectID.entity
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .managedObjectResultType
        fetchRequest.sortDescriptors = []
        fetchRequest.includesPendingChanges = false
        fetchRequest.shouldRefreshRefetchedObjects = true
        
        let fetchedResultsController = Internals.CoreStoreFetchedResultsController(
            context: context,
            fetchRequest: fetchRequest,
            from: From<ObjectType>([objectID.persistentStore?.configurationName]),
            applyFetchClauses: Where<ObjectType>("SELF", isEqualTo: objectID).applyToFetchRequest
        )
        
        let fetchedResultsControllerDelegate = Internals.FetchedResultsControllerDelegate()
        
        self.objectID = objectID
        self.fetchedResultsController = fetchedResultsController
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
        
        fetchedResultsControllerDelegate.handler = self
        fetchedResultsControllerDelegate.fetchedResultsController = fetchedResultsController
        try! fetchedResultsController.performFetchFromSpecifiedStores()
        
        self.lastCommittedAttributes = (self.object?.cs_toRaw().committedValues(forKeys: nil) as? [String: NSObject]) ?? [:]
    }
    
    internal func registerObserver<U: AnyObject>(_ observer: U, willChangeObject: @escaping (_ observer: U, _ monitor: ObjectMonitor<ObjectType>, _ object: ObjectType) -> Void, didDeleteObject: @escaping (_ observer: U, _ monitor: ObjectMonitor<ObjectType>, _ object: ObjectType) -> Void, didUpdateObject: @escaping (_ observer: U, _ monitor: ObjectMonitor<ObjectType>, _ object: ObjectType, _ changedPersistentKeys: Set<String>) -> Void) {
        
        Internals.assert(
            Thread.isMainThread,
            "Attempted to add an observer of type \(Internals.typeName(observer as AnyObject)) outside the main thread."
        )
        self.registerChangeNotification(
            &self.willChangeObjectKey,
            name: Notification.Name.objectMonitorWillChangeObject,
            toObserver: observer,
            callback: { [weak observer] (monitor) -> Void in
                
                guard let object = monitor.object, let observer = observer else {
                    
                    return
                }
                willChangeObject(observer, monitor, object)
            }
        )
        self.registerObjectNotification(
            &self.didDeleteObjectKey,
            name: Notification.Name.objectMonitorDidDeleteObject,
            toObserver: observer,
            callback: { [weak observer] (monitor, object) -> Void in
                
                guard let observer = observer else {
                    
                    return
                }
                didDeleteObject(observer, monitor, object)
            }
        )
        self.registerObjectNotification(
            &self.didUpdateObjectKey,
            name: Notification.Name.objectMonitorDidUpdateObject,
            toObserver: observer,
            callback: { [weak self, weak observer] (monitor, object) -> Void in
                
                guard let `self` = self, let observer = observer else {
                    
                    return
                }
                
                let previousCommitedAttributes = self.lastCommittedAttributes
                let currentCommitedAttributes = object.cs_toRaw().committedValues(forKeys: nil) as! [String: NSObject]
                
                var changedKeys = Set<String>()
                for key in currentCommitedAttributes.keys {
                    
                    if previousCommitedAttributes[key] != currentCommitedAttributes[key] {
                        
                        changedKeys.insert(key)
                    }
                }
                
                self.lastCommittedAttributes = currentCommitedAttributes
                didUpdateObject(observer, monitor, object, changedKeys)
            }
        )
    }
    
    internal func unregisterObserver(_ observer: AnyObject) {
        
        Internals.assert(
            Thread.isMainThread,
            "Attempted to remove an observer of type \(Internals.typeName(observer)) outside the main thread."
        )
        
        let nilValue: AnyObject? = nil
        Internals.setAssociatedRetainedObject(nilValue, forKey: &self.willChangeObjectKey, inObject: observer)
        Internals.setAssociatedRetainedObject(nilValue, forKey: &self.didDeleteObjectKey, inObject: observer)
        Internals.setAssociatedRetainedObject(nilValue, forKey: &self.didUpdateObjectKey, inObject: observer)
    }
    
    deinit {
        
        self.fetchedResultsControllerDelegate.fetchedResultsController = nil
    }
    
    
    // MARK: Private
    
    private let objectID: ObjectType.ObjectID
    private let fetchedResultsController: Internals.CoreStoreFetchedResultsController
    private let fetchedResultsControllerDelegate: Internals.FetchedResultsControllerDelegate
    private var lastCommittedAttributes = [String: NSObject]()
    
    private var willChangeObjectKey: Void?
    private var didDeleteObjectKey: Void?
    private var didUpdateObjectKey: Void?
    
    private func registerChangeNotification(_ notificationKey: UnsafeRawPointer, name: Notification.Name, toObserver observer: AnyObject, callback: @escaping (_ monitor: ObjectMonitor<ObjectType>) -> Void) {
        
        Internals.setAssociatedRetainedObject(
            Internals.NotificationObserver(
                notificationName: name,
                object: self,
                closure: { [weak self] _ in
                    
                    guard let `self` = self else {
                        
                        return
                    }
                    callback(self)
                }
            ),
            forKey: notificationKey,
            inObject: observer
        )
    }
    
    private func registerObjectNotification(_ notificationKey: UnsafeRawPointer, name: Notification.Name, toObserver observer: AnyObject, callback: @escaping (_ monitor: ObjectMonitor<ObjectType>, _ object: ObjectType) -> Void) {
        
        Internals.setAssociatedRetainedObject(
            Internals.NotificationObserver(
                notificationName: name,
                object: self,
                closure: { [weak self] (note) in
                    
                    guard let `self` = self,
                        let userInfo = note.userInfo,
                        let object = userInfo[String(describing: NSManagedObject.self)] as! NSManagedObject? else {
                            
                            return
                    }
                    callback(self, ObjectType.cs_fromRaw(object: object))
                }
            ),
            forKey: notificationKey,
            inObject: observer
        )
    }
}


// MARK: - ObjectMonitor: FetchedResultsControllerHandler

@available(macOS 10.12, *)
extension ObjectMonitor: FetchedResultsControllerHandler {
    
    // MARK: FetchedResultsControllerHandler
    
    internal func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        NotificationCenter.default.post(
            name: Notification.Name.objectMonitorWillChangeObject,
            object: self
        )
    }
    
    internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { }
    
    internal func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeObject anObject: Any, atIndexPath indexPath: IndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .delete:
            NotificationCenter.default.post(
                name: Notification.Name.objectMonitorDidDeleteObject,
                object: self,
                userInfo: [String(describing: NSManagedObject.self): anObject]
            )
            
        case .update,
             .move where indexPath == newIndexPath:
            NotificationCenter.default.post(
                name: Notification.Name.objectMonitorDidUpdateObject,
                object: self,
                userInfo: [String(describing: NSManagedObject.self): anObject]
            )
            
        default:
            break
        }
    }
    
    internal func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) { }
    
    internal func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String?) -> String? {
        
        return sectionName
    }
}
    
    
// MARK: - Notification.Name

@available(macOS 10.12, *)
extension Notification.Name {
    
    fileprivate static let objectMonitorWillChangeObject = Notification.Name(rawValue: "objectMonitorWillChangeObject")
    fileprivate static let objectMonitorDidDeleteObject = Notification.Name(rawValue: "objectMonitorDidDeleteObject")
    fileprivate static let objectMonitorDidUpdateObject = Notification.Name(rawValue: "objectMonitorDidUpdateObject")
}
