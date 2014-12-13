//
//  Query.swift
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

public class Query<T: NSManagedObject> {
    
    public var entityName: String {
        
        return self.entity.entityName
    }
    
    public func WHERE(predicate: NSPredicate) -> Query<T> {
        
        if self.predicate != nil {
            
        }
        self.predicate = predicate
        return self
    }
    
    public func WHERE(value: Bool) -> Query<T> {
        
        return self.WHERE(NSPredicate(value: value))
    }
    
    public func WHERE(format: String, _ args: CVarArgType...) -> Query<T> {
        
        return self.WHERE(NSPredicate(format: format, arguments: withVaList(args, { $0 })))
    }
    
    public func WHERE(format: String, argumentArray: [AnyObject]?) -> Query<T> {
        
        return self.WHERE(NSPredicate(format: format, argumentArray: argumentArray))
    }
    
    public func SORTEDBY(order: [SortOrder]) -> Query<T> {
        
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
    
    public func SORTEDBY(order: SortOrder, _ subOrder: SortOrder...) -> Query<T> {
        
        return self.SORTEDBY([order] + subOrder)
    }
    
    public func createFetchRequestInContext(context: NSManagedObjectContext) -> NSFetchRequest {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(
            self.entityName,
            inManagedObjectContext: context)
        fetchRequest.fetchLimit = self.fetchLimit
        fetchRequest.fetchOffset = self.fetchOffset
        fetchRequest.fetchBatchSize = self.fetchBatchSize
        fetchRequest.predicate = self.predicate
        
        return fetchRequest
    }
    
    // MARK: Internal
    
    internal init(entity: T.Type) {
        
        self.entity = entity
    }
    
    
    // MARK: Private
    private let entity: T.Type
    public var fetchLimit: Int = 0
    public var fetchOffset: Int = 0
    public var fetchBatchSize: Int = 0
    public var predicate: NSPredicate?
    public var sortDescriptors: [NSSortDescriptor]?
}
