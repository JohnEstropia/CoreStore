//
//  CoreStoreFetchedResultsController.swift
//  CoreStore
//
//  Copyright © 2016 John Rommel Estropia
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


// MARK: - CoreStoreFetchedResultsController

@available(OSX, unavailable)
internal final class CoreStoreFetchedResultsController<T: NSManagedObject>: NSFetchedResultsController {
    
    
    // MARK: Internal
    
    internal convenience init<T>(dataStack: DataStack, fetchRequest: NSFetchRequest, from: From<T>? = nil, sectionBy: SectionBy? = nil, fetchClauses: [FetchClause]) {
        
        self.init(
            context: dataStack.mainContext,
            fetchRequest: fetchRequest,
            from: from,
            sectionBy: sectionBy,
            fetchClauses: fetchClauses
        )
    }
    
    internal init<T>(context: NSManagedObjectContext, fetchRequest: NSFetchRequest, from: From<T>? = nil, sectionBy: SectionBy? = nil, fetchClauses: [FetchClause]) {
        
        from?.applyToFetchRequest(fetchRequest, context: context, applyAffectedStores: false)
        for clause in fetchClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        if let from = from {
            
            self.reapplyAffectedStores = { fetchRequest, context in
                
                return from.applyAffectedStoresForFetchedRequest(fetchRequest, context: context)
            }
        }
        else {
            
            guard let from = (fetchRequest.entity.flatMap { $0.managedObjectClassName }).flatMap(NSClassFromString).flatMap(From.init) else {
                
                fatalError("Attempted to create an \(typeName(NSFetchedResultsController)) without a  From clause or an NSEntityDescription.")
            }
            
            self.reapplyAffectedStores = { fetchRequest, context in
                
                return from.applyAffectedStoresForFetchedRequest(fetchRequest, context: context)
            }
        }
        
        super.init(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: sectionBy?.sectionKeyPath,
            cacheName: nil
        )
    }
    
    internal func performFetchFromSpecifiedStores() throws {
        
        if !self.reapplyAffectedStores(fetchRequest: self.fetchRequest, context: self.managedObjectContext) {
            
            CoreStore.log(
                .Warning,
                message: "Attempted to perform a fetch on an \(typeName(NSFetchedResultsController)) but could not find any persistent store for the entity \(typeName(self.fetchRequest.entityName))"
            )
        }
        try self.performFetch()
    }
    
    deinit {
        
        self.delegate = nil
    }
    
    
    // MARK: Private
    
    private let reapplyAffectedStores: (fetchRequest: NSFetchRequest, context: NSManagedObjectContext) -> Bool
}
