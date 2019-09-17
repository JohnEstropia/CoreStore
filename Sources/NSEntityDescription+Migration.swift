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
    
    /// Maps attributes of the current entity with the earlier-version source entity. Todo: Log a warning if the renaming identifier is used but not found in source.
    internal func mapAttributes(in sourceEntity: NSEntityDescription) throws -> [NSAttributeDescription: NSAttributeDescription] {
        let sourceAttributes: [String: NSAttributeDescription] = sourceEntity.attributesByName
        return try self.properties.lazy.compactMap({ $0 as? NSAttributeDescription }).reduce(into: [:], { (result, attribute: NSAttributeDescription) in
            if let sourceAttribute = attribute.renamingIdentifier.flatMap({ sourceAttributes[$0] }) ?? sourceAttributes[attribute.name] {
                result[attribute] = sourceAttribute
            } else if !attribute.isOptional && attribute.defaultValue == nil {
                throw MappingError.cannotMapAttribute(attribute: attribute)
            }
        })
    }
    
    /// Maps relationships of the current entity with the earlier-version source entity. Todo: Log a warning if the renaming identifier is used but not found in source.
    internal func mapRelationships(in sourceEntity: NSEntityDescription) throws -> [NSRelationshipDescription: NSRelationshipDescription] {
        let sourceRelationships: [String: NSRelationshipDescription] = sourceEntity.relationshipsByName
        return try self.properties.lazy.compactMap({ $0 as? NSRelationshipDescription }).reduce(into: [:], { (result, relationship: NSRelationshipDescription) in
            if let sourceRelationship = relationship.renamingIdentifier.flatMap({ sourceRelationships[$0] }) ?? sourceRelationships[relationship.name] {
                result[relationship] = sourceRelationship
            } else if !relationship.isOptional {
                throw MappingError.cannotMapRelationship(relationship: relationship)
            }
        })
    }
}

extension NSEntityDescription {
    internal enum MappingError: Swift.Error {
        
        /// The required attribute without default value could not be mapped in source entity. 
        case cannotMapAttribute(attribute: NSAttributeDescription)
        
        /// The required relationship could not be mapped in source entity. 
        case cannotMapRelationship(relationship: NSRelationshipDescription)
    }
}