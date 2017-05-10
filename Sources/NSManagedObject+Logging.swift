//
//  NSManagedObject+Logging.swift
//  CoreStore
//
//  Copyright © 2017 John Rommel Estropia
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

internal extension NSManagedObject {
    
    @nonobjc
    internal func isRunningInAllowedQueue() -> Bool? {
        
        guard let context = self.managedObjectContext else {
            
            return nil
        }
        if context.isTransactionContext {
            
            return context.parentTransaction?.isRunningInAllowedQueue()
        }
        if context.isDataStackContext {
            
            return Thread.isMainThread
        }
        return nil
    }
    
    @nonobjc
    internal func isEditableInContext() -> Bool? {
        
        guard let context = self.managedObjectContext else {
            
            return nil
        }
        if context.isTransactionContext {
            
            return true
        }
        if context.isDataStackContext {
            
            return false
        }
        return nil
    }
    
    // TODO: test before release (rolled back)
//    @nonobjc
//    internal static func cs_swizzleMethodsForLogging() {
//
//        struct Static {
//
//            static let isSwizzled = Static.swizzle()
//            
//            private static func swizzle() -> Bool {
//                
//                NSManagedObject.cs_swizzle(
//                    original: #selector(NSManagedObject.willAccessValue(forKey:)),
//                    proxy: #selector(NSManagedObject.cs_willAccessValue(forKey:))
//                )
//                NSManagedObject.cs_swizzle(
//                    original: #selector(NSManagedObject.willChangeValue(forKey:)),
//                    proxy: #selector(NSManagedObject.cs_willChangeValue(forKey:))
//                )
//                NSManagedObject.cs_swizzle(
//                    original: #selector(NSManagedObject.willChangeValue(forKey:withSetMutation:using:)),
//                    proxy: #selector(NSManagedObject.cs_willChangeValue(forKey:withSetMutation:using:))
//                )
//                return true
//            }
//        }
//        assert(Static.isSwizzled)
//    }
//    
//    @nonobjc
//    private static func cs_swizzle(original originalSelector: Selector, proxy swizzledSelector: Selector) {
//        
//        let originalMethod = class_getInstanceMethod(NSManagedObject.self, originalSelector)
//        let swizzledMethod = class_getInstanceMethod(NSManagedObject.self, swizzledSelector)
//        let didAddMethod = class_addMethod(
//            NSManagedObject.self,
//            originalSelector,
//            method_getImplementation(swizzledMethod),
//            method_getTypeEncoding(swizzledMethod)
//        )
//        if didAddMethod {
//            
//            class_replaceMethod(
//                NSManagedObject.self,
//                swizzledSelector,
//                method_getImplementation(originalMethod),
//                method_getTypeEncoding(originalMethod)
//            )
//        }
//        else {
//            
//            method_exchangeImplementations(originalMethod, swizzledMethod)
//        }
//    }
//    
//    private dynamic func cs_willAccessValue(forKey key: String?) {
//        
//        self.cs_willAccessValue(forKey: key)
//        
//        guard CoreStore.logger.enableObjectConcurrencyDebugging else {
//            
//            return
//        }
//        
//        guard let context = self.managedObjectContext else {
//            
//            CoreStore.log(
//                .warning,
//                message: "Attempted to access the \"\(key ?? "")\" key of an object of type \(cs_typeName(self)) after has been deleted from its \(cs_typeName(NSManagedObjectContext.self))."
//            )
//            return
//        }
//        if context.isTransactionContext {
//            
//            guard let transaction = context.parentTransaction else {
//                
//                CoreStore.log(
//                    .warning,
//                    message: "Attempted to access the \"\(key ?? "")\" key of an object of type \(cs_typeName(self)) after has been deleted from its transaction."
//                )
//                return
//            }
//            CoreStore.assert(
//                transaction.isRunningInAllowedQueue(),
//                "Attempted to access the \"\(key ?? "")\" key of an object of type \(cs_typeName(self)) outside its transaction's designated queue."
//            )
//            return
//        }
//        if context.isDataStackContext {
//            
//            guard context.parentStack != nil else {
//                
//                CoreStore.log(
//                    .warning,
//                    message: "Attempted to access the \"\(key ?? "")\" key of an object of type \(cs_typeName(self)) after has been deleted from its \(cs_typeName(DataStack.self)).")
//                return
//            }
//            CoreStore.assert(
//                Thread.isMainThread,
//                "Attempted to access the \"\(key ?? "")\" key of an object of type \(cs_typeName(self)) outside the main thread."
//            )
//            return
//        }
//    }
//    
//    private dynamic func cs_willChangeValue(forKey key: String?) {
//        
//        self.cs_willChangeValue(forKey: key)
//        
//        guard CoreStore.logger.enableObjectConcurrencyDebugging else {
//            
//            return
//        }
//        
//        guard let context = self.managedObjectContext else {
//            
//            CoreStore.log(
//                .warning,
//                message: "Attempted to change the \"\(key ?? "")\" of an object of type \(cs_typeName(self)) after has been deleted from its \(cs_typeName(NSManagedObjectContext.self))."
//            )
//            return
//        }
//        if context.isTransactionContext {
//            
//            guard let transaction = context.parentTransaction else {
//                
//                CoreStore.log(
//                    .warning,
//                    message: "Attempted to change the \"\(key ?? "")\" of an object of type \(cs_typeName(self)) after has been deleted from its transaction."
//                )
//                return
//            }
//            CoreStore.assert(
//                transaction.isRunningInAllowedQueue(),
//                "Attempted to change the \"\(key ?? "")\" of an object of type \(cs_typeName(self)) outside its transaction's designated queue."
//            )
//            return
//        }
//        if context.isDataStackContext {
//            
//            guard context.parentStack != nil else {
//                
//                CoreStore.log(
//                    .warning,
//                    message: "Attempted to change the \"\(key ?? "")\" of an object of type \(cs_typeName(self)) after has been deleted from its \(cs_typeName(DataStack.self)).")
//                return
//            }
//            CoreStore.assert(
//                Thread.isMainThread,
//                "Attempted to change the \"\(key ?? "")\" of an object of type \(cs_typeName(self)) outside the main thread."
//            )
//            return
//        }
//    }
//    
//    private dynamic func cs_willChangeValue(forKey inKey: String, withSetMutation inMutationKind: NSKeyValueSetMutationKind, using inObjects: Set<AnyHashable>) {
//        
//        self.cs_willChangeValue(
//            forKey: inKey,
//            withSetMutation: inMutationKind,
//            using: inObjects
//        )
//        
//        guard CoreStore.logger.enableObjectConcurrencyDebugging else {
//            
//            return
//        }
//        
//        guard let context = self.managedObjectContext else {
//            
//            CoreStore.log(
//                .warning,
//                message: "Attempted to mutate the \"\(inKey)\" of an object of type \(cs_typeName(self)) after has been deleted from its \(cs_typeName(NSManagedObjectContext.self))."
//            )
//            return
//        }
//        if context.isTransactionContext {
//            
//            guard let transaction = context.parentTransaction else {
//                
//                CoreStore.log(
//                    .warning,
//                    message: "Attempted to mutate the \"\(inKey)\" of an object of type \(cs_typeName(self)) after has been deleted from its transaction."
//                )
//                return
//            }
//            CoreStore.assert(
//                transaction.isRunningInAllowedQueue(),
//                "Attempted to mutate the \"\(inKey)\" of an object of type \(cs_typeName(self)) outside its transaction's designated queue."
//            )
//            return
//        }
//        if context.isDataStackContext {
//            
//            guard context.parentStack != nil else {
//                
//                CoreStore.log(
//                    .warning,
//                    message: "Attempted to mutate the \"\(inKey)\" of an object of type \(cs_typeName(self)) after has been deleted from its \(cs_typeName(DataStack.self)).")
//                return
//            }
//            CoreStore.assert(
//                Thread.isMainThread,
//                "Attempted to mutate the \"\(inKey)\" of an object of type \(cs_typeName(self)) outside the main thread."
//            )
//            return
//        }
//    }
}
