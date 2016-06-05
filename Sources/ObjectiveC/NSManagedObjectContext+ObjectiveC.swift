//
//  NSManagedObjectContext+ObjectiveC.swift
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


// MARK: - NSManagedObjectContext

internal extension NSManagedObjectContext {

    // MARK: Internal
    
    @nonobjc
    internal func fetchOne(from: CSFrom, _ fetchClauses: [CSFetchClause]) -> NSManagedObject? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .ManagedObjectResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchOne(fetchRequest)
    }
    
    @nonobjc
    internal func fetchAll(from: CSFrom, _ fetchClauses: [CSFetchClause]) -> [NSManagedObject]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchAll(fetchRequest)
    }
    
    @nonobjc
    internal func fetchCount(from: CSFrom, _ fetchClauses: [CSFetchClause]) -> Int? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchCount(fetchRequest)
    }
    
    @nonobjc
    internal func fetchObjectID(from: CSFrom, _ fetchClauses: [CSFetchClause]) -> NSManagedObjectID? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .ManagedObjectIDResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchObjectID(fetchRequest)
    }
    
    @nonobjc
    internal func fetchObjectIDs(from: CSFrom, _ fetchClauses: [CSFetchClause]) -> [NSManagedObjectID]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectIDResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.fetchObjectIDs(fetchRequest)
    }
    
    @nonobjc
    internal func deleteAll(from: CSFrom, _ deleteClauses: [CSDeleteClause]) -> Int? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectResultType
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.includesPropertyValues = false
        deleteClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.deleteAll(fetchRequest)
    }
    
    @nonobjc
    internal func queryValue(from: CSFrom, _ selectClause: CSSelect, _ queryClauses: [CSQueryClause]) -> AnyObject? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        
        let selectTerms = selectClause.selectTerms
        selectTerms.applyToFetchRequest(fetchRequest, owner: selectClause)
        queryClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.queryValue(selectTerms, fetchRequest: fetchRequest)
    }
    
    @nonobjc
    internal func queryAttributes(from: CSFrom, _ selectClause: CSSelect, _ queryClauses: [CSQueryClause]) -> [[NSString: AnyObject]]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.bridgeToSwift.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchLimit = 0
        
        selectClause.selectTerms.applyToFetchRequest(fetchRequest, owner: selectClause)
        queryClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        return self.queryAttributes(fetchRequest)
    }
}
