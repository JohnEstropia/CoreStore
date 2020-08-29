//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.Species
    
    /**
     ⭐️ Sample 1: This sample shows how to declare `CoreStoreObject` subclasses that implement `ImportableUniqueObject`. For this class the `ImportSource` is a JSON `Dictionary`.
     */
    final class Species: CoreStoreObject, ImportableUniqueObject {
        
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
        
        
        @Field.Coded(
            "formsURLs",
            coder: FieldCoders.Json.self
        )
        var formsURLs: [URL] = []


        @Field.Relationship("details", inverse: \.$species)
        var details: Modern.PokedexDemo.Details?


        // MARK: ImportableObject

        typealias ImportSource = Dictionary<String, Any>


        // MARK: ImportableUniqueObject
        
        typealias UniqueIDType = Int

        static let uniqueIDKeyPath: String = String(keyPath: \Modern.PokedexDemo.Species.$id)

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
            self.weight = try Service.parseJSON(json["weight"])

            for json in try Service.parseJSON(json["types"]) as [Dictionary<String, Any>] {
                
                let slot: Int = try Service.parseJSON(json["slot"])
                let pokemonType = try Service.parseJSON(
                    json["type"],
                    transformer: { (json: Dictionary<String, Any>) in
                        Modern.PokedexDemo.PokemonType(rawValue: try Service.parseJSON(json["name"]))
                    }
                )
                switch slot {
                    
                case 1:     self.pokemonType1 = pokemonType
                case 2:     self.pokemonType2 = pokemonType
                default:    continue
                }
            }
            
            for json in try Service.parseJSON(json["stats"]) as [Dictionary<String, Any>] {
                
                let baseStat: Int = try Service.parseJSON(json["base_stat"])
                let name: String = try Service.parseJSON(
                    json["stat"],
                    transformer: { (json: Dictionary<String, Any>) in
                        try Service.parseJSON(json["name"])
                    }
                )
                switch name {
                    
                case "hp":              self.statHitPoints = baseStat
                case "attack":          self.statAttack = baseStat
                case "defense":         self.statDefense = baseStat
                case "special-attack":  self.statSpecialAttack = baseStat
                case "special-defense": self.statSpecialDefense = baseStat
                case "speed":           self.statSpeed = baseStat
                default:                continue
                }
            }
            
            self.formsURLs = try (Service.parseJSON(json["forms"]) as [Dictionary<String, Any>])
                .map({ try Service.parseJSON($0["url"], transformer: URL.init(string:)) })
        }
    }
}
