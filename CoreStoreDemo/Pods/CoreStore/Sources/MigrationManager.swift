//
//  MigrationManager.swift
//  CoreStore
//
//  Copyright © 2015 John Rommel Estropia
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


// MARK: - MigrationManager

internal final class MigrationManager: NSMigrationManager, ProgressReporting {
    
    // MARK: NSObject
    
    override func didChangeValue(forKey key: String) {
        
        super.didChangeValue(forKey: key)
        
        guard key == #keyPath(NSMigrationManager.migrationProgress) else {
            
            return
        }
        let progress = self.progress
        progress.completedUnitCount = Int64(Float(progress.totalUnitCount) * self.migrationProgress)
    }
    
    
    // MARK: NSMigrationManager

    init(sourceModel: NSManagedObjectModel, destinationModel: NSManagedObjectModel, progress: Progress) {
        
        self.progress = progress
        
        super.init(sourceModel: sourceModel, destinationModel: destinationModel)
    }
    

    // MARK: ProgressReporting
    
    let progress: Progress
}
