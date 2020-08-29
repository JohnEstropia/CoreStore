//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import UIKit

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.PokemonDetails
    
    final class PokemonDetails: CoreStoreObject {
        
        // MARK: Internal
        
        @Field.Relationship("pokedexEntry", inverse: \.$pokemonDetails)
        var pokedexEntry: Modern.PokedexDemo.PokedexEntry?
        
        @Field.Relationship("pokemonForm")
        var pokemonForm: Modern.PokedexDemo.PokemonForm?
        
        @Field.Relationship("pokemonDisplays")
        var pokemonDisplays: [Modern.PokedexDemo.PokemonDisplay]
    }
}
