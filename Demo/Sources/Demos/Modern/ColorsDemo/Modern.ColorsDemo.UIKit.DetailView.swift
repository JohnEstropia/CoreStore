//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Combine
import CoreStore
import SwiftUI

// MARK: - Modern.ColorsDemo.UIKit

extension Modern.ColorsDemo.UIKit {
    
    // MARK: - Modern.ColorsDemo.UIKit.DetailView
    
    struct DetailView: UIViewControllerRepresentable {
        
        // MARK: Internal
        
        init(_ palette: ObjectPublisher<Modern.ColorsDemo.Palette>) {
            
            self.palette = palette
        }
        
        // MARK: UIViewControllerRepresentable

        typealias UIViewControllerType = Modern.ColorsDemo.UIKit.DetailViewController

        func makeUIViewController(context: Self.Context) -> UIViewControllerType {
            
            return UIViewControllerType(self.palette)
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Self.Context) {
            
            uiViewController.palette = Modern.ColorsDemo.dataStack.monitorObject(
                self.palette.object!
            )
        }

        static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Void) {}
        
        
        // MARK: Private
        
        private var palette: ObjectPublisher<Modern.ColorsDemo.Palette>
    }
}

#if DEBUG

struct _Demo_Modern_ColorsDemo_UIKit_DetailView_Preview: PreviewProvider {
    
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
        
        return Modern.ColorsDemo.UIKit.DetailView(
            Modern.ColorsDemo.palettesPublisher.snapshot.first!
        )
    }
}

#endif
