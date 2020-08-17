//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import SwiftUI

// MARK: - LazyView

struct LazyView<Content: View>: View {
    
    // MARK: Internal
    
    init(_ load: @escaping () -> Content) {
        
        self.load = load
    }
    
    
    // MARK: View
    
    var body: Content {
        
        self.load()
    }
    
    // MARK: Private
    
    private let load: () -> Content
}
