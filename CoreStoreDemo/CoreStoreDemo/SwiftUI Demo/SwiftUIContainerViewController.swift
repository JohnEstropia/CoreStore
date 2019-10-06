//
//  SwiftUIContainerViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2019/10/02.
//  Copyright © 2019 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore

#if canImport(SwiftUI)
import SwiftUI

#endif

final class SwiftUIContainerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if canImport(SwiftUI)
        
        if #available(iOS 13, *) {
            
            let hostingController = UIHostingController(
                rootView: SwiftUIView(
                    palettes: ColorsDemo.stack.liveList(
                        From<Palette>()
                            .sectionBy(\.colorName)
                            .orderBy(.ascending(\.hue))
                    )
                )
                .environment(\.dataStack, ColorsDemo.stack)
            )
            self.addChild(hostingController)
            
            hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hostingController.view.frame = self.view.bounds.inset(by: self.view.safeAreaInsets)
            self.view.addSubview(hostingController.view)
            
            hostingController.didMove(toParent: self)
        }

        #endif
    }
}
