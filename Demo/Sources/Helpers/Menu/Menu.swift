//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import SwiftUI


// MARK: - Menu

enum Menu {
    
    // MARK: - Section
    
    enum Section: String, CaseIterable, Hashable {
        
        case modern = "Modern (CoreStoreObject subclasses)"
        case classic = "Classic (NSManagedObject subclasses)"
        case advanced = "Advanced"
        
        var routes: [Route] {
            switch self {
                
            case .modern:
                return [
                    .placemarks,
                    .timeZones,
                    .colorsUIKit,
                    .colorsSwiftUI,
                    .pokedex
                ]
                
            case .classic:
                return [
                    .classicColors
                ]
                
            case .advanced:
                return [
                    .accounts,
                    .evolution,
                    .logger
                ]
            }
        }
    }
    
    
    // MARK: - Route
    
    enum Route: String, CaseIterable, Hashable, Identifiable {
        
        case placemarks
        case timeZones
        case colorsUIKit
        case colorsSwiftUI
        case pokedex
        case classicColors
        case accounts
        case evolution
        case logger
        
        var id: Self {
            self
        }
        
        var title: String {
            
            switch self {
            case .placemarks:
                "Placemarks"
                
            case .timeZones:
                "Time Zones"
                
            case .colorsUIKit:
                "Colors (UIKit)"
                
            case .colorsSwiftUI:
                "Colors (SwiftUI)"
                
            case .pokedex:
                "Pokedex API"
                
            case .classicColors:
                "Colors"
                
            case .accounts:
                "Accounts"
                
            case .evolution:
                "Evolution"
                
            case .logger:
                "Logger"
            }
        }
        
        var subtitle: String {
            
            switch self {
            case .placemarks:
                "Making changes using Transactions"
                
            case .timeZones:
                "Fetching objects and Querying raw values"
                
            case .colorsUIKit:
                "Observing list changes and single-object changes using DiffableDataSources"
                
            case .colorsSwiftUI:
                "Observing list changes and single-object changes using SwiftUI bindings"
                
            case .pokedex:
                "Importing JSON data from external source"
                
            case .classicColors:
                "Observing list changes and single-object changes using ListMonitor"
                
            case .accounts:
                "Switching between multiple persistent stores"
                
            case .evolution:
                "Migrating and reverse-migrating stores"
                
            case .logger:
                "Implementing a custom logger"
            }
        }
        
        var isEnabled: Bool {
            
            switch self {
                
            case .placemarks,
                 .timeZones,
                 .colorsUIKit,
                 .colorsSwiftUI,
                 .pokedex,
                 .classicColors,
                 .evolution:
                return true
                
            case .accounts,
                 .logger:
                return false
            }
        }
        
        @MainActor
        @ViewBuilder
        var destination: some View {
            
            switch self {
            case .placemarks:
                Modern.PlacemarksDemo.MainView()
                
            case .timeZones:
                Modern.TimeZonesDemo.MainView()
                
            case .colorsUIKit:
                Modern.ColorsDemo.MainView(
                    listView: { listPublisher, onPaletteTapped in
                        Modern.ColorsDemo.UIKit.ListView(
                            listPublisher: listPublisher,
                            onPaletteTapped: onPaletteTapped
                        )
                        .ignoresSafeArea()
                    },
                    detailView: { objectPublisher in
                        Modern.ColorsDemo.UIKit.DetailView(objectPublisher)
                    }
                )
                
            case .colorsSwiftUI:
                Modern.ColorsDemo.MainView(
                    listView: { listPublisher, onPaletteTapped in
                        Modern.ColorsDemo.SwiftUI.ListView(
                            listPublisher: listPublisher,
                            onPaletteTapped: onPaletteTapped
                        )
                    },
                    detailView: { objectPublisher in
                        Modern.ColorsDemo.SwiftUI.DetailView(objectPublisher)
                    }
                )
                
            case .pokedex:
                Modern.PokedexDemo.MainView(
                    listView: Modern.PokedexDemo.UIKit.ListView.init
                )
                
            case .classicColors:
                Classic.ColorsDemo.MainView()
                
            case .accounts, .logger:
                EmptyView()
                
            case .evolution:
                Advanced.EvolutionDemo.MainView()
            }
        }
    }
}
