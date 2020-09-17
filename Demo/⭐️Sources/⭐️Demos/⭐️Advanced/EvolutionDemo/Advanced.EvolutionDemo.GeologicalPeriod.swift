//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore


// MARK: - AdvancedEvolutionDemo

extension Advanced.EvolutionDemo {
    
    // MARK: - GeologicalPeriod
    
    enum GeologicalPeriod: RawRepresentable, CaseIterable, Hashable, CustomStringConvertible {


        // MARK: Internal
        
        case ageOfInvertebrates
        case ageOfFishes
        case ageOfReptiles
        case ageOfMammals

        var version: ModelVersion {

            return self.rawValue
        }

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


        // MARK: CustomStringConvertible

        var description: String {

            switch self {

            case .ageOfInvertebrates:
                return "Invertebrates"
            case .ageOfFishes:
                return "Fishes"
            case .ageOfReptiles:
                return "Reptiles"
            case .ageOfMammals:
                return "Mammals"
            }
        }


        // MARK: RawRepresentable

        typealias RawValue = ModelVersion

        var rawValue: ModelVersion {

            switch self {

            case .ageOfInvertebrates:
                return Advanced.EvolutionDemo.V1.name
            case .ageOfFishes:
                return Advanced.EvolutionDemo.V2.name
            case .ageOfReptiles:
                return Advanced.EvolutionDemo.V3.name
            case .ageOfMammals:
                return Advanced.EvolutionDemo.V4.name
            }
        }

        init?(rawValue: ModelVersion) {

            switch rawValue {

            case Advanced.EvolutionDemo.V1.name:
                self = .ageOfInvertebrates
            case Advanced.EvolutionDemo.V2.name:
                self = .ageOfFishes
            case Advanced.EvolutionDemo.V3.name:
                self = .ageOfReptiles
            case Advanced.EvolutionDemo.V4.name:
                self = .ageOfMammals
            default:
                return nil
            }
        }
    }
}
