//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Foundation
import SwiftUI


// MARK: - Menu

extension Menu {
    
    // MARK: - Menu.MainView

    struct MainView: View {
        
        // MARK: View
        
        var body: some View {
            NavigationView {
                List {
                    Section(header: Text("Modern (CoreStoreObject subclasses)")) {
                        Menu.ItemView(
                            title: "Placemarks",
                            subtitle: "Making changes using Transactions",
                            destination: {
                                Modern.PlacemarksDemo.MainView()
                            }
                        )
                        Menu.ItemView(
                            title: "Time Zones",
                            subtitle: "Fetching objects and Querying raw values",
                            destination: {
                                Modern.TimeZonesDemo.MainView()
                            }
                        )
                        Menu.ItemView(
                            title: "Colors (UIKit)",
                            subtitle: "Observing list changes and single-object changes using DiffableDataSources",
                            destination: {
                                Modern.ColorsDemo.MainView(
                                    listView: { listPublisher, onPaletteTapped in
                                        Modern.ColorsDemo.UIKit.ListView(
                                            listPublisher: listPublisher,
                                            onPaletteTapped: onPaletteTapped
                                        )
                                        .edgesIgnoringSafeArea(.all)
                                    },
                                    detailView: { objectPublisher in
                                        Modern.ColorsDemo.UIKit.DetailView(objectPublisher)
                                    }
                                )
                            }
                        )
                        Menu.ItemView(
                            title: "Colors (SwiftUI)",
                            subtitle: "Observing list changes and single-object changes using SwiftUI bindings",
                            destination: {
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
                            }
                        )
                        Menu.ItemView(
                            title: "Pokedex API",
                            subtitle: "Importing JSON data from external source",
                            destination: {
                                Modern.PokedexDemo.MainView(
                                    listView: Modern.PokedexDemo.UIKit.ListView.init
                                )
                            }
                        )
                    }
                    Section(header: Text("Classic (NSManagedObject subclasses)")) {
                        Menu.ItemView(
                            title: "Colors",
                            subtitle: "Observing list changes and single-object changes using ListMonitor",
                            destination: {
                                Classic.ColorsDemo.MainView()
                            }
                        )
                    }
                    Section(header: Text("Advanced")) {
                        Menu.ItemView(
                            title: "Accounts",
                            subtitle: "Switching between multiple persistent stores",
                            destination: { EmptyView() }
                        )
                        .disabled(true)
                        Menu.ItemView(
                            title: "Evolution",
                            subtitle: "Migrating and reverse-migrating stores",
                            destination: {
                                Advanced.EvolutionDemo.MainView()
                            }
                        )
                        Menu.ItemView(
                            title: "Logger",
                            subtitle: "Implementing a custom logger",
                            destination: { EmptyView() }
                        )
                        .disabled(true)
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationBarTitle("CoreStore Demos")
                Menu.PlaceholderView()
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
    }
}

#if DEBUG

struct _Demo_Menu_MainView_Preview: PreviewProvider {
    
    // MARK: PreviewProvider
    
    static var previews: some View {
        
        Menu.MainView()
    }
}

#endif
