//
//  SelectTests.swift
//  CoreStore
//
//  Copyright © 2016 John Rommel Estropia
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


//MARK: - SelectTests

final class SelectTests: XCTestCase {
    
    @objc
    dynamic func test_ThatAttributeSelectTerms_ConfigureCorrectly() {
        
        do {
            
            let term: SelectTerm = "attribute"
            XCTAssertEqual(term, SelectTerm.attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.attribute("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.objectID())
            switch term {
                
            case ._attribute(let key):
                XCTAssertEqual(key, "attribute")
                
            default:
                XCTFail()
            }
        }
        do {
            
            let term = SelectTerm.attribute("attribute")
            XCTAssertNotEqual(term, SelectTerm.attribute("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.objectID())
            switch term {
                
            case ._attribute(let key):
                XCTAssertEqual(key, "attribute")
                
            default:
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatAverageSelectTerms_ConfigureCorrectly() {
        
        do {
            
            let term = SelectTerm.average("attribute")
            XCTAssertEqual(term, SelectTerm.average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute", as: "alias"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.objectID())
            switch term {
                
            case ._aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "average:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "average(attribute)")
                XCTAssertTrue(nativeType == .decimalAttributeType)
                
            default:
                XCTFail()
            }
        }
        do {
            
            let term = SelectTerm.average("attribute", as: "alias")
            XCTAssertEqual(term, SelectTerm.average("attribute", as: "alias"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute", as: "alias2"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.objectID())
            switch term {
                
            case ._aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "average:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "alias")
                XCTAssertTrue(nativeType == .decimalAttributeType)
                
            default:
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatCountSelectTerms_ConfigureCorrectly() {
        
        do {
            
            let term = SelectTerm.count("attribute")
            XCTAssertEqual(term, SelectTerm.count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute", as: "alias"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.objectID())
            switch term {
                
            case ._aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "count:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "count(attribute)")
                XCTAssertTrue(nativeType == .integer64AttributeType)
                
            default:
                XCTFail()
            }
        }
        do {
            
            let term = SelectTerm.count("attribute", as: "alias")
            XCTAssertEqual(term, SelectTerm.count("attribute", as: "alias"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute", as: "alias2"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.objectID())
            switch term {
                
            case ._aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "count:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "alias")
                XCTAssertTrue(nativeType == .integer64AttributeType)
                
            default:
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatMaximumSelectTerms_ConfigureCorrectly() {
        
        do {
            
            let term = SelectTerm.maximum("attribute")
            XCTAssertEqual(term, SelectTerm.maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute", as: "alias"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.objectID())
            switch term {
                
            case ._aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "max:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "max(attribute)")
                XCTAssertTrue(nativeType == .undefinedAttributeType)
                
            default:
                XCTFail()
            }
        }
        do {
            
            let term = SelectTerm.maximum("attribute", as: "alias")
            XCTAssertEqual(term, SelectTerm.maximum("attribute", as: "alias"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute", as: "alias2"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.objectID())
            switch term {
                
            case ._aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "max:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "alias")
                XCTAssertTrue(nativeType == .undefinedAttributeType)
                
            default:
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatMinimumSelectTerms_ConfigureCorrectly() {
        
        do {
            
            let term = SelectTerm.minimum("attribute")
            XCTAssertEqual(term, SelectTerm.minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute", as: "alias"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.objectID())
            switch term {
                
            case ._aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "min:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "min(attribute)")
                XCTAssertTrue(nativeType == .undefinedAttributeType)
                
            default:
                XCTFail()
            }
        }
        do {
            
            let term = SelectTerm.minimum("attribute", as: "alias")
            XCTAssertEqual(term, SelectTerm.minimum("attribute", as: "alias"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute", as: "alias2"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.objectID())
            switch term {
                
            case ._aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "min:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "alias")
                XCTAssertTrue(nativeType == .undefinedAttributeType)
                
            default:
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatSumSelectTerms_ConfigureCorrectly() {
        
        do {
            
            let term = SelectTerm.sum("attribute")
            XCTAssertEqual(term, SelectTerm.sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute", as: "alias"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.objectID())
            switch term {
                
            case ._aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "sum:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "sum(attribute)")
                XCTAssertTrue(nativeType == .decimalAttributeType)
                
            default:
                XCTFail()
            }
        }
        do {
            
            let term = SelectTerm.sum("attribute", as: "alias")
            XCTAssertEqual(term, SelectTerm.sum("attribute", as: "alias"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute", as: "alias2"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.objectID())
            switch term {
                
            case ._aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "sum:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "alias")
                XCTAssertTrue(nativeType == .decimalAttributeType)
                
            default:
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatObjectIDSelectTerms_ConfigureCorrectly() {
        
        do {
            
            let term = SelectTerm.objectID()
            XCTAssertEqual(term, SelectTerm.objectID())
            XCTAssertNotEqual(term, SelectTerm.objectID(as: "alias"))
            XCTAssertNotEqual(term, SelectTerm.attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute"))
            switch term {
                
            case ._identity(let alias, let nativeType):
                XCTAssertEqual(alias, "objectID")
                XCTAssertTrue(nativeType == .objectIDAttributeType)
                
            default:
                XCTFail()
            }
        }
        do {
            
            let term = SelectTerm.objectID(as: "alias")
            XCTAssertEqual(term, SelectTerm.objectID(as: "alias"))
            XCTAssertNotEqual(term, SelectTerm.objectID(as: "alias2"))
            XCTAssertNotEqual(term, SelectTerm.objectID())
            XCTAssertNotEqual(term, SelectTerm.attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.sum("attribute"))
            switch term {
                
            case ._identity(let alias, let nativeType):
                XCTAssertEqual(alias, "alias")
                XCTAssertTrue(nativeType == .objectIDAttributeType)
                
            default:
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatSelectClauses_ConfigureCorrectly() {
        
        let term1 = SelectTerm.attribute("attribute1")
        let term2 = SelectTerm.attribute("attribute2")
        let term3 = SelectTerm.attribute("attribute3")
        do {
            
            let select = Select<Int>(term1, term2, term3)
            XCTAssertEqual(select.selectTerms, [term1, term2, term3])
            XCTAssertNotEqual(select.selectTerms, [term1, term3, term2])
            XCTAssertNotEqual(select.selectTerms, [term2, term1, term3])
            XCTAssertNotEqual(select.selectTerms, [term2, term3, term1])
            XCTAssertNotEqual(select.selectTerms, [term3, term1, term2])
            XCTAssertNotEqual(select.selectTerms, [term3, term2, term1])
        }
        do {
            
            let select = Select<Int>([term1, term2, term3])
            XCTAssertEqual(select.selectTerms, [term1, term2, term3])
            XCTAssertNotEqual(select.selectTerms, [term1, term3, term2])
            XCTAssertNotEqual(select.selectTerms, [term2, term1, term3])
            XCTAssertNotEqual(select.selectTerms, [term2, term3, term1])
            XCTAssertNotEqual(select.selectTerms, [term3, term1, term2])
            XCTAssertNotEqual(select.selectTerms, [term3, term2, term1])
        }
    }
}
