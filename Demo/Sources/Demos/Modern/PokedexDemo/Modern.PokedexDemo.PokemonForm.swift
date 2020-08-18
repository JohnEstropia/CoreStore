//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.PokemonForm
    
    final class PokemonForm: CoreStoreObject {
        
        // MARK: Internal
        
        @Field.Stored("id")
        var id: Int = 0
        
        @Field.Stored("name")
        var name: String = ""

        @Field.Stored("weight")
        var weight: Int = 0
        
        @Field.Stored("pokemonType1")
        var pokemonType1: Modern.PokedexDemo.PokemonType = .normal
        
        @Field.Stored("pokemonType2")
        var pokemonType2: Modern.PokedexDemo.PokemonType?

        @Field.Stored("spriteURL")
        var spriteURL: URL?
        
        
        @Field.Stored("statHitPoints")
        var statHitPoints: Int = 0
        
        @Field.Stored("statAttack")
        var statAttack: Int = 0
        
        @Field.Stored("statDefense")
        var statDefense: Int = 0
        
        @Field.Stored("statSpecialAttack")
        var statSpecialAttack: Int = 0
        
        @Field.Stored("statSpecialDefense")
        var statSpecialDefense: Int = 0
        
        @Field.Stored("statSpeed")
        var statSpeed: Int = 0
        
        
        @Field.Relationship("abilities", inverse: \.$learners)
        var abilities: Set<Modern.PokedexDemo.Ability>
        
        @Field.Relationship("moves", inverse: \.$learners)
        var moves: Set<Modern.PokedexDemo.Move>


        @Field.Relationship("pokedexEntry", inverse: \.$form)
        var pokedexEntry: Modern.PokedexDemo.PokedexEntry?

        @Field.Relationship("species", inverse: \.$forms)
        var species: Modern.PokedexDemo.PokemonSpecies?
    }
}
