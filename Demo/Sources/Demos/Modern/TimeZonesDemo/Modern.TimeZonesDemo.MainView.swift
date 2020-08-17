//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import SwiftUI

// MARK: - Modern.TimeZonesDemo

extension Modern.TimeZonesDemo {
    
    // MARK: - Modern.TimeZonesDemo.MainView

    struct MainView: View {
        
        /**
         ⭐️ Sample 1: Plain object fetch
         */
        private func fetchAllTimeZones() -> [Modern.TimeZonesDemo.TimeZone] {
            
            return try! Modern.TimeZonesDemo.dataStack.fetchAll(
                From<Modern.TimeZonesDemo.TimeZone>()
                    .orderBy(.ascending(\.$secondsFromGMT))
            )
        }
        
        /**
         ⭐️ Sample 2: Plain object fetch with simple `where` clause
         */
        private func fetchTimeZonesWithDST() -> [Modern.TimeZonesDemo.TimeZone] {
            
            return try! Modern.TimeZonesDemo.dataStack.fetchAll(
                From<Modern.TimeZonesDemo.TimeZone>()
                    .where(\.$isDaylightSavingTime == true)
                    .orderBy(.ascending(\.$name))
            )
        }
        
        /**
         ⭐️ Sample 3: Plain object fetch with custom `where` clause
         */
        private func fetchTimeZonesInAsia() -> [Modern.TimeZonesDemo.TimeZone] {
            
            return try! Modern.TimeZonesDemo.dataStack.fetchAll(
                From<Modern.TimeZonesDemo.TimeZone>()
                    .where(
                        format: "%K BEGINSWITH[c] %@",
                        String(keyPath: \Modern.TimeZonesDemo.TimeZone.$name),
                        "Asia"
                    )
                    .orderBy(.ascending(\.$secondsFromGMT))
            )
        }
        
        /**
         ⭐️ Sample 4: Plain object fetch with complex `where` clauses
         */
        private func fetchTimeZonesNearUTC() -> [Modern.TimeZonesDemo.TimeZone] {
            
            let secondsIn3Hours = 60 * 60 * 3
            return try! Modern.TimeZonesDemo.dataStack.fetchAll(
                From<Modern.TimeZonesDemo.TimeZone>()
                    .where((-secondsIn3Hours ... secondsIn3Hours) ~= \.$secondsFromGMT)
                    /// equivalent to:
                    /// ```
                    /// .where(\.$secondsFromGMT >= -secondsIn3Hours
                    ///     && \.$secondsFromGMT <= secondsIn3Hours)
                    /// ```
                    .orderBy(.ascending(\.$secondsFromGMT))
            )
        }
        
        /**
         ⭐️ Sample 5: Querying single raw value with simple `select` clause
         */
        private func queryNumberOfTimeZones() -> Int? {
            
            return try! Modern.TimeZonesDemo.dataStack.queryValue(
                From<Modern.TimeZonesDemo.TimeZone>()
                    .select(Int.self, .count(\.$name))
            )
        }
        
        /**
         ⭐️ Sample 6: Querying single raw values with `select` and `where` clauses
         */
        private func queryTokyoTimeZoneAbbreviation() -> String? {
            
            return try! Modern.TimeZonesDemo.dataStack.queryValue(
                From<Modern.TimeZonesDemo.TimeZone>()
                    .select(String.self, .attribute(\.$abbreviation))
                    .where(
                        format: "%K ENDSWITH[c] %@",
                        String(keyPath: \Modern.TimeZonesDemo.TimeZone.$name),
                        "Tokyo"
                    )
            )
        }
        
        /**
         ⭐️ Sample 7: Querying a list of raw values with multiple attributes
         */
        private func queryAllNamesAndAbbreviations() -> [[String: Any]]? {
            
            return try! Modern.TimeZonesDemo.dataStack.queryAttributes(
                From<Modern.TimeZonesDemo.TimeZone>()
                    .select(
                        NSDictionary.self,
                        .attribute(\.$name),
                        .attribute(\.$abbreviation)
                    )
                    .orderBy(.ascending(\.$name))
            )
        }
        
        /**
         ⭐️ Sample 7: Querying a list of raw values grouped by similar field
         */
        private func queryNumberOfCountriesWithAndWithoutDST() -> [[String: Any]]? {
            
            return try! Modern.TimeZonesDemo.dataStack.queryAttributes(
                From<Modern.TimeZonesDemo.TimeZone>()
                    .select(
                        NSDictionary.self,
                        .count(\.$isDaylightSavingTime, as: "numberOfCountries"),
                        .attribute(\.$isDaylightSavingTime)
                    )
                    .groupBy(\.$isDaylightSavingTime)
                    .orderBy(
                        .ascending(\.$isDaylightSavingTime),
                        .ascending(\.$name)
                    )
            )
        }
        
        
        // MARK: View
        
        var body: some View {
            List {
                Section(header: Text("Fetching objects")) {
                    ForEach(self.fetchingItems, id: \.title) { item in
                        Menu.ItemView(
                            title: item.title,
                            destination: {
                                Modern.TimeZonesDemo.ListView(
                                    title: item.title,
                                    objects: item.objects()
                                )
                            }
                        )
                    }
                }
                Section(header: Text("Querying raw values")) {
                    ForEach(self.queryingItems, id: \.title) { item in
                        Menu.ItemView(
                            title: item.title,
                            destination: {
                                Modern.TimeZonesDemo.ListView(
                                    title: item.title,
                                    value: item.value()
                                )
                            }
                        )
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Time Zones")
        }
        
        
        // MARK: Private
        
        private var fetchingItems: [(title: String, objects: () -> [Modern.TimeZonesDemo.TimeZone])] {
            
            return [
                (
                    "All Time Zones",
                    self.fetchAllTimeZones
                ),
                (
                    "Time Zones with Daylight Savings",
                    self.fetchTimeZonesWithDST
                ),
                (
                    "Time Zones in Asia",
                    self.fetchTimeZonesInAsia
                ),
                (
                    "Time Zones at most 3 hours away from UTC",
                    self.fetchTimeZonesNearUTC
                )
            ]
        }
        
        private var queryingItems: [(title: String, value: () -> Any?)] {
            
            return [
                (
                    "Number of Time Zones",
                    self.queryNumberOfTimeZones
                ),
                (
                    "Abbreviation for Tokyo's Time Zone",
                    self.queryTokyoTimeZoneAbbreviation
                ),
                (
                    "All Names and Abbreviations",
                    self.queryAllNamesAndAbbreviations
                ),
                (
                    "Number of Countries with and without DST",
                    self.queryNumberOfCountriesWithAndWithoutDST
                )
            ]
        }
    }
}


#if DEBUG

struct _Demo_Modern_TimeZonesDemo_MainView_Preview: PreviewProvider {
    
    // MARK: PreviewProvider
    
    static var previews: some View {
        
        Modern.TimeZonesDemo.MainView()
    }
}

#endif
