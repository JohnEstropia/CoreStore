//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import SwiftUI

// MARK: - Modern.ColorsDemo.UIKit

extension Modern.ColorsDemo.UIKit {
    
    // MARK: - Modern.ColorsDemo.UIKit.ListView

    struct ListView: UIViewControllerRepresentable {
        
        // MARK: Internal
        
        init(
            listPublisher: ListPublisher<Modern.ColorsDemo.Palette>,
            onPaletteTapped: @escaping (ObjectPublisher<Modern.ColorsDemo.Palette>) -> Void
        ) {
            
            self.listPublisher = listPublisher
            self.onPaletteTapped = onPaletteTapped
        }
        
        
        // MARK: UIViewControllerRepresentable

        typealias UIViewControllerType = Modern.ColorsDemo.UIKit.ListViewController

        func makeUIViewController(context: Self.Context) -> UIViewControllerType {
            
            return UIViewControllerType(
                listPublisher: self.listPublisher,
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
        
        private let listPublisher: ListPublisher<Modern.ColorsDemo.Palette>
        private let onPaletteTapped: (ObjectPublisher<Modern.ColorsDemo.Palette>) -> Void
    }
}

#if DEBUG

struct _Demo_Modern_ColorsDemo_UIKit_ListView_Preview: PreviewProvider {
    
    // MARK: PreviewProvider
    
    static var previews: some View {
        
        let minimumSamples = 10
        try! Modern.ColorsDemo.dataStack.perform(
            synchronous: { transaction in

                let missing = minimumSamples
                    - (try transaction.fetchCount(From<Modern.ColorsDemo.Palette>()))
                guard missing > 0 else {
                    return
                }
                for _ in 0..<missing {
                    
                    let palette = transaction.create(Into<Modern.ColorsDemo.Palette>())
                    palette.setRandomHue()
                }
            }
        )
        return Modern.ColorsDemo.UIKit.ListView(
            listPublisher: Modern.ColorsDemo.palettesPublisher,
            onPaletteTapped: { _ in }
        )
    }
}

#endif
