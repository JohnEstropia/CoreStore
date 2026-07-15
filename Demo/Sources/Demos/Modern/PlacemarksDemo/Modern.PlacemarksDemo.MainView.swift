//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreLocation
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
                    
                    let place = self.$place?.asEditable(in: transaction)
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
                    
                    let place = self.$place?.asEditable(in: transaction)
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
        
        @ObjectState(Modern.PlacemarksDemo.placePublisher)
        var place: ObjectSnapshot<Modern.PlacemarksDemo.Place>?
        
        
        // MARK: View
        
        var body: some View {
            
            Group {
                
                if let place = self.place {
                    
                    Modern.PlacemarksDemo.MapView(
                        place: place,
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
                }
            }
            .task(id: self.place.map({ "\($0.$latitude),\($0.$longitude)" })) {
                
                guard let place = self.place else {
                    
                    return
                }
                let geocoded = await self.geocoder.geocode(place: place)
                guard self.place?.objectID() == place.objectID() else {
                    
                    return
                }
                guard geocoded.title != nil || geocoded.subtitle != nil else {
                    
                    return
                }
                self.demoUnsafeTransaction(
                    title: geocoded.title,
                    subtitle: geocoded.subtitle,
                    for: place
                )
            }
            .navigationTitle("Placemarks")
            .toolbar {
                
                Button("Random") {
                    
                    self.demoSynchronousTransaction()
                }
            }
        }
        
        
        // MARK: Private
        
        @State
        private var geocoder = Modern.PlacemarksDemo.Geocoder()
    }
}
