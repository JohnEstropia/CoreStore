//
//  ICloudStore.swift
//  CoreStore
//
//  Copyright © 2016 John Rommel Estropia
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


#if os(iOS) || os(OSX)

// MARK: - ICloudStore

/**
 A storage interface backed by an SQLite database managed by iCloud.
 */
public class ICloudStore: CloudStorage {
    
    /**
     Initializes an iCloud store interface from the given ubiquitous store information. Returns `nil` if the container could not be located or if iCloud storage is unavailable for the current user or device
     ```
     guard let storage = ICloudStore(
         ubiquitousContentName: "MyAppCloudData",
         ubiquitousContentTransactionLogsSubdirectory: "logs/config1",
         ubiquitousContainerID: "iCloud.com.mycompany.myapp.containername",
         ubiquitousPeerToken: "9614d658014f4151a95d8048fb717cf0",
         configuration: "Config1",
         cloudStorageOptions: .RecreateLocalStoreOnModelMismatch
     ) else {
         // iCloud is not available on the device
         return
     }
     CoreStore.addStorage(
         storage,
         completion: { result in
             // ...
         }
     )
     ```
     
     - parameter ubiquitousContentName: the name of the store in iCloud. This is required and should not be empty, and should not contain periods (`.`).
     - parameter ubiquitousContentTransactionLogsSubdirectory: an optional subdirectory path for the transaction logs
     - parameter ubiquitousContainerID: a container if your app has multiple ubiquity container identifiers in its entitlements
     - parameter ubiquitousPeerToken: a per-application salt to allow multiple apps on the same device to share a Core Data store integrated with iCloud
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `ubiquitousContentName` explicitly for each of them.
     - parameter mappingModelBundles: a list of `NSBundle`s from which to search mapping models for migration.
     - parameter cloudStorageOptions: When the `ICloudStore` is passed to the `DataStack`'s `addStorage()` methods, tells the `DataStack` how to setup the persistent store. Defaults to `.None`.
     */
    public required init?(ubiquitousContentName: String, ubiquitousContentTransactionLogsSubdirectory: String? = nil, ubiquitousContainerID: String? = nil, ubiquitousPeerToken: String? = nil, configuration: String? = nil, cloudStorageOptions: CloudStorageOptions = nil) {
        
        CoreStore.assert(
            !ubiquitousContentName.isEmpty,
            "The ubiquitousContentName cannot be empty."
        )
        CoreStore.assert(
            !ubiquitousContentName.containsString("."),
            "The ubiquitousContentName cannot contain periods."
        )
        CoreStore.assert(
            ubiquitousContentTransactionLogsSubdirectory?.isEmpty != true,
            "The ubiquitousContentURLRelativePath should not be empty if provided."
        )
        CoreStore.assert(
            ubiquitousPeerToken?.isEmpty != true,
            "The ubiquitousPeerToken should not be empty if provided."
        )
        
        let fileManager = NSFileManager.defaultManager()
        guard let cacheFileURL = fileManager.URLForUbiquityContainerIdentifier(ubiquitousContainerID) else {
            
            return nil
        }
        
        var storeOptions: [String: AnyObject] = [
            NSSQLitePragmasOption: ["journal_mode": "WAL"],
            NSPersistentStoreUbiquitousContentNameKey: ubiquitousContentName
        ]
        storeOptions[NSPersistentStoreUbiquitousContentURLKey] = ubiquitousContentTransactionLogsSubdirectory
        storeOptions[NSPersistentStoreUbiquitousContainerIdentifierKey] = ubiquitousContainerID
        storeOptions[NSPersistentStoreUbiquitousPeerTokenOption] = ubiquitousPeerToken
        
        self.cacheFileURL = cacheFileURL
        self.configuration = configuration
        self.cloudStorageOptions = cloudStorageOptions
        self.storeOptions = storeOptions
    }
    
