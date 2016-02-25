//
//  NSManagedObject+Convenience.swift
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


// MARK: - NSFetchedResultsController

public extension NSFetchedResultsController {
    
    /**
     Utility for creating an `NSFetchedResultsController` from a `DataStack`. This is useful to partially support Objective-C classes by passing an `NSFetchedResultsController` instance instead of a `ListMonitor`.
     */
    public static func createForStack<T: NSManagedObject>(dataStack: DataStack, fetchRequest: NSFetchRequest, from: From<T>? = nil, sectionBy: SectionBy? = nil, fetchClauses: [FetchClause]) -> NSFetchedResultsController {
        
        return CoreStoreFetchedResultsController<T>(
            context: dataStack.mainContext,
            fetchRequest: fetchRequest,
            from: from,
            sectionBy: sectionBy,
            fetchClauses: fetchClauses
        )
    }
    
    @available(*, deprecated=1.5.2, message="Use NSFetchedResultsController.createForStack(_:fetchRequest:from:sectionBy:fetchClauses:) to create NSFetchedResultsControllers directly")
    public convenience init<T: NSManagedObject>(dataStack: DataStack, fetchRequest: NSFetchRequest, from: From<T>? = nil, sectionBy: SectionBy? = nil, fetchClauses: [FetchClause]) {
        
        let context = dataStack.mainContext
        from?.applyToFetchRequest(fetchRequest, context: context, applyAffectedStores: false)
        for clause in fetchClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        if let from = from {
            
            from.applyAffectedStoresForFetchedRequest(fetchRequest, context: context)
        }
        else {
            
            guard let from = (fetchRequest.entity.flatMap { $0.managedObjectClassName }).flatMap(NSClassFromString).flatMap(From.init) else {
                
                fatalError("Attempted to create an \(typeName(NSFetchedResultsController)) without a  From clause or an NSEntityDescription.")
            }
            from.applyAffectedStoresForFetchedRequest(fetchRequest, context: context)
        }
        
        self.init(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: sectionBy?.sectionKeyPath,
            cacheName: nil
        )
    }
    
    
    // MARK: Internal
    
    internal static func createFromContext<T: NSManagedObject>(context: NSManagedObjectContext, fetchRequest: NSFetchRequest, from: From<T>? = nil, sectionBy: SectionBy? = nil, fetchClauses: [FetchClause]) -> NSFetchedResultsController {
        
        return CoreStoreFetchedResultsController<T>(
            context: context,
            fetchRequest: fetchRequest,
            from: from,
            sectionBy: sectionBy,
            fetchClauses: fetchClauses
        )
    }
}
