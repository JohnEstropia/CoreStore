//
//  TimeZone.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/06/15.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import Foundation
import CoreData

class TimeZone: NSManagedObject {

    @NSManaged var secondsFromGMT: Int32
    @NSManaged var abbreviation: String
    @NSManaged var hasDaylightSavingTime: Bool
    @NSManaged var daylightSavingTimeOffset: Double
    @NSManaged var name: String

}
