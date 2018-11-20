//
//  CoreStore+OffsetQuerying.swift
//  BlueSkyMe
//
//  Created by Sagar Shah on 16/11/18.
//  Copyright © 2018 Sagar Shah. All rights reserved.
//

import Foundation
import CoreData

public extension CoreStore {
    
    public static func fetchWithOffset<T>(_ from: From<T>, _ offset: Int, _ limit: Int, _ fetchClauses: FetchClause...) -> [T]? {
        
        return self.defaultStack.fetchWithOffset(from, offset, limit, fetchClauses)
    }
    
    public static func fetchWithOffset<T>(_ from: From<T>, _ offset: Int, _ limit: Int, _ fetchClauses: [FetchClause]) -> [T]? {
        
        return self.defaultStack.fetchWithOffset(from, offset, limit, fetchClauses)
    }
}
