//
//  NSManagedObject+Convenience.swift
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


// MARK: - NSManagedObject

public extension NSManagedObject {
    
    /**
     Provides a convenience wrapper for accessing `primitiveValueForKey(...)` with proper calls to `willAccessValueForKey(...)` and `didAccessValueForKey(...)`. This is useful when implementing accessor methods for transient attributes.
     
     - parameter KVCKey: the KVC key
     - returns: the primitive value for the KVC key
     */
    @warn_unused_result
    public func accessValueForKVCKey(KVCKey: KeyPath) -> AnyObject? {
        
        self.willAccessValueForKey(KVCKey)
        let primitiveValue: AnyObject? = self.primitiveValueForKey(KVCKey)
        self.didAccessValueForKey(KVCKey)
        
        return primitiveValue
    }
    
    /**
     Provides a convenience wrapper for setting `setPrimitiveValue(...)` with proper calls to `willChangeValueForKey(...)` and `didChangeValueForKey(...)`. This is useful when implementing mutator methods for transient attributes.
     
     - parameter value: the value to set the KVC key with
     - parameter KVCKey: the KVC key
     */
    public func setValue(value: AnyObject?, forKVCKey KVCKey: KeyPath) {
        
        self.willChangeValueForKey(KVCKey)
        self.setPrimitiveValue(value, forKey: KVCKey)
        self.didChangeValueForKey(KVCKey)
    }
    
    /**
     Re-faults the object to use the latest values from the persistent store
     */
    public func refreshAsFault() {
        
        self.managedObjectContext?.refreshObject(self, mergeChanges: false)
    }
    
    /**
     Re-faults the object to use the latest values from the persistent store and merges previously pending changes back
     */
    public func refreshAndMerge() {
        
        self.managedObjectContext?.refreshObject(self, mergeChanges: true)
    }
}
