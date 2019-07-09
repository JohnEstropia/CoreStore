//
//  CSObjectMonitor.swift
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


// MARK: - CSObjectMonitor

/**
 The `CSObjectMonitor` serves as the Objective-C bridging type for `ObjectMonitor<T>`.
 
 - SeeAlso: `ObjectMonitor`
 */
@available(macOS 10.12, *)
@objc
public final class CSObjectMonitor: NSObject {
    
    /**
     Returns the `NSManagedObject` instance being observed, or `nil` if the object was already deleted.
     */
    public var object: Any? {
        
        return self.bridgeToSwift.object
    }
    
    /**
     Returns `YES` if the `NSManagedObject` instance being observed still exists, or `NO` if the object was already deleted.
     */
    public var isObjectDeleted: Bool {
        
        return self.bridgeToSwift.isObjectDeleted
    }
    
    /**
     Registers a `CSObjectObserver` to be notified when changes to the receiver's `object` are made.
     
     To prevent retain-cycles, `CSObjectMonitor` only keeps `weak` references to its observers.
     
     For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
     
     Calling `-addObjectObserver:` multiple times on the same observer is safe, as `CSObjectMonitor` unregisters previous notifications to the observer before re-registering them.
     
     - parameter observer: an `CSObjectObserver` to send change notifications to
     */
    public func addObjectObserver(_ observer: CSObjectObserver) {
        
        let swift = self.bridgeToSwift
        swift.unregisterObserver(observer)
        swift.registerObserver(
            observer,
            willChangeObject: { (observer, monitor, object) in
                
                observer.objectMonitor?(monitor.bridgeToObjectiveC, willUpdateObject: object)
            },
            didDeleteObject: { (observer, monitor, object) in
                
                observer.objectMonitor?(monitor.bridgeToObjectiveC, didDeleteObject: object)
            },
            didUpdateObject: { (observer, monitor, object, changedPersistentKeys) in
                
                observer.objectMonitor?(monitor.bridgeToObjectiveC, didUpdateObject: object, changedPersistentKeys: changedPersistentKeys)
            }
        )
    }
    
    /**
     Unregisters an `CSObjectObserver` from receiving notifications for changes to the receiver's `object`.
     
     For thread safety, this method needs to be called from the main thread. An assertion failure will occur (on debug builds only) if called from any thread other than the main thread.
     
     - parameter observer: an `CSObjectObserver` to unregister notifications to
     */
    public func removeObjectObserver(_ observer: CSObjectObserver) {
        
        self.bridgeToSwift.unregisterObserver(observer)
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {

        var hasher = Hasher()
        self.bridgeToSwift.hash(into: &hasher)
        return hasher.finalize()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let object = object as? CSObjectMonitor else {
            
            return false
        }
        return self.bridgeToSwift == object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: Self.self))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    @nonobjc
    public let bridgeToSwift: ObjectMonitor<NSManagedObject>
    
    @nonobjc
    public required init<T: NSManagedObject>(_ swiftValue: ObjectMonitor<T>) {
        
        self.bridgeToSwift = swiftValue.downcast()
        super.init()
    }
}


// MARK: - ObjectMonitor

@available(macOS 10.12, *)
extension ObjectMonitor where ObjectMonitor.ObjectType: NSManagedObject {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSObjectMonitor {
        
        return CSObjectMonitor(self)
    }
    
    
    // MARK: FilePrivate
    
    fileprivate func downcast() -> ObjectMonitor<NSManagedObject> {
        
        func noWarnUnsafeBitCast<T, U>(_ x: T, to type: U.Type) -> U {
            
            return unsafeBitCast(x, to: type)
        }
        return noWarnUnsafeBitCast(self, to: ObjectMonitor<NSManagedObject>.self)
    }
}
