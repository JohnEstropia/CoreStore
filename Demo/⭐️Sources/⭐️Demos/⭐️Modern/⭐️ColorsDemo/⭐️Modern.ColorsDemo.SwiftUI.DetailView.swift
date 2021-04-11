//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Combine
import CoreStore
import SwiftUI

// MARK: - Modern.ColorsDemo.SwiftUI

extension Modern.ColorsDemo.SwiftUI {
    
    // MARK: - Modern.ColorsDemo.SwiftUI.DetailView
    
    struct DetailView: View {
        
        /**
         ⭐️ Sample 1: Using a `ObjectState` to observe object changes. Note that the `ObjectSnapshot` is always `Optional`
         */
        @ObjectState
        private var palette: ObjectSnapshot<Modern.ColorsDemo.Palette>?
        
        /**
         ⭐️ Sample 2: Setting properties that can be binded to controls (`Slider` in this case) by creating custom `@Binding` instances that updates the store when the values change.
         */
        @Binding
        private var hue: Float
        
        @Binding
        private var saturation: Float
        
        @Binding
        private var brightness: Float

        init(_ palette: ObjectPublisher<Modern.ColorsDemo.Palette>) {

            self._palette = .init(palette)
            self._hue = Binding(
                get: { palette.hue ?? 0 },
                set: { percentage in
                    
                    Modern.ColorsDemo.dataStack.perform(
                        asynchronous: { (transaction) in
                            
                            let palette = palette.asEditable(in: transaction)
                            palette?.hue = percentage
                        },
                        completion: { _ in }
                    )
                }
            )
            self._saturation = Binding(
                get: { palette.saturation ?? 0 },
                set: { percentage in
                    
                    Modern.ColorsDemo.dataStack.perform(
                        asynchronous: { (transaction) in
                            
                            let palette = palette.asEditable(in: transaction)
                            palette?.saturation = percentage
                        },
                        completion: { _ in }
                    )
                }
            )
            self._brightness = Binding(
                get: { palette.brightness ?? 0 },
                set: { percentage in
                    
                    Modern.ColorsDemo.dataStack.perform(
                        asynchronous: { (transaction) in
                            
                            let palette = palette.asEditable(in: transaction)
                            palette?.brightness = percentage
                        },
                        completion: { _ in }
                    )
                }
            )
        }

        
        // MARK: View
        
        var body: some View {
            
            if let palette = self.palette {
                
                ZStack(alignment: .center) {
                    Color(palette.$color)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Color(.sRGB, white: 0.5, opacity: 0.3), radius: 2, x: 1, y: 1)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("H: \(Int(palette.$hue * 359))°")
                                    .frame(width: 80)
                                Slider(
                                    value: self.$hue,
                                    in: 0 ... 1,
                                    step: 1 / 359
                                )
                            }
                            HStack {
                                Text("S: \(Int(palette.$saturation * 100))%")
                                    .frame(width: 80)
                                Slider(
                                    value: self.$saturation,
                                    in: 0 ... 1,
                                    step: 1 / 100
                                )
                            }
                            HStack {
                                Text("B: \(Int(palette.$brightness * 100))%")
                                    .frame(width: 80)
                                Slider(
                                    value: self.$brightness,
                                    in: 0 ... 1,
                                    step: 1 / 100
                                )
                            }
                        }
                        .foregroundColor(Color(.sRGB, white: 0, opacity: 0.8))
                        .padding()
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                }
            }
        }
    }
}

#if DEBUG

struct _Demo_Modern_ColorsDemo_SwiftUI_DetailView_Preview: PreviewProvider {
    
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
        
        return Modern.ColorsDemo.SwiftUI.DetailView(
            Modern.ColorsDemo.palettesPublisher.snapshot.first!
        )
    }
}

#endif
