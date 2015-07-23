//
//  NSManagedObjectContext+Transaction.swift
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


// MARK: - NSManagedObjectContext

internal extension NSManagedObjectContext {
    
    // MARK: Internal
    
    internal weak var parentTransaction: BaseDataTransaction? {
        
        get {
            
            return getAssociatedObjectForKey(
                &PropertyKeys.parentTransaction,
                inObject: self
            )
        }
        set {
            
            setAssociatedWeakObject(
                newValue,
                forKey: &PropertyKeys.parentTransaction,
                inObject: self
            )
        }
    }
    
    internal func temporaryContextInTransactionWithConcurrencyType(concurrencyType: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
        
        let context = NSManagedObjectContext(concurrencyType: concurrencyType)
        context.parentContext = self
        context.parentStack = self.parentStack
        context.setupForCoreStoreWithContextName("com.corestore.temporarycontext")
        context.shouldCascadeSavesToParent = (self.parentStack?.rootSavingContext == self)
        context.retainsRegisteredObjects = true
        
        return context
    }
    
    internal func saveSynchronously() -> SaveResult {
        
        var result = SaveResult(hasChanges: false)
        
        self.performBlockAndWait { [unowned self] () -> Void in
            
            if !self.hasChanges {
                
                return
            }
            
            do {
                
                try self.save()
            }
            catch {
                
                let saveError = error as NSError
                CoreStore.handleError(
                    saveError,
                    "Failed to save \(typeName(NSManagedObjectContext))."
                )
                result = SaveResult(saveError)
                return
            }
            
            if let parentContext = self.parentContext where self.shouldCascadeSavesToParent {
                
                switch parentContext.saveSynchronously() {
                    
                case .Success:
                    result = SaveResult(hasChanges: true)
                    
                case .Failure(let error):
                    result = SaveResult(error)
                }
            }
            else {
                
                result = SaveResult(hasChanges: true)
            }
        }
        
        return result
    }
    
    internal func saveAsynchronouslyWithCompletion(completion: ((result: SaveResult) -> Void)?) {
        
        self.performBlock { () -> Void in
            
            if !self.hasChanges {
                
                if let completion = completion {
                    
                    GCDQueue.Main.async {
                        
                        completion(result: SaveResult(hasChanges: false))
                    }
                }
                return
            }
            
            do {
                
                try self.save()
            }
            catch {
                
                let saveError = error as NSError
                CoreStore.handleError(
                    saveError,
                    "Failed to save \(typeName(NSManagedObjectContext))."
                )
                if let completion = completion {
                    
                    GCDQueue.Main.async {
                        
                        completion(result: SaveResult(saveError))
                    }
                }
                return
            }
            
            if let parentContext = self.parentContext where self.shouldCascadeSavesToParent {
                
                parentContext.saveAsynchronouslyWithCompletion {
                    result in
                    
                    if let completion = completion {
                        
                        GCDQueue.Main.async {
                        
                            completion(result: result)
                        }
                    }
                }
            }
            else if let completion = completion {
                
                GCDQueue.Main.async {
                    
                    completion(result: SaveResult(hasChanges: true))
                }
            }
        }
    }
    
    
    // MARK: Private
    
    private struct PropertyKeys {
        
        static var parentTransaction: Void?
    }
}
