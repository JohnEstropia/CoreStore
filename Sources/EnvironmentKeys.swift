//
//  EnvironmentKeys.swift
//  CoreStore
//
//  Created by John Rommel Estropia on 2019/10/05.
//  Copyright © 2019 John Rommel Estropia. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI


// MARK: - DataStackEnvironmentKey

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 15.0, *)
public struct DataStackEnvironmentKey: EnvironmentKey {

    // MARK: Public
    
    public static var defaultValue: DataStack {
        
        return Shared.defaultStack
    }
}


// MARK: - EnvironmentValues

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 15.0, *)
extension EnvironmentValues {
    
    // MARK: Public
    
    public var dataStack: DataStack {
        get {
            return self[DataStackEnvironmentKey.self]
        }
        set {
            self[DataStackEnvironmentKey.self] = newValue
        }
    }
}

#endif
