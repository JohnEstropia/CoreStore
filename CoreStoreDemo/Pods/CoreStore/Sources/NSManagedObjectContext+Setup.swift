//
//  NSManagedObjectContext+Setup.swift
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
    internal weak var parentStack: DataStack? {
        
        get {
            
            if let parentContext = self.parent {
                
                return parentContext.parentStack
            }
            
            return cs_getAssociatedObjectForKey(&PropertyKeys.parentStack, inObject: self)
        }
        set {
            
            guard self.parent == nil else {
                
                return
            }
            
            cs_setAssociatedWeakObject(
                newValue,
                forKey: &PropertyKeys.parentStack,
                inObject: self
            )
        }
    }
    
    @nonobjc
    internal static func rootSavingContextForCoordinator(_ coordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext {
        
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
        context.setupForCoreStoreWithContextName("com.corestore.rootcontext")
        
        #if os(iOS) || os(OSX)
            
        context.observerForDidImportUbiquitousContentChangesNotification = NotificationObserver(
            notificationName: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges,
            object: coordinator,
            closure: { [weak context] (note) -> Void in
                
                context?.perform { () -> Void in
                    
                    if let updatedObjectIDs = (note.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObjectID>) {
                        
                        for objectID in updatedObjectIDs {
                            
                            context?.registeredObject(for: objectID)?.willAccessValue(forKey: nil)
                        }
                    }
                    context?.mergeChanges(fromContextDidSave: note)
                }
            }
        )
            
        #endif
        
        return context
    }
    
    @nonobjc
    internal static func mainContextForRootContext(_ rootContext: NSManagedObjectContext) -> NSManagedObjectContext {
        
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = rootContext
        context.mergePolicy = NSRollbackMergePolicy
        context.undoManager = nil
        context.setupForCoreStoreWithContextName("com.corestore.maincontext")
        context.observerForDidSaveNotification = NotificationObserver(
            notificationName: NSNotification.Name.NSManagedObjectContextDidSave,
            object: rootContext,
            closure: { [weak context] (note) -> Void in
                
                guard let rootContext = note.object as? NSManagedObjectContext,
                    let context = context else {
                        
                        return
                }
                let mergeChanges = { () -> Void in
                    
                    if let updatedObjects = (note.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>) {
                        
                        for object in updatedObjects {
                            
                            context.object(with: object.objectID).willAccessValue(forKey: nil)
                        }
                    }
                    context.mergeChanges(fromContextDidSave: note)
                }
                if rootContext.isSavingSynchronously == true {
                    
                    context.performAndWait(mergeChanges)
                }
                else {
                    
                    context.perform(mergeChanges)
                }
            }
        )
        return context
    }
    
    
    // MARK: Private
    
    private struct PropertyKeys {
        
        static var parentStack: Void?
        static var observerForDidSaveNotification: Void?
        static var observerForDidImportUbiquitousContentChangesNotification: Void?
    }
    
    @nonobjc
    private var observerForDidSaveNotification: NotificationObserver? {
        
        get {
            
            return cs_getAssociatedObjectForKey(
                &PropertyKeys.observerForDidSaveNotification,
                inObject: self
            )
        }
        set {
            
            cs_setAssociatedRetainedObject(
                newValue,
                forKey: &PropertyKeys.observerForDidSaveNotification,
                inObject: self
            )
        }
    }
    
    @nonobjc
    private var observerForDidImportUbiquitousContentChangesNotification: NotificationObserver? {
        
        get {
            
            return cs_getAssociatedObjectForKey(
                &PropertyKeys.observerForDidImportUbiquitousContentChangesNotification,
                inObject: self
            )
        }
        set {
            
            cs_setAssociatedRetainedObject(
                newValue,
                forKey: &PropertyKeys.observerForDidImportUbiquitousContentChangesNotification,
                inObject: self
            )
        }
    }
}
