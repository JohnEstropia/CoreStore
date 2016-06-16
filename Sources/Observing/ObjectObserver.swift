//
//  ObjectObserver.swift
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


#if os(iOS) || os(watchOS) || os(tvOS)

// MARK: - ObjectObserver

/**
 Implement the `ObjectObserver` protocol to observe changes to a single `NSManagedObject` instance. `ObjectObserver`s may register themselves to a `ObjectMonitor`'s `addObserver(_:)` method:
 ```
 let monitor = CoreStore.monitorObject(object)
 monitor.addObserver(self)
 ```
 */
public protocol ObjectObserver: class {
    
    /**
     The `NSManagedObject` type for the observed object
     */
    associatedtype ObjectEntityType: NSManagedObject
    
    /**
     Handles processing just before a change to the observed `object` occurs
     
     - parameter monitor: the `ObjectMonitor` monitoring the object being observed
     - parameter object: the `NSManagedObject` instance being observed
     */
    func objectMonitor(monitor: ObjectMonitor<ObjectEntityType>, willUpdateObject object: ObjectEntityType)
    
    /**
     Handles processing right after a change to the observed `object` occurs
     
     - parameter monitor: the `ObjectMonitor` monitoring the object being observed
     - parameter object: the `NSManagedObject` instance being observed
     - parameter changedPersistentKeys: a `Set` of key paths for the attributes that were changed. Note that `changedPersistentKeys` only contains keys for attributes/relationships present in the persistent store, thus transient properties will not be reported.
     */
    func objectMonitor(monitor: ObjectMonitor<ObjectEntityType>, didUpdateObject object: ObjectEntityType, changedPersistentKeys: Set<KeyPath>)
    
    /**
     Handles processing right after `object` is deleted
     
     - parameter monitor: the `ObjectMonitor` monitoring the object being observed
     - parameter object: the `NSManagedObject` instance being observed
     */
    func objectMonitor(monitor: ObjectMonitor<ObjectEntityType>, didDeleteObject object: ObjectEntityType)
}


// MARK: - ObjectObserver (Default Implementations)

public extension ObjectObserver {
    
    /**
     The default implementation does nothing.
     */
    func objectMonitor(monitor: ObjectMonitor<ObjectEntityType>, willUpdateObject object: ObjectEntityType) { }
    
    /**
     The default implementation does nothing.
     */
    func objectMonitor(monitor: ObjectMonitor<ObjectEntityType>, didUpdateObject object: ObjectEntityType, changedPersistentKeys: Set<KeyPath>) { }
    
    /**
     The default implementation does nothing.
     */
    func objectMonitor(monitor: ObjectMonitor<ObjectEntityType>, didDeleteObject object: ObjectEntityType) { }
}

#endif
