//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.Move
    
    final class Move: CoreStoreObject {
        
        // MARK: Internal
        
        @Field.Stored("id")
        var id: Int = 0
        
        @Field.Stored("name")
        var name: String = ""
        
        @Field.Stored("text")
        var text: String = ""
        
        @Field.Stored("pokemonType")
        var pokemonType: Modern.PokedexDemo.PokemonType = .normal
        
        @Field.Stored("power")
        var power: Int = 0
        
        @Field.Stored("accuracy")
        var accuracy: Int = 0
        
        @Field.Stored("powerPoints")
        var powerPoints: Int = 0
        
        @Field.Stored("effectChance")
        var effectChance: Int = 0
        
        @Field.Stored("priority")
        var priority: Int = 0
        
        
        @Field.Relationship("learners")
        var learners: Set<Modern.PokedexDemo.PokemonForm>
    }
}
