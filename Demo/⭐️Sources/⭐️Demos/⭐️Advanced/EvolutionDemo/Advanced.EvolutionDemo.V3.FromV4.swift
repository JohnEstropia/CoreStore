//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore


// MARK: - Advanced.EvolutionDemo.V3

extension Advanced.EvolutionDemo.V3 {

    // MARK: - Advanced.EvolutionDemo.V3.FromV4

    enum FromV4 {

        // MARK: Internal

        static var mapping: CustomSchemaMappingProvider {

            return CustomSchemaMappingProvider(
                from: Advanced.EvolutionDemo.V4.name,
                to: Advanced.EvolutionDemo.V3.name,
                entityMappings: [
                    .transformEntity(
                        sourceEntity: "Creature",
                        destinationEntity: "Creature",
                        transformer: CustomSchemaMappingProvider.CustomMapping.inferredTransformation(_:_:)
                    )
                ]
            )
        }
    }
}
