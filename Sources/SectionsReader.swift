//
//  SectionsReader.swift
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

#if canImport(Combine) && canImport(SwiftUI)

import Combine
import SwiftUI


// MARK: - SectionsReader

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public struct SectionsReader<Object: DynamicObject, Content: View>: View {
    
    // MARK: Internal
    
    public init(
        _ listPublisher: ListPublisher<Object>,
        @ViewBuilder content: @escaping (LiveList<Object>.Items) -> Content
    ) {
        
        self._list = .init(listPublisher)
        self.content = content
    }
    
    
    // MARK: View
    
    public var body: some View {
        
        self.content(self.list)
    }
    
    
    // MARK: Private
    
    @LiveList
    private var list: LiveList<Object>.Items
    
    private let content: (LiveList<Object>.Items) -> Content
}

#endif
