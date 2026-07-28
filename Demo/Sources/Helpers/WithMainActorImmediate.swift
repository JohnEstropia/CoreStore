//
//  WithMainActorImmediate.swift
//  Demo
//
//  Created by John Estropia on 2026/07/21.
//

import Foundation


// MARK: - withMainActorImmediate

func withMainActorImmediate(
    _ task: @MainActor @Sendable @escaping () -> Void
) {
    
    if #available(iOS 26.0, *) {
        
        Task.immediate(operation: task)
    }
    else if Thread.isMainThread {
        
        MainActor.assumeIsolated {
            
            task()
        }
    }
    else {
        
        Task.init(operation: task)
    }
}
