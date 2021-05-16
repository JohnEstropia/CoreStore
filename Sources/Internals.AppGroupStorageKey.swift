//
//  Internals.AppGroupStorageKey.swift
//  CoreStore
//
//  Created by John Rommel Estropia on 2021/05/08.
//  Copyright © 2021 John Rommel Estropia. All rights reserved.
//

import Foundation


// MARK: - Internals

extension Internals {
    
    // MARK: - AppGroupStorageKey
    
    internal struct AppGroupStorageKey: Hashable {
        
        // MARK: Internal
        
        internal let appGroupID: AppGroupID
        internal let bundleID: BundleID
        internal let storageID: StorageID
        
        
        // MARK: - AppGroupID
        
        internal struct AppGroupID: RawRepresentable, Codable, Hashable, CustomStringConvertible {
            
            // MARK: - RawRepresentable
            
            let rawValue: String
            
            init(rawValue: String) {
                
                self.rawValue = rawValue
            }
            
            
            // MARK: - CustomStringConvertible
            
            var description: String {
                
                return self.rawValue
            }
        }
        
        
        // MARK: - BundleID
        
        internal struct BundleID: RawRepresentable, Codable, Hashable, CustomStringConvertible {
            
            // MARK: - RawRepresentable
            
            let rawValue: String
            
            init(rawValue: String) {
                
                self.rawValue = rawValue
            }
            
            
            // MARK: - CustomStringConvertible
            
            var description: String {
                
                return self.rawValue
            }
        }
        
        
        // MARK: - StorageID
        
        internal struct StorageID: RawRepresentable, Codable, Hashable, CustomStringConvertible {
            
            // MARK: - RawRepresentable
            
            let rawValue: UUID
            
            init(rawValue: UUID) {
                
                self.rawValue = rawValue
            }
            
            
            // MARK: - CustomStringConvertible
            
            var description: String {
                
                return self.rawValue.uuidString
            }
        }
    }
}
