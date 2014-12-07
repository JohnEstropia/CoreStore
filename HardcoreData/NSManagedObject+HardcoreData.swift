//
//  NSManagedObject+HardcoreData.swift
//  HardcoreData
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

public extension NSManagedObject {
    
    public class var entityName: String {
        
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public class func createInContext(context: NSManagedObjectContext) -> Self {
        
        return self(entity: NSEntityDescription.entityForName(self.entityName, inManagedObjectContext: context)!,
            insertIntoManagedObjectContext: context)
    }
    
    public func inContext<T: NSManagedObject>(context: NSManagedObjectContext) -> T? {
        
        let objectID = self.objectID
        if objectID.temporaryID {
            
            var permanentIDError: NSError?
            if !context.obtainPermanentIDsForObjects([self], error: &permanentIDError) {
                
                HardcoreData.handleError(
                    permanentIDError!,
                    "Failed to obtain permanent ID for object.")
                return nil
            }
        }
        
        var existingObjectError: NSError?
        if let existingObject = context.existingObjectWithID(objectID, error: &existingObjectError) {
            
            return (existingObject as T)
        }
        
        HardcoreData.handleError(
            existingObjectError!,
            "Failed to load existing NSManagedObject in context.")
        return nil;
    }
    
    public func deleteFromContext() {
        
        self.managedObjectContext?.deleteObject(self)
    }
}