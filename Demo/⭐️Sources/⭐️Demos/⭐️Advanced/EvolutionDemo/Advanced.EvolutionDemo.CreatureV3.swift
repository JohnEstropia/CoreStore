//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import UIKit
import CoreStore

// MARK: - Advanced.EvolutionDemo

extension Advanced.EvolutionDemo {

    // MARK: - Advanced.EvolutionDemo.CreatureV3

    final class CreatureV3: CoreStoreObject, Advanced.EvolutionDemo.CreatureType {

        // MARK: Internal

        @Field.Stored("dnaCode")
        var dnaCode: Int64 = 0

        @Field.Stored("hasHead")
        var hasHead: Bool = false

        @Field.Stored("hasTail")
        var hasTail: Bool = false

        @Field.Stored("hasTail")
        var numberOfFlippers: Int32 = 0
    }
}
