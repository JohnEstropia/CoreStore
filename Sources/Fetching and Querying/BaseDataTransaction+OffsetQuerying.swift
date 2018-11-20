//
//  BaseDataTransaction+OffsetQuerying.swift
//  BlueSkyMe
//
//  Created by Sagar Shah on 16/11/18.
//  Copyright © 2018 Sagar Shah. All rights reserved.
//

import Foundation

extension BaseDataTransaction {
    
    public func fetchWithOffset<T>(_ from: From<T>, _ offset: Int, _ limit: Int, _ fetchClauses: FetchClause...) -> [T]? {
        
        CoreStore.assert(
            self.isRunningInAllowedQueue(),
            "Attempted to fetch from a \(cs_typeName(self)) outside its designated queue."
        )
        return self.context.fetchWithOffset(from, offset, limit, fetchClauses)
    }
    
    public func fetchWithOffset<T>(_ from: From<T>, _ offset: Int, _ limit: Int, _ fetchClauses: [FetchClause]) -> [T]? {
        
        CoreStore.assert(
            self.isRunningInAllowedQueue(),
            "Attempted to fetch from a \(cs_typeName(self)) outside its designated queue."
        )
        return self.context.fetchWithOffset(from, offset, limit, fetchClauses)
    }
}