    /**
     Registers an `ICloudStoreObserver` to start receive notifications from the ubiquitous store
     
     - parameter observer: the observer to start sending ubiquitous notifications to
     */
    public func addObserver<T: ICloudStoreObserver>(observer: T) {
        
        CoreStore.assert(
            NSThread.isMainThread(),
            "Attempted to add an observer of type \(cs_typeName(observer)) outside the main thread."
        )
        
        self.removeObserver(observer)
        
        self.registerNotification(
            &self.willFinishInitialImportKey,
            name: ICloudUbiquitousStoreWillFinishInitialImportNotification,
            toObserver: observer,
            callback: { (observer, storage, dataStack) in
                
                observer.iCloudStoreWillFinishUbiquitousStoreInitialImport(storage: storage, dataStack: dataStack)
            }
        )
        self.registerNotification(
            &self.didFinishInitialImportKey,
            name: ICloudUbiquitousStoreDidFinishInitialImportNotification,
            toObserver: observer,
            callback: { (observer, storage, dataStack) in
                
                observer.iCloudStoreDidFinishUbiquitousStoreInitialImport(storage: storage, dataStack: dataStack)
            }
        )
        self.registerNotification(
            &self.willAddAccountKey,
            name: ICloudUbiquitousStoreWillAddAccountNotification,
            toObserver: observer,
            callback: { (observer, storage, dataStack) in
                
                observer.iCloudStoreWillAddAccount(storage: storage, dataStack: dataStack)
            }
        )
        self.registerNotification(
            &self.didAddAccountKey,
            name: ICloudUbiquitousStoreDidAddAccountNotification,
            toObserver: observer,
            callback: { (observer, storage, dataStack) in
                
                observer.iCloudStoreDidAddAccount(storage: storage, dataStack: dataStack)
            }
        )
        self.registerNotification(
            &self.willRemoveAccountKey,
            name: ICloudUbiquitousStoreWillRemoveAccountNotification,
            toObserver: observer,
            callback: { (observer, storage, dataStack) in
                
                observer.iCloudStoreWillRemoveAccount(storage: storage, dataStack: dataStack)
            }
        )
        self.registerNotification(
            &self.didRemoveAccountKey,
            name: ICloudUbiquitousStoreDidRemoveAccountNotification,
            toObserver: observer,
            callback: { (observer, storage, dataStack) in
                
                observer.iCloudStoreDidRemoveAccount(storage: storage, dataStack: dataStack)
            }
        )
        self.registerNotification(
            &self.willRemoveContentKey,
            name: ICloudUbiquitousStoreWillRemoveContentNotification,
            toObserver: observer,
            callback: { (observer, storage, dataStack) in
            
                observer.iCloudStoreWillRemoveContent(storage: storage, dataStack: dataStack)
            }
        )
        self.registerNotification(
            &self.didRemoveContentKey,
            name: ICloudUbiquitousStoreDidRemoveContentNotification,
            toObserver: observer,
            callback: { (observer, storage, dataStack) in
                
                observer.iCloudStoreDidRemoveContent(storage: storage, dataStack: dataStack)
            }
        )
    }
    
    /**
     Unregisters an `ICloudStoreObserver` to stop receiving notifications from the ubiquitous store
     
     - parameter observer: the observer to stop sending ubiquitous notifications to
     */
    public func removeObserver(observer: ICloudStoreObserver) {
        
        CoreStore.assert(
            NSThread.isMainThread(),
            "Attempted to remove an observer of type \(cs_typeName(observer)) outside the main thread."
        )
        let nilValue: AnyObject? = nil
        cs_setAssociatedRetainedObject(
            nilValue,
            forKey: &self.willFinishInitialImportKey,
            inObject: observer
        )
        cs_setAssociatedRetainedObject(
            nilValue,
            forKey: &self.didFinishInitialImportKey,
            inObject: observer
        )
        cs_setAssociatedRetainedObject(
            nilValue,
            forKey: &self.willAddAccountKey,
            inObject: observer
        )
        cs_setAssociatedRetainedObject(
            nilValue,
            forKey: &self.didAddAccountKey,
            inObject: observer
        )
        cs_setAssociatedRetainedObject(
            nilValue,
            forKey: &self.willRemoveAccountKey,
            inObject: observer
        )
        cs_setAssociatedRetainedObject(
            nilValue,
            forKey: &self.didRemoveAccountKey,
            inObject: observer
        )
        cs_setAssociatedRetainedObject(
            nilValue,
            forKey: &self.willRemoveContentKey,
            inObject: observer
        )
        cs_setAssociatedRetainedObject(
            nilValue,
            forKey: &self.didRemoveContentKey,
            inObject: observer
        )
    }
    
    
    // MARK: StorageInterface
    
    /**
     The string identifier for the `NSPersistentStore`'s `type` property. For `SQLiteStore`s, this is always set to `NSSQLiteStoreType`.
     */
    public static let storeType = NSSQLiteStoreType
    
