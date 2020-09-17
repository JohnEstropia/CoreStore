//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore


// MARK: - Advanced.EvolutionDemo.V2

extension Advanced.EvolutionDemo.V2 {

    // MARK: - Advanced.EvolutionDemo.V2.FromV1

    enum FromV1 {

        // MARK: Internal

        static var mapping: XcodeSchemaMappingProvider {

            return XcodeSchemaMappingProvider(
                from: Advanced.EvolutionDemo.V1.name,
                to: Advanced.EvolutionDemo.V2.name,
                mappingModelBundle: Bundle(for: Advanced.EvolutionDemo.V1.Creature.self)
            )
        }
    }
}
