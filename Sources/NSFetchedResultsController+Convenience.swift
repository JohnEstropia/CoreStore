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


// MARK: - DataStack

@available(OSX 10.12, *)
public extension DataStack {
    
    /**
     Utility for creating an `NSFetchedResultsController` from the `DataStack`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     - Note: It is the caller's responsibility to call `performFetch()` on the created `NSFetchedResultsController`.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: an `NSFetchedResultsController` that observes the `DataStack`
     */
    @nonobjc
    public func createFetchedResultsController<T: NSManagedObject>(_ from: From<T>, _ sectionBy: SectionBy, _ fetchClauses: FetchClause...) -> NSFetchedResultsController<T> {
        
        return createFRC(
            fromContext: self.mainContext,
            from: from,
            sectionBy: sectionBy,
            fetchClauses: fetchClauses
        )
    }
    
    /**
     Utility for creating an `NSFetchedResultsController` from a `DataStack`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     - Note: It is the caller's responsibility to call `performFetch()` on the created `NSFetchedResultsController`.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: an `NSFetchedResultsController` that observes the `DataStack`
     */
    @nonobjc
    public func createFetchedResultsController<T: NSManagedObject>(_ from: From<T>, _ sectionBy: SectionBy, _ fetchClauses: [FetchClause]) -> NSFetchedResultsController<T> {
        
        return createFRC(
            fromContext: self.mainContext,
            from: from,
            sectionBy: sectionBy,
            fetchClauses: fetchClauses
        )
    }
    
    /**
     Utility for creating an `NSFetchedResultsController` from the `DataStack`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     - Note: It is the caller's responsibility to call `performFetch()` on the created `NSFetchedResultsController`.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: an `NSFetchedResultsController` that observes the `DataStack`
     */
    @nonobjc
    public func createFetchedResultsController<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: FetchClause...) -> NSFetchedResultsController<T> {
        
        return createFRC(
            fromContext: self.mainContext,
            from: from,
            sectionBy: nil,
            fetchClauses: fetchClauses
        )
    }
    
    /**
     Utility for creating an `NSFetchedResultsController` from the `DataStack`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     - Note: It is the caller's responsibility to call `performFetch()` on the created `NSFetchedResultsController`.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: an `NSFetchedResultsController` that observes the `DataStack`
     */
    @nonobjc
    public func createFetchedResultsController<T: NSManagedObject>(forDataStack dataStack: DataStack, _ from: From<T>, _ fetchClauses: [FetchClause]) -> NSFetchedResultsController<T> {
        
        return createFRC(
            fromContext: self.mainContext,
            from: from,
            sectionBy: nil,
            fetchClauses: fetchClauses
        )
    }
}


// MARK: - UnsafeDataTransaction

@available(OSX 10.12, *)
public extension UnsafeDataTransaction {
    
    /**
     Utility for creating an `NSFetchedResultsController` from the `UnsafeDataTransaction`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     - Note: It is the caller's responsibility to call `performFetch()` on the created `NSFetchedResultsController`.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: an `NSFetchedResultsController` that observes the `UnsafeDataTransaction`
     */
    @nonobjc
    public func createFetchedResultsController<T: NSManagedObject>(_ from: From<T>, _ sectionBy: SectionBy, _ fetchClauses: FetchClause...) -> NSFetchedResultsController<T> {
        
        return createFRC(
            fromContext: self.context,
            from: from,
            sectionBy: sectionBy,
            fetchClauses: fetchClauses
        )
    }
    
    /**
     Utility for creating an `NSFetchedResultsController` from the `UnsafeDataTransaction`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     - Note: It is the caller's responsibility to call `performFetch()` on the created `NSFetchedResultsController`.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter sectionBy: a `SectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: an `NSFetchedResultsController` that observes the `UnsafeDataTransaction`
     */
    @nonobjc
    public func createFetchedResultsController<T: NSManagedObject>(_ from: From<T>, _ sectionBy: SectionBy, _ fetchClauses: [FetchClause]) -> NSFetchedResultsController<T> {
        
        return createFRC(
            fromContext: self.context,
            from: from,
            sectionBy: sectionBy,
            fetchClauses: fetchClauses
        )
    }
    
    /**
     Utility for creating an `NSFetchedResultsController` from the `UnsafeDataTransaction`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     - Note: It is the caller's responsibility to call `performFetch()` on the created `NSFetchedResultsController`.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: an `NSFetchedResultsController` that observes the `UnsafeDataTransaction`
     */
    @nonobjc
    public func createFetchedResultsController<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: FetchClause...) -> NSFetchedResultsController<T> {
        
        return createFRC(
            fromContext: self.context,
            from: from,
            sectionBy: nil,
            fetchClauses: fetchClauses
        )
    }
    
    /**
     Utility for creating an `NSFetchedResultsController` from the `UnsafeDataTransaction`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `ListMonitor`s abstraction.
     - Note: It is the caller's responsibility to call `performFetch()` on the created `NSFetchedResultsController`.
     
     - parameter from: a `From` clause indicating the entity type
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `Where`, `OrderBy`, and `Tweak` clauses.
     - returns: an `NSFetchedResultsController` that observes the `UnsafeDataTransaction`
     */
    @nonobjc
    public func createFetchedResultsController<T: NSManagedObject>(_ from: From<T>, _ fetchClauses: [FetchClause]) -> NSFetchedResultsController<T> {
        
        return createFRC(
            fromContext: self.context,
            from: from,
            sectionBy: nil,
            fetchClauses: fetchClauses
        )
    }
}



// MARK: - Private

@available(OSX 10.12, *)
fileprivate func createFRC<T: NSManagedObject>(fromContext context: NSManagedObjectContext, from: From<T>, sectionBy: SectionBy? = nil, fetchClauses: [FetchClause]) -> NSFetchedResultsController<T> {
    
    let controller = CoreStoreFetchedResultsController(
        context: context,
        fetchRequest: CoreStoreFetchRequest().dynamicCast(),
        from: from,
        sectionBy: sectionBy,
        applyFetchClauses: { (fetchRequest) in
            
            fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) }
            
            CoreStore.assert(
                fetchRequest.sortDescriptors?.isEmpty == false,
                "An \(cs_typeName(NSFetchedResultsController<NSManagedObject>.self)) requires a sort information. Specify from a \(cs_typeName(OrderBy.self)) clause or any custom \(cs_typeName(FetchClause.self)) that provides a sort descriptor."
            )
        }
    )
    return controller.dynamicCast()
}
