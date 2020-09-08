//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore


// MARK: - Modern.ColorsDemo

extension Modern.ColorsDemo {
    
    // MARK: - Modern.ColorsDemo.Filter
    
    enum Filter: String, CaseIterable {
        
        case all = "All Colors"
        case light = "Light Colors"
        case dark = "Dark Colors"
        
        func next() -> Filter {
            
            let allCases = Self.allCases
            return allCases[(allCases.firstIndex(of: self)! + 1) % allCases.count]
        }
        
        func whereClause() -> Where<Modern.ColorsDemo.Palette> {
            
            switch self {
                
            case .all: return .init()
            case .light: return (\.$brightness >= 0.6)
            case .dark: return (\.$brightness <= 0.4)
            }
        }
    }
}
