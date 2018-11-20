//
//  CSBaseDataTransaction+OffsetQuerying.swift
//  BlueSkyMe
//
//  Created by Sagar Shah on 16/11/18.
//  Copyright © 2018 Sagar Shah. All rights reserved.
//

import Foundation
import CoreData

public extension CSBaseDataTransaction {
    
    @objc
    public func fetchWithOffsetFrom(_ from: CSFrom, _ offset: Int, _ limit: Int, fetchClauses: [CSFetchClause]) -> [Any]? {
        
        CoreStore.assert(
            self.swiftTransaction.isRunningInAllowedQueue(),
            "Attempted to fetch from a \(cs_typeName(self)) outside its designated queue."
        )
        return self.swiftTransaction.context.fetchWithOffset(from, offset, limit, fetchClauses)
    }
}
