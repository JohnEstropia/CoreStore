//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore

// MARK: - Modern

extension Modern {
    
    // MARK: - Modern.TimeZonesDemo
    
    /**
    Sample usages for creating Fetch and Query clauses for `CoreStoreObject`s
    */
    enum TimeZonesDemo {
        
        // MARK: Internal
        
        static let dataStack: DataStack = {
            
            let dataStack = DataStack(
                CoreStoreSchema(
                    modelVersion: "V1",
                    entities: [
                        Entity<Modern.TimeZonesDemo.TimeZone>("TimeZone")
                    ],
                    versionLock: [
                        "TimeZone": [0x9b1d35108434c8fd, 0x4cb8a80903e66b64, 0x405acca3c1945fe3, 0x3b49dccaee0753d8]
                    ]
                )
            )
            
            /**
             - Important: `addStorageAndWait(_:)` and `perform(synchronous:)` methods were used here to simplify initializing the demo, but in practice the asynchronous function variants are recommended.
             */
            try! dataStack.addStorageAndWait(
                SQLiteStore(
                    fileName: "Modern.TimeZonesDemo.sqlite",
                    localStorageOptions: .recreateStoreOnModelMismatch
                )
            )
            _ = try! dataStack.perform(
                synchronous: { (transaction) in
                    
                    try transaction.deleteAll(From<TimeZone>())
                    
                    for name in NSTimeZone.knownTimeZoneNames {
                        
                        let rawTimeZone = NSTimeZone(name: name)!
                        let cachedTimeZone = transaction.create(Into<TimeZone>())
                        
                        cachedTimeZone.name = rawTimeZone.name
                        cachedTimeZone.abbreviation = rawTimeZone.abbreviation ?? ""
                        cachedTimeZone.secondsFromGMT = rawTimeZone.secondsFromGMT
                        cachedTimeZone.isDaylightSavingTime = rawTimeZone.isDaylightSavingTime
                        cachedTimeZone.daylightSavingTimeOffset = rawTimeZone.daylightSavingTimeOffset
                    }
                }
            )
            return dataStack
        }()
    }
}
