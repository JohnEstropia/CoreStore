//
//  OrganismProtocol.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/06/27.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import Foundation

protocol OrganismProtocol: class {
    
    var dna: Int64 { get set }
    
    func mutate()
}
