//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import UIKit


// MARK: - UIImage

extension UIImage {
    
    // MARK: Internal
    
    convenience init(
        color: UIColor,
        size: CGSize = CGSize(width: 1, height: 1),
        cornerRadius: CGFloat = 0
    ) {
        let rect = CGRect(origin: .zero, size: size)
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()!

        if cornerRadius > 0 {
            UIBezierPath(
                roundedRect: rect,
                cornerRadius: cornerRadius
            )
            .addClip()
        }
        color.setFill()
        context.fill(rect)

        self.init(
            cgImage: UIGraphicsGetImageFromCurrentImageContext()!.cgImage!,
            scale: scale,
            orientation: .up
        )
    }
}
