//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore


// MARK: - Advanced.EvolutionDemo.V4

extension Advanced.EvolutionDemo.V4 {

    // MARK: - Advanced.EvolutionDemo.V4.FromV3

    enum FromV3 {

        // MARK: Internal

        static var mapping: CustomSchemaMappingProvider {

            return CustomSchemaMappingProvider(
                from: Advanced.EvolutionDemo.V3.name,
                to: Advanced.EvolutionDemo.V4.name,
                entityMappings: [
                    .transformEntity(
                        sourceEntity: "Creature",
                        destinationEntity: "Creature",
                        transformer: { (source, createDestination) in

                            let destination = createDestination()
                            destination.enumerateAttributes { (destinationAttribute, sourceAttribute) in

                                if let sourceAttribute = sourceAttribute {

                                    destination[destinationAttribute] = source[sourceAttribute]
                                }
                            }
                            destination["isWarmBlooded"] = Bool.random()
                        }
                    )
                ]
            )
        }
    }
}
