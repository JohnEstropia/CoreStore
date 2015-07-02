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
    
    // MARK: Public
    
    public func contains(version: String) -> Bool {
        
        return self.rootVersions.contains(version)
            || self.leafVersions.contains(version)
            || self.versionTree[version] != nil
    }
    
    public func nextVersionFrom(version: String) -> String? {
        
        return self.versionTree[version]
    }
    
    
    // MARK: NilLiteralConvertible
    
    public init(nilLiteral: ()) {
        
        self.versionTree = [:]
        self.rootVersions = []
        self.leafVersions = []
    }
    
    
    // MARK: StringLiteralConvertible
    
    public init(stringLiteral value: String) {
        
        self.versionTree = [:]
        self.rootVersions = [value]
        self.leafVersions = [value]
    }
    
    // MARK: ExtendedGraphemeClusterLiteralConvertible
    
    public init(extendedGraphemeClusterLiteral value: String) {
        
        self.versionTree = [:]
        self.rootVersions = [value]
        self.leafVersions = [value]
    }
    
    
    // MARK: UnicodeScalarLiteralConvertible
    
    public init(unicodeScalarLiteral value: String) {
        
        self.versionTree = [:]
        self.rootVersions = [value]
        self.leafVersions = [value]
    }
    
    
    // MARK: DictionaryLiteralConvertible
    
    public init(dictionaryLiteral elements: (String, String)...) {
        
        let versionTree = elements.reduce([String: String]()) { (var versionTree, tuple: (String, String)) -> [String: String] in
            
            versionTree[tuple.0] = tuple.1
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
    }
    
    
    // MARK: ArrayLiteralConvertible
    
    public init(arrayLiteral elements: String...) {
        
        CoreStore.assert(Set(elements).count == elements.count, "\(typeName(MigrationChain))'s migration chain could not be created due to duplicate version strings.")
        
        var lastVersion: String?
        var versionTree = [String: String]()
        for version in elements {
            
            if let lastVersion = lastVersion {
                
                versionTree[lastVersion] = version
            }
            lastVersion = version
        }
        
        self.versionTree = versionTree
        self.rootVersions = Set(flatMap([elements.first]) { $0 == nil ? [] : [$0!] })
        self.leafVersions = Set(flatMap([elements.last]) { $0 == nil ? [] : [$0!] })
    }
    
    
    // MARK: Internal
    
    internal let rootVersions: Set<String>
    internal let leafVersions: Set<String>
    
    
    // MARK: Private
    
    private let versionTree: [String: String]
}
