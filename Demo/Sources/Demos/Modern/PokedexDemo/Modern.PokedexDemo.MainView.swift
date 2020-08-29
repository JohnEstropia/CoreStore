//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Combine
import CoreStore
import SwiftUI

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.MainView

    struct MainView: View {

        /**
         ⭐️ Sample 1: Setting a sectioned `ListPublisher` declared as an `@ObservedObject`
         */
        @ObservedObject
        private var pokedexEntries: ListPublisher<Modern.PokedexDemo.PokedexEntry>


        // MARK: Internal

        init() {

            self.pokedexEntries = Modern.PokedexDemo.pokedexEntries
        }


        // MARK: View

        var body: some View {
            let pokedexEntries = self.pokedexEntries.snapshot
            return ZStack {
                
                Modern.PokedexDemo.ListView(
                    service: self.service,
                    listPublisher: self.pokedexEntries
                )
                .frame(minHeight: 0, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.vertical)
                
                if pokedexEntries.isEmpty {
                    
                    VStack(alignment: .center, spacing: 20) {
                        Text("This demo needs to make a network connection to download Pokedex entries")
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

        @ObservedObject
        private var service: Modern.PokedexDemo.Service = .init()
    }
}


#if DEBUG

@available(iOS 14.0, *)
struct _Demo_Modern_PokedexDemo_MainView_Preview: PreviewProvider {

    // MARK: PreviewProvider

    static var previews: some View {

        Modern.PokedexDemo.MainView()
    }
}

#endif
