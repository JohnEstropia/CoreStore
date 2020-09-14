//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

// MARK: - AdvancedEvolutionDemo

extension Advanced.EvolutionDemo {
    
    // MARK: - GeologicalPeriod
    
    enum GeologicalPeriod: CaseIterable {

        // MARK: Internal
        
        case ageOfInvertebrates
        case ageOfFishes
        case ageOfReptiles
        case ageOfMammals

        var creatureType: Advanced.EvolutionDemo.CreatureType.Type {

            switch self {

            case .ageOfInvertebrates:
                return Advanced.EvolutionDemo.V1.Creature.self
            case .ageOfFishes:
                return Advanced.EvolutionDemo.V2.Creature.self
            case .ageOfReptiles:
                return Advanced.EvolutionDemo.V3.Creature.self
            case .ageOfMammals:
                return Advanced.EvolutionDemo.V4.Creature.self
            }
        }
    }
}
