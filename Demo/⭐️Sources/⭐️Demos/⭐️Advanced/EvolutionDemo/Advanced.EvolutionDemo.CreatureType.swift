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

protocol Advanced_EvolutionDemo_CreatureType: CoreStoreObject, CustomStringConvertible {

    var dnaCode: Int64 { get }

    func mutate()
}
