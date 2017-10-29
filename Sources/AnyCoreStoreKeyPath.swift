//
//  AnyCoreStoreKeyPath.swift
//  CoreStore
//
//  Copyright © 2017 John Rommel Estropia
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

import Foundation


// MARK: - AnyCoreStoreKeyPath

public protocol AnyCoreStoreKeyPath {
    
    var cs_keyPathString: String { get }
}

// SE-0143 is not implemented: https://github.com/apple/swift-evolution/blob/master/proposals/0143-conditional-conformances.md
//extension KeyPath: AnyCoreStoreKeyPath where Root: NSManagedObject, Value: ImportableAttributeType {
//
//    public var cs_keyPathString: String {
//
//        return self._kvcKeyPathString!
//    }
//}

extension ValueContainer.Required: AnyCoreStoreKeyPath {
    
    public var cs_keyPathString: String {
    
        return self.keyPath
    }
}

extension ValueContainer.Optional: AnyCoreStoreKeyPath {
    
    public var cs_keyPathString: String {
        
        return self.keyPath
    }
}

extension TransformableContainer.Required: AnyCoreStoreKeyPath {
    
    public var cs_keyPathString: String {
        
        return self.keyPath
    }
}

extension TransformableContainer.Optional: AnyCoreStoreKeyPath {
    
    public var cs_keyPathString: String {
        
        return self.keyPath
    }
}

extension RelationshipContainer.ToOne: AnyCoreStoreKeyPath {
    
    public var cs_keyPathString: String {
        
        return self.keyPath
    }
}

extension RelationshipContainer.ToManyOrdered: AnyCoreStoreKeyPath {
    
    public var cs_keyPathString: String {
        
        return self.keyPath
    }
}

extension RelationshipContainer.ToManyUnordered: AnyCoreStoreKeyPath {
    
    public var cs_keyPathString: String {
        
        return self.keyPath
    }
}

