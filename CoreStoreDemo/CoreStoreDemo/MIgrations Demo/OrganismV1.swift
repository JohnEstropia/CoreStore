//
//  OrganismV1.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/06/21.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import Foundation
import CoreData

class OrganismV1: NSManagedObject, OrganismProtocol {

    @NSManaged var dna: Int64
    @NSManaged var hasHead: Bool
    @NSManaged var hasTail: Bool
    
    // MARK: OrganismProtocol
    
    func mutate() {
        
        self.hasHead = arc4random_uniform(2) == 1
        self.hasTail = arc4random_uniform(2) == 1
    }
}
