//
//  NSManagedObject+Transaction.swift
//  CoreStore
//
//  Copyright (c) 2014 John Rommel Estropia
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
    
    // MARK: Internal
    
    internal dynamic class func createInContext(context: NSManagedObjectContext) -> Self {
        
        return self(
            entity: context.entityDescriptionForEntityType(self)!,
            insertIntoManagedObjectContext: context
        )
    }
    
    internal dynamic class func inContext(context: NSManagedObjectContext, withObjectID objectID: NSManagedObjectID) -> Self? {
        
        return self.typedObjectInContext(context, objectID: objectID)
    }
    
    internal func inContext(context: NSManagedObjectContext) -> Self? {
        
        return self.typedObjectInContext(context)
    }
    
    internal func deleteFromContext() {
        
        self.managedObjectContext?.deleteObject(self)
    }
    
    
    // MARK: Private
    
    private class func typedObjectInContext<T: NSManagedObject>(context: NSManagedObjectContext, objectID: NSManagedObjectID) -> T? {
        
        var error: NSError?
        if let existingObject = context.existingObjectWithID(objectID, error: &error) {
            
            return (existingObject as! T)
        }
        
        CoreStore.handleError(
            error ?? NSError(coreStoreErrorCode: .UnknownError),
            "Failed to load existing \(typeName(self)) in context.")
        return nil;
    }
    
    private func typedObjectInContext<T: NSManagedObject>(context: NSManagedObjectContext) -> T? {
        
        let objectID = self.objectID
        if objectID.temporaryID {

            var error: NSError?
            let didSucceed = withExtendedLifetime(self.managedObjectContext) {
                
                return $0?.obtainPermanentIDsForObjects([self], error: &error)
            }
            if didSucceed != true {
                
                CoreStore.handleError(
                    error ?? NSError(coreStoreErrorCode: .UnknownError),
                    "Failed to obtain permanent ID for object.")
                return nil
            }
        }

        var error: NSError?
        if let existingObject = context.existingObjectWithID(objectID, error: &error) {
            
            return (existingObject as! T)
        }
        
        CoreStore.handleError(
            error ?? NSError(coreStoreErrorCode: .UnknownError),
            "Failed to load existing \(typeName(self)) in context.")
        return nil;
    }
}
