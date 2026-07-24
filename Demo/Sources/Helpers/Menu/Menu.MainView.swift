//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Foundation
import SwiftUI


// MARK: - Menu

extension Menu {
    
    // MARK: - Menu.MainView
    
    struct MainView: View {

        @Environment(\.horizontalSizeClass)
        private var horizontalSizeClass
        
        // MARK: View
        
        @ViewBuilder
        var body: some View {

            if self.horizontalSizeClass == .compact {
                NavigationStack {
                    self.menuList
                }
            }
            else {
                NavigationSplitView(
                    sidebar: {
                        self.menuList
                    },
                    detail: {
                        Menu.PlaceholderView()
                    }
                )
            }
        }


        // MARK: Private

        @ViewBuilder
        private var menuList: some View {
            List {

                ForEach(Menu.Section.allCases, id: \.self) { section in

                    SwiftUI.Section(
                        content: {

                            ForEach(section.routes) { route in

                                NavigationLink(
                                    destination: {
                                        route.destination
                                    },
                                    label: {
                                        Menu.ItemView(
                                            title: route.title,
                                            subtitle: route.subtitle,
                                            isEnabled: route.isEnabled
                                        )
                                    }
                                )
                                .disabled(!route.isEnabled)
                            }
                        },
                        header: {

                            Text(section.rawValue)
                        }
                    )
                }
            }
            .navigationTitle("CoreStore Demos")
            .listStyle(.sidebar)
        }
    }
}
