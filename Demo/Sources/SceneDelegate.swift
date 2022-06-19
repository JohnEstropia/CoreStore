//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import SwiftUI
import UIKit

// MARK: - SceneDelegate

@objc final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: UIWindowSceneDelegate

    @objc dynamic var window: UIWindow?

    
    // MARK: UISceneDelegate

    @objc dynamic func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        
        guard case let scene as UIWindowScene = scene else {
            
            return
        }
        let window = UIWindow(windowScene: scene)
        window.rootViewController = UIHostingController(
            rootView: Menu.MainView()
        )
        self.window = window
        window.makeKeyAndVisible()
    }
}
