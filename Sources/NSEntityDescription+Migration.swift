//
//  NSEntityDescription+Migration.swift
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

import CoreData
import Foundation


// MARK: - NSEntityDescription

internal extension NSEntityDescription {
    
    @nonobjc
    internal func cs_resolvedAttributeRenamingIdentities() -> [String: (attribute: NSAttributeDescription, versionHash: Data)] {
        
        var mapping: [String: (attribute: NSAttributeDescription, versionHash: Data)] = [:]
        for (attributeName, attributeDescription) in self.attributesByName {
            
            mapping[attributeDescription.renamingIdentifier ?? attributeName] = (attributeDescription, attributeDescription.versionHash)
        }
        return mapping
    }
    
    @nonobjc
    internal func cs_resolvedRelationshipRenamingIdentities() -> [String: (relationship: NSRelationshipDescription, versionHash: Data)] {
        
        var mapping: [String: (relationship: NSRelationshipDescription, versionHash: Data)] = [:]
        for (relationshipName, relationshipDescription) in self.relationshipsByName {
            
            mapping[relationshipDescription.renamingIdentifier ?? relationshipName] = (relationshipDescription, relationshipDescription.versionHash)
        }
        return mapping
    }
}
