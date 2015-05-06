//
//  HardcoreData+Observing.swift
//  HardcoreData
//
//  Created by John Rommel Estropia on 2015/05/06.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import Foundation


// MARK: - HardcoreData

public extension HardcoreData {
    
    // MARK: Public
    
    public static func observeObject<T: NSManagedObject>(object: T) -> ManagedObjectController<T> {
        
        return self.defaultStack.observeObject(object)
    }
    
    public static func observeObjectList<T: NSManagedObject>(from: From<T>, _ groupBy: GroupBy? = nil, _ queryClauses: FetchClause...) -> ManagedObjectListController<T> {
        
        return self.defaultStack.observeObjectList(from, groupBy, queryClauses)
    }
}