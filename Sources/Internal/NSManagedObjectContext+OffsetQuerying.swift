//
//  NSManagedObjectContext+OffsetObjectiveC.swift
//  BlueSkyMe
//
//  Created by Sagar Shah on 16/11/18.
//  Copyright © 2018 Sagar Shah. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    @nonobjc
    public func fetchWithOffset<T>(_ from: From<T>, _ offset: Int, _ limit: Int, _ fetchClauses: FetchClause...) -> [T]? {
        
        return self.fetchWithOffset(from, offset, limit, fetchClauses)
    }
    
    @nonobjc
    public func fetchWithOffset<T>(_ from: From<T>, _ offset: Int, _ limit: Int, _ fetchClauses: [FetchClause]) -> [T]? {
        
        let fetchRequest = CoreStoreFetchRequest()
        let storeFound = from.applyToFetchRequest(fetchRequest, context: self)
        
        fetchRequest.fetchOffset = offset
        fetchRequest.fetchLimit = limit
        fetchRequest.resultType = .managedObjectResultType
        fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }
        
        guard storeFound else {
            
            return nil
        }
        let entityClass = from.entityClass
        return self.fetchAll(fetchRequest.dynamicCast())?.map(entityClass.cs_fromRaw)
        
    }
}
