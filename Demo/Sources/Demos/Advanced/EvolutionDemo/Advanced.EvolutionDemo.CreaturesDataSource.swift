//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import Observation


// MARK: - Advanced.EvolutionDemo

extension Advanced.EvolutionDemo {
    
    // MARK: - Advanced.EvolutionDemo.CreaturesDataSource
    
    /**
     A type-erasing adapter to support different `ListPublisher` types
     */
    @MainActor
    @Observable
    final class CreaturesDataSource {
        
        // MARK: Internal
        
        init<T: DynamicObject & Advanced.EvolutionDemo.CreatureType>(
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
                
                let persistentID = listPublisher.snapshot[index].persistentID()
                dataStack.perform(
                    asynchronous: { transaction in
                        
                        persistentID
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
            listPublisher.addObserver(self) { [weak self] _ in
                
                Task { @MainActor in
                    self?.refreshID += 1
                }
            }
        }
        
        func numberOfCreatures() -> Int {
            
            _ = self.refreshID
            return self.numberOfItems()
        }
        
        func creatureDescription(at index: Int) -> String? {
            
            _ = self.refreshID
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
        
        private var refreshID: Int = 0
        
        @ObservationIgnored
        private let numberOfItems: () -> Int
        
        @ObservationIgnored
        private let itemDescriptionAtIndex: (Int) -> String?
        
        @ObservationIgnored
        private let mutateItemAtIndex: (Int) -> Void
        
        @ObservationIgnored
        private let addItems: (Int) -> Void
        
        @ObservationIgnored
        private let deleteAllItems: () -> Void
    }
}
