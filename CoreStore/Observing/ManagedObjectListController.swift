//
//  ManagedObjectListController.swift
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


// MARK: - SectionedBy

/**
The `SectionedBy` clause indicates the key path to use to group the `ManagedObjectListController` objects into sections. An optional closure can also be provided to transform the value into an appropriate section name:

    let listController = CoreStore.observeSectionedList(
        From(MyPersonEntity),
        SectionedBy("age") { "Age \($0)" },
        OrderBy(.Ascending("lastName"))
    )
*/
public struct SectionedBy {
    
    // MARK: Public
    
    /**
    Initializes a `SectionedBy` clause with the key path to use to group `ManagedObjectListController` objects into sections
    
    :param: sectionKeyPath the key path to use to group the objects into sections
    */
    public init(_ sectionKeyPath: KeyPath) {
        
        self.init(sectionKeyPath, { $0 })
    }
    
    /**
    Initializes a `SectionedBy` clause with the key path to use to group `ManagedObjectListController` objects into sections, and a closure to transform the value for the key path to an appropriate section name
    
    :param: sectionKeyPath the key path to use to group the objects into sections
    :param: sectionIndexTransformer a closure to transform the value for the key path to an appropriate section name
    */
    public init(_ sectionKeyPath: KeyPath, _ sectionIndexTransformer: (sectionName: String?) -> String?) {
        
        self.sectionKeyPath = sectionKeyPath
        self.sectionIndexTransformer = sectionIndexTransformer
    }
    
    
    // MARK: Internal
    
    internal let sectionKeyPath: KeyPath
    internal let sectionIndexTransformer: (sectionName: KeyPath?) -> String?
}


// MARK: - ManagedObjectListController

/**
The `ManagedObjectListController` monitors changes to a list of `NSManagedObject` instances. Observers that implement the `ManagedObjectListChangeObserver` protocol may then register themselves to the `ManagedObjectListController`'s `addObserver(_:)` method:

    let listController = CoreStore.observeObjectList(
        From(MyPersonEntity),
        Where("title", isEqualTo: "Engineer"),
        OrderBy(.Ascending("lastName"))
    )
    listController.addObserver(self)

The `ManagedObjectListController` instance needs to be held on (retained) for as long as the list needs to be observed.
Observers registered via `addObserver(_:)` are not retained. `ManagedObjectListController` only keeps a `weak` reference to all observers, thus keeping itself free from retain-cycles.

Lists created with `observeObjectList(...)` keep a single-section list of objects, where each object can be accessed by index:

    let firstPerson: MyPersonEntity = listController[0]

Accessing the list with an index above the valid range will throw an exception.

Creating a sectioned-list is also possible with the `observeSectionedList(...)` method:

    let listController = CoreStore.observeSectionedList(
        From(MyPersonEntity),
        SectionedBy("age") { "Age \($0)" },
        Where("title", isEqualTo: "Engineer"),
        OrderBy(.Ascending("lastName"))
    )
    listController.addObserver(self)

Objects from `ManagedObjectListController`'s created this way can be accessed either by an `NSIndexPath` or a tuple:

    let indexPath = NSIndexPath(forItem: 3, inSection: 2)
    let person1 = listController[indexPath]
    let person2 = listController[2, 3]

In the example above, both `person1` and `person2` will contain the object at section=2, index=3.
*/
public final class ManagedObjectListController<T: NSManagedObject> {
    
    // MARK: Public
    
    /**
    Accesses the object at the given index within the first section. This subscript indexer is typically used for `ManagedObjectListController`'s created with `addObserver(_:)`.
    
    :param: index the index of the object. Using an index above the valid range will throw an exception.
    */
    public subscript(index: Int) -> T {
        
        return self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as! T
    }
    
    /**
    Accesses the object at the given `NSIndexPath`. This subscript indexer is typically used for `ManagedObjectListController`'s created with `observeSectionedList(_:)`.
    
    :param: indexPath the `NSIndexPath` for the object. Using an `indexPath` with an invalid range will throw an exception.
    */
    public subscript(indexPath: NSIndexPath) -> T {
        
        return self.fetchedResultsController.objectAtIndexPath(indexPath) as! T
    }
    
