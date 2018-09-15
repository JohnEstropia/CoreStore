//
//  NSFetchedResultsController+ObjectiveC.swift
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
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


// MARK: - CSDataStack

@available(macOS 10.12, *)
public extension CSDataStack {
    
    @available(*, deprecated, message: "CoreStore will obsolete NSFetchedResultsController support in the future in favor of CSListMonitor")
    @objc
    public func createFetchedResultsControllerFrom(_ from: CSFrom, sectionBy: CSSectionBy, fetchClauses: [CSFetchClause]) -> NSFetchedResultsController<NSManagedObject> {
        
        return createFRC(
            fromContext: self.bridgeToSwift.mainContext,
            from: from,
            sectionBy: sectionBy,
            fetchClauses: fetchClauses
        )
    }
}
    
    
// MARK: - CSUnsafeDataTransaction

@available(macOS 10.12, *)
public extension CSUnsafeDataTransaction {
    
    @available(*, deprecated, message: "CoreStore will obsolete NSFetchedResultsController support in the future in favor of CSListMonitor")
    @objc
    public func createFetchedResultsControllerFrom(_ from: CSFrom, sectionBy: CSSectionBy, fetchClauses: [CSFetchClause]) -> NSFetchedResultsController<NSManagedObject> {
        
        return createFRC(
            fromContext: self.bridgeToSwift.context,
            from: from,
            sectionBy: sectionBy,
            fetchClauses: fetchClauses
        )
    }
}
    
    
// MARK: - Private

@available(macOS 10.12, *)
fileprivate func createFRC(fromContext context: NSManagedObjectContext, from: CSFrom, sectionBy: CSSectionBy?, fetchClauses: [CSFetchClause]) -> NSFetchedResultsController<NSManagedObject> {
    
    let controller = CoreStoreFetchedResultsController(
        context: context,
        fetchRequest: CoreStoreFetchRequest().dynamicCast(),
        from: from.bridgeToSwift,
        sectionBy: sectionBy?.bridgeToSwift,
        applyFetchClauses: { (fetchRequest) in
            
            fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) }
            
            CoreStore.assert(
                fetchRequest.sortDescriptors?.isEmpty == false,
                "An \(cs_typeName(NSFetchedResultsController<NSManagedObject>.self)) requires a sort information. Specify from a \(cs_typeName(CSOrderBy.self)) clause or any custom \(cs_typeName(CSFetchClause.self)) that provides a sort descriptor."
            )
        }
    )
    return controller.dynamicCast()
}
