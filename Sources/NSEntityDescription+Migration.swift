//
//  NSEntityDescription+Migration.swift
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
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

extension NSEntityDescription {
    
    @nonobjc
    internal func cs_resolveAttributeNames() -> [
        String: (
            attribute: NSAttributeDescription,
            versionHash: Data
        )
    ] {

        return self.attributesByName.reduce(
            into: [:],
            { (result, attribute: (key: String, value: NSAttributeDescription)) in

                result[attribute.key] = (attribute.value, attribute.value.versionHash)
            }
        )
    }
    
    @nonobjc
    internal func cs_resolveAttributeRenamingIdentities() -> [
        String: (
            attribute: NSAttributeDescription,
            versionHash: Data
        )
    ] {

        return self.attributesByName.reduce(
            into: [:],
            { (result, attribute: (key: String, value: NSAttributeDescription)) in

                result[attribute.value.renamingIdentifier ?? attribute.key] = (attribute.value, attribute.value.versionHash)
            }
        )
    }
    
    @nonobjc
    internal func cs_resolveRelationshipNames() -> [
        String: (
            relationship: NSRelationshipDescription,
            versionHash: Data
        )
    ] {

        return self.relationshipsByName.reduce(
            into: [:],
            { (result, relationship: (key: String, value: NSRelationshipDescription)) in

                result[relationship.key] = (relationship.value, relationship.value.versionHash)
            }
        )
    }
    
    @nonobjc
    internal func cs_resolveRelationshipRenamingIdentities() -> [
        String: (
            relationship: NSRelationshipDescription,
            versionHash: Data
        )
    ] {

        return self.relationshipsByName.reduce(
            into: [:],
            { (result, relationship: (key: String, value: NSRelationshipDescription)) in

                result[relationship.value.renamingIdentifier ?? relationship.key] = (relationship.value, relationship.value.versionHash)
            }
        )
    }
}
