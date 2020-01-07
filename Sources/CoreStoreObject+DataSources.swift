//
//  CoreStoreObject+DataSources.swift
//  CoreStore iOS
//
//  Created by John Estropia on 2019/10/04.
//  Copyright © 2019 John Rommel Estropia. All rights reserved.
//

#if canImport(UIKit) || canImport(AppKit)

#if canImport(Combine)
import Combine

// MARK: - ListPublisher: ObservableObject

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
extension CoreStoreObject: ObservableObject {

    // MARK: ObservableObject

    public var objectWillChange: ObservableObjectPublisher {

        return self.cs_toRaw().objectWillChange
    }
}

#endif

#endif
