//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import SwiftUI

// MARK: - InstructionsView

struct InstructionsView: View {
    
    // MARK: Internal
    
    init(_ rows: (header: String, description: String)...) {
        
        self.rows = rows.map({ .init(header: $0, description: $1) })
    }
    
    
    // MARK: View
    
    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color(.sRGB, white: 0.5, opacity: 0.3), radius: 2, x: 1, y: 1)
            VStack(alignment: .leading, spacing: 3) {
                ForEach(self.rows, id: \.header) { row in
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(row.header)
                            .font(.callout)
                            .fontWeight(.bold)
                        Text(row.description)
                            .font(.footnote)
                    }
                }
            }
            .foregroundColor(Color(.sRGB, white: 0, opacity: 0.8))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
        }
        .fixedSize()
    }
    
    // MARK: Private
    
    private let rows: [InstructionsView.Row]
    
    
    // MARK: - Row
    
    struct Row: Hashable {
    
        // MARK: Internal
        let header: String
        let description: String
    }
}