    /**
    Accesses the object at the given `sectionIndex` and `itemIndex`. This subscript indexer is typically used for `ManagedObjectListController`'s created with `observeSectionedList(_:)`.
    
    :param: sectionIndex the section index for the object. Using a `sectionIndex` with an invalid range will throw an exception.
    :param: itemIndex the index for the object within the section. Using an `itemIndex` with an invalid range will throw an exception.
    */
    public subscript(sectionIndex: Int, itemIndex: Int) -> T {
        
        return self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forItem: itemIndex, inSection: sectionIndex)) as! T
    }
    
    /**
    Returns the number of sections
    */
    public func numberOfSections() -> Int {
        
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    /**
    Returns the number of objects in the specified section
    
    :param: section the section index
    */
    public func numberOfObjectsInSection(section: Int) -> Int {
        
        return (self.fetchedResultsController.sections?[section] as? NSFetchedResultsSectionInfo)?.numberOfObjects ?? 0
    }
    
    /**
    Returns the `NSFetchedResultsSectionInfo` for the specified section
    
    :param: section the section index
    */
    public func sectionInfoAtIndex(section: Int) -> NSFetchedResultsSectionInfo {
        
        return self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
    }
    
    /**
    Registers a `ManagedObjectListChangeObserver` to be notified when changes to the receiver's list occur.
    
    To prevent retain-cycles, `ManagedObjectListController` only keeps `weak` references to its observers.
    
    For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
    
    Calling `addObserver(_:)` multiple times on the same observer is safe, as `ManagedObjectListController` unregisters previous notifications to the observer before re-registering them.
    
    :param: observer a `ManagedObjectListChangeObserver` to send change notifications to
    */
    public func addObserver<U: ManagedObjectListChangeObserver where U.EntityType == T>(observer: U) {
        
        CoreStore.assert(NSThread.isMainThread(), "Attempted to add an observer of type \(typeName(observer)) outside the main thread.")
        
        self.removeObserver(observer)
        
        self.registerChangeNotification(
            &NotificationKey.willChangeList,
            name: ManagedObjectListControllerWillChangeListNotification,
            toObserver: observer,
            callback: { [weak observer] (listController) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectListWillChange(listController)
                }
            }
        )
        self.registerChangeNotification(
            &NotificationKey.didChangeList,
            name: ManagedObjectListControllerDidChangeListNotification,
            toObserver: observer,
            callback: { [weak observer] (listController) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectListDidChange(listController)
                }
            }
        )
    }
    
    /**
    Registers a `ManagedObjectListObjectObserver` to be notified when changes to the receiver's list occur.
    
    To prevent retain-cycles, `ManagedObjectListController` only keeps `weak` references to its observers.
    
    For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
    
    Calling `addObserver(_:)` multiple times on the same observer is safe, as `ManagedObjectListController` unregisters previous notifications to the observer before re-registering them.
    
    :param: observer a `ManagedObjectListObjectObserver` to send change notifications to
    */
    public func addObserver<U: ManagedObjectListObjectObserver where U.EntityType == T>(observer: U) {
        
        CoreStore.assert(NSThread.isMainThread(), "Attempted to add an observer of type \(typeName(observer)) outside the main thread.")
        
        self.removeObserver(observer)
        
        self.registerChangeNotification(
            &NotificationKey.willChangeList,
            name: ManagedObjectListControllerWillChangeListNotification,
            toObserver: observer,
            callback: { [weak observer] (listController) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectListWillChange(listController)
                }
            }
        )
        self.registerChangeNotification(
            &NotificationKey.didChangeList,
            name: ManagedObjectListControllerDidChangeListNotification,
            toObserver: observer,
            callback: { [weak observer] (listController) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectListDidChange(listController)
                }
            }
        )
        
        self.registerObjectNotification(
            &NotificationKey.didInsertObject,
            name: ManagedObjectListControllerDidInsertObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (listController, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectList(
                        listController,
                        didInsertObject: object,
                        toIndexPath: newIndexPath!
                    )
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didDeleteObject,
            name: ManagedObjectListControllerDidDeleteObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (listController, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectList(
                        listController,
                        didDeleteObject: object,
                        fromIndexPath: indexPath!
                    )
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didUpdateObject,
            name: ManagedObjectListControllerDidUpdateObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (listController, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectList(
                        listController,
                        didUpdateObject: object,
                        atIndexPath: indexPath!
                    )
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didMoveObject,
            name: ManagedObjectListControllerDidMoveObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (listController, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectList(
                        listController,
                        didMoveObject: object,
                        fromIndexPath: indexPath!,
                        toIndexPath: newIndexPath!
                    )
                }
            }
        )
    }
    
    /**
    Registers a `ManagedObjectListSectionObserver` to be notified when changes to the receiver's list occur.
    
    To prevent retain-cycles, `ManagedObjectListController` only keeps `weak` references to its observers.
    
    For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
    
    Calling `addObserver(_:)` multiple times on the same observer is safe, as `ManagedObjectListController` unregisters previous notifications to the observer before re-registering them.
    
    :param: observer a `ManagedObjectListSectionObserver` to send change notifications to
    */
    public func addObserver<U: ManagedObjectListSectionObserver where U.EntityType == T>(observer: U) {
        
        CoreStore.assert(NSThread.isMainThread(), "Attempted to add an observer of type \(typeName(observer)) outside the main thread.")
        
        self.removeObserver(observer)
        
        self.registerChangeNotification(
            &NotificationKey.willChangeList,
            name: ManagedObjectListControllerWillChangeListNotification,
            toObserver: observer,
            callback: { [weak observer] (listController) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectListWillChange(listController)
                }
            }
        )
        self.registerChangeNotification(
            &NotificationKey.didChangeList,
            name: ManagedObjectListControllerDidChangeListNotification,
            toObserver: observer,
            callback: { [weak observer] (listController) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectListDidChange(listController)
                }
            }
        )
        
        self.registerObjectNotification(
            &NotificationKey.didInsertObject,
            name: ManagedObjectListControllerDidInsertObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (listController, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectList(
                        listController,
                        didInsertObject: object,
                        toIndexPath: newIndexPath!
                    )
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didDeleteObject,
            name: ManagedObjectListControllerDidDeleteObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (listController, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectList(
                        listController,
                        didDeleteObject: object,
                        fromIndexPath: indexPath!
                    )
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didUpdateObject,
            name: ManagedObjectListControllerDidUpdateObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (listController, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectList(
                        listController,
                        didUpdateObject: object,
                        atIndexPath: indexPath!
                    )
                }
            }
        )
        self.registerObjectNotification(
            &NotificationKey.didMoveObject,
            name: ManagedObjectListControllerDidMoveObjectNotification,
            toObserver: observer,
            callback: { [weak observer] (listController, object, indexPath, newIndexPath) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectList(
                        listController,
                        didMoveObject: object,
                        fromIndexPath: indexPath!,
                        toIndexPath: newIndexPath!
                    )
                }
            }
        )
        
        self.registerSectionNotification(
            &NotificationKey.didInsertSection,
            name: ManagedObjectListControllerDidInsertSectionNotification,
            toObserver: observer,
            callback: { [weak observer] (listController, sectionInfo, sectionIndex) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectList(
                        listController,
                        didInsertSection: sectionInfo,
                        toSectionIndex: sectionIndex
                    )
                }
            }
        )
        self.registerSectionNotification(
            &NotificationKey.didDeleteSection,
            name: ManagedObjectListControllerDidDeleteSectionNotification,
            toObserver: observer,
            callback: { [weak observer] (listController, sectionInfo, sectionIndex) -> Void in
                
                if let observer = observer {
                    
                    observer.managedObjectList(
                        listController,
                        didDeleteSection: sectionInfo,
                        fromSectionIndex: sectionIndex
                    )
                }
            }
        )
    }
    
    /**
    Unregisters a `ManagedObjectListChangeObserver` from receiving notifications for changes to the receiver's list.
    
    For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
    
    :param: observer a `ManagedObjectListChangeObserver` to unregister notifications to
    */
    public func removeObserver<U: ManagedObjectListChangeObserver where U.EntityType == T>(observer: U) {
        
        CoreStore.assert(NSThread.isMainThread(), "Attempted to remove an observer of type \(typeName(observer)) outside the main thread.")
        
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
    
    internal init(dataStack: DataStack, from: From<T>, sectionedBy: SectionedBy?, fetchClauses: [FetchClause]) {
        
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
            sectionNameKeyPath: sectionedBy?.sectionKeyPath,
            cacheName: nil
        )
        
        let fetchedResultsControllerDelegate = FetchedResultsControllerDelegate()
        
        self.fetchedResultsController = fetchedResultsController
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
        self.parentStack = dataStack
        
        if let sectionIndexTransformer = sectionedBy?.sectionIndexTransformer {
            
            self.sectionIndexTransformer = sectionIndexTransformer
        }
        else {
            
            self.sectionIndexTransformer = { $0 }
        }
        
        
        fetchedResultsControllerDelegate.handler = self
        fetchedResultsControllerDelegate.fetchedResultsController = fetchedResultsController
        
        var error: NSError?
        if !fetchedResultsController.performFetch(&error) {
            
            CoreStore.handleError(
                error ?? NSError(coreStoreErrorCode: .UnknownError),
                "Failed to perform fetch on <\(NSFetchedResultsController.self)>.")
        }
    }
    
    
    // MARK: Private
    
    private let fetchedResultsController: NSFetchedResultsController
    private let fetchedResultsControllerDelegate: FetchedResultsControllerDelegate
    private let sectionIndexTransformer: (sectionName: KeyPath?) -> String?
    private weak var parentStack: DataStack?
    
    private func registerChangeNotification(notificationKey: UnsafePointer<Void>, name: String, toObserver observer: AnyObject, callback: (listController: ManagedObjectListController<T>) -> Void) {
        
        setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: name,
                object: self,
                closure: { [weak self] (note) -> Void in
                    
                    if let strongSelf = self {
                        
                        callback(listController: strongSelf)
                    }
                }
            ),
            forKey: notificationKey,
            inObject: observer
        )
    }
    
    private func registerObjectNotification(notificationKey: UnsafePointer<Void>, name: String, toObserver observer: AnyObject, callback: (listController: ManagedObjectListController<T>, object: T, indexPath: NSIndexPath?, newIndexPath: NSIndexPath?) -> Void) {
        
        setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: name,
                object: self,
                closure: { [weak self] (note) -> Void in
                    
                    if let strongSelf = self,
                        let userInfo = note.userInfo,
                        let object = userInfo[UserInfoKeyObject] as? T {
                            
                            callback(
                                listController: strongSelf,
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
    
    private func registerSectionNotification(notificationKey: UnsafePointer<Void>, name: String, toObserver observer: AnyObject, callback: (listController: ManagedObjectListController<T>, sectionInfo: NSFetchedResultsSectionInfo, sectionIndex: Int) -> Void) {
        
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
                                listController: strongSelf,
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


// MARK: - ManagedObjectListController: FetchedResultsControllerHandler

extension ManagedObjectListController: FetchedResultsControllerHandler {
    
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
        
        switch type {
            
        case .Insert:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ManagedObjectListControllerDidInsertSectionNotification,
                object: self,
                userInfo: [
                    UserInfoKeySectionInfo: sectionInfo,
                    UserInfoKeySectionIndex: NSNumber(integer: sectionIndex)
                ]
            )
            
        case .Delete:
            NSNotificationCenter.defaultCenter().postNotificationName(
                ManagedObjectListControllerDidDeleteSectionNotification,
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

private final class FetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate {
    
    // MARK: NSFetchedResultsControllerDelegate
    
    @objc func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        self.handler?.controllerWillChangeContent(controller)
    }
    
    @objc func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        self.handler?.controllerDidChangeContent(controller)
    }
    
    @objc func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        self.handler?.controller(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
    }
    
    @objc func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        self.handler?.controller(controller, didChangeSection: sectionInfo, atIndex: sectionIndex, forChangeType: type)
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


private let ManagedObjectListControllerWillChangeListNotification = "ManagedObjectListControllerWillChangeListNotification"
private let ManagedObjectListControllerDidChangeListNotification = "ManagedObjectListControllerDidChangeListNotification"

private let ManagedObjectListControllerDidInsertObjectNotification = "ManagedObjectListControllerDidInsertObjectNotification"
private let ManagedObjectListControllerDidDeleteObjectNotification = "ManagedObjectListControllerDidDeleteObjectNotification"
private let ManagedObjectListControllerDidUpdateObjectNotification = "ManagedObjectListControllerDidUpdateObjectNotification"
private let ManagedObjectListControllerDidMoveObjectNotification = "ManagedObjectListControllerDidMoveObjectNotification"

private let ManagedObjectListControllerDidInsertSectionNotification = "ManagedObjectListControllerDidInsertSectionNotification"
private let ManagedObjectListControllerDidDeleteSectionNotification = "ManagedObjectListControllerDidDeleteSectionNotification"

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
