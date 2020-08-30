//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore

// MARK: - Classic

extension Classic {
    
    // MARK: - Classic.ColorsDemo
    
    /**
    Sample usages for observing lists or single instances of `NSManagedObject`s
    */
    enum ColorsDemo {
        
        // MARK: Internal
        
        typealias Palette = Classic_ColorsDemo_Palette
        
        static let dataStack: DataStack = {
            
            let dataStack = DataStack(
                xcodeModelName: "Classic.ColorsDemo",
                bundle: Bundle(for: Palette.self)
            )
            
            /**
             - Important: `addStorageAndWait(_:)` was used here to simplify initializing the demo, but in practice the asynchronous function variants are recommended.
             */
            try! dataStack.addStorageAndWait(
                SQLiteStore(
                    fileName: "Classic.ColorsDemo.sqlite",
                    localStorageOptions: .recreateStoreOnModelMismatch
                )
            )
            return dataStack
        }()
        
        static let palettesMonitor: ListMonitor<Classic.ColorsDemo.Palette> = Classic.ColorsDemo.dataStack.monitorSectionedList(
            From<Classic.ColorsDemo.Palette>()
                .sectionBy(\.colorGroup)
                .where(Classic.ColorsDemo.filter.whereClause())
                .orderBy(.ascending(\.hue))
        )
        
        static var filter: Classic.ColorsDemo.Filter = .all {
            
            didSet {
                
                Classic.ColorsDemo.palettesMonitor.refetch(
                    self.filter.whereClause(),
                    OrderBy<Classic.ColorsDemo.Palette>(.ascending(\.hue))
                )
            }
        }
    }
}
