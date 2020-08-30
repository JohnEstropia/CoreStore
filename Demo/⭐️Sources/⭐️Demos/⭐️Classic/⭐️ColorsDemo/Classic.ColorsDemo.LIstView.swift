//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import SwiftUI

// MARK: - Classic.ColorsDemo

extension Classic.ColorsDemo {
    
    // MARK: - Classic.ColorsDemo.ListView

    struct ListView: UIViewControllerRepresentable {
        
        // MARK: Internal
        
        init(
            listMonitor: ListMonitor<Classic.ColorsDemo.Palette>,
            onPaletteTapped: @escaping (Classic.ColorsDemo.Palette) -> Void
        ) {
            
            self.listMonitor = listMonitor
            self.onPaletteTapped = onPaletteTapped
        }
        
        
        // MARK: UIViewControllerRepresentable

        typealias UIViewControllerType = Classic.ColorsDemo.ListViewController

        func makeUIViewController(context: Self.Context) -> UIViewControllerType {
            
            return UIViewControllerType(
                listMonitor: self.listMonitor,
                onPaletteTapped: self.onPaletteTapped
            )
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Self.Context) {
            
            uiViewController.setEditing(
                context.environment.editMode?.wrappedValue.isEditing == true,
                animated: true
            )
        }

        static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Void) {}
        
        
        // MARK: Private
        
        private let listMonitor: ListMonitor<Classic.ColorsDemo.Palette>
        private let onPaletteTapped: (Classic.ColorsDemo.Palette) -> Void
    }
}

#if DEBUG

struct _Demo_Classic_ColorsDemo_ListView_Preview: PreviewProvider {
    
    // MARK: PreviewProvider
    
    static var previews: some View {
        
        let minimumSamples = 10
        try! Classic.ColorsDemo.dataStack.perform(
            synchronous: { transaction in

                let missing = minimumSamples
                    - (try transaction.fetchCount(From<Classic.ColorsDemo.Palette>()))
                guard missing > 0 else {
                    return
                }
                for _ in 0..<missing {
                    
                    let palette = transaction.create(Into<Classic.ColorsDemo.Palette>())
                    palette.setRandomHue()
                }
            }
        )
        return Classic.ColorsDemo.ListView(
            listMonitor: Classic.ColorsDemo.palettesMonitor,
            onPaletteTapped: { _ in }
        )
    }
}

#endif
