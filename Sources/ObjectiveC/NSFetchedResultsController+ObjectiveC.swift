//
//  NSFetchedResultsController+ObjectiveC.swift
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


#if os(iOS) || os(watchOS) || os(tvOS)

// MARK: - NSFetchedResultsController

public extension NSFetchedResultsController {
    
    /**
     Utility for creating an `NSFetchedResultsController` from a `CSDataStack`. This is useful when an `NSFetchedResultsController` is preferred over the overhead of `CSListMonitor`s abstractio
     
     - parameter dataStack: the `CSDataStack` to observe objects from
     - parameter fetchRequest: the `NSFetchRequest` instance to use with the `NSFetchedResultsController`
     - parameter from: an optional `CSFrom` clause indicating the entity type. If not specified, the `fetchRequest` argument's `entity` property should already be set.
     - parameter sectionBy: a `CSSectionBy` clause indicating the keyPath for the attribute to use when sorting the list into sections.
     - parameter fetchClauses: a series of `FetchClause` instances for fetching the object list. Accepts `CSWhere`, `CSOrderBy`, and `CSTweak` clauses.
     */
    @objc
    public static func cs_createForStack(dataStack: CSDataStack, fetchRequest: NSFetchRequest, from: CSFrom?, sectionBy: CSSectionBy?, fetchClauses: [CSFetchClause]) -> NSFetchedResultsController {
        
        return CoreStoreFetchedResultsController(
            context: dataStack.bridgeToSwift.mainContext,
            fetchRequest: fetchRequest,
            from: from?.bridgeToSwift,
            sectionBy: sectionBy?.bridgeToSwift,
            applyFetchClauses: { fetchRequest in
                
                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

                CoreStore.assert(
                    fetchRequest.sortDescriptors?.isEmpty == false,
                    "An \(cs_typeName(NSFetchedResultsController)) requires a sort information. Specify from a \(cs_typeName(CSOrderBy)) clause or any custom \(cs_typeName(CSFetchClause)) that provides a sort descriptor."
                )
            }
        )
    }
}

#endif
