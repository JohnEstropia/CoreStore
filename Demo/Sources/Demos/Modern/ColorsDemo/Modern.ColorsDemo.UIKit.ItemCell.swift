//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import UIKit


// MARK: - Modern.ColorsDemo.UIKit

extension Modern.ColorsDemo.UIKit {

    // MARK: - Modern.ColorsDemo.UIKit.ItemCell
    
    final class ItemCell: UITableViewCell {
        
        // MARK: Internal
        
        static let reuseIdentifier: String = NSStringFromClass(Modern.ColorsDemo.UIKit.ItemCell.self)
        
        func setPalette(_ palette: Modern.ColorsDemo.Palette) {

            self.imageView?.image = UIImage(
                color: palette.color,
                size: .init(width: 30, height: 30),
                cornerRadius: 5
            )
            self.textLabel?.text = palette.colorText
        }
    }
}
