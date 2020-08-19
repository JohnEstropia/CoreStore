//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore

// MARK: - Modern

extension Modern {
    
    // MARK: - Modern.PokedexDemo
    
    /**
    Sample usages for importing external data into `CoreStoreObject` attributes
    */
    enum PokedexDemo {
        
        // MARK: Internal
        
        static let dataStack: DataStack = {
            
            let dataStack = DataStack(
                CoreStoreSchema(
                    modelVersion: "V1",
                    entities: [
                        Entity<Modern.PokedexDemo.PokedexEntry>("PokedexEntry"),
                        Entity<Modern.PokedexDemo.PokemonSpecies>("PokemonSpecies"),
                        Entity<Modern.PokedexDemo.PokemonForm>("PokemonForm"),
                        Entity<Modern.PokedexDemo.Move>("Move"),
                        Entity<Modern.PokedexDemo.Ability>("Ability")
                    ]
                )
            )
            
            /**
             - Important: `addStorageAndWait(_:)` was used here to simplify initializing the demo, but in practice the asynchronous function variants are recommended.
             */
            try! dataStack.addStorageAndWait(
                SQLiteStore(
                    fileName: "Modern.PokedexDemo.sqlite",
                    localStorageOptions: .recreateStoreOnModelMismatch
                )
            )
            return dataStack
        }()
        
        static let pokedexEntries: ListPublisher<Modern.PokedexDemo.PokedexEntry> = Modern.PokedexDemo.dataStack.publishList(
            From<Modern.PokedexDemo.PokedexEntry>()
                .orderBy(.ascending(\.$index))
        )
    }
}
