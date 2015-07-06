//
//  ListMonitor.swift
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


// MARK: - ListMonitor

/**
The `ListMonitor` monitors changes to a list of `NSManagedObject` instances. Observers that implement the `ListObserver` protocol may then register themselves to the `ListMonitor`'s `addObserver(_:)` method:

    let monitor = CoreStore.monitorList(
        From(MyPersonEntity),
        Where("title", isEqualTo: "Engineer"),
        OrderBy(.Ascending("lastName"))
    )
    monitor.addObserver(self)

The `ListMonitor` instance needs to be held on (retained) for as long as the list needs to be observed.
Observers registered via `addObserver(_:)` are not retained. `ListMonitor` only keeps a `weak` reference to all observers, thus keeping itself free from retain-cycles.

Lists created with `monitorList(...)` keep a single-section list of objects, where each object can be accessed by index:

    let firstPerson: MyPersonEntity = monitor[0]

Accessing the list with an index above the valid range will throw an exception.

Creating a sectioned-list is also possible with the `monitorSectionedList(...)` method:

    let monitor = CoreStore.monitorSectionedList(
        From(MyPersonEntity),
        SectionBy("age") { "Age \($0)" },
        Where("title", isEqualTo: "Engineer"),
        OrderBy(.Ascending("lastName"))
    )
    monitor.addObserver(self)

Objects from `ListMonitor`s created this way can be accessed either by an `NSIndexPath` or a tuple:

    let indexPath = NSIndexPath(forItem: 3, inSection: 2)
    let person1 = monitor[indexPath]
    let person2 = monitor[2, 3]

In the example above, both `person1` and `person2` will contain the object at section=2, index=3.
*/
public final class ListMonitor<T: NSManagedObject> {
    
    // MARK: Public
    
    /**
    Accesses the object at the given index within the first section. This subscript indexer is typically used for `ListMonitor`s created with `addObserver(_:)`.
    
    - parameter index: the index of the object. Using an index above the valid range will throw an exception.
    */
    public subscript(index: Int) -> T {
        
        return self[0, index]
    }
    
    /**
    Accesses the object at the given `sectionIndex` and `itemIndex`. This subscript indexer is typically used for `ListMonitor`s created with `monitorSectionedList(_:)`.
    
    - parameter sectionIndex: the section index for the object. Using a `sectionIndex` with an invalid range will throw an exception.
    - parameter itemIndex: the index for the object within the section. Using an `itemIndex` with an invalid range will throw an exception.
    */
    public subscript(sectionIndex: Int, itemIndex: Int) -> T {
        
        return self[NSIndexPath(forItem: itemIndex, inSection: sectionIndex)]
    }
    
    /**
    Accesses the object at the given `NSIndexPath`. This subscript indexer is typically used for `ListMonitor`s created with `monitorSectionedList(_:)`.
    
    - parameter indexPath: the `NSIndexPath` for the object. Using an `indexPath` with an invalid range will throw an exception.
    */
    public subscript(indexPath: NSIndexPath) -> T {
        
        return self.fetchedResultsController.objectAtIndexPath(indexPath) as! T
    }
    
