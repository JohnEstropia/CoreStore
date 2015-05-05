//
//  PaletteTableViewCell.swift
//  HardcoreDataDemo
//
//  Created by John Rommel Estropia on 2015/05/05.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import UIKit

class PaletteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var colorView: UIView?
    @IBOutlet weak var label: UILabel?
    
    func setHue(hue: Int32, saturation: Float, brightness: Float) {
        
        let color = UIColor(
            hue: CGFloat(hue) / 360.0,
            saturation: CGFloat(saturation),
            brightness: CGFloat(brightness),
            alpha: 1.0)
        self.colorView?.backgroundColor = color
        self.label?.text = "H: \(hue)˚, S: \(round(saturation * 100.0))%, B: \(round(brightness * 100.0))%"
    }
}
