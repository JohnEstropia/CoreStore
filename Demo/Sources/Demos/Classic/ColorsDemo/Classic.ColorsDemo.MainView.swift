//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import Observation
import SwiftUI

// MARK: - Classic.ColorsDemo

extension Classic.ColorsDemo {
    
    // MARK: - Classic.ColorsDemo.MainView

    struct MainView: View {

        // MARK: Internal

        init() {

            let listMonitor = Classic.ColorsDemo.palettesMonitor
            self.listMonitor = listMonitor
            self._listHelper = State(initialValue: .init(listMonitor: listMonitor))
            self._filter = Binding(
                get: { Classic.ColorsDemo.filter },
                set: { Classic.ColorsDemo.filter = $0 }
            )
        }


        // MARK: View

        var body: some View {
            VStack(spacing: 0) {
                Classic.ColorsDemo.ListView(
                    listMonitor: self.listMonitor,
                    onPaletteTapped: {

                        self.listHelper.setSelectedPalette($0)
                    }
                )
                .frame(minHeight: 0, maxHeight: .infinity)
                .ignoresSafeArea(.container, edges: .vertical)

                if let selectedObject = self.listHelper.selectedObject() {
                    Classic.ColorsDemo.DetailView(selectedObject)
                        .ignoresSafeArea()
                        .frame(minHeight: 0, maxHeight: .infinity)
                }
            }
            .navigationTitle("Colors (\(self.listHelper.count) objects)")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    EditButton()
                    Button("Clear") {

                        self.clearColors()
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(self.filter.rawValue) {

                        self.changeFilter()
                    }
                    Button("Shuffle") {

                        self.shuffleColors()
                    }
                    Button("Add") {

                        self.addColor()
                    }
                }
            }
        }


        // MARK: Private

        private let listMonitor: ListMonitor<Classic.ColorsDemo.Palette>

        @State
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

        @MainActor
        @Observable
        fileprivate final class ListHelper: ListObjectObserver {

            // MARK: FilePrivate

            fileprivate private(set) var count: Int = 0

            fileprivate init(listMonitor: ListMonitor<Classic.ColorsDemo.Palette>) {

                listMonitor.addObserver(self)
                self.count = listMonitor.numberOfObjects()
            }

            fileprivate func selectedObject() -> ObjectMonitor<Classic.ColorsDemo.Palette>? {

                self.selectedPalette.flatMap {
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
                if let palette, !palette.isDeleted {

                    self.selectedPalette = palette
                }
                else {

                    self.selectedPalette = nil
                }
            }


            // MARK: ListObserver

            typealias ListEntityType = Classic.ColorsDemo.Palette

            nonisolated func listMonitorDidChange(_ monitor: ListMonitor<Classic.ColorsDemo.Palette>) {
                let count = monitor.numberOfObjects()

                Task { @MainActor in
                    self.count = count
                }
            }

            nonisolated func listMonitorDidRefetch(_ monitor: ListMonitor<ListEntityType>) {
                let count = monitor.numberOfObjects()

                Task { @MainActor in
                    self.count = count
                }
            }

            // MARK: ListObjectObserver

            nonisolated func listMonitor(
                _ monitor: ListMonitor<Classic.ColorsDemo.Palette>,
                didDeleteObject object: Classic.ColorsDemo.Palette,
                fromIndexPath indexPath: IndexPath
            ) {
                let deletedObjectURI = object.objectID.uriRepresentation()

                Task { @MainActor in
                    if self.selectedPalette?.objectID.uriRepresentation() == deletedObjectURI {

                        self.setSelectedPalette(nil)
                    }
                }
            }


            // MARK: Private

            private var selectedPalette: Classic.ColorsDemo.Palette?
        }
    }
}
