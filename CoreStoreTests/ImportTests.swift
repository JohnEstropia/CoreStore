//
//  ImportTests.swift
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

import XCTest

@testable
import CoreStore


// MARK: - ImportTests

class ImportTests: BaseTestDataTestCase {
    
    @objc
    dynamic func test_ThatAttributeProtocols_BehaveCorrectly() {
        
        XCTAssertEqual(NSNumber.cs_fromQueryableNativeType(NSNumber(value: true))?.boolValue, true)
        XCTAssertEqual(NSNumber.cs_fromQueryableNativeType(NSNumber(value: Int16.max))?.int16Value, Int16.max)
        XCTAssertEqual(NSNumber.cs_fromQueryableNativeType(NSNumber(value: Int32.max))?.int32Value, Int32.max)
        XCTAssertEqual(NSNumber.cs_fromQueryableNativeType(NSNumber(value: Int64.max))?.int64Value, Int64.max)
        XCTAssertEqual(NSNumber.cs_fromQueryableNativeType(NSNumber(value: MAXFLOAT))?.floatValue, MAXFLOAT)
        XCTAssertEqual(NSNumber.cs_fromQueryableNativeType(NSNumber(value: Double(MAXFLOAT)))?.doubleValue, Double(MAXFLOAT))
        
        XCTAssertEqual(NSDecimalNumber.cs_fromQueryableNativeType(NSDecimalNumber(string: "1"))?.boolValue, true)
        XCTAssertEqual(NSDecimalNumber.cs_fromQueryableNativeType(NSDecimalNumber(string: Int16.max.description))?.int16Value, Int16.max)
        XCTAssertEqual(NSDecimalNumber.cs_fromQueryableNativeType(NSDecimalNumber(string: Int32.max.description))?.int32Value, Int32.max)
        XCTAssertEqual(NSDecimalNumber.cs_fromQueryableNativeType(NSDecimalNumber(string: Int64.max.description))?.int64Value, Int64.max)
        XCTAssertEqual(NSDecimalNumber.cs_fromQueryableNativeType(NSDecimalNumber(string: MAXFLOAT.description))?.doubleValue, NSDecimalNumber(string: MAXFLOAT.description).doubleValue)
        XCTAssertEqual(NSDecimalNumber.cs_fromQueryableNativeType(NSDecimalNumber(string: MAXFLOAT.description))?.floatValue, NSDecimalNumber(string: MAXFLOAT.description).floatValue)
        
        XCTAssertEqual(NSNumber.cs_fromQueryableNativeType(NSDecimalNumber(string: "1"))?.boolValue, true)
        XCTAssertEqual(NSNumber.cs_fromQueryableNativeType(NSDecimalNumber(string: Int16.max.description))?.int16Value, Int16.max)
        XCTAssertEqual(NSNumber.cs_fromQueryableNativeType(NSDecimalNumber(string: Int32.max.description))?.int32Value, Int32.max)
        XCTAssertEqual(NSNumber.cs_fromQueryableNativeType(NSDecimalNumber(string: Int64.max.description))?.int64Value, Int64.max)
        XCTAssertEqual(NSNumber.cs_fromQueryableNativeType(NSDecimalNumber(string: MAXFLOAT.description))?.doubleValue, NSDecimalNumber(string: MAXFLOAT.description).doubleValue)
        XCTAssertEqual(NSNumber.cs_fromQueryableNativeType(NSDecimalNumber(string: MAXFLOAT.description))?.floatValue, NSDecimalNumber(string: MAXFLOAT.description).floatValue)
        
        XCTAssertNil(NSDecimalNumber.cs_fromQueryableNativeType(NSNumber(value: true)))
        XCTAssertNil(NSDecimalNumber.cs_fromQueryableNativeType(NSNumber(value: Int16.max)))
        XCTAssertNil(NSDecimalNumber.cs_fromQueryableNativeType(NSNumber(value: Int32.max)))
        XCTAssertNil(NSDecimalNumber.cs_fromQueryableNativeType(NSNumber(value: Int64.max)))
        XCTAssertNil(NSDecimalNumber.cs_fromQueryableNativeType(NSNumber(value: MAXFLOAT)))
        XCTAssertNil(NSDecimalNumber.cs_fromQueryableNativeType(NSNumber(value: Double(MAXFLOAT))))
        
        XCTAssertEqual(true.cs_toQueryableNativeType(), NSNumber(value: true))
        XCTAssertEqual(Int16.max.cs_toQueryableNativeType(), NSNumber(value: Int16.max))
        XCTAssertEqual(Int32.max.cs_toQueryableNativeType(), NSNumber(value: Int32.max))
        XCTAssertEqual(Int64.max.cs_toQueryableNativeType(), NSNumber(value: Int64.max))
        XCTAssertEqual(MAXFLOAT.cs_toQueryableNativeType(), NSNumber(value: MAXFLOAT))
        XCTAssertEqual(Double(MAXFLOAT).cs_toQueryableNativeType(), NSNumber(value: Double(MAXFLOAT)))
    }
}
