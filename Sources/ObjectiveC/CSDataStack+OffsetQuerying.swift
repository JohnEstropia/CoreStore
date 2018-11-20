//
//  CSDataStack+OffsetQuerying.swift
//  BlueSkyMe
//
//  Created by Sagar Shah on 16/11/18.
//  Copyright © 2018 Sagar Shah. All rights reserved.
//

import Foundation
import CoreData

public extension CSDataStack {
    
    @objc
    public func fetchWithOffsetFrom(_ from: CSFrom, _ offset: Int, _ limit: Int, fetchClauses: [CSFetchClause]) -> [Any]? {
        
        CoreStore.assert(
            Thread.isMainThread,
            "Attempted to fetch from a \(cs_typeName(self)) outside the main thread."
        )
        return self.bridgeToSwift.mainContext.fetchWithOffset(from, offset, limit, fetchClauses)
    }
}
