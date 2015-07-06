//
//  NSManagedObjectModel+Setup.swift
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


// MARK: - NSManagedObjectModel

internal extension NSManagedObjectModel {
    
    // MARK: Internal
    
    func entityNameForClass(entityClass: AnyClass) -> String {
        
        return self.entityNameMapping[NSStringFromClass(entityClass)]!
    }
    
    func configurationsForClass(entityClass: AnyClass) -> Set<String> {
        
        return self.entityConfigurationsMapping[NSStringFromClass(entityClass)]!
    }
    
    
    // MARK: Private
    
    
    internal var entityNameMapping: [String: String] {
        
        get {
            
            if let mapping: NSDictionary? = getAssociatedObjectForKey(&PropertyKeys.entityNameMapping, inObject: self) {
                
                return mapping as! [String: String]
            }
            
            let mapping = self.entities.reduce([String: String]()) {
                (var mapping, entityDescription) -> [String: String] in
                
                if let entityName = entityDescription.name {
                    
                    let className = entityDescription.managedObjectClassName
                    mapping[className] = entityName
                }
                return mapping
            }
            setAssociatedCopiedObject(
                mapping as NSDictionary,
                forKey: &PropertyKeys.entityNameMapping,
                inObject: self
            )
            return mapping
        }
    }
    
    private lazy var entityConfigurationsMapping: [String: Set<String>] = {
        [unowned self] in
        
        return self.configurations.reduce([String: Set<String>]()) {
            (var mapping, configuration) -> [String: Set<String>] in
            
            return (self.entitiesForConfiguration(configuration) ?? []).reduce(mapping) {
                (var mapping, entityDescription) -> [String: Set<String>] in
                
                let className = entityDescription.managedObjectClassName
                mapping[className]?.insert(configuration)
                return mapping
            }
        }
    }()
    
    private struct PropertyKeys {
        
        static var entityNameMapping: Void?
        static var entityConfigurationsMapping: Void?
    }
}
