//
//  OrganismV3.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/06/27.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import Foundation
import CoreData

class OrganismV3: NSManagedObject, OrganismProtocol {
    
    @NSManaged var dna: Int64
    @NSManaged var hasHead: Bool
    @NSManaged var hasTail: Bool
    @NSManaged var numberOfLimbs: Int32
    @NSManaged var hasVertebrae: Bool
    
    // MARK: OrganismProtocol
    
    func mutate() {
        
        self.hasHead = arc4random_uniform(2) == 1
        self.hasTail = arc4random_uniform(2) == 1
        self.numberOfLimbs = Int32(arc4random_uniform(9) / 2 * 2)
        self.hasVertebrae = arc4random_uniform(2) == 1
    }
}
