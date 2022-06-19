//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreData
import CoreStore


// MARK: - Advanced.EvolutionDemo.V2.FromV1MigrationPolicy

@objc(Advanced_EvolutionDemo_V2_FromV1MigrationPolicy)
final class Advanced_EvolutionDemo_V2_FromV1MigrationPolicy: NSEntityMigrationPolicy {

    // MARK: NSEntityMigrationPolicy

    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {

        try super.createDestinationInstances(
            forSource: sInstance,
            in: mapping,
            manager: manager
        )

        for dInstance in manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance]) {

            dInstance.setValue(
                Bool.random(),
                forKey: #keyPath(Advanced.EvolutionDemo.V2.Creature.hasVertebrae)
            )
            dInstance.setValue(
                Bool.random(),
                forKey: #keyPath(Advanced.EvolutionDemo.V2.Creature.hasTail)
            )
        }
    }
}