    /**
    Returns the number of sections
    */
    public func numberOfSections() -> Int {
        
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    /**
    Returns the number of objects in the specified section
    
    - parameter section: the section index
    */
    public func numberOfObjectsInSection(section: Int) -> Int {
        
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    /**
    Returns the `NSFetchedResultsSectionInfo` for the specified section
    
    - parameter section: the section index
    */
    public func sectionInfoAtIndex(section: Int) -> NSFetchedResultsSectionInfo {
        
        return self.fetchedResultsController.sections![section]
    }
    
    /**
    Registers a `ListObserver` to be notified when changes to the receiver's list occur.
    
    To prevent retain-cycles, `ListMonitor` only keeps `weak` references to its observers.
    
    For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
    
    Calling `addObserver(_:)` multiple times on the same observer is safe, as `ListMonitor` unregisters previous notifications to the observer before re-registering them.
    
    - parameter observer: a `ListObserver` to send change notifications to
    */
    public func addObserver<U: ListObserver where U.EntityType == T>(observer: U) {
        
        CoreStore.assert(
            NSThread.isMainThread(),
            "Attempted to add an observer of type \(typeName(observer)) outside the main thread."
        )
        
        self.removeObserver(observer)
        
        self.registerChangeNotification(
            &NotificationKey.willChangeList,
            name: ListMonitorWillChangeListNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitorWillChange(monitor)
                }
            }
        )
        self.registerChangeNotification(
            &NotificationKey.didChangeList,
            name: ListMonitorDidChangeListNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitorDidChange(monitor)
                }
            }
        )
    }
    
    /**
    Registers a `ListObjectObserver` to be notified when changes to the receiver's list occur.
    
    To prevent retain-cycles, `ListMonitor` only keeps `weak` references to its observers.
    
    For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
    
    Calling `addObserver(_:)` multiple times on the same observer is safe, as `ListMonitor` unregisters previous notifications to the observer before re-registering them.
    
    - parameter observer: a `ListObjectObserver` to send change notifications to
    */
    public func addObserver<U: ListObjectObserver where U.EntityType == T>(observer: U) {
        
        CoreStore.assert(
            NSThread.isMainThread(),
            "Attempted to add an observer of type \(typeName(observer)) outside the main thread."
        )
        
        self.removeObserver(observer)
        
        self.registerChangeNotification(
            &NotificationKey.willChangeList,
            name: ListMonitorWillChangeListNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitorWillChange(monitor)
                }
            }
        )
        self.registerChangeNotification(
            &NotificationKey.didChangeList,
            name: ListMonitorDidChangeListNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitorDidChange(monitor)
                }
            }
        )
        
        self.registerObjectNotification(
            &NotificationKey.didInsertObject,
            name: ListMonitorDidInsertObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitor(
                        monitor,
                        didInsertObject: object,
                        toIndexPath: newIndexPath!
                    )
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didDeleteObject,
            name: ListMonitorDidDeleteObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitor(
                        monitor,
                        didDeleteObject: object,
                        fromIndexPath: indexPath!
                    )
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didUpdateObject,
            name: ListMonitorDidUpdateObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitor(
                        monitor,
                        didUpdateObject: object,
                        atIndexPath: indexPath!
                    )
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didMoveObject,
            name: ListMonitorDidMoveObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitor(
                        monitor,
                        didMoveObject: object,
                        fromIndexPath: indexPath!,
                        toIndexPath: newIndexPath!
                    )
                }
            }
        )
    }
    
    /**
    Registers a `ListSectionObserver` to be notified when changes to the receiver's list occur.
    
    To prevent retain-cycles, `ListMonitor` only keeps `weak` references to its observers.
    
    For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
    
    Calling `addObserver(_:)` multiple times on the same observer is safe, as `ListMonitor` unregisters previous notifications to the observer before re-registering them.
    
    - parameter observer: a `ListSectionObserver` to send change notifications to
    */
    public func addObserver<U: ListSectionObserver where U.EntityType == T>(observer: U) {
        
        CoreStore.assert(
            NSThread.isMainThread(),
            "Attempted to add an observer of type \(typeName(observer)) outside the main thread."
        )
        
        self.removeObserver(observer)
        
        self.registerChangeNotification(
            &NotificationKey.willChangeList,
            name: ListMonitorWillChangeListNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitorWillChange(monitor)
                }
            }
        )
        self.registerChangeNotification(
            &NotificationKey.didChangeList,
            name: ListMonitorDidChangeListNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitorDidChange(monitor)
                }
            }
        )
        
        self.registerObjectNotification(
            &NotificationKey.didInsertObject,
            name: ListMonitorDidInsertObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitor(
                        monitor,
                        didInsertObject: object,
                        toIndexPath: newIndexPath!
                    )
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didDeleteObject,
            name: ListMonitorDidDeleteObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitor(
                        monitor,
                        didDeleteObject: object,
                        fromIndexPath: indexPath!
                    )
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didUpdateObject,
            name: ListMonitorDidUpdateObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitor(
                        monitor,
                        didUpdateObject: object,
                        atIndexPath: indexPath!
                    )
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didMoveObject,
            name: ListMonitorDidMoveObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitor(
                        monitor,
                        didMoveObject: object,
                        fromIndexPath: indexPath!,
                        toIndexPath: newIndexPath!
                    )
                }
            }
        )
        
        self.registerSectionNotification(
            &NotificationKey.didInsertSection,
            name: ListMonitorDidInsertSectionNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor, sectionInfo, sectionIndex) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitor(
                        monitor,
                        didInsertSection: sectionInfo,
                        toSectionIndex: sectionIndex
                    )
                }
            }
        )
        self.registerSectionNotification(
            &NotificationKey.didDeleteSection,
            name: ListMonitorDidDeleteSectionNotification,
            toObserver: observer,
            callback: { [weak observer] (monitor, sectionInfo, sectionIndex) -> Void in
                
                if let observer = observer {
                    
                    observer.listMonitor(
                        monitor,
                        didDeleteSection: sectionInfo,
                        fromSectionIndex: sectionIndex
                    )
                }
            }
        )
    }
    
    /**
    Unregisters a `ListObserver` from receiving notifications for changes to the receiver's list.
    
    For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
    
    - parameter observer: a `ListObserver` to unregister notifications to
    */
    public func removeObserver<U: ListObserver where U.EntityType == T>(observer: U) {
        
        CoreStore.assert(
            NSThread.isMainThread(),
            "Attempted to remove an observer of type \(typeName(observer)) outside the main thread."
        )
        
        let nilValue: AnyObject? = nil
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.willChangeList, inObject: observer)
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.didChangeList, inObject: observer)
        
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.didInsertObject, inObject: observer)
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.didDeleteObject, inObject: observer)
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.didUpdateObject, inObject: observer)
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.didMoveObject, inObject: observer)
        
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.didInsertSection, inObject: observer)
        setAssociatedRetainedObject(nilValue, forKey: &NotificationKey.didDeleteSection, inObject: observer)
    }
    
    
    // MARK: Internal
    
    internal init(dataStack: DataStack, from: From<T>, sectionBy: SectionBy?, fetchClauses: [FetchClause]) {
        
        let context = dataStack.mainContext
        
        let fetchRequest = NSFetchRequest()
        from.applyToFetchRequest(fetchRequest, context: context)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectResultType
        
        for clause in fetchClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: sectionBy?.sectionKeyPath,
            cacheName: nil
        )
        
        let fetchedResultsControllerDelegate = FetchedResultsControllerDelegate()
        
        self.fetchedResultsController = fetchedResultsController
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
        self.parentStack = dataStack
        
        if let sectionIndexTransformer = sectionBy?.sectionIndexTransformer {
            
            self.sectionIndexTransformer = sectionIndexTransformer
        }
        else {
            
            self.sectionIndexTransformer = { $0 }
        }
        
        
        fetchedResultsControllerDelegate.handler = self
        fetchedResultsControllerDelegate.fetchedResultsController = fetchedResultsController
        
        do {
            
            try fetchedResultsController.performFetch()
        }
        catch {
            
            CoreStore.handleError(
                error as NSError,
                "Failed to perform fetch on \(typeName(NSFetchedResultsController))."
            )
        }
    }
    
    
    // MARK: Private
    
    private let fetchedResultsController: NSFetchedResultsController
    private let fetchedResultsControllerDelegate: FetchedResultsControllerDelegate
    private let sectionIndexTransformer: (sectionName: KeyPath?) -> String?
    private weak var parentStack: DataStack?
    
    private func registerChangeNotification(notificationKey: UnsafePointer<Void>, name: String, toObserver observer: AnyObject, callback: (monitor: ListMonitor<T>) -> Void) {
        
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
    
    private func registerObjectNotification(notificationKey: UnsafePointer<Void>, name: String, toObserver observer: AnyObject, callback: (monitor: ListMonitor<T>, object: T, indexPath: NSIndexPath?, newIndexPath: NSIndexPath?) -> Void) {
        
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
                                object: object,
                                indexPath: userInfo[UserInfoKeyIndexPath] as? NSIndexPath,
                                newIndexPath: userInfo[UserInfoKeyNewIndexPath] as? NSIndexPath
                            )
                    }
                }
            ),
            forKey: notificationKey,
            inObject: observer
        )
    }
    
    private func registerSectionNotification(notificationKey: UnsafePointer<Void>, name: String, toObserver observer: AnyObject, callback: (monitor: ListMonitor<T>, sectionInfo: NSFetchedResultsSectionInfo, sectionIndex: Int) -> Void) {
        
        setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: name,
                object: self,
                closure: { [weak self] (note) -> Void in
                    
                    if let strongSelf = self,
                        let userInfo = note.userInfo,
                        let sectionInfo = userInfo[UserInfoKeySectionInfo] as? NSFetchedResultsSectionInfo,
                        let sectionIndex = (userInfo[UserInfoKeySectionIndex] as? NSNumber)?.integerValue {
                            
                            callback(
                                monitor: strongSelf,
                                sectionInfo: sectionInfo,
                                sectionIndex: sectionIndex
                            )
                    }
                }
            ),
            forKey: notificationKey,
            inObject: observer
        )
    }
}


