//
//  ICloudStore.swift
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


#if os(iOS) || os(macOS)

// MARK: - ICloudStore

/**
 A storage interface backed by an SQLite database managed by iCloud.
 */
public final class ICloudStore: CloudStorage {
    
    /**
     Initializes an iCloud store interface from the given ubiquitous store information. Returns `nil` if the container could not be located or if iCloud storage is unavailable for the current user or device
     ```
     guard let storage = ICloudStore(
         ubiquitousContentName: "MyAppCloudData",
         ubiquitousContentTransactionLogsSubdirectory: "logs/config1",
         ubiquitousContainerID: "iCloud.com.mycompany.myapp.containername",
         ubiquitousPeerToken: "9614d658014f4151a95d8048fb717cf0",
         configuration: "Config1",
         cloudStorageOptions: .recreateLocalStoreOnModelMismatch
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
     - parameter ubiquitousContentTransactionLogsSubdirectory: a required relative path for the transaction logs
     - parameter ubiquitousContainerID: a container if your app has multiple ubiquity container identifiers in its entitlements
     - parameter ubiquitousPeerToken: a per-application salt to allow multiple apps on the same device to share a Core Data store integrated with iCloud
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration. Note that if you have multiple configurations, you will need to specify a different `ubiquitousContentName` explicitly for each of them.
     - parameter cloudStorageOptions: When the `ICloudStore` is passed to the `DataStack`'s `addStorage()` methods, tells the `DataStack` how to setup the persistent store. Defaults to `.None`.
     */
    public required init?(ubiquitousContentName: String, ubiquitousContentTransactionLogsSubdirectory: String, ubiquitousContainerID: String? = nil, ubiquitousPeerToken: String? = nil, configuration: ModelConfiguration = nil, cloudStorageOptions: CloudStorageOptions = nil) {
        
        CoreStore.assert(
            !ubiquitousContentName.isEmpty,
            "The ubiquitousContentName cannot be empty."
        )
        CoreStore.assert(
            !ubiquitousContentName.contains("."),
            "The ubiquitousContentName cannot contain periods."
        )
        CoreStore.assert(
            !ubiquitousContentTransactionLogsSubdirectory.isEmpty,
            "The ubiquitousContentURLRelativePath should not be empty."
        )
        CoreStore.assert(
            ubiquitousPeerToken?.isEmpty != true,
            "The ubiquitousPeerToken should not be empty if provided."
        )
        
        let fileManager = FileManager.default
        guard let cacheFolderURL = fileManager.url(forUbiquityContainerIdentifier: ubiquitousContainerID) else {
            
            return nil
        }
        let cacheFileURL = cacheFolderURL.appendingPathComponent(ubiquitousContentTransactionLogsSubdirectory)
        
        var storeOptions: [String: Any] = [
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
    public func addObserver<T: ICloudStoreObserver>(_ observer: T) {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to add an observer of type \(cs_typeName(observer)) outside the main thread."
        )
        
        self.removeObserver(observer)
        
        self.registerNotification(
            &self.willFinishInitialImportKey,
            name: Notification.Name.iCloudUbiquitousStoreWillFinishInitialImport,
            toObserver: observer,
            callback: { (observer, storage, dataStack) in
                
                observer.iCloudStoreWillFinishUbiquitousStoreInitialImport(storage: storage, dataStack: dataStack)
            }
        )
        self.registerNotification(
            &self.didFinishInitialImportKey,
            name: Notification.Name.iCloudUbiquitousStoreDidFinishInitialImport,
            toObserver: observer,
            callback: { (observer, storage, dataStack) in
                
                observer.iCloudStoreDidFinishUbiquitousStoreInitialImport(storage: storage, dataStack: dataStack)
            }
        )
        self.registerNotification(
            &self.willAddAccountKey,
            name: Notification.Name.iCloudUbiquitousStoreWillAddAccount,
            toObserver: observer,
            callback: { (observer, storage, dataStack) in
                
                observer.iCloudStoreWillAddAccount(storage: storage, dataStack: dataStack)
            }
        )
        self.registerNotification(
            &self.didAddAccountKey,
            name: Notification.Name.iCloudUbiquitousStoreDidAddAccount,
            toObserver: observer,
            callback: { (observer, storage, dataStack) in
                
                observer.iCloudStoreDidAddAccount(storage: storage, dataStack: dataStack)
            }
        )
        self.registerNotification(
            &self.willRemoveAccountKey,
            name: Notification.Name.iCloudUbiquitousStoreWillRemoveAccount,
            toObserver: observer,
            callback: { (observer, storage, dataStack) in
                
                observer.iCloudStoreWillRemoveAccount(storage: storage, dataStack: dataStack)
            }
        )
        self.registerNotification(
            &self.didRemoveAccountKey,
            name: Notification.Name.iCloudUbiquitousStoreDidRemoveAccount,
            toObserver: observer,
            callback: { (observer, storage, dataStack) in
                
                observer.iCloudStoreDidRemoveAccount(storage: storage, dataStack: dataStack)
            }
        )
        self.registerNotification(
            &self.willRemoveContentKey,
            name: Notification.Name.iCloudUbiquitousStoreWillRemoveContent,
            toObserver: observer,
            callback: { (observer, storage, dataStack) in
            
                observer.iCloudStoreWillRemoveContent(storage: storage, dataStack: dataStack)
            }
        )
        self.registerNotification(
            &self.didRemoveContentKey,
            name: Notification.Name.iCloudUbiquitousStoreDidRemoveContent,
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
    public func removeObserver(_ observer: ICloudStoreObserver) {
        
        CoreStore.assert(
            Thread.isMainThread,
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
    public let configuration: ModelConfiguration
    
    /**
     The options dictionary for the `NSPersistentStore`. For `SQLiteStore`s, this is always set to
     ```
     [NSSQLitePragmasOption: ["journal_mode": "WAL"]]
     ```
     */
    public let storeOptions: [AnyHashable: Any]?
    
    /**
     Do not call directly. Used by the `DataStack` internally.
     */
    public func cs_didAddToDataStack(_ dataStack: DataStack) {
        
        self.cs_didRemoveFromDataStack(dataStack)
        
        self.dataStack = dataStack
        let coordinator = dataStack.coordinator
        
        cs_setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: Notification.Name.NSPersistentStoreCoordinatorStoresWillChange,
                object: coordinator,
                closure: { [weak self, weak dataStack] (note) -> Void in
                    
                    guard let `self` = self,
                        let dataStack = dataStack,
                        let userInfo = note.userInfo,
                        let transitionType = userInfo[NSPersistentStoreUbiquitousTransitionTypeKey] as? NSNumber else {
                            
                            return
                    }
                    
                    let notification: Notification.Name
                    switch NSPersistentStoreUbiquitousTransitionType(rawValue: transitionType.uintValue) {
                        
                    case .initialImportCompleted?:
                        notification = Notification.Name.iCloudUbiquitousStoreWillFinishInitialImport
                        
                    case .accountAdded?:
                        notification = Notification.Name.iCloudUbiquitousStoreWillAddAccount
                        
                    case .accountRemoved?:
                        notification = Notification.Name.iCloudUbiquitousStoreWillRemoveAccount
                        
                    case .contentRemoved?:
                        notification = Notification.Name.iCloudUbiquitousStoreWillRemoveContent
                        
                    default:
                        return
                    }
                    NotificationCenter.default.post(
                        name: notification,
                        object: self,
                        userInfo: [String(describing: DataStack.self): dataStack]
                    )
                }
            ),
            forKey: &Static.persistentStoreCoordinatorWillChangeStores,
            inObject: self
        )
        cs_setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange,
                object: coordinator,
                closure: { [weak self, weak dataStack] (note) -> Void in
                    
                    guard let `self` = self,
                        let dataStack = dataStack,
                        let userInfo = note.userInfo,
                        let transitionType = userInfo[NSPersistentStoreUbiquitousTransitionTypeKey] as? NSNumber else {
                            
                            return
                    }
                    
                    let notification: Notification.Name
                    switch NSPersistentStoreUbiquitousTransitionType(rawValue: transitionType.uintValue) {
                        
                    case .initialImportCompleted?:
                        notification = Notification.Name.iCloudUbiquitousStoreDidFinishInitialImport
                        
                    case .accountAdded?:
                        notification = Notification.Name.iCloudUbiquitousStoreDidAddAccount
                        
                    case .accountRemoved?:
                        notification = Notification.Name.iCloudUbiquitousStoreDidRemoveAccount
                        
                    case .contentRemoved?:
                        notification = Notification.Name.iCloudUbiquitousStoreDidRemoveContent
                        
                    default:
                        return
                    }
                    NotificationCenter.default.post(
                        name: notification,
                        object: self,
                        userInfo: [String(describing: DataStack.self): dataStack]
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
    public func cs_didRemoveFromDataStack(_ dataStack: DataStack) {
        
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
    public let cacheFileURL: URL
    
    /**
     Options that tell the `DataStack` how to setup the persistent store
     */
    public var cloudStorageOptions: CloudStorageOptions
    
    /**
     The options dictionary for the specified `CloudStorageOptions`
     */
    public func dictionary(forOptions options: CloudStorageOptions) -> [AnyHashable: Any]? {
        
        if options == .none {
            
            return self.storeOptions
        }
        
        var storeOptions = self.storeOptions ?? [:]
        if options.contains(.allowSynchronousLightweightMigration) {
            
            storeOptions[NSMigratePersistentStoresAutomaticallyOption] = true
            storeOptions[NSInferMappingModelAutomaticallyOption] = true
        }
        if options.contains(.recreateLocalStoreOnModelMismatch) {
            
            storeOptions[NSPersistentStoreRebuildFromUbiquitousContentOption] = true
        }
        return storeOptions
    }
    
    /**
     Called by the `DataStack` to perform actual deletion of the store file from disk. Do not call directly! The `sourceModel` argument is a hint for the existing store's model version. For `SQLiteStore`, this converts the database's WAL journaling mode to DELETE before deleting the file.
     */
    public func cs_eraseStorageAndWait(soureModel: NSManagedObjectModel) throws {
        
        let cacheFileURL = self.cacheFileURL
        try autoreleasepool {
            
            let journalUpdatingCoordinator = NSPersistentStoreCoordinator(managedObjectModel: soureModel)
            let options = [
                NSSQLitePragmasOption: ["journal_mode": "DELETE"],
                NSPersistentStoreRemoveUbiquitousMetadataOption: true
            ] as [String : Any]
            let store = try journalUpdatingCoordinator.addPersistentStore(
                ofType: type(of: self).storeType,
                configurationName: self.configuration,
                at: cacheFileURL,
                options: options
            )
            try journalUpdatingCoordinator.remove(store)
            try NSPersistentStoreCoordinator.removeUbiquitousContentAndPersistentStore(
                at: cacheFileURL,
                options: options
            )
        }
    }
    
    
    // MARK: Private
    
    fileprivate struct Static {
        
        fileprivate static var persistentStoreCoordinatorWillChangeStores: Void?
        fileprivate static var persistentStoreCoordinatorDidChangeStores: Void?
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
    
    private func registerNotification<T: ICloudStoreObserver>(_ notificationKey: UnsafeRawPointer, name: Notification.Name, toObserver observer: T, callback: @escaping (_ observer: T, _ storage: ICloudStore, _ dataStack: DataStack) -> Void) {
        
        cs_setAssociatedRetainedObject(
            NotificationObserver(
                notificationName: name,
                object: self,
                closure: { [weak self, weak observer] (note) -> Void in
                    
                    guard let `self` = self,
                        let observer = observer,
                        let dataStack = note.userInfo?[String(describing: DataStack.self)] as? DataStack,
                        self.dataStack === dataStack else {
                            
                            return
                    }
                    callback(observer, self, dataStack)
                }
            ),
            forKey: notificationKey,
            inObject: observer
        )
    }
}


// MARK: - Notification Keys
    
fileprivate extension Notification.Name {
    
    fileprivate static let iCloudUbiquitousStoreWillFinishInitialImport = Notification.Name(rawValue: "iCloudUbiquitousStoreWillFinishInitialImport")
    fileprivate static let iCloudUbiquitousStoreDidFinishInitialImport = Notification.Name(rawValue: "iCloudUbiquitousStoreDidFinishInitialImport")
    fileprivate static let iCloudUbiquitousStoreWillAddAccount = Notification.Name(rawValue: "iCloudUbiquitousStoreWillAddAccount")
    fileprivate static let iCloudUbiquitousStoreDidAddAccount = Notification.Name(rawValue: "iCloudUbiquitousStoreDidAddAccount")
    fileprivate static let iCloudUbiquitousStoreWillRemoveAccount = Notification.Name(rawValue: "iCloudUbiquitousStoreWillRemoveAccount")
    fileprivate static let iCloudUbiquitousStoreDidRemoveAccount = Notification.Name(rawValue: "iCloudUbiquitousStoreDidRemoveAccount")
    fileprivate static let iCloudUbiquitousStoreWillRemoveContent = Notification.Name(rawValue: "iCloudUbiquitousStoreWillRemoveContent")
    fileprivate static let iCloudUbiquitousStoreDidRemoveContent = Notification.Name(rawValue: "iCloudUbiquitousStoreDidRemoveContent")
}

#endif
