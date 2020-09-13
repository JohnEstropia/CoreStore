//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

// MARK: - Advanced

extension Advanced {
    
    // MARK: - Advanced.EvolutionDemo
    
    /**
    Sample execution of progressive migrations. This demo also supports backwards migration.
    */
    enum EvolutionDemo: CaseIterable {
        
        // MARK: Internal
        
        case ageOfInvertebrates
        case ageOfFishes
        case ageOfReptiles
        case ageOfMammals

        var creatureType: Advanced.EvolutionDemo.CreatureType.Type {

            switch self {

            case .ageOfInvertebrates:   return Advanced.EvolutionDemo.CreatureV1.self
            case .ageOfFishes:          return Advanced.EvolutionDemo.CreatureV2.self
            case .ageOfReptiles:        return Advanced.EvolutionDemo.CreatureV3.self
            case .ageOfMammals:         return Advanced.EvolutionDemo.CreatureV4.self
            }
        }
    }
}
