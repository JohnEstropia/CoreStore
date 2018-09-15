//
//  ObjectObserver.swift
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


// MARK: - ObjectObserver

/**
 Implement the `ObjectObserver` protocol to observe changes to a single `DynamicObject` instance. `ObjectObserver`s may register themselves to a `ObjectMonitor`'s `addObserver(_:)` method:
 ```
 let monitor = CoreStore.monitorObject(object)
 monitor.addObserver(self)
 ```
 */
@available(macOS 10.12, *)
public protocol ObjectObserver: class {
    
    /**
     The `DynamicObject` type for the observed object
     */
    associatedtype ObjectEntityType: DynamicObject
    
    /**
     Handles processing just before a change to the observed `object` occurs. (Optional)
     The default implementation does nothing.
     
     - parameter monitor: the `ObjectMonitor` monitoring the object being observed
     - parameter object: the `DynamicObject` instance being observed
     */
    func objectMonitor(_ monitor: ObjectMonitor<ObjectEntityType>, willUpdateObject object: ObjectEntityType)
    
    /**
     Handles processing right after a change to the observed `object` occurs. (Optional)
     The default implementation does nothing.
     
     - parameter monitor: the `ObjectMonitor` monitoring the object being observed
     - parameter object: the `DynamicObject` instance being observed
     - parameter changedPersistentKeys: a `Set` of key paths for the attributes that were changed. Note that `changedPersistentKeys` only contains keys for attributes/relationships present in the persistent store, thus transient properties will not be reported.
     */
    func objectMonitor(_ monitor: ObjectMonitor<ObjectEntityType>, didUpdateObject object: ObjectEntityType, changedPersistentKeys: Set<KeyPathString>)
    
    /**
     Handles processing right after `object` is deleted. (Optional)
     The default implementation does nothing.
     
     - parameter monitor: the `ObjectMonitor` monitoring the object being observed
     - parameter object: the `DynamicObject` instance being observed
     */
    func objectMonitor(_ monitor: ObjectMonitor<ObjectEntityType>, didDeleteObject object: ObjectEntityType)
}


// MARK: - ObjectObserver (Default Implementations)

@available(macOS 10.12, *)
public extension ObjectObserver {
    
    public func objectMonitor(_ monitor: ObjectMonitor<ObjectEntityType>, willUpdateObject object: ObjectEntityType) { }
    
    public func objectMonitor(_ monitor: ObjectMonitor<ObjectEntityType>, didUpdateObject object: ObjectEntityType, changedPersistentKeys: Set<KeyPathString>) { }
    
    public func objectMonitor(_ monitor: ObjectMonitor<ObjectEntityType>, didDeleteObject object: ObjectEntityType) { }
}
