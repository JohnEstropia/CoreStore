//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import SwiftUI

// MARK: - Modern.ColorsDemo

extension Modern.ColorsDemo {
    
    // MARK: - Modern.ColorsDemo.MainView

    struct MainView<ListView: View, DetailView: View>: View {
        
        // MARK: Internal
        
        init(
            listView: @escaping (
                _ listPublisher: ListPublisher<Modern.ColorsDemo.Palette>,
                _ onPaletteTapped: @escaping (ObjectPublisher<Modern.ColorsDemo.Palette>) -> Void
            ) -> ListView,
            detailView: @escaping (ObjectPublisher<Modern.ColorsDemo.Palette>) -> DetailView) {
            
            self.listView = listView
            self.detailView = detailView
        }
        
        
        // MARK: View
        
        var body: some View {
            return VStack(spacing: 0) {
                self.listView(self.$palettes, { self.selectedPalette = $0 })
                    .navigationBarTitle(
                        Text("Colors (\(self.palettes.count) objects)")
                    )
                    .frame(minHeight: 0, maxHeight: .infinity)
                self.selectedPalette.map {
                    
                    self.detailView($0)
                        .edgesIgnoringSafeArea(.all)
                        .frame(minHeight: 0, maxHeight: .infinity)
                }
            }
            .navigationBarItems(
                leading: HStack {
                    EditButton()
                    Button(
                        action: { self.clearColors() },
                        label: { Text("Clear") }
                    )
                },
                trailing: HStack {
                    Button(
                        action: { self.changeFilter() },
                        label: { Text(self.filter.rawValue) }
                    )
                    Button(
                        action: { self.shuffleColors() },
                        label: { Text("Shuffle") }
                    )
                    Button(
                        action: { self.addColor() },
                        label: { Text("Add") }
                    )
                }
            )
        }
        
        
        // MARK: Private
        
        @ListState(Modern.ColorsDemo.palettesPublisher)
        private var palettes: ListSnapshot
        
        private let listView: (
            _ listPublisher: ListPublisher<Modern.ColorsDemo.Palette>,
            _ onPaletteTapped: @escaping (ObjectPublisher<Modern.ColorsDemo.Palette>) -> Void
        ) -> ListView
        
        private let detailView: (
            _ objectPublisher: ObjectPublisher<Modern.ColorsDemo.Palette>
        ) -> DetailView
        
        @State
        private var selectedPalette: ObjectPublisher<Modern.ColorsDemo.Palette>?
        
        @State
        private var filter: Modern.ColorsDemo.Filter = Modern.ColorsDemo.filter
        
        private func changeFilter() {
            
            Modern.ColorsDemo.filter = Modern.ColorsDemo.filter.next()
            self.filter = Modern.ColorsDemo.filter
        }
        
        private func clearColors() {
            
            Modern.ColorsDemo.dataStack.perform(
                asynchronous: { transaction in

                    try transaction.deleteAll(From<Modern.ColorsDemo.Palette>())
                },
                sourceIdentifier: TransactionSource.clear,
                completion: { _ in }
            )
        }
        
        private func addColor() {

            Modern.ColorsDemo.dataStack.perform(
                asynchronous: { transaction in

                    _ = transaction.create(Into<Modern.ColorsDemo.Palette>())
                },
                sourceIdentifier: TransactionSource.add,
                completion: { _ in }
            )
        }
        
        private func shuffleColors() {

            Modern.ColorsDemo.dataStack.perform(
                asynchronous: { transaction in

                    for palette in try transaction.fetchAll(From<Modern.ColorsDemo.Palette>()) {

                        palette.setRandomHue()
                    }
                },
                sourceIdentifier: TransactionSource.shuffle,
                completion: { _ in }
            )
        }
    }
}

#if DEBUG

struct _Demo_Modern_ColorsDemo_MainView_Preview: PreviewProvider {
    
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
        return Modern.ColorsDemo.MainView(
            listView: { listPublisher, onPaletteTapped in
                Modern.ColorsDemo.SwiftUI.ListView(
                    listPublisher: listPublisher,
                    onPaletteTapped: onPaletteTapped
                )
            },
            detailView: { objectPublisher in
                Modern.ColorsDemo.SwiftUI.DetailView(objectPublisher)
            }
        )
    }
}

#endif
