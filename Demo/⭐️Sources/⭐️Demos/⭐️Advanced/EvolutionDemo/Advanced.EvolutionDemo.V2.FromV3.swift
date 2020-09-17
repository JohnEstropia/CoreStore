//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore


// MARK: - Advanced.EvolutionDemo.V2

extension Advanced.EvolutionDemo.V2 {

    // MARK: - Advanced.EvolutionDemo.V2.FromV3

    enum FromV3 {

        // MARK: Internal

        static var mapping: CustomSchemaMappingProvider {

            return CustomSchemaMappingProvider(
                from: Advanced.EvolutionDemo.V3.name,
                to: Advanced.EvolutionDemo.V2.name,
                entityMappings: [
                    .transformEntity(
                        sourceEntity: "Creature",
                        destinationEntity: "Creature",
                        transformer: { (source, createDestination) in

                            let destination = createDestination()
                            destination["dnaCode"] = source["dnaCode"]
                            destination["numberOfFlippers"] = source["numberOfLimbs"]
                            destination["hasVertebrae"] = source["hasVertebrae"]
                            destination["hasHead"] = source["hasHead"]
                            destination["hasTail"] = source["hasTail"]
                        }
                    )
                ]
            )
        }
    }
}
