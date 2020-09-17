//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import Foundation


// MARK: - Advanced.EvolutionDemo

extension Advanced.EvolutionDemo {

    typealias CreatureType = Advanced_EvolutionDemo_CreatureType
}


// MARK: - Advanced.EvolutionDemo.CreatureType

protocol Advanced_EvolutionDemo_CreatureType: DynamicObject, CustomStringConvertible {

    var dnaCode: Int64 { get set }

    static func dataSource(in dataStack: DataStack) -> Advanced.EvolutionDemo.CreaturesDataSource

    static func count(in transaction: BaseDataTransaction) throws -> Int

    static func create(in transaction: BaseDataTransaction) -> Self

    func mutate(in transaction: BaseDataTransaction)
}
