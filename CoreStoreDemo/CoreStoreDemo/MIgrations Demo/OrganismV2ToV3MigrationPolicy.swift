//
//  OrganismV2ToV3MigrationPolicy.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/06/27.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import CoreData

class OrganismV2ToV3MigrationPolicy: NSEntityMigrationPolicy {
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
        
        for dInstance in manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance]) {
            
            dInstance.setValue(
                false,
                forKey: #keyPath(OrganismV3.hasVertebrae)
            )
            dInstance.setValue(
                sInstance.value(forKey: #keyPath(OrganismV2.numberOfFlippers)),
                forKey: #keyPath(OrganismV3.numberOfLimbs)
            )
        }
    }
}
