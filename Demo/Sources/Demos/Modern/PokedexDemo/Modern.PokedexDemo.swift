//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore

// MARK: - Modern

extension Modern {
    
    // MARK: - Modern.PokedexDemo
    
    /**
    Sample usages for importing external data into `CoreStoreObject` attributes
    */
    enum PokedexDemo {
        
        // MARK: Internal
        
        static let dataStack: DataStack = {
            
            let dataStack = DataStack(
                CoreStoreSchema(
                    modelVersion: "V1",
                    entities: [
                        Entity<Modern.PokedexDemo.PokedexEntry>("PokedexEntry"),
                        Entity<Modern.PokedexDemo.Details>("Details"),
                        Entity<Modern.PokedexDemo.Species>("Species"),
                        Entity<Modern.PokedexDemo.Form>("Form")
                    ],
                    versionLock: [
                        "Details": [0x1cce0e9508eaa960, 0x74819067b54bd5c6, 0xc30c837f48811f10, 0x622bead2d27dea95],
                        "Form": [0x7cb78e58bbb79e3c, 0x149557c60be8427, 0x6b30ad511d1d2d33, 0xb9f1319657b988dc],
                        "PokedexEntry": [0xc212013c9be094eb, 0x3fd8f513e363194a, 0x8693cfb8988d3e75, 0x12717c1cc2645816],
                        "Species": [0xda257fcd856bbf94, 0x1d556c6d7d2f52c5, 0xc46dd65d582a6e48, 0x943b1e876293ae1]
                    ]
                )
            )
            
            /**
             - Important: `addStorageAndWait(_:)` was used here to simplify initializing the demo, but in practice the asynchronous function variants are recommended.
             */
            try! dataStack.addStorageAndWait(
                SQLiteStore(
                    fileName: "Modern.PokedexDemo.sqlite",
                    localStorageOptions: .recreateStoreOnModelMismatch
                )
            )
            return dataStack
        }()
        
        static let pokedexEntries: ListPublisher<Modern.PokedexDemo.PokedexEntry> = Modern.PokedexDemo.dataStack.publishList(
            From<Modern.PokedexDemo.PokedexEntry>()
                .orderBy(.ascending(\.$index))
        )
    }
}
