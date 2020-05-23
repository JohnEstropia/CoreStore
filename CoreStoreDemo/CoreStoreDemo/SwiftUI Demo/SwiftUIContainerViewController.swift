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

#if canImport(Combine)
import Combine

#endif

import Compression
final class SwiftUIContainerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if canImport(SwiftUI) && canImport(Combine)
        
        if #available(iOS 13, *) {
            
            let hostingController = UIHostingController(
                rootView: SwiftUIView(
                    palettes: ColorsDemo.stack.publishList(
                        From<Palette>()
                            .sectionBy(\.$colorName)
                            .orderBy(.ascending(\.$hue))
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
