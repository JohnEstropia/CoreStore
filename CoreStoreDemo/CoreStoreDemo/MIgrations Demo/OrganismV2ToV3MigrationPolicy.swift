//
//  OrganismV2ToV3MigrationPolicy.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/06/27.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import CoreData

class OrganismV2ToV3MigrationPolicy: NSEntityMigrationPolicy {
    
    override func createDestinationInstancesForSourceInstance(sInstance: NSManagedObject, entityMapping mapping: NSEntityMapping, manager: NSMigrationManager, error: NSErrorPointer) -> Bool {
        
        if !super.createDestinationInstancesForSourceInstance(sInstance, entityMapping: mapping, manager: manager, error: error) {
            
            return false
        }
        
        for dInstance in manager.destinationInstancesForEntityMappingNamed(mapping.name, sourceInstances: [sInstance]) {
            
            dInstance.setValue(false, forKey: "hasVertebrae")
            dInstance.setValue(sInstance.valueForKey("numberOfFlippers"), forKey: "numberOfLimbs")
        }
        return true
    }
}
