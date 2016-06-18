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
    let dateFormatter: NSDateFormatter = {
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone(name: "UTC")
        formatter.calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        return formatter
    }()
    
    @nonobjc
    func prepareTestDataForStack(stack: DataStack, configurations: [String?] = [nil]) {
        
        stack.beginSynchronous { (transaction) in
            
            for (configurationIndex, configuration) in configurations.enumerate() {
                
                let configurationOrdinal = configurationIndex + 1
                if configuration == nil || configuration == "Config1" {
                    
                    for idIndex in 1 ... 5 {
                        
                        let object = transaction.create(Into<TestEntity1>(configuration))
                        object.testEntityID = NSNumber(integer: (configurationOrdinal * 100) + idIndex)
                        
                        object.testNumber = idIndex
                        object.testDate = self.dateFormatter.dateFromString("2000-\(configurationOrdinal)-\(idIndex)T00:00:00Z")
                        object.testBoolean = (idIndex % 2) == 1
                        object.testDecimal = NSDecimalNumber(string: "\(idIndex)")
                        
                        let string = "\(configuration ?? "nil"):TestEntity1:\(idIndex)"
                        object.testString = string
                        object.testData = (string as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                    }
                }
                if configuration == nil || configuration == "Config2" {
                    
                    for idIndex in 1 ... 5 {
                        
                        let object = transaction.create(Into<TestEntity2>(configuration))
                        object.testEntityID = NSNumber(integer: (configurationOrdinal * 200) + idIndex)
                        
                        object.testNumber = idIndex
                        object.testDate = self.dateFormatter.dateFromString("2000-\(configurationOrdinal)-\(idIndex)T00:00:00Z")
                        object.testBoolean = (idIndex % 2) == 1
                        object.testDecimal = NSDecimalNumber(string: "\(idIndex)")
                        
                        let string = "\(configuration ?? "nil"):TestEntity2:\(idIndex)"
                        object.testString = string
                        object.testData = (string as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                    }
                }
            }
            transaction.commitAndWait()
        }
    }
}