// MARK: - ListMonitor: FetchedResultsControllerHandler

extension ListMonitor: FetchedResultsControllerHandler {
    
    // MARK: FetchedResultsControllerHandler
    
    private func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Insert:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ListMonitorDidInsertObjectNotification,
                object: self,
                userInfo: [
                    UserInfoKeyObject: anObject,
                    UserInfoKeyNewIndexPath: newIndexPath!
                ]
            )
            
        case .Delete:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ListMonitorDidDeleteObjectNotification,
                object: self,
                userInfo: [
                    UserInfoKeyObject: anObject,
                    UserInfoKeyIndexPath: indexPath!
                ]
            )
            
        case .Update:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ListMonitorDidUpdateObjectNotification,
                object: self,
                userInfo: [
                    UserInfoKeyObject: anObject,
                    UserInfoKeyIndexPath: indexPath!
                ]
            )
            
        case .Move:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ListMonitorDidMoveObjectNotification,
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
        
        switch type {
            
        case .Insert:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ListMonitorDidInsertSectionNotification,
                object: self,
                userInfo: [
                    UserInfoKeySectionInfo: sectionInfo,
                    UserInfoKeySectionIndex: NSNumber(integer: sectionIndex)
                ]
            )
            
        case .Delete:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ListMonitorDidDeleteSectionNotification,
                object: self,
                userInfo: [
                    UserInfoKeySectionInfo: sectionInfo,
                    UserInfoKeySectionIndex: NSNumber(integer: sectionIndex)
                ]
            )
            
        default:
            break
        }
    }
    
    private func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            ListMonitorWillChangeListNotification,
            object: self
        )
    }
    
    private func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            ListMonitorDidChangeListNotification,
            object: self
        )
    }
    
    private func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String?) -> String? {
        
        return self.sectionIndexTransformer(sectionName: sectionName)
    }
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

