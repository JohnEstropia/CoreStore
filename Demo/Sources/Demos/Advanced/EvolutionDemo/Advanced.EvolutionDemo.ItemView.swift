//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import SwiftUI

// MARK: - Advanced.EvolutionDemo

extension Advanced.EvolutionDemo {
    
    // MARK: - Advanced.EvolutionDemo.ItemView
    
    struct ItemView: View {
        
        // MARK: Internal
        
        init(description: String?, mutate: @escaping () -> Void) {
            
            self.description = description
            self.mutate = mutate
        }
        
        
        // MARK: View
        
        var body: some View {
            
            HStack {
                
                Text(self.description ?? "")
                    .font(.footnote)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(
                    action: self.mutate,
                    label: {
                        
                        Text("Mutate")
                            .foregroundColor(.accentColor)
                            .fontWeight(.bold)
                    }
                )
                .buttonStyle(.plain)
            }
            .disabled(self.description == nil)
        }
        
        
        // MARK: FilePrivate
        
        fileprivate let description: String?
        fileprivate let mutate: () -> Void
    }
}
