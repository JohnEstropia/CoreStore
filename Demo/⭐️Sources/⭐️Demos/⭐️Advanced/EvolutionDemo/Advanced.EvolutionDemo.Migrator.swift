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
        
        var currentPeriod: Advanced.EvolutionDemo.GeologicalPeriod? {
            
            return self.current?.period
        }
        
        
        // MARK: Private
        
        private var current: (period: Advanced.EvolutionDemo.GeologicalPeriod, dataStack: DataStack)? {
            
            willSet {
                
                self.objectWillChange.send()
            }
        }
        
        private func findAndSetCurrentVersion() {
            
            let xcodeV1ToV2ModelSchema = XcodeDataModelSchema.from(
                modelName: "Advanced.EvolutionDemo.V1",
                bundle: Bundle(for: Advanced.EvolutionDemo.V1.Creature.self),
                migrationChain: [
                    Advanced.EvolutionDemo.V1.name,
                    Advanced.EvolutionDemo.V2.name
                ]
            )
            let dataStack = DataStack(
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
                    migrationChain: [
                        Advanced.EvolutionDemo.V1.name,
                        Advanced.EvolutionDemo.V2.name,
                        Advanced.EvolutionDemo.V3.name,
                        Advanced.EvolutionDemo.V4.name
                    ]
                )
            )
        }
        
        private func selectModelVersion(_ period: GeologicalPeriod) {
            
            guard period != self.current?.period else {
                
                return
            }
            
            // explicitly trigger `NSPersistentStore` cleanup by deallocating the `DataStack`
            self.current = nil
            
        }
        
        
        // MARK: - VersionMetadata
        
        private struct VersionMetadata {
            
            let label: String
            let entityType: Advanced.EvolutionDemo.CreatureType.Type
            let schemaHistory: SchemaHistory
        }
    }
}
