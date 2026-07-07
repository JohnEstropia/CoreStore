//
//  ObjectState.swift
//  CoreStore
//
//  Copyright © 2021 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#if canImport(Observation) && canImport(SwiftUI)

import Observation
import SwiftUI


// MARK: - ObjectState

/**
 A property wrapper type that can read `ObjectPublisher` changes.
 */
@propertyWrapper
public struct ObjectState<O: DynamicObject>: DynamicProperty {
    
    // MARK: Public
    
    /**
     Creates an instance that observes `ObjectPublisher` changes and exposes an `Optional<ObjectSnapshot<O>>` value.
     ```
     @ObjectState
     var person: ObjectSnapshot<Person>?
     
     init(objectPublisher: ObjectPublisher<Person>) {
     
        self._person = .init(objectPublisher)
     }
     
     var body: some View {
     
        HStack {
     
            AsyncImage(self.person?.$avatarURL)
            Text(self.person?.$fullName ?? "")
        }
     }
     ```
     
     - parameter objectPublisher: The `ObjectPublisher` that the `ObjectState` will observe changes for
     */
    @MainActor
    public init(_ objectPublisher: ObjectPublisher<O>?) {
        
        self._observer = .init(wrappedValue: .init(objectPublisher: objectPublisher))
    }
    
    
    // MARK: @propertyWrapper
    
    @MainActor
    public var wrappedValue: ObjectSnapshot<O>? {
        
        return self.observer.item
    }
    
    @MainActor
    public var projectedValue: ObjectPublisher<O>? {
        
        return self.observer.objectPublisher
    }
    
    
    // MARK: DynamicProperty
    
    public mutating func update() {
        
        self._observer.update()
    }
    
    
    // MARK: Private
    
    @State
    private var observer: Observer
    
    
    // MARK: - Observer
    
    @MainActor
    private final class Observer: Observation.Observable {
        
        private let registrar = ObservationRegistrar()
        private var _item: ObjectSnapshot<O>?
        
        let objectPublisher: ObjectPublisher<O>?
        
        var item: ObjectSnapshot<O>? {
            
            get {
                
                self.registrar.access(self, keyPath: \.item)
                return self._item
            }
            set {
                
                self.registrar.withMutation(of: self, keyPath: \.item) {
                    
                    self._item = newValue
                }
            }
        }
        
        init(objectPublisher: ObjectPublisher<O>?) {

            guard
                let dataStack = objectPublisher?.cs_dataStack(),
                let objectPublisher = objectPublisher?.asPublisher(in: dataStack)
            else {

                self.objectPublisher = nil
                self._item = nil
                return
            }
            
            self.objectPublisher = objectPublisher
            self._item = objectPublisher.snapshot
            
            objectPublisher.addObserver(self) { [weak self] (objectPublisher) in
                
                guard let self = self else {
                    
                    return
                }
                self.item = objectPublisher.snapshot
            }
        }
        
        isolated deinit {
            
            self.objectPublisher?.removeObserver(self)
        }
    }
}

#endif
