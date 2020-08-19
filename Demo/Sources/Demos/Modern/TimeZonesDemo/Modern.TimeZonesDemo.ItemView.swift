//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import SwiftUI

// MARK: - Modern.TimeZonesDemo

extension Modern.TimeZonesDemo {
    
    // MARK: - Modern.TimeZonesDemo.ItemView
    
    struct ItemView: View {
        
        // MARK: Internal
        
        init(title: String, subtitle: String) {
            self.title = title
            self.subtitle = subtitle
        }
        
        
        // MARK: View

        var body: some View {
            VStack(alignment: .leading) {
                Text(self.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(self.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        
        
        // MARK: FilePrivate
        
        fileprivate let title: String
        fileprivate let subtitle: String
    }
}

#if DEBUG

struct _Demo_Modern_TimeZonesDemo_ItemView_Preview: PreviewProvider {
    
    // MARK: PreviewProvider
    
    static var previews: some View {
        Modern.TimeZonesDemo.ItemView(
            title: "Item Title",
            subtitle: "A subtitle caption for this item"
        )
    }
}

#endif
