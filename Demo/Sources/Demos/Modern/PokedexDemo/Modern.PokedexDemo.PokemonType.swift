//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.Move
    
    enum PokemonType: String, CaseIterable, ImportableAttributeType, FieldStorableType {
        
        // MARK: Internal
        
        case bug
        case dark
        case dragon
        case electric
        case fairy
        case fighting
        case fire
        case flying
        case ghost
        case grass
        case ground
        case ice
        case normal
        case poison
        case psychic
        case rock
        case steel
        case water
    }
}
