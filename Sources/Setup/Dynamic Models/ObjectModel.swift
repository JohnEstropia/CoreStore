//
//  ObjectModel.swift
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

import CoreGraphics
import Foundation


// MARK: - ObjectModel

public final class ObjectModel {
    
    public let version: String
    
    public convenience init(version: String, entities: [EntityProtocol]) {
        
        self.init(version: version, configurationEntities: [DataStack.defaultConfigurationName: entities])
    }
    
    public required init(version: String, configurationEntities: [String: [EntityProtocol]]) {
        
        self.version = version
        
        var entityConfigurations: [String: Set<NSEntityDescription>] = [:]
        for (configuration, entities) in configurationEntities {
            
            entityConfigurations[configuration] = Set(entities.map({ $0.entityDescription }))
        }
        let allEntities = Set(entityConfigurations.map({ $0.value }).joined())
        entityConfigurations[DataStack.defaultConfigurationName] = allEntities
        
        self.entityConfigurations = entityConfigurations
        self.entities = allEntities
    }
    
    
    // MARK: Internal
    
    internal let entities: Set<NSEntityDescription>
    internal let entityConfigurations: [String: Set<NSEntityDescription>]
    
    internal func createModel() -> NSManagedObjectModel {
        
        let model = NSManagedObjectModel()
        model.entities = self.entities.sorted(by: { $0.name! < $1.name! })
        for (configuration, entities) in self.entityConfigurations {
            
            model.setEntities(
                entities.sorted(by: { $0.name! < $1.name! }),
                forConfigurationName: configuration
            )
        }
        return model
    }
}
