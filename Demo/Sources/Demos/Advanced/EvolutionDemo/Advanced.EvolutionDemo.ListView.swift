//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import SwiftUI

// MARK: - Advanced.EvolutionDemo

extension Advanced.EvolutionDemo {
    
    // MARK: - Advanced.EvolutionDemo.ListView
    
    struct ListView: View {
        
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
        
        
        // MARK: View
        
        var body: some View {
            
            List {
                ForEach(0 ..< self.dataSource.numberOfCreatures(), id: \.self) { index in
                    
                    Advanced.EvolutionDemo.ItemView(
                        description: self.dataSource.creatureDescription(at: index),
                        mutate: {
                            
                            self.dataSource.mutate(at: index)
                        }
                    )
                }
            }
            .listStyle(.plain)
        }
        
        
        // MARK: Private
        
        private let period: Advanced.EvolutionDemo.GeologicalPeriod
        
        private let dataStack: DataStack
        
        private let dataSource: Advanced.EvolutionDemo.CreaturesDataSource
    }
}
