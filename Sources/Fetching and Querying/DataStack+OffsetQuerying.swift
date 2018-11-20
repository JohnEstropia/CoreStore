//
//  DataStack+OffsetQuerying.swift
//  BlueSkyMe
//
//  Created by Sagar Shah on 16/11/18.
//  Copyright © 2018 Sagar Shah. All rights reserved.
//

import Foundation
import CoreData

extension DataStack {
    
    public func fetchWithOffset<T>(_ from: From<T>, _ offset: Int, _ limit: Int, _ fetchClauses: FetchClause...) -> [T]? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to fetch from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.fetchWithOffset(from, offset, limit, fetchClauses)
    }
    
    public func fetchWithOffset<T>(_ from: From<T>, _ offset: Int, _ limit: Int, _ fetchClauses: [FetchClause]) -> [T]? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to fetch from a \(cs_typeName(self)) outside the main thread."
        )
        return self.mainContext.fetchWithOffset(from, offset, limit, fetchClauses)
    }
}
