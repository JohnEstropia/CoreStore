//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import SwiftUI

// MARK: - Advanced.EvolutionDemo

extension Advanced.EvolutionDemo {
    
    // MARK: - Advanced.EvolutionDemo.MainView
    
    struct MainView: View {
        
        @State
        private var migrator = Advanced.EvolutionDemo.Migrator()
        
        
        // MARK: View
        
        var body: some View {
            
            VStack(spacing: 0) {
                
                HStack(alignment: .center, spacing: 0) {
                    
                    Text("Age of")
                        .padding(.trailing)
                    
                    Picker(selection: $migrator.currentPeriod, label: EmptyView()) {
                        
                        ForEach(Advanced.EvolutionDemo.GeologicalPeriod.allCases, id: \.self) { period in
                            
                            Text(period.description).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                
                if let current = migrator.current {
                    
                    Advanced.EvolutionDemo.ListView(
                        period: current.period,
                        dataStack: current.dataStack,
                        dataSource: current.dataSource
                    )
                    .ignoresSafeArea(.container, edges: .vertical)
                }
                else {
                    
                    Advanced.EvolutionDemo.ProgressView(progress: migrator.progress)
                        .ignoresSafeArea(.container, edges: .vertical)
                }
            }
            .navigationTitle("Evolution")
            .disabled(migrator.isBusy || migrator.current == nil)
        }
    }
}
