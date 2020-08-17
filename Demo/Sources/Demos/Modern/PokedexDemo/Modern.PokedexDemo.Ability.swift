//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.Ability
    
    final class Ability: CoreStoreObject {
        
        // MARK: Internal
        
        @Field.Stored("id")
        var id: Int = 0
        
        @Field.Stored("name")
        var name: String = ""
        
        @Field.Stored("text")
        var text: String = ""
        
        @Field.Stored("isHiddenAbility")
        var isHiddenAbility: Bool = false
        
        
        @Field.Relationship("learners")
        var learners: Set<Modern.PokedexDemo.PokemonForm>
    }
}
