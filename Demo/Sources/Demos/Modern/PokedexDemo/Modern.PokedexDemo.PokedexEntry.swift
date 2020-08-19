//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.PokedexEntry

    final class PokedexEntry: CoreStoreObject, ImportableUniqueObject {

        // MARK: Internal

        @Field.Stored("index")
        var index: Int = 0
        
        @Field.Stored("id")
        var id: String = ""

        @Field.Stored(
            "url",
            dynamicInitialValue: { URL(string: "data:application/json,%7B%7D")! }
        )
        var url: URL

        
        @Field.Relationship("form")
        var form: Modern.PokedexDemo.PokemonForm?


        // MARK: ImportableObject

        typealias ImportSource = (index: Int, json: Dictionary<String, Any>)


        // MARK: ImportableUniqueObject
        
        typealias UniqueIDType = String

        static let uniqueIDKeyPath: String = String(keyPath: \Modern.PokedexDemo.PokedexEntry.$id)

        var uniqueIDValue: UniqueIDType {

            get { return self.id }
            set { self.id = newValue }
        }

        static func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> String? {

            let json = source.json
            return try Modern.PokedexDemo.Service.parseJSON(json["name"])
        }

        func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {

            let json = source.json
            self.index = source.index
            self.url = try Modern.PokedexDemo.Service.parseJSON(json["url"], transformer: URL.init(string:))
        }
    }
}
