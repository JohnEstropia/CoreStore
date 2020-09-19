//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore


// MARK: - Advanced.EvolutionDemo.V1

extension Advanced.EvolutionDemo.V1 {

    // MARK: - Advanced.EvolutionDemo.V1.FromV2

    enum FromV2 {

        // MARK: Internal

        static var mapping: XcodeSchemaMappingProvider {

            return XcodeSchemaMappingProvider(
                from: Advanced.EvolutionDemo.V2.name,
                to: Advanced.EvolutionDemo.V1.name,
                mappingModelBundle: Bundle(for: Advanced.EvolutionDemo.V1.Creature.self)
            )
        }
    }
}
