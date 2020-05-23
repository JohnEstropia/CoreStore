//
//  ColorsDemo.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2019/10/17.
//  Copyright © 2019 John Rommel Estropia. All rights reserved.
//

import Foundation
import CoreStore


// MARK: - ColorsDemo

struct ColorsDemo {
    
    enum Filter: String {
        
        case all = "All Colors"
        case light = "Light Colors"
        case dark = "Dark Colors"
        
        func next() -> Filter {
            
            switch self {
                
            case .all: return .light
            case .light: return .dark
            case .dark: return .all
            }
        }
        
        func whereClause() -> Where<Palette> {
            
            switch self {
                
            case .all: return .init()
            case .light: return (\Palette.$brightness >= 0.9)
            case .dark: return (\Palette.$brightness <= 0.4)
            }
        }
    }
    
    static var filter = Filter.all {
        
        didSet {
            
            try! self.palettes.refetch(
                From<Palette>()
                    .sectionBy(\.$colorName)
                    .where(self.filter.whereClause())
                    .orderBy(.ascending(\.$hue))
            )
        }
    }
    
    static let stack: DataStack = {
     
        let dataStack = DataStack(
            CoreStoreSchema(
                modelVersion: "ColorsDemo",
                entities: [
                    Entity<Palette>("Palette"),
                ],
                versionLock: [
                    "Palette": [0x8c25aa53c7c90a28, 0xa243a34d25f1a3a7, 0x56565b6935b6055a, 0x4f988bb257bf274f]
                ]
            )
        )

        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "ColorsDemo.sqlite",
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )
        return dataStack
    }()
    
    static let palettes: ListPublisher<Palette> = {

        return ColorsDemo.stack.publishList(
            From<Palette>()
                .sectionBy(\.$colorName)
                .orderBy(.ascending(\.$hue))
        )
    }()
}
