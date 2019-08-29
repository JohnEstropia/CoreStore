//
//  NSManagedObjectContext+ObjectiveC.swift
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


// MARK: - NSManagedObjectContext

extension NSManagedObjectContext {

    // MARK: Internal
    
    @nonobjc
    internal func fetchOne(_ from: CSFrom, _ fetchClauses: [CSFetchClause]) throws -> NSManagedObject? {
        
        let fetchRequest = Internals.CoreStoreFetchRequest<NSManagedObject>()
        try from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .managedObjectResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

        return try self.fetchOne(fetchRequest)
    }
    
    @nonobjc
    internal func fetchAll<T: NSManagedObject>(_ from: CSFrom, _ fetchClauses: [CSFetchClause]) throws -> [T] {
        
        let fetchRequest = Internals.CoreStoreFetchRequest<T>()
        try from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .managedObjectResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

        return try self.fetchAll(fetchRequest)
    }
    
    @nonobjc
    internal func fetchCount(_ from: CSFrom, _ fetchClauses: [CSFetchClause]) throws -> Int {
        
        let fetchRequest = Internals.CoreStoreFetchRequest<NSNumber>()
        try from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)

        fetchRequest.resultType = .countResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

        return try self.fetchCount(fetchRequest)
    }
    
    @nonobjc
    internal func fetchObjectID(_ from: CSFrom, _ fetchClauses: [CSFetchClause]) throws -> NSManagedObjectID? {
        
        let fetchRequest = Internals.CoreStoreFetchRequest<NSManagedObjectID>()
        try from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .managedObjectIDResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

        return try self.fetchObjectID(fetchRequest)
    }
    
    @nonobjc
    internal func fetchObjectIDs(_ from: CSFrom, _ fetchClauses: [CSFetchClause]) throws -> [NSManagedObjectID] {
        
        let fetchRequest = Internals.CoreStoreFetchRequest<NSManagedObjectID>()
        try from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .managedObjectIDResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

        return try self.fetchObjectIDs(fetchRequest)
    }
    
    @nonobjc
    internal func deleteAll(_ from: CSFrom, _ deleteClauses: [CSDeleteClause]) throws -> Int {
        
        let fetchRequest = Internals.CoreStoreFetchRequest<NSManagedObject>()
        try from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .managedObjectResultType
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.includesPropertyValues = false
        deleteClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

        return try self.deleteAll(fetchRequest)
    }
    
    @nonobjc
    internal func queryValue(_ from: CSFrom, _ selectClause: CSSelect, _ queryClauses: [CSQueryClause]) throws -> Any? {
        
        let fetchRequest = Internals.CoreStoreFetchRequest<NSDictionary>()
        try from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        
        selectClause.applyToFetchRequest(fetchRequest)
        queryClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

        return try self.queryValue(selectClause.selectTerms, fetchRequest: fetchRequest)
    }
    
    @nonobjc
    internal func queryAttributes(_ from: CSFrom, _ selectClause: CSSelect, _ queryClauses: [CSQueryClause]) throws -> [[String: Any]] {
        
        let fetchRequest = Internals.CoreStoreFetchRequest<NSDictionary>()
        try from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        
        selectClause.applyToFetchRequest(fetchRequest)
        queryClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

        return try self.queryAttributes(fetchRequest)
    }
}
