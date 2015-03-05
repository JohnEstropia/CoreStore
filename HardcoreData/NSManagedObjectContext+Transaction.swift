//
//  NSManagedObjectContext+Transaction.swift
//  HardcoreData
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
    
    internal weak var parentTransaction: DataTransaction? {
        
        get {
            
            return self.getAssociatedObjectForKey(&PropertyKeys.parentTransaction)
        }
        set {
            
            self.setAssociatedWeakObject(
                newValue,
                forKey: &PropertyKeys.parentTransaction)
        }
    }
    
    internal func temporaryContextInTransaction(transaction: DataTransaction?) -> NSManagedObjectContext {
        
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = self
        context.parentStack = self.parentStack
        context.setupForHardcoreDataWithContextName("com.hardcoredata.temporarycontext")
        context.shouldCascadeSavesToParent = (self.concurrencyType == .MainQueueConcurrencyType)
        
        return context
    }
    
    internal func saveSynchronously() -> SaveResult {
        
        var result = SaveResult(hasChanges: false)
        self.performBlockAndWait {
            [unowned self] () -> Void in
            
            if !self.hasChanges {
                
                return
            }
            
            var saveError: NSError?
            if self.save(&saveError) {
                
                if self.shouldCascadeSavesToParent {
                    
                    if let parentContext = self.parentContext {
                        
                        switch parentContext.saveSynchronously() {
                            
                        case .Success(let hasChanges):
                            result = SaveResult(hasChanges: true)
                        case .Failure(let error):
                            result = SaveResult(error)
                        }
                        return
                    }
                }
                
                result = SaveResult(hasChanges: true)
            }
            else if let error = saveError {
                
                HardcoreData.handleError(
                    error,
                    "Failed to save <\(NSManagedObjectContext.self)>.")
                result = SaveResult(error)
            }
            else {
                
                result = SaveResult(hasChanges: false)
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
            
            var saveError: NSError?
            if self.save(&saveError) {
                
                if self.shouldCascadeSavesToParent {
                    
                    if let parentContext = self.parentContext {
                        
                        let result = parentContext.saveSynchronously()
                        if let completion = completion {
                            
                            GCDQueue.Main.async {
                                
                                completion(result: result)
                            }
                        }
                        return
                    }
                }
                
                if let completion = completion {
                    
                    GCDQueue.Main.async {
                        
                        completion(result: SaveResult(hasChanges: true))
                    }
                }
            }
            else if let error = saveError {
                
                HardcoreData.handleError(
                    error,
                    "Failed to save <\(NSManagedObjectContext.self)>.")
                if let completion = completion {
                    
                    GCDQueue.Main.async {
                        
                        completion(result: SaveResult(error))
                    }
                }
            }
            else if let completion = completion {
                
                GCDQueue.Main.async {
                    
                    completion(result: SaveResult(hasChanges: false))
                }
            }
        }
    }
    
    
    // MARK: Private
    
    private struct PropertyKeys {
        
        static var parentTransaction: Void?
    }
}