//
//  CSCoreStore+OffsetQuerying.swift
//  BlueSkyMe
//
//  Created by Sagar Shah on 16/11/18.
//  Copyright © 2018 Sagar Shah. All rights reserved.
//

import Foundation
import CoreData

public extension CSCoreStore {
    
    @objc
    public static func fetchWithOffsetFrom(_ from: CSFrom, _ offset: Int, _ limit: Int, fetchClauses: [CSFetchClause]) -> [Any]? {
        
        return self.defaultStack.fetchWithOffsetFrom(from, offset, limit, fetchClauses: fetchClauses)
    }
}
