//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import UIKit
import CoreStore

// MARK: - Advanced.EvolutionDemo.V3

extension Advanced.EvolutionDemo.V3 {

    // MARK: - Advanced.EvolutionDemo.V3.Creature

    final class Creature: CoreStoreObject, Advanced.EvolutionDemo.CreatureType {
        
        // MARK: Internal

        @Field.Stored("dnaCode")
        var dnaCode: Int64 = 0

        @Field.Stored("numberOfLimbs")
        var numberOfLimbs: Int32 = 0

        @Field.Stored("hasVertebrae")
        var hasVertebrae: Bool = false

        @Field.Stored("hasHead")
        var hasHead: Bool = true

        @Field.Stored("hasTail")
        var hasTail: Bool = true

        @Field.Stored("hasWings")
        var hasWings: Bool = false

        @Field.Stored("habitat")
        var habitat: Habitat = .water
        
        
        // MARK: - Habitat
        
        enum Habitat: String, CaseIterable, ImportableAttributeType, FieldStorableType {
            
            case water = "water"
            case land = "land"
            case amphibian = "amphibian"
        }
        
        
        // MARK: CustomStringConvertible
        
        var description: String {
            
            return """
                dnaCode: \(self.dnaCode)
                numberOfLimbs: \(self.numberOfLimbs)
                hasVertebrae: \(self.hasVertebrae)
                hasHead: \(self.hasHead)
                hasTail: \(self.hasTail)
                habitat: \(self.habitat)
                hasWings: \(self.hasWings)
                """
        }
        
        
        // MARK: Advanced.EvolutionDemo.CreatureType

        static func dataSource(in dataStack: DataStack) -> Advanced.EvolutionDemo.CreaturesDataSource {

            return .init(
                listPublisher: dataStack.publishList(
                    From<Advanced.EvolutionDemo.V3.Creature>()
                        .orderBy(.descending(\.$dnaCode))
                ),
                dataStack: dataStack
            )
        }

        static func count(in transaction: BaseDataTransaction) throws -> Int {

            return try transaction.fetchCount(
                From<Advanced.EvolutionDemo.V3.Creature>()
            )
        }

        static func create(in transaction: BaseDataTransaction) -> Advanced.EvolutionDemo.V3.Creature {

            return transaction.create(
                Into<Advanced.EvolutionDemo.V3.Creature>()
            )
        }
        
        func mutate(in transaction: BaseDataTransaction) {
            
            self.numberOfLimbs = .random(in: 1...4) * 2
            self.hasVertebrae = .random()
            self.hasHead = true
            self.hasTail = .random()
            self.habitat = Habitat.allCases.randomElement()!
            self.hasWings = .random()
        }
    }
}
