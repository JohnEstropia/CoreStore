//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import UIKit

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.Details
    
    final class Details: CoreStoreObject {
        
        // MARK: Internal
        
        @Field.Relationship("pokedexEntry", inverse: \.$details)
        var pokedexEntry: Modern.PokedexDemo.PokedexEntry?
        
        @Field.Relationship("species")
        var species: Modern.PokedexDemo.Species?
        
        @Field.Relationship("forms")
        var forms: [Modern.PokedexDemo.Form]
    }
}
