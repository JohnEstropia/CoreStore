//
//  SwiftUIHostingController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2019/10/02.
//  Copyright © 2019 John Rommel Estropia. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI
import UIKit

@available(iOS 13.0.0, *)
class SwiftUIHostingController: UIHostingController<SwiftUIView> {

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: SwiftUIView())
    }
}

#endif
