//
//  XcodeDataModelSchema.swift
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


// MARK: - XcodeDataModelSchema

public final class XcodeDataModelSchema: DynamicSchema {
    
    public required init(modelVersion: ModelVersion, modelVersionFileURL: URL) {
        
        CoreStore.assert(
            NSManagedObjectModel(contentsOf: modelVersionFileURL) != nil,
            "Could not find the \"\(modelVersion).mom\" version file for the model at URL \"\(modelVersionFileURL)\"."
        )
        
        self.modelVersion = modelVersion
        self.modelVersionFileURL = modelVersionFileURL
    }
    
    
    // MARK: DynamicSchema
    
    public let modelVersion: ModelVersion
    
    public func rawModel() -> NSManagedObjectModel {
    
        if let cachedRawModel = self.cachedRawModel {
            
            return cachedRawModel
        }
        if let rawModel = NSManagedObjectModel(contentsOf: self.modelVersionFileURL) {
            
            self.cachedRawModel = rawModel
            return rawModel
        }
        CoreStore.abort("Could not create an \(cs_typeName(NSManagedObjectModel.self)) from the model at URL \"\(self.modelVersionFileURL)\".")
    }
    
    
    // MARK: Internal
    
    internal let modelVersionFileURL: URL
    
    private lazy var rootModelFileURL: URL = cs_lazy { [unowned self] in
     
        return self.modelVersionFileURL.deletingLastPathComponent()
    }
    
    
    // MARK: Private
    
    private weak var cachedRawModel: NSManagedObjectModel?
}
