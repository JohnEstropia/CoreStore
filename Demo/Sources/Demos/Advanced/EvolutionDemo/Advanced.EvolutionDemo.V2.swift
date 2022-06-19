//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore


// MARK: - Advanced.EvolutionDemo

extension Advanced.EvolutionDemo {
    
    // MARK: - Advanced.EvolutionDemo.V2
    
    /**
    Namespace for V2 models (`Advanced.EvolutionDemo.GeologicalPeriod.ageOfFishes`)
    */
    enum V2 {
        
        // MARK: Internal
        
        static let name: ModelVersion = "Advanced.EvolutionDemo.V2"
        
        typealias Creature = Advanced_EvolutionDemo_V2_Creature

        typealias FromV1MigrationPolicy = Advanced_EvolutionDemo_V2_FromV1MigrationPolicy
    }
}
