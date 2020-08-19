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
            let pokemonForm = pokedexEntry?.$pokemonForm?.snapshot
            let pokemonDisplay = pokemonForm?.$pokemonDisplay?.snapshot
            
            return HStack(spacing: 10) {
                
                LazyView {
                    
                    NetworkImageView(url: pokemonDisplay?.$spriteURL)
                        .frame(width: 70, height: 70)
                        .id(pokemonDisplay)
                }
                ZStack {
                    
                    if let pokemonForm = pokemonForm {

                        VStack(alignment: .leading) {
                            
                            HStack {
                                Text(pokemonDisplay?.$displayName ?? pokemonForm.$name)
                                Spacer()
                            }
                            HStack {
                                self.view(for: pokemonForm.$pokemonType1)
                                if let pokemonType2 = pokemonForm.$pokemonType2 {
                                    
                                    self.view(for: pokemonType2)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    else {

                        Text(pokedexEntry?.$id ?? "")
                            .foregroundColor(Color(UIColor.placeholderText))
                            .fontWeight(.heavy)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .onAppear {

                if let pokedexEntry = pokedexEntry {

                    self.service.fetchPokemonForm(for: pokedexEntry)
                }
            }
        }


        // MARK: Private

        @ObservedObject
        private var pokedexEntry: ObjectPublisher<Modern.PokedexDemo.PokedexEntry>

        private let service: Modern.PokedexDemo.Service
        
        private func view(for pokemonType: Modern.PokedexDemo.PokemonType) -> some View {
            ZStack {
                Color(pokemonType.color)
                    .cornerRadius(5)
                Text(pokemonType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
            }
        }
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
                pokedexEntry.pokemonFormURL = URL(string: "https://pokeapi.co/api/v2/pokemon/1/")!
            }
        )

        return Modern.PokedexDemo.ItemView(
            pokedexEntry: Modern.PokedexDemo.pokedexEntries.snapshot.first!,
            service: Modern.PokedexDemo.Service()
        )
    }
}

#endif
