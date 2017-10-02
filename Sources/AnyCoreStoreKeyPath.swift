//
//  AnyCoreStoreKeyPath.swift
//  CoreStore
//
//  Created by John Estropia on 2017/10/02.
//  Copyright © 2017 John Rommel Estropia. All rights reserved.
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

