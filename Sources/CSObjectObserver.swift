//
//  CSObjectObserver.swift
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


// MARK: - CSObjectObserver

/**
 Implement the `CSObjectObserver` protocol to observe changes  to a single `NSManagedObject` instance. `CSObjectObserver`s may register themselves to a `CSObjectMonitor`'s `-addObjectObserver:` method:
 ```
 CSObjectMonitor *monitor = [CSCoreStore monitorObject:myObject];
 [monitor addObjectObserver:self];
 ```
 
 - SeeAlso: `ObjectObserver`
 */
@available(macOS 10.12, *)
@objc
public protocol CSObjectObserver: AnyObject {
    
    /**
     Handles processing just before a change to the observed `object` occurs
     
     - parameter monitor: the `CSObjectMonitor` monitoring the object being observed
     - parameter object: the `NSManagedObject` instance being observed
     */
    @objc
    optional func objectMonitor(_ monitor: CSObjectMonitor, willUpdateObject object: Any)
    
    /**
     Handles processing right after a change to the observed `object` occurs
     
     - parameter monitor: the `CSObjectMonitor` monitoring the object being observed
     - parameter object: the `NSManagedObject` instance being observed
     - parameter changedPersistentKeys: an `NSSet` of key paths for the attributes that were changed. Note that `changedPersistentKeys` only contains keys for attributes/relationships present in the persistent store, thus transient properties will not be reported.
     */
    @objc
    optional func objectMonitor(_ monitor: CSObjectMonitor, didUpdateObject object: Any, changedPersistentKeys: Set<String>)
    
    /**
     Handles processing right after `object` is deleted
     
     - parameter monitor: the `CSObjectMonitor` monitoring the object being observed
     - parameter object: the `NSManagedObject` instance being observed
     */
    @objc
    optional func objectMonitor(_ monitor: CSObjectMonitor, didDeleteObject object: Any)
}
