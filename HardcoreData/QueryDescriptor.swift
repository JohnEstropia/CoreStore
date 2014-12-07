//
//  QueryDescriptor.swift
//  HardcoreData
//
//  Created by John Rommel Estropia on 14/11/16.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

import Foundation
import CoreData

public struct QueryDescriptor<T: NSManagedObject> {
    
    public var entityName: String {
        
        return self.entity.entityName
    }
    
    // MARK: Internal
    
    internal init(entity: T.Type) {
        self.entity = entity
    }
    
    
    // MARK: Private
    private let entity: T.Type
    private var predicate: NSPredicate?
    private var sortDescriptors: [NSSortDescriptor]?
}