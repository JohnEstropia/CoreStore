//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import Foundation
import Combine


// MARK: - Advanced.EvolutionDemo

extension Advanced.EvolutionDemo {
    
    // MARK: - Advanced.EvolutionDemo.Migrator
    
    final class Migrator: ObservableObject {

        /**
         ⭐️ Sample 1: Creating a complex `DataStack` that contains all schema histories. The `exactCurrentModelVersion` will specify the target version (if required), and `migrationChain` will provide the upgrade/downgrade progressive migration path.
         */
        private func createDataStack(
            exactCurrentModelVersion: ModelVersion?,
            migrationChain: MigrationChain
        ) -> DataStack {

            let xcodeV1ToV2ModelSchema = XcodeDataModelSchema.from(
                modelName: "Advanced.EvolutionDemo.V1",
                bundle: Bundle(for: Advanced.EvolutionDemo.V1.Creature.self)
            )
            return DataStack(
                schemaHistory: SchemaHistory(
                    allSchema: xcodeV1ToV2ModelSchema.allSchema
                    + [
                        CoreStoreSchema(
                            modelVersion: Advanced.EvolutionDemo.V3.name,
                            entities: [
                                Entity<Advanced.EvolutionDemo.V3.Creature>("Creature")
                            ]
                        ),
                        CoreStoreSchema(
                            modelVersion: Advanced.EvolutionDemo.V4.name,
                            entities: [
                                Entity<Advanced.EvolutionDemo.V4.Creature>("Creature")
                            ]
                        )
                    ],
                    migrationChain: migrationChain,
                    exactCurrentModelVersion: exactCurrentModelVersion
                )
            )
        }

        /**
         ⭐️ Sample 2: Creating a complex `SQLiteStore` that contains all schema mappings for both upgrade and downgrade cases.
         */
        private func accessSQLiteStore() -> SQLiteStore {

            let upgradeMappings: [SchemaMappingProvider] = [
                Advanced.EvolutionDemo.V2.FromV1.mapping,
                Advanced.EvolutionDemo.V3.FromV2.mapping,
                Advanced.EvolutionDemo.V4.FromV3.mapping
            ]
            let downgradeMappings: [SchemaMappingProvider] = [
                Advanced.EvolutionDemo.V3.FromV4.mapping,
                Advanced.EvolutionDemo.V2.FromV3.mapping,
                Advanced.EvolutionDemo.V1.FromV2.mapping,
            ]
            return SQLiteStore(
                fileName: "Advanced.EvolutionDemo.sqlite",
                configuration: nil,
                migrationMappingProviders: upgradeMappings + downgradeMappings,
                localStorageOptions: []
            )
        }

        /**
         ⭐️ Sample 3: Find the model version used by an existing `SQLiteStore`, or just return the latest version if the store is not created yet.
         */
        private func findCurrentVersion() -> ModelVersion {

            let allVersions = Advanced.EvolutionDemo.GeologicalPeriod.allCases
                .map({ $0.version })

            // Since we are only interested in finding current version, we'll assume an upgrading `MigrationChain`
            let dataStack = self.createDataStack(
                exactCurrentModelVersion: nil,
                migrationChain: MigrationChain(allVersions)
            )
            let migrations = try! dataStack.requiredMigrationsForStorage(
                self.accessSQLiteStore()
            )

            // If no migrations are needed, it means either the store is not created yet, or the store is already at the latest model version. In either case, we already know that the store will use the latest version
            return migrations.first?.sourceVersion
                ?? allVersions.last!
        }


        // MARK: Internal

        var currentPeriod: Advanced.EvolutionDemo.GeologicalPeriod = Advanced.EvolutionDemo.GeologicalPeriod.allCases.last! {

            didSet {

                self.selectModelVersion(self.currentPeriod)
            }
        }

        private(set) var current: (
            period: Advanced.EvolutionDemo.GeologicalPeriod,
            dataStack: DataStack,
            dataSource: Advanced.EvolutionDemo.CreaturesDataSource
        )? {

            willSet {

                self.objectWillChange.send()
            }
        }

        private(set) var isBusy: Bool = false

        private(set) var progress: Progress?


        init() {

            self.synchronizeCurrentVersion()
        }
        
        
        // MARK: Private
        
        private func synchronizeCurrentVersion() {

            guard
                let currentPeriod = Advanced.EvolutionDemo.GeologicalPeriod(rawValue: self.findCurrentVersion())
            else {

                self.selectModelVersion(self.currentPeriod)
                return
            }
            self.selectModelVersion(currentPeriod)
        }
        
        private func selectModelVersion(_ period: Advanced.EvolutionDemo.GeologicalPeriod) {

            let currentPeriod = self.current?.period
            guard period != currentPeriod else {
                
                return
            }

            self.objectWillChange.send()

            self.isBusy = true
            
            // explicitly trigger `NSPersistentStore` cleanup by deallocating the `DataStack`
            self.current = nil

            let migrationChain: MigrationChain
            switch (currentPeriod?.version, period.version) {

            case (nil, let newVersion):
                migrationChain = [newVersion]

            case (let currentVersion?, let newVersion):
                let upgradeMigrationChain = Advanced.EvolutionDemo.GeologicalPeriod.allCases
                    .map({ $0.version })
                let currentVersionIndex = upgradeMigrationChain.firstIndex(of: currentVersion)!
                let newVersionIndex = upgradeMigrationChain.firstIndex(of: newVersion)!

                migrationChain = MigrationChain(
                    currentVersionIndex > newVersionIndex
                        ? upgradeMigrationChain.reversed()
                        : upgradeMigrationChain
                )
            }
            let dataStack = self.createDataStack(
                exactCurrentModelVersion: period.version,
                migrationChain: migrationChain
            )

            let completion = { [weak self] () -> Void in

                guard let self = self else {

                    return
                }
                self.objectWillChange.send()
                defer {

                    self.isBusy = false
                }
                self.current = (
                    period: period,
                    dataStack: dataStack,
                    dataSource: period.creatureType.dataSource(in: dataStack)
                )
                self.currentPeriod = period
            }

            self.progress = dataStack.addStorage(
                self.accessSQLiteStore(),
                completion: { [weak self] result in

                    guard let self = self else {

                        return
                    }
                    guard case .success = result else {

                        self.objectWillChange.send()
                        self.isBusy = false
                        return
                    }
                    if self.progress == nil {

                        self.spawnCreatures(in: dataStack, period: period, completion: completion)
                    }
                    else {

                        completion()
                    }
                }
            )
        }

        private func spawnCreatures(
            in dataStack: DataStack,
            period: Advanced.EvolutionDemo.GeologicalPeriod,
            completion: @escaping () -> Void
        ) {

            dataStack.perform(
                asynchronous: { (transaction) in

                    let creatureType = period.creatureType
                    for dnaCode in try creatureType.count(in: transaction) ..< 10000 {

                        let object = creatureType.create(in: transaction)
                        object.dnaCode = Int64(dnaCode)
                        object.mutate(in: transaction)
                    }
                },
                completion: { _ in completion() }
            )
        }
        
        
        // MARK: - VersionMetadata
        
        private struct VersionMetadata {
            
            let label: String
            let entityType: Advanced.EvolutionDemo.CreatureType.Type
            let schemaHistory: SchemaHistory
        }
    }
}
