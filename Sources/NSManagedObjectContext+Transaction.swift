//
//  NSManagedObjectContext+Transaction.swift
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


// MARK: - NSManagedObjectContext

internal extension NSManagedObjectContext {
    
    // MARK: Internal
    
    @nonobjc
    internal weak var parentTransaction: BaseDataTransaction? {
        
        get {
            
            return cs_getAssociatedObjectForKey(
                &PropertyKeys.parentTransaction,
                inObject: self
            )
        }
        set {
            
            cs_setAssociatedWeakObject(
                newValue,
                forKey: &PropertyKeys.parentTransaction,
                inObject: self
            )
        }
    }
    
    @nonobjc
    internal var isSavingSynchronously: Bool? {
        
        get {
            
            let value: NSNumber? = cs_getAssociatedObjectForKey(
                &PropertyKeys.isSavingSynchronously,
                inObject: self
            )
            return value?.boolValue
        }
        set {
            
            cs_setAssociatedWeakObject(
                newValue.flatMap { NSNumber(value: $0) },
                forKey: &PropertyKeys.isSavingSynchronously,
                inObject: self
            )
        }
    }
    
    @nonobjc
    internal var isTransactionContext: Bool {
        
        get {
            
            let value: NSNumber? = cs_getAssociatedObjectForKey(
                &PropertyKeys.isTransactionContext,
                inObject: self
            )
            return value?.boolValue == true
        }
        set {
            
            cs_setAssociatedCopiedObject(
                NSNumber(value: newValue),
                forKey: &PropertyKeys.isTransactionContext,
                inObject: self
            )
        }
    }
    
    @nonobjc
    internal var isDataStackContext: Bool {
        
        get {
            
            let value: NSNumber? = cs_getAssociatedObjectForKey(
                &PropertyKeys.isDataStackContext,
                inObject: self
            )
            return value?.boolValue == true
        }
        set {
            
            cs_setAssociatedCopiedObject(
                NSNumber(value: newValue),
                forKey: &PropertyKeys.isDataStackContext,
                inObject: self
            )
        }
    }
    
    @nonobjc
    internal func isRunningInAllowedQueue() -> Bool {
        
        guard let parentTransaction = self.parentTransaction else {
            
            return false
        }
        return parentTransaction.isRunningInAllowedQueue()
    }
    
    @nonobjc
    internal func temporaryContextInTransactionWithConcurrencyType(_ concurrencyType: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
        
        let context = NSManagedObjectContext(concurrencyType: concurrencyType)
        context.parent = self
        context.parentStack = self.parentStack
        context.setupForCoreStoreWithContextName("com.corestore.temporarycontext")
        context.shouldCascadeSavesToParent = (self.parentStack?.rootSavingContext == self)
        context.retainsRegisteredObjects = true
        
        return context
    }
    
    @nonobjc
    internal func saveSynchronously(waitForMerge: Bool) -> (hasChanges: Bool, error: CoreStoreError?) {
      
        var result: (hasChanges: Bool, error: CoreStoreError?) = (false, nil)
        self.performAndWait {
            
            guard self.hasChanges else {
                
                return
            }
            do {
                
                self.isSavingSynchronously = waitForMerge
                try self.save()
                self.isSavingSynchronously = nil
            }
            catch {
                
                let saveError = CoreStoreError(error)
                CoreStore.log(
                    saveError,
                    "Failed to save \(cs_typeName(NSManagedObjectContext.self))."
                )
                result = (true, saveError)
                return
            }
            if let parentContext = self.parent, self.shouldCascadeSavesToParent {
                
                let (_, error) = parentContext.saveSynchronously(waitForMerge: waitForMerge)
                result = (true, error)
            }
            else {
                
                result = (true, nil)
            }
        }
        return result
    }
    
    @nonobjc
    internal func saveAsynchronouslyWithCompletion(_ completion: @escaping (_ hasChanges: Bool, _ error: CoreStoreError?) -> Void = { (_, _) in }) {
        
        self.perform {
            
            guard self.hasChanges else {
                
                DispatchQueue.main.async {
                    
                    completion(false, nil)
                }
                return
            }
            do {
                
                self.isSavingSynchronously = false
                try self.save()
                self.isSavingSynchronously = nil
            }
            catch {
                
                let saveError = CoreStoreError(error)
                CoreStore.log(
                    saveError,
                    "Failed to save \(cs_typeName(NSManagedObjectContext.self))."
                )
                DispatchQueue.main.async {
    
                    completion(true, saveError)
                }
                return
            }
            if self.shouldCascadeSavesToParent, let parentContext = self.parent {
                
                parentContext.saveAsynchronouslyWithCompletion { (_, error) in
                    
                    completion(true, error)
                }
            }
            else {
                
                DispatchQueue.main.async {
    
                    completion(true, nil)
                }
            }
        }
    }
    
    @nonobjc
    internal func refreshAndMergeAllObjects() {
        
        if #available(iOS 8.3, OSX 10.11, *) {
            
            self.refreshAllObjects()
        }
        else {
            
            self.registeredObjects.forEach { self.refresh($0, mergeChanges: true) }
        }
    }
    
    
    // MARK: Private
    
    private struct PropertyKeys {
        
        static var parentTransaction: Void?
        static var isSavingSynchronously: Void?
        static var isTransactionContext: Void?
        static var isDataStackContext: Void?
    }
}
