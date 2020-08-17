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
         ⭐️ Sample 1: Setting an `ObjectPublisher` declared as an `@ObservedObject`
         */
        @ObservedObject
        private var palette: ObjectPublisher<Modern.ColorsDemo.Palette>
        
        
        // MARK: Internal
        
        internal init(_ palette: ObjectPublisher<Modern.ColorsDemo.Palette>) {
            
            self.palette = palette
        }
        
        
        // MARK: View

        var body: some View {
            
            guard let palette = self.palette.snapshot else {
                
                return AnyView(EmptyView())
            }
            return AnyView(
                HStack {
                    Color(palette.$color)
                        .cornerRadius(5)
                        .frame(width: 30, height: 30, alignment: .leading)
                    Text(palette.$colorText)
                }
            )
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
