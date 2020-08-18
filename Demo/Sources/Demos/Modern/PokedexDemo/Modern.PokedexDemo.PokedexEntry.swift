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
        var id: String = ""

        @Field.Stored("url")
        var url: URL!

        
        @Field.Relationship("form")
        var form: Modern.PokedexDemo.PokemonForm?


        // MARK: ImportableObject

        typealias ImportSource = Dictionary<String, Any>


        // MARK: ImportableUniqueObject

        static let uniqueIDKeyPath: String = String(keyPath: \Modern.PokedexDemo.PokedexEntry.$id)

        var uniqueIDValue: String {

            get {

                return self.id
            }
            set {

                self.id = newValue
            }
        }

        static func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> String? {

            return try Modern.PokedexDemo.Service.parseJSON(source["name"])
        }

        func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {

            self.url = URL(string: try Modern.PokedexDemo.Service.parseJSON(source["url"]))
        }
    }
}
