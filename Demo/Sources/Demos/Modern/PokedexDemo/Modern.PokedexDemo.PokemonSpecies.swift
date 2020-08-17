//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.PokemonSpecies
    
    final class PokemonSpecies: CoreStoreObject {
        
        // MARK: Internal
        
        @Field.Stored("id")
        var id: Int = 0
        
        @Field.Stored("name")
        var name: String = ""
        
        @Field.Stored("weight")
        var weight: Int = 0
        
        @Field.Relationship("forms", inverse: \.$species)
        var forms: Set<Modern.PokedexDemo.PokemonForm>
    }
}
