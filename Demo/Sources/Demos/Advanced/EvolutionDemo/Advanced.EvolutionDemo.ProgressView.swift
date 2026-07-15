//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Observation
import SwiftUI

// MARK: - Advanced.EvolutionDemo

extension Advanced.EvolutionDemo {
    
    // MARK: - Advanced.EvolutionDemo.ProgressView
    
    struct ProgressView: View {
        
        // MARK: Internal
        
        init(progress: Progress?) {
            
            self.progress = progress
            self._progressObserver = State(initialValue: .init(progress))
        }
        
        
        // MARK: View
        
        var body: some View {
            
            Group {
                
                if self.progressObserver.isMigrating {
                    
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
                }
                else {
                    
                    VStack(alignment: .center) {
                        Text("Preparing creatures...")
                            .padding()
                        Spacer()
                    }
                    .padding()
                }
            }
            .task(id: self.progress.map { ObjectIdentifier($0) }) {
                
                self.progressObserver = .init(self.progress)
            }
        }
        
        
        // MARK: Private
        
        private let progress: Progress?
        
        @State
        private var progressObserver: ProgressObserver
        
        
        // MARK: - ProgressObserver
        
        @MainActor
        @Observable
        fileprivate final class ProgressObserver {
            
            private(set) var fractionCompleted: CGFloat = 0
            private(set) var localizedDescription: String = ""
            private(set) var localizedAdditionalDescription: String = ""
            
            var isMigrating: Bool {
                
                self.progress != nil
            }
            
            init(_ progress: Progress?) {
                
                self.progress = progress
                self.syncValues(from: progress)
                
                progress?.setProgressHandler { [weak self] progress in
                    
                    self?.syncValues(from: progress)
                }
            }
            
            
            // MARK: Private
            
            @ObservationIgnored
            private let progress: Progress?
            
            private func syncValues(from progress: Progress?) {
                
                self.fractionCompleted = CGFloat(progress?.fractionCompleted ?? 0)
                self.localizedDescription = progress?.localizedDescription ?? ""
                self.localizedAdditionalDescription = progress?.localizedAdditionalDescription ?? ""
            }
        }
    }
}
