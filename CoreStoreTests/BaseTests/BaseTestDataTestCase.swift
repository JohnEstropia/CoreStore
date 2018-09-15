//
//  BaseTestDataTestCase.swift
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
