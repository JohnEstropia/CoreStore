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
    
    // MARK: - Entity Utilities
    
    public class var entityName: String {
        
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public func inContext(context: NSManagedObjectContext) -> Self? {
        
        return self.typedObjectInContext(context)
    }
    
    public func deleteFromContext() {
        
        self.managedObjectContext?.deleteObject(self)
    }
    
    
    // MARK: Querying
    
    public class func WHERE(predicate: NSPredicate) -> ObjectQuery<NSManagedObject> {
        
        return ObjectQuery(entity: self).WHERE(predicate)
    }
    
    public class func WHERE(value: Bool) -> ObjectQuery<NSManagedObject> {
        
        return self.WHERE(NSPredicate(value: value))
    }
    
    public class func WHERE(format: String, _ args: CVarArgType...) -> ObjectQuery<NSManagedObject> {
        
        return self.WHERE(NSPredicate(format: format, arguments: getVaList(args)))
    }
    
    public class func WHERE(format: String, argumentArray: [AnyObject]?) -> ObjectQuery<NSManagedObject> {
        
        return self.WHERE(NSPredicate(format: format, argumentArray: argumentArray))
    }
    
    public class func WHERE(attributeName: AttributeName, isEqualTo value: NSObject?) -> ObjectQuery<NSManagedObject> {
        
        return ObjectQuery(entity: self).WHERE(attributeName, isEqualTo: value)
    }
    
    public class func SORTEDBY(order: [SortOrder]) -> ObjectQuery<NSManagedObject> {
        
        return ObjectQuery(entity: self).SORTEDBY(order)
    }
    
    public class func SORTEDBY(order: SortOrder, _ subOrder: SortOrder...) -> ObjectQuery<NSManagedObject> {
        
        return self.SORTEDBY([order] + subOrder)
    }
    
    
    
    // MARK: - Internal
    
    internal class func createInContext(context: NSManagedObjectContext) -> Self {
        
        return self(entity: NSEntityDescription.entityForName(self.entityName, inManagedObjectContext: context)!,
            insertIntoManagedObjectContext: context)
    }
    
    private func typedObjectInContext<T: NSManagedObject>(context: NSManagedObjectContext) -> T? {
        
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
}