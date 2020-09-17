//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import SwiftUI

// MARK: - Advanced.EvolutionDemo

extension Advanced.EvolutionDemo {

    // MARK: - Advanced.EvolutionDemo.MainView

    struct MainView: View {

        // MARK: View

        var body: some View {
            let migrator = self.migrator
            let listView: AnyView
            if let current = migrator.current {

                listView = AnyView(
                    Advanced.EvolutionDemo.ListView(
                        period: current.period,
                        dataStack: current.dataStack,
                        dataSource: current.dataSource
                    )
                )
            }
            else {

                listView = AnyView(
                    Advanced.EvolutionDemo.ProgressView(progress: migrator.progress)
                )
            }

            return VStack(spacing: 0) {
                    HStack(alignment: .center, spacing: 0) {
                        Text("Age of")
                            .padding(.trailing)
                        Picker(selection: self.$migrator.currentPeriod, label: EmptyView()) {
                            ForEach(Advanced.EvolutionDemo.GeologicalPeriod.allCases, id: \.self) { period in
                                Text(period.description).tag(period)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding()
                    listView
                        .edgesIgnoringSafeArea(.vertical)
                }
                .navigationBarTitle("Evolution")
                .disabled(migrator.isBusy || migrator.current == nil)
        }


        // MARK: Private

        @ObservedObject
        private var migrator: Advanced.EvolutionDemo.Migrator = .init()
    }
}


#if DEBUG

struct _Demo_Advanced_EvolutionDemo_MainView_Preview: PreviewProvider {

    // MARK: PreviewProvider

    static var previews: some View {

        Advanced.EvolutionDemo.MainView()
    }
}

#endif
