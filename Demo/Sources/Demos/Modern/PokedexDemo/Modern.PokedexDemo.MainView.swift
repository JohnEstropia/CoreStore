//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Combine
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
                .edgesIgnoringSafeArea(.vertical)
                
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
            .navigationBarTitle("Pokedex")
        }


        // MARK: Private
        
        @ListState(
            From<Modern.PokedexDemo.PokedexEntry>()
                .orderBy(.ascending(\.$index)),
            in: Modern.PokedexDemo.dataStack
        )
        private var pokedexEntries

        @ObservedObject
        private var service: Modern.PokedexDemo.Service = .init()
        
        private let listView: () -> ListView
    }
}


#if DEBUG

@available(iOS 14.0, *)
struct _Demo_Modern_PokedexDemo_MainView_Preview: PreviewProvider {

    // MARK: PreviewProvider

    static var previews: some View {

        Modern.PokedexDemo.MainView(
            listView: Modern.PokedexDemo.UIKit.ListView.init
        )
    }
}

#endif
