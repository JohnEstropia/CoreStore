//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Combine
import CoreStore
import SwiftUI

// MARK: - Classic.ColorsDemo

extension Classic.ColorsDemo {
    
    // MARK: - Classic.ColorsDemo.DetailView
    
    struct DetailView: UIViewControllerRepresentable {
        
        // MARK: Internal
        
        init(_ palette: ObjectMonitor<Classic.ColorsDemo.Palette>) {
            
            self.palette = palette
        }
        
        // MARK: UIViewControllerRepresentable

        typealias UIViewControllerType = Classic.ColorsDemo.DetailViewController

        func makeUIViewController(context: Self.Context) -> UIViewControllerType {
            
            return UIViewControllerType(self.palette)
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Self.Context) {
            
            uiViewController.palette = self.palette
        }

        static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Void) {}
        
        func makeCoordinator() -> ObjectMonitor<Classic.ColorsDemo.Palette> {
            
            return self.palette
        }
        
        
        // MARK: Private
        
        private let palette: ObjectMonitor<Classic.ColorsDemo.Palette>
    }
}

#if DEBUG

struct _Demo_Classic_ColorsDemo_DetailView_Preview: PreviewProvider {
    
    // MARK: PreviewProvider
    
    static var previews: some View {
        
        try! Classic.ColorsDemo.dataStack.perform(
            synchronous: { transaction in

                guard (try transaction.fetchCount(From<Modern.ColorsDemo.Palette>())) <= 0 else {
                    return
                }
                let palette = transaction.create(Into<Modern.ColorsDemo.Palette>())
                palette.setRandomHue()
            }
        )
        
        return Classic.ColorsDemo.DetailView(
            Classic.ColorsDemo.dataStack.monitorObject(
                Classic.ColorsDemo.palettesMonitor[0, 0]
            )
        )
    }
}

#endif
