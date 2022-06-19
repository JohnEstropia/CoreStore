//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import SwiftUI

// MARK: - Advanced.EvolutionDemo

extension Advanced.EvolutionDemo {

    // MARK: - Advanced.EvolutionDemo.ProgressView

    struct ProgressView: View {

        // MARK: Internal

        init(progress: Progress?) {

            self.progressObserver = .init(progress)
        }


        // MARK: View

        var body: some View {

            guard self.progressObserver.isMigrating else {

                return AnyView(
                    VStack(alignment: .center) {
                        Text("Preparing creatures...")
                            .padding()
                        Spacer()
                    }
                    .padding()
                )
            }
            return AnyView(
                VStack(alignment: .leading) {
                    Text("Migrating: \(self.progressObserver.localizedDescription)")
                        .font(.headline)
                        .padding([.top, .horizontal])
                    Text("Progressive step: \(self.progressObserver.localizedAdditionalDescription)")
                        .font(.subheadline)
                        .padding(.horizontal)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: geometry.size.width, height: 8)
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color.blue)
                                .frame(
                                    width: geometry.size.width
                                        * self.progressObserver.fractionCompleted,
                                    height: 8
                                )
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    Spacer()
                }
                .padding()
            )
        }


        // MARK: FilePrivate

        @ObservedObject
        private var progressObserver: ProgressObserver


        // MARK: - ProgressObserver

        fileprivate final class ProgressObserver: ObservableObject {

            private(set) var fractionCompleted: CGFloat = 0
            private(set) var localizedDescription: String = ""
            private(set) var localizedAdditionalDescription: String = ""

            var isMigrating: Bool {

                return self.progress != nil
            }

            init(_ progress: Progress?) {

                self.progress = progress

                progress?.setProgressHandler { [weak self] (progess) in

                    guard let self = self else {
                        return
                    }
                    self.objectWillChange.send()
                    self.fractionCompleted = CGFloat(progress?.fractionCompleted ?? 0)
                    self.localizedDescription = progress?.localizedDescription ?? ""
                    self.localizedAdditionalDescription = progress?.localizedAdditionalDescription ?? ""
                }
            }

            // MARK: Private

            private let progress: Progress?
        }
    }
}

#if DEBUG

struct _Demo_Advanced_EvolutionDemo_ProgressView_Preview: PreviewProvider {

    // MARK: PreviewProvider

    static var previews: some View {
        let progress = Progress(totalUnitCount: 10)
        progress.completedUnitCount = 3
        return Advanced.EvolutionDemo.ProgressView(
            progress: progress
        )
    }
}

#endif
