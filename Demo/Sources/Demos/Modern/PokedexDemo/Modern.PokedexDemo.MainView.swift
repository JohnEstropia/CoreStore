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
            List() {
                ForEach(self.pokedexEntries.snapshot, id: \.self) { pokedexEntry in
                    LazyView {
                        Text(pokedexEntry.snapshot?.$id ?? "")
                    }
                }
            }
            .overlay(
                InstructionsView(
                    ("Random", "Sets random coordinate"),
                    ("Tap", "Sets to tapped coordinate")
                )
                .padding(.leading, 10)
                .padding(.bottom, 40),
                alignment: .bottomLeading
            )
            .navigationBarTitle("Pokedex")
        }


        // MARK: Private

        private let service: Modern.PokedexDemo.Service = .init()
    }
}


#if DEBUG

struct _Demo_Modern_PokedexDemo_MainView_Preview: PreviewProvider {

    // MARK: PreviewProvider

    static var previews: some View {

        Modern.PokedexDemo.MainView()
    }
}

#endif
