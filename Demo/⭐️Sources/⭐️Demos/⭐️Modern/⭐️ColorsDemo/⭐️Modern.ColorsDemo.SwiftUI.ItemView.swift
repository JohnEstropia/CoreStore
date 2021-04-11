//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import SwiftUI

// MARK: - Modern.ColorsDemo.SwiftUI

extension Modern.ColorsDemo.SwiftUI {
    
    // MARK: - Modern.ColorsDemo.SwiftUI.ItemView
    
    struct ItemView: View {
        
        /**
         ⭐️ Sample 1: Using a `ObjectState` to observe object changes. Note that the `ObjectSnapshot` is always `Optional`
         */
        @ObjectState
        private var palette: ObjectSnapshot<Modern.ColorsDemo.Palette>?
        
        /**
         ⭐️ Sample 2: Initializing a `ObjectState` from an existing `ObjectPublisher`
         */
        internal init(_ palette: ObjectPublisher<Modern.ColorsDemo.Palette>) {
            
            self._palette = .init(palette)
        }
        
        /**
         ⭐️ Sample 3: Readding values directly from the `ObjectSnapshot`
         */
        var body: some View {
            
            if let palette = self.palette {
                
                Color(palette.$color).overlay(
                    Text(palette.$colorText)
                        .foregroundColor(palette.$brightness > 0.6 ? .black : .white)
                        .padding(),
                    alignment: .leading
                )
                .animation(.default)
            }
        }
    }
}

#if DEBUG

struct _Demo_Modern_ColorsDemo_SwiftUI_ItemView_Preview: PreviewProvider {
    
    // MARK: PreviewProvider
    
    static var previews: some View {
        
        try! Modern.ColorsDemo.dataStack.perform(
            synchronous: { transaction in

                guard (try transaction.fetchCount(From<Modern.ColorsDemo.Palette>())) <= 0 else {
                    return
                }
                let palette = transaction.create(Into<Modern.ColorsDemo.Palette>())
                palette.setRandomHue()
            }
        )
        
        return Modern.ColorsDemo.SwiftUI.ItemView(
            Modern.ColorsDemo.palettesPublisher.snapshot.first!
        )
    }
}

#endif
