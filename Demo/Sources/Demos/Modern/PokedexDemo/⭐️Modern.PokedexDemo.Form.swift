//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import UIKit

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.Form
    
    /**
     ⭐️ Sample 1: This sample shows how to declare `CoreStoreObject` subclasses that implement `ImportableUniqueObject`. For this class the `ImportSource` is a JSON `Dictionary`.
     */
    final class Form: CoreStoreObject, ImportableUniqueObject {
        
        // MARK: Internal
        
        @Field.Stored("id")
        var id: Int = 0
        
        @Field.Stored("name")
        var name: String?
        
        @Field.Stored("spriteURL")
        var spriteURL: URL?
        
        
        @Field.Relationship("details", inverse: \.$forms)
        var details: Modern.PokedexDemo.Details?
        
        
        // MARK: ImportableObject

        typealias ImportSource = Dictionary<String, Any>


        // MARK: ImportableUniqueObject
        
        typealias UniqueIDType = Int

        static let uniqueIDKeyPath: String = String(keyPath: \Modern.PokedexDemo.Form.$id)

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
