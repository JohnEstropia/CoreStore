//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import SwiftUI

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {
    
    // MARK: - Modern.PokedexDemo.ListView

    struct ListView: UIViewControllerRepresentable {
        
        // MARK: Internal
        
        init(
            service: Modern.PokedexDemo.Service,
            listPublisher: ListPublisher<Modern.PokedexDemo.PokedexEntry>
        ) {
            
            self.service = service
            self.listPublisher = listPublisher
        }
        
        
        // MARK: UIViewControllerRepresentable

        typealias UIViewControllerType = Modern.PokedexDemo.ListViewController

        func makeUIViewController(context: Self.Context) -> UIViewControllerType {
            
            return UIViewControllerType(
                service: self.service,
                listPublisher: self.listPublisher
            )
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Self.Context) {}

        static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Void) {}
        
        
        // MARK: Private
        
        @ObservedObject
        private var service: Modern.PokedexDemo.Service
        
        private let listPublisher: ListPublisher<Modern.PokedexDemo.PokedexEntry>
    }
}

#if DEBUG

struct _Demo_Modern_PokedexDemo_ListView_Preview: PreviewProvider {
    
    // MARK: PreviewProvider
    
    static var previews: some View {
        
        let service = Modern.PokedexDemo.Service()
        service.fetchPokedexEntries()
        
        return Modern.PokedexDemo.ListView(
            service: service,
            listPublisher: Modern.PokedexDemo.pokedexEntries
        )
    }
}

#endif
