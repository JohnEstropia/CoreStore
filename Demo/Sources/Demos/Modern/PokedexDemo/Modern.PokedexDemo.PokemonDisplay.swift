//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import UIKit

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.PokemonDisplay
    
    final class PokemonDisplay: CoreStoreObject, ImportableUniqueObject {
        
        // MARK: Internal
        
        @Field.Stored("id")
        var id: Int = 0
        
        @Field.Stored("name")
        var name: String?
        
        @Field.Stored("spriteURL")
        var spriteURL: URL?
        
        
        @Field.Relationship("pokemonDetails", inverse: \.$pokemonDisplays)
        var pokemonDetails: Modern.PokedexDemo.PokemonDetails?
        
        
        // MARK: ImportableObject

        typealias ImportSource = Dictionary<String, Any>


        // MARK: ImportableUniqueObject
        
        typealias UniqueIDType = Int

        static let uniqueIDKeyPath: String = String(keyPath: \Modern.PokedexDemo.PokemonDisplay.$id)

        var uniqueIDValue: UniqueIDType {

            get { return self.id }
            set { self.id = newValue }
        }

        static func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> UniqueIDType? {

            let json = source
            return try Modern.PokedexDemo.Service.parseJSON(json["id"])
        }

        func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {

            typealias Service = Modern.PokedexDemo.Service
            let json = source
            
            self.name = try Service.parseJSON(json["name"])
            self.spriteURL = try? Service.parseJSON(
                json["sprites"],
                transformer: { (json: Dictionary<String, Any>) in
                    try Service.parseJSON(json["front_default"], transformer: URL.init(string:))
                }
            )
        }
    }
}
