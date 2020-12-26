//
//  ListState.swift
//  CoreStore
//
//  Created by John Rommel Estropia on 2020/12/26.
//  Copyright © 2020 John Rommel Estropia. All rights reserved.
//

#if canImport(Combine) && canImport(SwiftUI)

import Combine
import SwiftUI


// MARK: - ObjectReader

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public struct ObjectReader<Object: DynamicObject, Content: View, Placeholder: View>: View {
    
    // MARK: Internal
    
    public init(
        _ objectPublisher: ObjectPublisher<Object>?,
        @ViewBuilder content: @escaping (ObjectSnapshot<Object>) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        
        self.objectPublisher = .init(
            objectPublisher.flatMap {
                
                guard let dataStack = $0.cs_dataStack() else {
                    
                    return nil
                }
                return $0.asPublisher(in: dataStack)
            }
        )
        self.content = content
        self.placeholder = placeholder
    }
    
    public init(
        _ objectPublisher: ObjectPublisher<Object>?,
        @ViewBuilder content: @escaping (ObjectSnapshot<Object>) -> Content
    ) where Placeholder == EmptyView {
        
        self.init(
            objectPublisher,
            content: content,
            placeholder: EmptyView.init
        )
    }
    
    
    // MARK: View
    
    public var body: some View {
        
        if let snapshot = self.objectPublisher.wrappedValue?.snapshot {
            
            self.content(snapshot)
        }
        else {
            
            self.placeholder()
        }
    }
    
    
    // MARK: Private
    
    @ObservedObject
    private var objectPublisher: OptionalObservedObject<ObjectPublisher<Object>>
    
    private let content: (ObjectSnapshot<Object>) -> Content
    private let placeholder: () -> Placeholder
    
    
    // MARK: - OptionalObservedObject
    
    fileprivate final class OptionalObservedObject<T: ObservableObject>: ObservableObject where ObservableObjectPublisher == T.ObjectWillChangePublisher {
        
        // MARK: Internal
        
        let wrappedValue: T?
        
        init(_ wrappedValue: T?) {
            
            self.wrappedValue = wrappedValue
            self.objectWillChange = wrappedValue.map(\.objectWillChange) ?? .init()
        }
        
        // MARK: ObservableObject
        
        let objectWillChange: ObservableObjectPublisher
    }
}

#endif

