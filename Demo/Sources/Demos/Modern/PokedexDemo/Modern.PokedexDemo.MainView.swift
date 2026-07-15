//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import SwiftUI

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {
    
    // MARK: - Modern.PokedexDemo.MainView
    
    struct MainView<ListView: View>: View {
        
        // MARK: Internal
        
        init(
            listView: @escaping () -> ListView
        ) {
            
            self.listView = listView
        }
        
        
        // MARK: View
        
        var body: some View {
            ZStack {
                
                self.listView()
                    .frame(minHeight: 0, maxHeight: .infinity)
                    .ignoresSafeArea(.container, edges: .vertical)
                
                if self.pokedexEntries.isEmpty {
                    
                    VStack(alignment: .center, spacing: 30) {
                        Text("This demo needs to make a network connection to download Pokedex entries")
                            .multilineTextAlignment(.center)
                        if self.service.isLoading {
                            
                            Text("Fetching Pokedex…")
                        }
                        else {
                            
                            Button(
                                action: { self.service.fetchPokedexEntries() },
                                label: {
                                    
                                    Text("Download Pokedex Entries")
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Pokedex")
        }
        
        
        // MARK: Private
        
        @ListState(
            From<Modern.PokedexDemo.PokedexEntry>()
                .orderBy(.ascending(\.$index)),
            in: Modern.PokedexDemo.dataStack
        )
        private var pokedexEntries
        
        @State
        private var service = Modern.PokedexDemo.Service()
        
        private let listView: () -> ListView
    }
}
