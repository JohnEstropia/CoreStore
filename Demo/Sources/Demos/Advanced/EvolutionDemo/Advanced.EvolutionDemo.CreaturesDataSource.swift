//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import Combine


// MARK: - Advanced.EvolutionDemo

extension Advanced.EvolutionDemo {

    // MARK: - Advanced.EvolutionDemo.CreaturesDataSource

    /**
     A type-erasing adapter to support different `ListPublisher` types
     */
    final class CreaturesDataSource: ObservableObject {

        // MARK: Internal

        init<T: NSManagedObject & Advanced.EvolutionDemo.CreatureType>(
            listPublisher: ListPublisher<T>,
            dataStack: DataStack
        ) {

            self.numberOfItems = {
                listPublisher.snapshot.numberOfItems
            }
            self.itemDescriptionAtIndex = { index in
                listPublisher.snapshot[index].object?.description
            }
            self.addItems = { count in

                dataStack.perform(
                    asynchronous: { transaction in

                        let nextDNACode = try transaction.fetchCount(From<T>())
                        for offset in 0 ..< count {

                            let object = transaction.create(Into<T>())
                            object.dnaCode = .init(nextDNACode + offset)
                            object.mutate(in: transaction)
                        }
                    },
                    completion: { _ in }
                )
            }
            self.mutateItemAtIndex = { index in

                let object = listPublisher.snapshot[index]
                dataStack.perform(
                    asynchronous: { transaction in

                        object
                            .asEditable(in: transaction)?
                            .mutate(in: transaction)
                    },
                    completion: { _ in }
                )
            }
            self.deleteAllItems = {

                dataStack.perform(
                    asynchronous: { transaction in

                        try transaction.deleteAll(From<T>())
                    },
                    completion: { _ in }
                )
            }
            listPublisher.addObserver(self) { [weak self] (listPublisher) in

                self?.objectWillChange.send()
            }
        }

        init<T: CoreStoreObject & Advanced.EvolutionDemo.CreatureType>(
            listPublisher: ListPublisher<T>,
            dataStack: DataStack
        ) {

            self.numberOfItems = {
                listPublisher.snapshot.numberOfItems
            }
            self.itemDescriptionAtIndex = { index in
                listPublisher.snapshot[index].object?.description
            }
            self.addItems = { count in

                dataStack.perform(
                    asynchronous: { transaction in

                        let nextDNACode = try transaction.fetchCount(From<T>())
                        for offset in 0 ..< count {

                            let object = transaction.create(Into<T>())
                            object.dnaCode = .init(nextDNACode + offset)
                            object.mutate(in: transaction)
                        }
                    },
                    completion: { _ in }
                )
            }
            self.mutateItemAtIndex = { index in

                let object = listPublisher.snapshot[index]
                dataStack.perform(
                    asynchronous: { transaction in

                        object
                            .asEditable(in: transaction)?
                            .mutate(in: transaction)
                    },
                    completion: { _ in }
                )
            }
            self.deleteAllItems = {

                dataStack.perform(
                    asynchronous: { transaction in

                        try transaction.deleteAll(From<T>())
                    },
                    completion: { _ in }
                )
            }
            listPublisher.addObserver(self) { [weak self] (listPublisher) in

                self?.objectWillChange.send()
            }
        }

        func numberOfCreatures() -> Int {

            return self.numberOfItems()
        }

        func creatureDescription(at index: Int) -> String? {

            return self.itemDescriptionAtIndex(index)
        }

        func mutate(at index: Int) {

            self.mutateItemAtIndex(index)
        }

        func add(count: Int) {

            self.addItems(count)
        }

        func clear() {

            self.deleteAllItems()
        }


        // MARK: Private

        private let numberOfItems: () -> Int
        private let itemDescriptionAtIndex: (Int) -> String?
        private let mutateItemAtIndex: (Int) -> Void
        private let addItems: (Int) -> Void
        private let deleteAllItems: () -> Void
    }
}
