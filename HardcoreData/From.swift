//
//  From.swift
//  HardcoreData
//
//  Created by John Rommel Estropia on 2015/03/21.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import Foundation
import CoreData


// MARK: - From

public struct From<T: NSManagedObject> {
    
    public init(){ }
    public init(_ entity: T.Type) { }
}
