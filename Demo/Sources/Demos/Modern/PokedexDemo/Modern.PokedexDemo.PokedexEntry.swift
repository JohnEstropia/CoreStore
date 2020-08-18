//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.PokedexEntry

    final class PokedexEntry: CoreStoreObject, ImportableUniqueObject {

        // MARK: Internal
        
        @Field.Stored("id")
        var id: Int = 0

        @Field.Stored("name")
        var name: String = ""

        @Field.Stored("url")
        var url: URL!

        
        @Field.Relationship("form")
        var form: Modern.PokedexDemo.PokemonForm?


        // MARK: ImportableObject

        typealias ImportSource = (index: Int, json: Dictionary<String, Any>)


        // MARK: ImportableUniqueObject
        
        typealias UniqueIDType = Int

        static let uniqueIDKeyPath: String = String(keyPath: \Modern.PokedexDemo.PokedexEntry.$id)

        var uniqueIDValue: UniqueIDType {

            get {

                return self.id
            }
            set {

                self.id = newValue
            }
        }

        static func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> UniqueIDType? {

            return source.index + 1
        }

        func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {

            let json = source.json
            self.name = try Modern.PokedexDemo.Service.parseJSON(json["name"])
            self.url = URL(string: try Modern.PokedexDemo.Service.parseJSON(json["url"]))
        }
    }
}
