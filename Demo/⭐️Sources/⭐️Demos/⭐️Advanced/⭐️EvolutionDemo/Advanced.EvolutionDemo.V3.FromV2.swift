//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore


// MARK: - Advanced.EvolutionDemo.V3

extension Advanced.EvolutionDemo.V3 {

    // MARK: - Advanced.EvolutionDemo.V3.FromV2

    enum FromV2 {

        // MARK: Internal

        static var mapping: CustomSchemaMappingProvider {

            return CustomSchemaMappingProvider(
                from: Advanced.EvolutionDemo.V2.name,
                to: Advanced.EvolutionDemo.V3.name,
                entityMappings: [
                    .transformEntity(
                        sourceEntity: "Creature",
                        destinationEntity: "Creature",
                        transformer: { (source, createDestination) in

                            let destination = createDestination()
                            destination["dnaCode"] = source["dnaCode"]
                            destination["numberOfLimbs"] = source["numberOfFlippers"]
                            destination["hasVertebrae"] = source["hasVertebrae"]
                            destination["hasHead"] = source["hasHead"]
                            destination["hasTail"] = source["hasTail"]
                            destination["hasWings"] = Bool.random()
                            destination["habitat"] = Advanced.EvolutionDemo.V3.Creature.Habitat.allCases.randomElement()!.rawValue
                        }
                    )
                ]
            )
        }
    }
}
