//
//  ObjectQuery.swift
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


public typealias AttributeName = Selector

public enum SortOrder {
    
    case Ascending(AttributeName)
    case Descending(AttributeName)
}

public final class ObjectQuery<T: NSManagedObject> {
    
    public var fetchLimit: Int = 0
    public var fetchOffset: Int = 0
    public var fetchBatchSize: Int = 0
    
    public var entityName: String {
        
        return self.entity.entityName
    }
    
    public func WHERE(predicate: NSPredicate) -> ObjectQuery<T> {
        
        if self.predicate != nil {
            
            HardcoreData.log(.Warning, message: "Attempted to set a Query's WHERE clause more than once. The last predicate set will be used.")
        }
        self.predicate = predicate
        return self
    }
    
    public func WHERE(value: Bool) -> ObjectQuery<T> {
        
        return self.WHERE(NSPredicate(value: value))
    }
    
    public func WHERE(format: String, _ args: CVarArgType...) -> ObjectQuery<T> {
        
        return self.WHERE(NSPredicate(format: format, arguments: getVaList(args)))
    }
    
    public func WHERE(format: String, argumentArray: [AnyObject]?) -> ObjectQuery<T> {
        
        return self.WHERE(NSPredicate(format: format, argumentArray: argumentArray))
    }
    
    public func WHERE(attributeName: AttributeName, isEqualTo value: NSObject?) -> ObjectQuery<T> {
        
        return self.WHERE(value == nil
            ? NSPredicate(format: "\(attributeName) == nil")!
            : NSPredicate(format: "\(attributeName) == %@", value!)!)
    }
    
    public func SORTEDBY(order: [SortOrder]) -> ObjectQuery<T> {
        
        if self.sortDescriptors != nil {
            
            HardcoreData.log(.Warning, message: "Attempted to set a Query's SORTEDBY clause more than once. The last sort order set will be used.")
        }
        self.sortDescriptors = order.map { sortOrder in
            
            switch sortOrder {
                
            case .Ascending(let attributeName):
                return NSSortDescriptor(
                    key: NSStringFromSelector(attributeName),
                    ascending: true)
                
            case .Descending(let attributeName):
                return NSSortDescriptor(
                    key: NSStringFromSelector(attributeName),
                    ascending: false)
            }
        }
        return self
    }
    
    public func SORTEDBY(order: SortOrder, _ subOrder: SortOrder...) -> ObjectQuery<T> {
        
        return self.SORTEDBY([order] + subOrder)
    }
    
    // MARK: Internal
    
    internal init(entity: T.Type) {
        
        self.entity = entity
    }
    
    internal func createFetchRequestForContext(context: NSManagedObjectContext) -> NSFetchRequest {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(
            self.entityName,
            inManagedObjectContext: context)
        fetchRequest.predicate = self.predicate
        fetchRequest.sortDescriptors = self.sortDescriptors
        
        return fetchRequest
    }
    
    
    // MARK: Private
    private let entity: T.Type
    private var predicate: NSPredicate?
    private var sortDescriptors: [NSSortDescriptor]?
}
