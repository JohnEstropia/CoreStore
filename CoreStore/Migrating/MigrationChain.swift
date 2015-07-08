//
//  MigrationChain.swift
//  CoreStore
//
//  Copyright (c) 2015 John Rommel Estropia
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
import CoreData


// MARK: - MigrationChain

public struct MigrationChain: NilLiteralConvertible, StringLiteralConvertible, DictionaryLiteralConvertible, ArrayLiteralConvertible {
    
    // MARK: NilLiteralConvertible
    
    public init(nilLiteral: ()) {
        
        self.versionTree = [:]
        self.rootVersions = []
        self.leafVersions = []
        self.valid = true
    }
    
    
    // MARK: StringLiteralConvertible
    
    public init(stringLiteral value: String) {
        
        self.versionTree = [:]
        self.rootVersions = [value]
        self.leafVersions = [value]
        self.valid = true
    }
    
    
    // MARK: ExtendedGraphemeClusterLiteralConvertible
    
    public init(extendedGraphemeClusterLiteral value: String) {
        
        self.versionTree = [:]
        self.rootVersions = [value]
        self.leafVersions = [value]
        self.valid = true
    }
    
    
    // MARK: UnicodeScalarLiteralConvertible
    
    public init(unicodeScalarLiteral value: String) {
        
        self.versionTree = [:]
        self.rootVersions = [value]
        self.leafVersions = [value]
        self.valid = true
    }
    
    
    // MARK: DictionaryLiteralConvertible
    
    public init(dictionaryLiteral elements: (String, String)...) {
        
        var valid = true
        let versionTree = elements.reduce([String: String]()) { (var versionTree, tuple: (String, String)) -> [String: String] in
            
            if let _ = versionTree.updateValue(tuple.1, forKey: tuple.0) {
                
                valid = false
            }
            return versionTree
        }
        let leafVersions = Set(
            elements.filter { (tuple: (String, String)) -> Bool in
                
                return versionTree[tuple.1] == nil
                
            }.map { $1 }
        )
        
        self.versionTree = versionTree
        self.rootVersions = Set(versionTree.keys).subtract(versionTree.values)
        self.leafVersions = leafVersions
        self.valid = valid
    }
    
    
    // MARK: ArrayLiteralConvertible
    
    public init(arrayLiteral elements: String...) {
        
        CoreStore.assert(Set(elements).count == elements.count, "\(typeName(MigrationChain))'s migration chain could not be created due to duplicate version strings.")
        
        var lastVersion: String?
        var versionTree = [String: String]()
        var valid = true
        for version in elements {
            
            if let lastVersion = lastVersion {
                
                if let _ = versionTree.updateValue(version, forKey: lastVersion) {
                    
                    valid = false
                }
            }
            lastVersion = version
        }
        
        self.versionTree = versionTree
        self.rootVersions = Set([elements.first].flatMap { $0 == nil ? [] : [$0!] })
        self.leafVersions = Set([elements.last].flatMap { $0 == nil ? [] : [$0!] })
        self.valid = valid
    }
    
    
    // MARK: Internal
    
    internal let rootVersions: Set<String>
    internal let leafVersions: Set<String>
    internal let valid: Bool
    
    internal func contains(version: String) -> Bool {
        
        return self.rootVersions.contains(version)
            || self.leafVersions.contains(version)
            || self.versionTree[version] != nil
    }
    
    internal func nextVersionFrom(version: String) -> String? {
        
        if let nextVersion = self.versionTree[version] where nextVersion != version {
            
            return nextVersion
        }
        return nil
    }
    
    
    // MARK: Private
    
    private let versionTree: [String: String]
}


// MARK: - MigrationChain: CustomDebugStringConvertible

extension MigrationChain: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        
        guard self.valid else {
            
            return "<invalid migration chain>"
        }
        
        var paths = [String]()
        for var version in self.rootVersions {
            
            var steps = [version]
            while let nextVersion = self.nextVersionFrom(version) {
                
                steps.append(nextVersion)
                version = nextVersion
            }
            paths.append(" → ".join(steps))
        }
        
        return "[" + "], [".join(paths) + "]"
    }
}
