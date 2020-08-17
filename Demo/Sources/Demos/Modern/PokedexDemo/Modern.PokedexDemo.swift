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
                        Entity<Modern.ColorsDemo.Palette>("Palette")
                    ],
                    versionLock: [
                        "Palette": [0xbaf4eaee9353176a, 0xdd6ca918cc2b0c38, 0xd04fad8882d7cc34, 0x3e90ca38c091503f]
                    ]
                )
            )
            
            /**
             - Important: `addStorageAndWait(_:)` was used here to simplify initializing the demo, but in practice the asynchronous function variants are recommended.
             */
            try! dataStack.addStorageAndWait(
                SQLiteStore(
                    fileName: "Modern.ColorsDemo.sqlite",
                    localStorageOptions: .recreateStoreOnModelMismatch
                )
            )
            return dataStack
        }()
        
        static let palettesPublisher: ListPublisher<Modern.ColorsDemo.Palette> = Modern.ColorsDemo.dataStack.publishList(
            From<Modern.ColorsDemo.Palette>()
                .sectionBy(\.$colorName)
                .where(Modern.ColorsDemo.filter.whereClause())
                .orderBy(.ascending(\.$hue))
        )
        
        static var filter: Modern.ColorsDemo.Filter = .all {
            
            didSet {
                
                try! Modern.ColorsDemo.palettesPublisher.refetch(
                    From<Modern.ColorsDemo.Palette>()
                        .sectionBy(\.$colorName)
                        .where(self.filter.whereClause())
                        .orderBy(.ascending(\.$hue))
                )
            }
        }
    }
}
