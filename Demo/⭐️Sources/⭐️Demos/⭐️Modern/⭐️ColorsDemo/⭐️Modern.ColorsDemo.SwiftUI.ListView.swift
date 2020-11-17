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
         ⭐️ Sample 1: Setting a sectioned `ListPublisher` declared as an `@ObservedObject`
         */
        @ObservedObject
        private var listPublisher: ListPublisher<Modern.ColorsDemo.Palette>
        
        /**
         ⭐️ Sample 2: Assigning sections and items of the `ListPublisher` to corresponding `View`s
         */
         var body: some View {
            let listSnapshot = self.listPublisher.snapshot
            return List {
                ForEach(listSnapshot.sectionIDs, id: \.self) { (sectionID) in
                    Section(header: Text(sectionID)) {
                        ForEach(listSnapshot.items(inSectionWithID: sectionID), id: \.self) { palette in
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

                            self.deleteColors(at: itemIndices, in: sectionID)
                        }
                    }
                }
                GeometryReader { geometry in
                    Spacer(minLength: geometry.safeAreaInsets.bottom)
                }
            }
            .listStyle(PlainListStyle())
         }
        
        
        // MARK: Internal
        
        init(
            listPublisher: ListPublisher<Modern.ColorsDemo.Palette>,
            onPaletteTapped: @escaping (ObjectPublisher<Modern.ColorsDemo.Palette>) -> Void
        ) {
            
            self.listPublisher = listPublisher
            self.onPaletteTapped = onPaletteTapped
        }
        
        
        // MARK: Private
        
        private let onPaletteTapped: (ObjectPublisher<Modern.ColorsDemo.Palette>) -> Void
        
        private func deleteColors(at indices: IndexSet, in sectionID: String) {
            
            let objectIDsToDelete = self.listPublisher.snapshot.itemIDs(
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
