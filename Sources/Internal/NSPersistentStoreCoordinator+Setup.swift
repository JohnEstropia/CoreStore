//
//  NSPersistentStoreCoordinator+Setup.swift
//  CoreStore
//
//  Copyright © 2016 John Rommel Estropia. All rights reserved.
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

#if USE_FRAMEWORKS
    import GCDKit
#endif


// MARK: - NSPersistentStoreCoordinator

internal extension NSPersistentStoreCoordinator {
    
    @nonobjc
    internal func performAsynchronously(closure: () -> Void) {
        
        #if USE_FRAMEWORKS
            
            self.performBlock(closure)
        #else
            
            if #available(iOS 8.0, *) {
                
                self.performBlock(closure)
            }
            else {
                
                self.lock()
                GCDQueue.Default.async {
                    
                    closure()
                    self.unlock()
                }
            }
        #endif
    }
    
    @nonobjc
    internal func performSynchronously<T>(closure: () -> T) -> T {
        
        var result: T?
        #if USE_FRAMEWORKS
            
            self.performBlockAndWait {
                
                result = closure()
            }
        #else
            
            if #available(iOS 8.0, *) {
                
                self.performBlockAndWait {
                    
                    result = closure()
                }
            }
            else {
                
                self.lock()
                cs_autoreleasepool {
                    
                    result = closure()
                }
                self.unlock()
            }
        #endif
        
        return result!
    }
    
    @nonobjc
    internal func performSynchronously<T>(closure: () throws -> T) throws -> T {
        
        var closureError: ErrorType?
        var result: T?
        #if USE_FRAMEWORKS
            
            self.performBlockAndWait {
                
                do {
                    
                    result = try closure()
                }
                catch {
                    
                    closureError = error
                }
            }
        #else
            
            if #available(iOS 8.0, *) {
                
                self.performBlockAndWait {
                    
                    do {
                        
                        result = try closure()
                    }
                    catch {
                        
                        closureError = error
                    }
                }
            }
            else {
                
                self.lock()
                cs_autoreleasepool {
                    
                    do {
                        
                        result = try closure()
                    }
                    catch {
                        
                        closureError = error
                    }
                }
                self.unlock()
            }
        #endif
        
        if let closureError = closureError {
            
            throw closureError
        }
        
        return result!
    }
    
    @nonobjc
    internal func addPersistentStoreSynchronously(storeType: String, configuration: String?, URL storeURL: NSURL?, options: [NSObject : AnyObject]?) throws -> NSPersistentStore {
        
        var store: NSPersistentStore?
        var storeError: NSError?
        self.performSynchronously {
            
            do {
                
                store = try self.addPersistentStoreWithType(
                    storeType,
                    configuration: configuration,
                    URL: storeURL,
                    options: options
                )
            }
            catch {
                
                storeError = error as NSError
            }
        }
        
        if let store = store {
            
            return store
        }
        
        throw CoreStoreError(storeError)
    }
}