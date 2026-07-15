//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Foundation
import SwiftUI


// MARK: - Menu

extension Menu {
    
    // MARK: - Menu.MainView
    
    struct MainView: View {
        
        @State
        private var selection: Menu.Route?
        
        
        // MARK: View
        
        var body: some View {
            
            NavigationSplitView(
                sidebar: {
                    
                    List(selection: self.$selection) {
                        
                        ForEach(Menu.Section.allCases, id: \.self) { section in
                            
                            Section(section.rawValue) {
                                
                                ForEach(section.routes) { route in
                                    
                                    Menu.ItemView(
                                        title: route.title,
                                        subtitle: route.subtitle,
                                        isEnabled: route.isEnabled
                                    )
                                    .tag(route as Menu.Route?)
                                    .disabled(!route.isEnabled)
                                }
                            }
                        }
                    }
                    .navigationTitle("CoreStore Demos")
                    .listStyle(.sidebar)
                },
                detail: {
                    
                    if let selection = self.selection {
                        
                        selection.destination
                    }
                    else {
                        
                        Menu.PlaceholderView()
                    }
                }
            )
        }
    }
}
