//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import SwiftUI

// MARK: - Advanced.EvolutionDemo

extension Advanced.EvolutionDemo {

    // MARK: - Advanced.EvolutionDemo.ListView

    struct ListView: View {

        // MARK: View

        var body: some View {
            let dataSource = self.dataSource
            return List {
                ForEach(0 ..< dataSource.numberOfCreatures(), id: \.self) { (index) in
                    Advanced.EvolutionDemo.ItemView(
                        description: dataSource.creatureDescription(at: index),
                        mutate: {

                            dataSource.mutate(at: index)
                        }
                    )
                }
            }
            .listStyle(PlainListStyle())
        }


        // MARK: Internal

        init(
            period: Advanced.EvolutionDemo.GeologicalPeriod,
            dataStack: DataStack,
            dataSource: Advanced.EvolutionDemo.CreaturesDataSource
        ) {

            self.period = period
            self.dataStack = dataStack
            self.dataSource = dataSource
        }


        // MARK: Private

        private let period: Advanced.EvolutionDemo.GeologicalPeriod

        private let dataStack: DataStack

        @ObservedObject
        private var dataSource: Advanced.EvolutionDemo.CreaturesDataSource
    }
}


#if DEBUG

struct _Demo_Advanced_EvolutionDemo_ListView_Preview: PreviewProvider {

    // MARK: PreviewProvider

    static var previews: some View {

        let dataStack = DataStack(
            CoreStoreSchema(
                modelVersion: Advanced.EvolutionDemo.V4.name,
                entities: [
                    Entity<Advanced.EvolutionDemo.V4.Creature>("Creature")
                ]
            )
        )
        try! dataStack.addStorageAndWait(
            SQLiteStore(fileName: "Advanced.EvolutionDemo.ListView.Preview.sqlite")
        )
        try! dataStack.perform(
            synchronous: { transaction in

                for dnaCode in 0 ..< 10 as Range<Int64> {

                    let object = transaction.create(Into<Advanced.EvolutionDemo.V4.Creature>())
                    object.dnaCode = dnaCode
                    object.mutate(in: transaction)
                }
            }
        )
        return Advanced.EvolutionDemo.ListView(
            period: .ageOfMammals,
            dataStack: dataStack,
            dataSource: Advanced.EvolutionDemo.V4.Creature.dataSource(in: dataStack)
        )
    }
}

#endif
