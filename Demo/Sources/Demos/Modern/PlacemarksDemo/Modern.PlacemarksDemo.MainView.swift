//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreLocation
import Combine
import CoreStore
import Foundation
import MapKit
import SwiftUI

// MARK: - Modern.PlacemarksDemo

extension Modern.PlacemarksDemo {
    
    // MARK: - Modern.PlacemarksDemo.MainView

    struct MainView: View {
        
        /**
         ⭐️ Sample 1: Asynchronous transactions
         */
        private func demoAsynchronousTransaction(coordinate: CLLocationCoordinate2D) {
            
            Modern.PlacemarksDemo.dataStack.perform(
                asynchronous: { (transaction) in
                    
                    let place = self.place.asEditable(in: transaction)
                    place?.annotation = .init(coordinate: coordinate)
                },
                completion: { _ in }
            )
        }
        
        /**
         ⭐️ Sample 2: Synchronous transactions
         
         - Important: `perform(synchronous:)` was used here for illustration purposes. In practice, `perform(asynchronous:completion:)` is the preferred transaction type as synchronous transactions are very likely to cause deadlocks.
         */
        private func demoSynchronousTransaction() {

            _ = try? Modern.PlacemarksDemo.dataStack.perform(
                synchronous: {  (transaction) in
                    
                    let place = self.place.asEditable(in: transaction)
                    place?.setRandomLocation()
                }
            )
        }
        
        /**
         ⭐️ Sample 3: Unsafe transactions
         
         - Important: `beginUnsafe()` was used here for illustration purposes. In practice, `perform(asynchronous:completion:)` is the preferred transaction type. Use Unsafe Transactions only when you need to bypass CoreStore's serialized transactions.
         */
        private func demoUnsafeTransaction(
            title: String?,
            subtitle: String?,
            for snapshot: ObjectSnapshot<Modern.PlacemarksDemo.Place>
        ) {
            let transaction = Modern.PlacemarksDemo.dataStack.beginUnsafe()
            let place = snapshot.asEditable(in: transaction)
            place?.title = title
            place?.subtitle = subtitle
            
            transaction.commit { (error) in
                
                print("Commit failed: \(error as Any)")
            }
        }

        // MARK: Internal

        @ObservedObject
        var place: ObjectPublisher<Modern.PlacemarksDemo.Place>
        
        init() {
            
            self.place = Modern.PlacemarksDemo.placePublisher
            self.sinkCancellable = self.place.sink(
                receiveCompletion: { _ in
                    
                    // Deleted, do nothing
                },
                receiveValue: { [self] (snapshot) in
                    
                    self.geocoder.geocode(place: snapshot) { (title, subtitle) in
                        
                        guard self.place.snapshot == snapshot else {
                            
                            return
                        }
                        self.demoUnsafeTransaction(
                            title: title,
                            subtitle: subtitle,
                            for: snapshot
                        )
                    }
                }
            )
        }
        
        
        // MARK: View
        
        var body: some View {
            Modern.PlacemarksDemo.MapView(
                place: self.place.snapshot,
                onTap: { coordinate in
                    
                    self.demoAsynchronousTransaction(coordinate: coordinate)
                }
            )
            .overlay(
                InstructionsView(
                    ("Random", "Sets random coordinate"),
                    ("Tap", "Sets to tapped coordinate")
                )
                .padding(.leading, 10)
                .padding(.bottom, 40),
                alignment: .bottomLeading
            )
            .navigationBarTitle("Placemarks")
            .navigationBarItems(
                trailing: Button("Random") {
                    
                    self.demoSynchronousTransaction()
                }
            )
        }
        
        
        // MARK: Private
        
        private var sinkCancellable: AnyCancellable? = nil
        private let geocoder = Modern.PlacemarksDemo.Geocoder()
    }
}


#if DEBUG

struct _Demo_Modern_PlacemarksDemo_MainView_Preview: PreviewProvider {
    
    // MARK: PreviewProvider
    
    static var previews: some View {
        
        Modern.PlacemarksDemo.MainView()
    }
}

#endif
