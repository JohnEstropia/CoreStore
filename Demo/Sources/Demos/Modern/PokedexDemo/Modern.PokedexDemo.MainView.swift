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
            let visibleItems = self.visibleItems
            return ZStack {

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
                else {

                    List {
                        
                        ForEach(0 ..< min(visibleItems, pokedexEntries.count), id: \.self) { index in
                            LazyView {
                                Modern.PokedexDemo.ItemView(
                                    pokedexEntry: pokedexEntries[index],
                                    service: self.service
                                )
                            }
                            .frame(height: Modern.PokedexDemo.ItemView.preferredHeight)
                            .frame(minWidth: 0, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        }
                        if visibleItems < pokedexEntries.count {

                            Spacer(minLength: Modern.PokedexDemo.ItemView.preferredHeight)
                                .onAppear {

                                    self.visibleItems = min(
                                        visibleItems + 50,
                                        pokedexEntries.count
                                    )
                                }
                        }
                    }
                    .id(pokedexEntries)
                }
            }
            .navigationBarTitle("Pokedex")
        }


        // MARK: Private

        @ObservedObject
        private var service: Modern.PokedexDemo.Service = .init()
        
        @State
        private var visibleItems: Int = 50
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
