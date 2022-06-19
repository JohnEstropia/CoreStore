//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import SwiftUI

// MARK: - Classic.ColorsDemo

extension Classic.ColorsDemo {
    
    // MARK: - Classic.ColorsDemo.MainView

    struct MainView: View {
        
        // MARK: Internal
        
        init() {
            
            let listMonitor = Classic.ColorsDemo.palettesMonitor
            self.listMonitor = listMonitor
            self.listHelper = .init(listMonitor: listMonitor)
            self._filter = Binding(
                get: { Classic.ColorsDemo.filter },
                set: { Classic.ColorsDemo.filter = $0 }
            )
        }
        
        
        // MARK: View
        
        var body: some View {
            let detailView: AnyView
            if let selectedObject = self.listHelper.selectedObject() {
                
                detailView = AnyView(
                    Classic.ColorsDemo.DetailView(selectedObject)
                )
            }
            else {
                
                detailView = AnyView(EmptyView())
            }
            let listMonitor = self.listMonitor
            return VStack(spacing: 0) {
                Classic.ColorsDemo.ListView
                    .init(
                        listMonitor: listMonitor,
                        onPaletteTapped: {
                            
                            self.listHelper.setSelectedPalette($0)
                        }
                    )
                    .navigationBarTitle(
                        Text("Colors (\(self.listHelper.count) objects)")
                    )
                    .frame(minHeight: 0, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.vertical)
                detailView
                    .edgesIgnoringSafeArea(.all)
                    .frame(minHeight: 0, maxHeight: .infinity)
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
        
        private let listMonitor: ListMonitor<Classic.ColorsDemo.Palette>
        
        @ObservedObject
        private var listHelper: ListHelper
        
        @Binding
        private var filter: Classic.ColorsDemo.Filter
        
        private func changeFilter() {
            
            Classic.ColorsDemo.filter = Classic.ColorsDemo.filter.next()
        }
        
        private func clearColors() {
            
            Classic.ColorsDemo.dataStack.perform(
                asynchronous: { transaction in

                    try transaction.deleteAll(From<Classic.ColorsDemo.Palette>())
                },
                completion: { _ in }
            )
        }
        
        private func addColor() {

            Classic.ColorsDemo.dataStack.perform(
                asynchronous: { transaction in

                    _ = transaction.create(Into<Classic.ColorsDemo.Palette>())
                },
                completion: { _ in }
            )
        }
        
        private func shuffleColors() {

            Classic.ColorsDemo.dataStack.perform(
                asynchronous: { transaction in

                    for palette in try transaction.fetchAll(From<Classic.ColorsDemo.Palette>()) {

                        palette.setRandomHue()
                    }
                },
                completion: { _ in }
            )
        }
        
        
        // MARK: - Classic.ColorsDemo.MainView.ListHelper
        
        fileprivate final class ListHelper: ObservableObject, ListObjectObserver {
            
            // MARK: FilePrivate
            
            fileprivate private(set) var count: Int = 0
            
            fileprivate init(listMonitor: ListMonitor<Classic.ColorsDemo.Palette>) {
                
                listMonitor.addObserver(self)
                self.count = listMonitor.numberOfObjects()
            }
            
            fileprivate func selectedObject() -> ObjectMonitor<Classic.ColorsDemo.Palette>? {
                
                return self.selectedPalette.flatMap {
                    
                    guard !$0.isDeleted else {
                        
                        return nil
                    }
                    return Classic.ColorsDemo.dataStack.monitorObject($0)
                }
            }
            
            fileprivate func setSelectedPalette(_ palette: Classic.ColorsDemo.Palette?) {
                
                guard self.selectedPalette != palette else {
                    
                    return
                }
                self.objectWillChange.send()
                if let palette = palette, !palette.isDeleted {
                    
                    self.selectedPalette = palette
                }
                else {
                    
                    self.selectedPalette = nil
                }
            }
            
            
            // MARK: ListObserver
            
            typealias ListEntityType = Classic.ColorsDemo.Palette
            
            func listMonitorDidChange(_ monitor: ListMonitor<Classic.ColorsDemo.Palette>) {
                
                self.objectWillChange.send()
                self.count = monitor.numberOfObjects()
            }
            
            func listMonitorDidRefetch(_ monitor: ListMonitor<ListEntityType>) {
                
                self.objectWillChange.send()
                self.count = monitor.numberOfObjects()
            }
            
            // MARK: ListObjectObserver
            
            func listMonitor(_ monitor: ListMonitor<Classic.ColorsDemo.Palette>, didDeleteObject object: Classic.ColorsDemo.Palette, fromIndexPath indexPath: IndexPath) {
                
                if self.selectedPalette == object {

                    self.setSelectedPalette(nil)
                }
            }
            
            
            // MARK: Private
            
            private var selectedPalette: Classic.ColorsDemo.Palette?
        }
    }
}

#if DEBUG

struct _Demo_Classic_ColorsDemo_MainView_Preview: PreviewProvider {
    
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
        return Classic.ColorsDemo.MainView()
    }
}

#endif
