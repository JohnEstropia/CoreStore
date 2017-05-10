//
//  ICloudStoreObserver.swift
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


#if os(iOS) || os(OSX)

// MARK: - ICloudStoreObserver

/**
 Implement the `ICloudStoreObserver` protocol to observe ubiquitous storage notifications from the specified iCloud store.
 Note that `ICloudStoreObserver` methods are only called when all the following conditions are true:
 - the observer is registered to the `ICloudStore` via the `ICloudStore.addObserver(_:)` method
 - the `ICloudStore` was added to a `DataStack`
 - the `ICloudStore` and the `DataStack` are still persisted in memory
 */
public protocol ICloudStoreObserver: class {
    
    /**
     Notifies that the initial ubiquitous store import will complete
     
     - parameter storage: the `ICloudStore` instance being observed
     - parameter dataStack: the `DataStack` that manages the peristent store
     */
    func iCloudStoreWillFinishUbiquitousStoreInitialImport(storage: ICloudStore, dataStack: DataStack)
    
    /**
     Notifies that the initial ubiquitous store import completed
     
     - parameter storage: the `ICloudStore` instance being observed
     - parameter dataStack: the `DataStack` that manages the peristent store
     */
    func iCloudStoreDidFinishUbiquitousStoreInitialImport(storage: ICloudStore, dataStack: DataStack)
    
    /**
     Notifies that an iCloud account will be added to the coordinator
     
     - parameter storage: the `ICloudStore` instance being observed
     - parameter dataStack: the `DataStack` that manages the peristent store
     */
    func iCloudStoreWillAddAccount(storage: ICloudStore, dataStack: DataStack)
    
    /**
     Notifies that an iCloud account was added to the coordinator
     
     - parameter storage: the `ICloudStore` instance being observed
     - parameter dataStack: the `DataStack` that manages the peristent store
     */
    func iCloudStoreDidAddAccount(storage: ICloudStore, dataStack: DataStack)
    
    /**
     Notifies that an iCloud account will be removed from the coordinator
     
     - parameter storage: the `ICloudStore` instance being observed
     - parameter dataStack: the `DataStack` that manages the peristent store
     */
    func iCloudStoreWillRemoveAccount(storage: ICloudStore, dataStack: DataStack)
    
    /**
     Notifies that an iCloud account was removed from the coordinator
     
     - parameter storage: the `ICloudStore` instance being observed
     - parameter dataStack: the `DataStack` that manages the peristent store
     */
    func iCloudStoreDidRemoveAccount(storage: ICloudStore, dataStack: DataStack)
    
    /**
     Notifies that iCloud contents will be deleted
     
     - parameter storage: the `ICloudStore` instance being observed
     - parameter dataStack: the `DataStack` that manages the peristent store
     */
    func iCloudStoreWillRemoveContent(storage: ICloudStore, dataStack: DataStack)
    
    /**
     Notifies that iCloud contents were deleted
     
     - parameter storage: the `ICloudStore` instance being observed
     - parameter dataStack: the `DataStack` that manages the peristent store
     */
    func iCloudStoreDidRemoveContent(storage: ICloudStore, dataStack: DataStack)
}

public extension ICloudStoreObserver {
    
    public func iCloudStoreWillFinishUbiquitousStoreInitialImport(storage: ICloudStore, dataStack: DataStack) {}
    
    public func iCloudStoreDidFinishUbiquitousStoreInitialImport(storage: ICloudStore, dataStack: DataStack) {}
    
    public func iCloudStoreWillAddAccount(storage: ICloudStore, dataStack: DataStack) {}
    
    public func iCloudStoreDidAddAccount(storage: ICloudStore, dataStack: DataStack) {}
    
    public func iCloudStoreWillRemoveAccount(storage: ICloudStore, dataStack: DataStack) {}
    
    public func iCloudStoreDidRemoveAccount(storage: ICloudStore, dataStack: DataStack) {}
    
    public func iCloudStoreWillRemoveContent(storage: ICloudStore, dataStack: DataStack) {}
    
    public func iCloudStoreDidRemoveContent(storage: ICloudStore, dataStack: DataStack) {}
}

#endif