private final class FetchedResultsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: NSFetchedResultsControllerDelegate
    
    @objc dynamic func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        self.handler?.controllerWillChangeContent(controller)
    }
    
    @objc dynamic func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        self.handler?.controllerDidChangeContent(controller)
    }
    
    @objc dynamic func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        self.handler?.controller(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
    }
    
    @objc dynamic func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        self.handler?.controller(controller, didChangeSection: sectionInfo, atIndex: sectionIndex, forChangeType: type)
    }
    
    @objc dynamic func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String? {
        
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


private let ListMonitorWillChangeListNotification = "ListMonitorWillChangeListNotification"
private let ListMonitorDidChangeListNotification = "ListMonitorDidChangeListNotification"

private let ListMonitorDidInsertObjectNotification = "ListMonitorDidInsertObjectNotification"
private let ListMonitorDidDeleteObjectNotification = "ListMonitorDidDeleteObjectNotification"
private let ListMonitorDidUpdateObjectNotification = "ListMonitorDidUpdateObjectNotification"
private let ListMonitorDidMoveObjectNotification = "ListMonitorDidMoveObjectNotification"

private let ListMonitorDidInsertSectionNotification = "ListMonitorDidInsertSectionNotification"
private let ListMonitorDidDeleteSectionNotification = "ListMonitorDidDeleteSectionNotification"

private let UserInfoKeyObject = "UserInfoKeyObject"
private let UserInfoKeyIndexPath = "UserInfoKeyIndexPath"
private let UserInfoKeyNewIndexPath = "UserInfoKeyNewIndexPath"

private let UserInfoKeySectionInfo = "UserInfoKeySectionInfo"
private let UserInfoKeySectionIndex = "UserInfoKeySectionIndex"

private struct NotificationKey {
    
    static var willChangeList: Void?
    static var didChangeList: Void?
    
    static var didInsertObject: Void?
    static var didDeleteObject: Void?
    static var didUpdateObject: Void?
    static var didMoveObject: Void?
    
    static var didInsertSection: Void?
    static var didDeleteSection: Void?
}
