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


#if os(iOS) || os(watchOS) || os(tvOS)

// MARK: - NSFetchedResultsController

public extension NSFetchedResultsController {
    
    /**
     Utility for creating an `NSFetchedResultsController` from a `DataStack`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     
     - parameter dataStack: the `DataStack` to observe objects from
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: an `NSFetchedResultsController` that observes a `DataStack`
     */
    @nonobjc
    public static func createFor<T: NSManagedObject>(dataStack: DataStack, _ from: From<T>, _ sectionBy: SectionBy, _ fetchClauses: FetchClause...) -> NSFetchedResultsController {
        
        return self.createFromContext(
            dataStack.mainContext,
            fetchRequest: CoreStoreFetchRequest(),
            from: from,
            sectionBy: sectionBy,
            fetchClauses: fetchClauses
        )
    }
    
    /**
     Utility for creating an `NSFetchedResultsController` from a `DataStack`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     
     - parameter dataStack: the `DataStack` to observe objects from
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: an `NSFetchedResultsController` that observes a `DataStack`
     */
    @nonobjc
    public static func createFor<T: NSManagedObject>(dataStack: DataStack, _ from: From<T>, _ sectionBy: SectionBy, _ fetchClauses: [FetchClause]) -> NSFetchedResultsController {
        
        return self.createFromContext(
            dataStack.mainContext,
            fetchRequest: CoreStoreFetchRequest(),
            from: from,
            sectionBy: sectionBy,
            fetchClauses: fetchClauses
        )
    }
    
    /**
     Utility for creating an `NSFetchedResultsController` from a `DataStack`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     
     - parameter dataStack: the `DataStack` to observe objects from
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: an `NSFetchedResultsController` that observes a `DataStack`
     */
    @nonobjc
    public static func createFor<T: NSManagedObject>(dataStack: DataStack, _ from: From<T>, _ fetchClauses: FetchClause...) -> NSFetchedResultsController {
        
        return self.createFromContext(
            dataStack.mainContext,
            fetchRequest: CoreStoreFetchRequest(),
            from: from,
            sectionBy: nil,
            fetchClauses: fetchClauses
        )
    }
    
    /**
     Utility for creating an `NSFetchedResultsController` from a `DataStack`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     
     - parameter dataStack: the `DataStack` to observe objects from
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: an `NSFetchedResultsController` that observes a `DataStack`
     */
    @nonobjc
    public static func createFor<T: NSManagedObject>(dataStack: DataStack, _ from: From<T>, _ fetchClauses: [FetchClause]) -> NSFetchedResultsController {
        
        return self.createFromContext(
            dataStack.mainContext,
            fetchRequest: CoreStoreFetchRequest(),
            from: from,
            sectionBy: nil,
            fetchClauses: fetchClauses
        )
    }
    
    /**
     Utility for creating an `NSFetchedResultsController` from an `UnsafeDataTransaction`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     
     - parameter transaction: the `UnsafeDataTransaction` to observe objects from
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: an `NSFetchedResultsController` that observes an `UnsafeDataTransaction`
     */
    @nonobjc
    public static func createFor<T: NSManagedObject>(transaction: UnsafeDataTransaction, _ from: From<T>, _ sectionBy: SectionBy, _ fetchClauses: FetchClause...) -> NSFetchedResultsController {
        
        return self.createFromContext(
            transaction.context,
            fetchRequest: CoreStoreFetchRequest(),
            from: from,
            sectionBy: sectionBy,
            fetchClauses: fetchClauses
        )
    }
    
    /**
     Utility for creating an `NSFetchedResultsController` from an `UnsafeDataTransaction`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     
     - parameter transaction: the `UnsafeDataTransaction` to observe objects from
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: an `NSFetchedResultsController` that observes an `UnsafeDataTransaction`
     */
    @nonobjc
    public static func createFor<T: NSManagedObject>(transaction: UnsafeDataTransaction, _ from: From<T>, _ sectionBy: SectionBy, _ fetchClauses: [FetchClause]) -> NSFetchedResultsController {
        
        return self.createFromContext(
            transaction.context,
            fetchRequest: CoreStoreFetchRequest(),
            from: from,
            sectionBy: sectionBy,
            fetchClauses: fetchClauses
        )
    }
    
    /**
     Utility for creating an `NSFetchedResultsController` from an `UnsafeDataTransaction`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     
     - parameter transaction: the `UnsafeDataTransaction` to observe objects from
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: an `NSFetchedResultsController` that observes an `UnsafeDataTransaction`
     */
    @nonobjc
    public static func createFor<T: NSManagedObject>(transaction: UnsafeDataTransaction, _ from: From<T>, _ fetchClauses: FetchClause...) -> NSFetchedResultsController {
        
        return self.createFromContext(
            transaction.context,
            fetchRequest: CoreStoreFetchRequest(),
            from: from,
            sectionBy: nil,
            fetchClauses: fetchClauses
        )
    }
    
    /**
     Utility for creating an `NSFetchedResultsController` from an `UnsafeDataTransaction`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     
     - parameter transaction: the `UnsafeDataTransaction` to observe objects from
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     */
    @nonobjc
    public static func createFor<T: NSManagedObject>(transaction: UnsafeDataTransaction, _ from: From<T>, _ fetchClauses: [FetchClause]) -> NSFetchedResultsController {
        
        return self.createFromContext(
            transaction.context,
            fetchRequest: CoreStoreFetchRequest(),
            from: from,
            sectionBy: nil,
            fetchClauses: fetchClauses
        )
    }
    
    
    // MARK: Internal
    
    @nonobjc
    internal static func createFromContext<T: NSManagedObject>(context: NSManagedObjectContext, fetchRequest: NSFetchRequest, from: From<T>? = nil, sectionBy: SectionBy? = nil, fetchClauses: [FetchClause]) -> NSFetchedResultsController {
        
        return CoreStoreFetchedResultsController(
            context: context,
            fetchRequest: fetchRequest,
            from: from,
            sectionBy: sectionBy,
            applyFetchClauses: { fetchRequest in
                
                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
                
                CoreStore.assert(
                    fetchRequest.sortDescriptors?.isEmpty == false,
                    "An \(cs_typeName(NSFetchedResultsController)) requires a sort information. Specify from a \(cs_typeName(OrderBy)) clause or any custom \(cs_typeName(FetchClause)) that provides a sort descriptor."
                )
            }
        )
    }
}

#endif
