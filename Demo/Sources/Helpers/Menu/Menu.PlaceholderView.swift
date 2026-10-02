//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import SwiftUI
import UIKit

// MARK: - Menu

extension Menu {
    
    // MARK: - Menu.PlaceholderView
    
    struct PlaceholderView: UIViewControllerRepresentable {
        
        // MARK: UIViewControllerRepresentable
        
        typealias UIViewControllerType = UIViewController
        
        func makeUIViewController(context: Self.Context) -> UIViewControllerType {
            
            return UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()!
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Self.Context) {}
        
        static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Void) {}
    }
}
