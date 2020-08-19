//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import SwiftUI

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.ItemView

    struct ItemView: View {

        // MARK: Internal

        static let preferredHeight: CGFloat = 100

        init(
            pokedexEntry: ObjectPublisher<Modern.PokedexDemo.PokedexEntry>,
            service: Modern.PokedexDemo.Service
        ) {

            self.pokedexEntry = pokedexEntry
            self.service = service
        }


        // MARK: View

        var body: some View {

            let pokedexEntry = self.pokedexEntry.snapshot
            let form = pokedexEntry?.$form
            let placeholderColor = Color.init(.sRGB, white: 0.95, opacity: 1)
            return HStack(spacing: 10) {
                placeholderColor
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)

                Text(form?.$name ?? pokedexEntry?.$id ?? "")
                    .foregroundColor(form == nil ? placeholderColor : .init(.darkText))
                    .fontWeight(form == nil ? .heavy : .regular)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .onAppear {

                if let pokedexEntry = pokedexEntry, form == nil {

                    self.service.fetchPokemonForm(for: pokedexEntry)
                }
            }
        }


        // MARK: Private

        @ObservedObject
        private var pokedexEntry: ObjectPublisher<Modern.PokedexDemo.PokedexEntry>

        private let service: Modern.PokedexDemo.Service
    }
}

#if DEBUG

struct _Demo_Modern_PokedexDemo_ItemView_Preview: PreviewProvider {

    // MARK: PreviewProvider

    static let service = Modern.PokedexDemo.Service()

    static var previews: some View {

        try! Modern.PokedexDemo.dataStack.perform(
            synchronous: { transaction in

                guard (try transaction.fetchCount(From<Modern.PokedexDemo.PokedexEntry>())) <= 0 else {
                    return
                }
                let pokedexEntry = transaction.create(Into<Modern.PokedexDemo.PokedexEntry>())
                pokedexEntry.id = "bulbasaur"
                pokedexEntry.url = URL(string: "https://pokeapi.co/api/v2/pokemon/1/")!
            }
        )

        return Modern.PokedexDemo.ItemView(
            pokedexEntry: Modern.PokedexDemo.pokedexEntries.snapshot.first!,
            service: Modern.PokedexDemo.Service()
        )
    }
}

#endif
