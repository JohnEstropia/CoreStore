//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore

// MARK: - Modern.TimeZonesDemo

extension Modern.TimeZonesDemo {

    // MARK: - Modern.TimeZonesDemo.TimeZone
    
    final class TimeZone: CoreStoreObject {
        
        // MARK: Internal
        
        @Field.Stored("secondsFromGMT")
        var secondsFromGMT: Int = 0
        
        @Field.Stored("abbreviation")
        var abbreviation: String = ""
        
        @Field.Stored("isDaylightSavingTime")
        var isDaylightSavingTime: Bool = false
        
        @Field.Stored("daylightSavingTimeOffset")
        var daylightSavingTimeOffset: Double = 0
        
        @Field.Stored("name")
        var name: String = ""
    }
}
