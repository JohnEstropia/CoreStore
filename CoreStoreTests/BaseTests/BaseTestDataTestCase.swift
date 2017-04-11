//
//  BaseTestDataTestCase.swift
//  CoreStore
//
//  Created by John Rommel Estropia on 2016/06/11.
//  Copyright © 2016 John Rommel Estropia. All rights reserved.
//

import Foundation

@testable
import CoreStore


// MARK: - BaseTestDataTestCase

class BaseTestDataTestCase: BaseTestCase {
    
    @nonobjc
    let dateFormatter: DateFormatter = cs_lazy {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        return formatter
    }
    
    @nonobjc
    func prepareTestDataForStack(_ stack: DataStack, configurations: [ModelConfiguration] = [nil]) {
        
        try! stack.perform(
            synchronous: { (transaction) in
                
                for (configurationIndex, configuration) in configurations.enumerated() {
                    
                    let configurationOrdinal = configurationIndex + 1
                    if configuration == nil || configuration == "Config1" {
                        
                        for idIndex in 1 ... 5 {
                            
                            let object = transaction.create(Into<TestEntity1>(configuration))
                            object.testEntityID = NSNumber(value: (configurationOrdinal * 100) + idIndex)
                            
                            object.testNumber = NSNumber(value: idIndex)
                            object.testDate = self.dateFormatter.date(from: "2000-\(configurationOrdinal)-\(idIndex)T00:00:00Z")
                            object.testBoolean = NSNumber(value: (idIndex % 2) == 1)
                            object.testDecimal = NSDecimalNumber(string: "\(idIndex)")
                            
                            let string = "\(configuration ?? "nil"):TestEntity1:\(idIndex)"
                            object.testString = string
                            object.testData = (string as NSString).data(using: String.Encoding.utf8.rawValue)
                        }
                    }
                    if configuration == nil || configuration == "Config2" {
                        
                        for idIndex in 1 ... 5 {
                            
                            let object = transaction.create(Into<TestEntity2>(configuration))
                            object.testEntityID = NSNumber(value: (configurationOrdinal * 200) + idIndex)
                            
                            object.testNumber = NSNumber(value: idIndex)
                            object.testDate = self.dateFormatter.date(from: "2000-\(configurationOrdinal)-\(idIndex)T00:00:00Z")
                            object.testBoolean = NSNumber(value: (idIndex % 2) == 1)
                            object.testDecimal = NSDecimalNumber(string: "\(idIndex)")
                            
                            let string = "\(configuration ?? "nil"):TestEntity2:\(idIndex)"
                            object.testString = string
                            object.testData = (string as NSString).data(using: String.Encoding.utf8.rawValue)
                        }
                    }
                }
            }
        )
    }
}
