//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import SwiftUI

// MARK: - Menu

extension Menu {
    
    // MARK: - Menu.ItemView
    
    struct ItemView: View {
        
        // MARK: Internal
        
        init(
            title: String,
            subtitle: String? = nil,
            isEnabled: Bool = true
        ) {
            
            self.title = title
            self.subtitle = subtitle
            self.isEnabled = isEnabled
        }
        
        
        // MARK: View
        
        var body: some View {
            VStack(alignment: .leading) {
                
                Text(self.title)
                    .font(.headline)
                    .foregroundStyle(self.isEnabled ? .primary : .secondary)
                
                self.subtitle.map {
                    
                    Text($0)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        
        
        // MARK: FilePrivate
        
        fileprivate let title: String
        fileprivate let subtitle: String?
        fileprivate let isEnabled: Bool
    }
}
