//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore

// MARK: - Modern

extension Modern {
    
    // MARK: - Modern.PlacemarksDemo
    
    /**
    Sample usages for `CoreStoreObject` transactions
    */
    enum PlacemarksDemo {
        
        // MARK: Internal
        
        /**
         ⭐️ Sample 1: Setting up the `DataStack` and storage
         */
        static let dataStack: DataStack = {
            
            let dataStack = DataStack(
                CoreStoreSchema(
                    modelVersion: "V1",
                    entities: [
                        Entity<Modern.PlacemarksDemo.Place>("Place")
                    ],
                    versionLock: [
                        "Place": [0xa7eec849af5e8fcb, 0x638e69c040090319, 0x4e976d66ed400447, 0x18e96bc0438d07bb]
                    ]
                )
            )
            
            /**
             - Important: `addStorageAndWait(_:)` and `perform(synchronous:)` methods were used here to simplify initializing the demo, but in practice the asynchronous function variants are recommended.
             */
            try! dataStack.addStorageAndWait(
                SQLiteStore(
                    fileName: "Modern.PlacemarksDemo.sqlite",
                    localStorageOptions: .recreateStoreOnModelMismatch
                )
            )
            return dataStack
        }()

        static let placePublisher: ObjectPublisher<Modern.PlacemarksDemo.Place> = {
            
            let dataStack = Modern.PlacemarksDemo.dataStack
            if let place = try! dataStack.fetchOne(From<Place>()) {
                
                return dataStack.publishObject(place)
            }
            _ = try! dataStack.perform(
                synchronous: { (transaction) in
                    
                    let place = transaction.create(Into<Place>())
                    place.setRandomLocation()
                }
            )
            let place = try! dataStack.fetchOne(From<Place>())
            return dataStack.publishObject(place!)
        }()
    }
}