    /**
     The configuration name in the model file
     */
    public let configuration: String?
    
    /**
     The options dictionary for the `NSPersistentStore`. For `SQLiteStore`s, this is always set to
     ```
     [NSSQLitePragmasOption: ["journal_mode": "WAL"]]
     ```
     */
    public let storeOptions: [String: AnyObject]?
    
    /**
     Do not call directly. Used by the `DataStack` internally.
     */
    public func didAddToDataStack(dataStack: DataStack) {
        
        self.didRemoveFromDataStack(dataStack)
        
        self.dataStack = dataStack
        let coordinator = dataStack.coordinator
        
        cs_setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: NSPersistentStoreCoordinatorStoresWillChangeNotification,
                object: coordinator,
                closure: { [weak self, weak dataStack] (note) -> Void in
                    
                    guard let `self` = self,
                        let dataStack = dataStack,
                        let userInfo = note.userInfo,
                        let transitionType = userInfo[NSPersistentStoreUbiquitousTransitionTypeKey] as? NSNumber else {
                            
                            return
                    }
                    
                    let notification: String
                    switch NSPersistentStoreUbiquitousTransitionType(rawValue: transitionType.unsignedIntegerValue) {
                        
                    case .InitialImportCompleted?:
                        notification = ICloudUbiquitousStoreWillFinishInitialImportNotification
                        
                    case .AccountAdded?:
                        notification = ICloudUbiquitousStoreWillAddAccountNotification
                        
                    case .AccountRemoved?:
                        notification = ICloudUbiquitousStoreWillRemoveAccountNotification
                        
                    case .ContentRemoved?:
                        notification = ICloudUbiquitousStoreWillRemoveContentNotification
                        
                    default:
                        return
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        notification,
                        object: self,
                        userInfo: [UserInfoKeyDataStack: dataStack]
                    )
                }
            ),
            forKey: &Static.persistentStoreCoordinatorWillChangeStores,
            inObject: self
        )
        cs_setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: NSPersistentStoreCoordinatorStoresDidChangeNotification,
                object: coordinator,
                closure: { [weak self, weak dataStack] (note) -> Void in
                    
                    guard let `self` = self,
                        let dataStack = dataStack,
                        let userInfo = note.userInfo,
                        let transitionType = userInfo[NSPersistentStoreUbiquitousTransitionTypeKey] as? NSNumber else {
                            
                            return
                    }
                    
                    let notification: String
                    switch NSPersistentStoreUbiquitousTransitionType(rawValue: transitionType.unsignedIntegerValue) {
                        
                    case .InitialImportCompleted?:
                        notification = ICloudUbiquitousStoreDidFinishInitialImportNotification
                        
                    case .AccountAdded?:
                        notification = ICloudUbiquitousStoreDidAddAccountNotification
                        
                    case .AccountRemoved?:
                        notification = ICloudUbiquitousStoreDidRemoveAccountNotification
                        
                    case .ContentRemoved?:
                        notification = ICloudUbiquitousStoreDidRemoveContentNotification
                        
                    default:
                        return
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        notification,
                        object: self,
                        userInfo: [UserInfoKeyDataStack: dataStack]
                    )
                }
            ),
            forKey: &Static.persistentStoreCoordinatorDidChangeStores,
            inObject: self
        )
    }
    
    /**
     Do not call directly. Used by the `DataStack` internally.
     */
    public func didRemoveFromDataStack(dataStack: DataStack) {
        
        let coordinator = dataStack.coordinator
        let nilValue: AnyObject? = nil
        cs_setAssociatedRetainedObject(
            nilValue,
            forKey: &Static.persistentStoreCoordinatorWillChangeStores,
            inObject: coordinator
        )
        cs_setAssociatedRetainedObject(
            nilValue,
            forKey: &Static.persistentStoreCoordinatorDidChangeStores,
            inObject: coordinator
        )
        
        self.dataStack = nil
    }
    
    
    // MARK: CloudStorage
    
    /**
     The `NSURL` that points to the ubiquity container file
     */
    public let cacheFileURL: NSURL
    
    /**
     Options that tell the `DataStack` how to setup the persistent store
     */
    public var cloudStorageOptions: CloudStorageOptions
    
    /**
     The options dictionary for the specified `CloudStorageOptions`
     */
    public func storeOptionsForOptions(options: CloudStorageOptions) -> [String: AnyObject]? {
        
        if options == .None {
            
            return self.storeOptions
        }
        
        var storeOptions = self.storeOptions ?? [:]
        if options.contains(.AllowSynchronousLightweightMigration) {
            
            storeOptions[NSMigratePersistentStoresAutomaticallyOption] = true
            storeOptions[NSInferMappingModelAutomaticallyOption] = true
        }
        if options.contains(.RecreateLocalStoreOnModelMismatch) {
            
            storeOptions[NSPersistentStoreRebuildFromUbiquitousContentOption] = true
        }
        return storeOptions
    }
    
    /**
     Called by the `DataStack` to perform actual deletion of the store file from disk. Do not call directly! The `sourceModel` argument is a hint for the existing store's model version. For `SQLiteStore`, this converts the database's WAL journaling mode to DELETE before deleting the file.
     */
    public func eraseStorageAndWait(soureModel soureModel: NSManagedObjectModel) throws {
        
        // TODO: check if attached to persistent store
        
        let cacheFileURL = self.cacheFileURL
        try cs_autoreleasepool {
            
            let journalUpdatingCoordinator = NSPersistentStoreCoordinator(managedObjectModel: soureModel)
            let options = [
                NSSQLitePragmasOption: ["journal_mode": "DELETE"],
                NSPersistentStoreRemoveUbiquitousMetadataOption: true
            ]
            let store = try journalUpdatingCoordinator.addPersistentStoreWithType(
                self.dynamicType.storeType,
                configuration: self.configuration,
                URL: cacheFileURL,
                options: options
            )
            try journalUpdatingCoordinator.removePersistentStore(store)
            try NSPersistentStoreCoordinator.removeUbiquitousContentAndPersistentStoreAtURL(
                cacheFileURL,
                options: options
            )
            try NSFileManager.defaultManager().removeItemAtURL(cacheFileURL)
        }
    }
    
    
    // MARK: Private
    
    private struct Static {
        
        private static var persistentStoreCoordinatorWillChangeStores: Void?
        private static var persistentStoreCoordinatorDidChangeStores: Void?
    }
    
    private var willFinishInitialImportKey: Void?
    private var didFinishInitialImportKey: Void?
    private var willAddAccountKey: Void?
    private var didAddAccountKey: Void?
    private var willRemoveAccountKey: Void?
    private var didRemoveAccountKey: Void?
    private var willRemoveContentKey: Void?
    private var didRemoveContentKey: Void?
    
    private weak var dataStack: DataStack?
    
    private func registerNotification<T: ICloudStoreObserver>(notificationKey: UnsafePointer<Void>, name: String, toObserver observer: T, callback: (observer: T, storage: ICloudStore, dataStack: DataStack) -> Void) {
        
        cs_setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: name,
                object: self,
                closure: { [weak self, weak observer] (note) -> Void in
                    
                    guard let `self` = self,
                        let observer = observer,
                        let dataStack = note.userInfo?[UserInfoKeyDataStack] as? DataStack
                        where self.dataStack === dataStack else {
                            
                            return
                    }
                    callback(observer: observer, storage: self, dataStack: dataStack)
                }
            ),
            forKey: notificationKey,
            inObject: observer
        )
    }
}


// MARK: - Notification Keys

private let ICloudUbiquitousStoreWillFinishInitialImportNotification = "ICloudUbiquitousStoreWillFinishInitialImportNotification"
private let ICloudUbiquitousStoreDidFinishInitialImportNotification = "ICloudUbiquitousStoreDidFinishInitialImportNotification"
private let ICloudUbiquitousStoreWillAddAccountNotification = "ICloudUbiquitousStoreWillAddAccountNotification"
private let ICloudUbiquitousStoreDidAddAccountNotification = "ICloudUbiquitousStoreDidAddAccountNotification"
private let ICloudUbiquitousStoreWillRemoveAccountNotification = "ICloudUbiquitousStoreWillRemoveAccountNotification"
private let ICloudUbiquitousStoreDidRemoveAccountNotification = "ICloudUbiquitousStoreDidRemoveAccountNotification"
private let ICloudUbiquitousStoreWillRemoveContentNotification = "ICloudUbiquitousStoreWillRemoveContentNotification"
private let ICloudUbiquitousStoreDidRemoveContentNotification = "ICloudUbiquitousStoreDidRemoveContentNotification"

private let UserInfoKeyDataStack = "UserInfoKeyDataStack"

#endif
