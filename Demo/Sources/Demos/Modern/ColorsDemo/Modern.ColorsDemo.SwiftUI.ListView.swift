//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import SwiftUI

// MARK: - Modern.ColorsDemo.SwiftUI

extension Modern.ColorsDemo.SwiftUI {
    
    // MARK: - Modern.ColorsDemo.SwiftUI.ListView

    struct ListView: View {
        
        /**
         ⭐️ Sample 1: Using a `ListState` to observe list changes
         */
        @ListState
        private var palettes: ListSnapshot<Modern.ColorsDemo.Palette>
        
        /**
         ⭐️ Sample 2: Initializing a `ListState` from an existing `ListPublisher`
         */
        init(
            listPublisher: ListPublisher<Modern.ColorsDemo.Palette>,
            onPaletteTapped: @escaping (ObjectPublisher<Modern.ColorsDemo.Palette>) -> Void
        ) {
            
            self._palettes = .init(listPublisher)
            self.onPaletteTapped = onPaletteTapped
        }
        
        /**
         ⭐️ Sample 3: Assigning sections and items of the `ListSnapshot` to corresponding `View`s by using the correct `ForEach` overloads.
         */
        var body: some View {
            
            List {
                
                ForEach(sectionIn: self.palettes) { section in
                    
                    Section(header: Text(section.sectionID)) {
                        
                        ForEach(objectIn: section) { palette in
                            
                            Button(
                                action: {
                                    
                                    self.onPaletteTapped(palette)
                                },
                                label: {
                                    
                                    Modern.ColorsDemo.SwiftUI.ItemView(palette)
                                }
                            )
                            .listRowInsets(.init())
                        }
                        .onDelete { itemIndices in
                            
                            self.deleteColors(at: itemIndices, in: section.sectionID)
                        }
                    }
                }
            }
//            .animation(.default) // breaks layout
            .listStyle(PlainListStyle())
            .edgesIgnoringSafeArea([])
        }
        
        
        // MARK: Private
        
        private let onPaletteTapped: (ObjectPublisher<Modern.ColorsDemo.Palette>) -> Void
        
        private func deleteColors(at indices: IndexSet, in sectionID: String) {
            
            let objectIDsToDelete = self.palettes.itemIDs(
                inSectionWithID: sectionID,
                atIndices: indices
            )
            Modern.ColorsDemo.dataStack.perform(
                asynchronous: { transaction in

                    transaction.delete(objectIDs: objectIDsToDelete)
                },
                completion: { _ in }
            )
        }
    }
}

#if DEBUG

struct _Demo_Modern_ColorsDemo_SwiftUI_ListView_Preview: PreviewProvider {
    
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
        return Modern.ColorsDemo.SwiftUI.ListView(
            listPublisher: Modern.ColorsDemo.palettesPublisher,
            onPaletteTapped: { _ in }
        )
    }
}

#endif
