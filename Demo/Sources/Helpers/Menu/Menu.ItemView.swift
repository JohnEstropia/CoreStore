//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import SwiftUI

// MARK: - Menu

extension Menu {
    
    // MARK: - Menu.ItemView
    
    struct ItemView<Destination: View>: View {
        
        // MARK: Internal
        
        init(
            title: String,
            subtitle: String? = nil,
            destination: @escaping () -> Destination
        ) {
            self.title = title
            self.subtitle = subtitle
            self.destination = destination
        }
        
        
        // MARK: View

        var body: some View {
            NavigationLink(destination: LazyView(self.destination)) {
                VStack(alignment: .leading) {
                    Text(self.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    self.subtitle.map {
                        Text($0)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        
        
        // MARK: FilePrivate
        
        fileprivate let title: String
        fileprivate let subtitle: String?
        fileprivate let destination: () -> Destination
    }
}

#if DEBUG

struct _Demo_Menu_ItemView_Preview: PreviewProvider {
    
    // MARK: PreviewProvider
    
    static var previews: some View {
        Menu.ItemView(
            title: "Item Title",
            subtitle: "A subtitle caption for this item",
            destination: {
                Color.blue
            }
        )
    }
}

#endif
