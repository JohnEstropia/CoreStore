//
//  OrganismTableViewCell.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/07/12.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import UIKit

class OrganismTableViewCell: UITableViewCell {

    @IBOutlet weak dynamic var dnaLabel: UILabel?
    @IBOutlet weak dynamic var mutateButton: UIButton?
    
    var mutateButtonHandler: (() -> Void)?

    @IBAction dynamic func mutateButtonTouchUpInside(_ sender: UIButton?) {
     
        self.mutateButtonHandler?()
    }
}
