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
            XCTAssertEqual(term, SelectTerm.Attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Attribute("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.ObjectID())
            switch term {
                
            case ._Attribute(let key):
                XCTAssertEqual(key, "attribute")
                
            default:
                XCTFail()
            }
        }
        do {
            
            let term = SelectTerm.Attribute("attribute")
            XCTAssertNotEqual(term, SelectTerm.Attribute("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.ObjectID())
            switch term {
                
            case ._Attribute(let key):
                XCTAssertEqual(key, "attribute")
                
            default:
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatAverageSelectTerms_ConfigureCorrectly() {
        
        do {
            
            let term = SelectTerm.Average("attribute")
            XCTAssertEqual(term, SelectTerm.Average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute", As: "alias"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.Attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.ObjectID())
            switch term {
                
            case ._Aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "average:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "average(attribute)")
                XCTAssertTrue(nativeType == .DecimalAttributeType)
                
            default:
                XCTFail()
            }
        }
        do {
            
            let term = SelectTerm.Average("attribute", As: "alias")
            XCTAssertEqual(term, SelectTerm.Average("attribute", As: "alias"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute", As: "alias2"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.Attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.ObjectID())
            switch term {
                
            case ._Aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "average:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "alias")
                XCTAssertTrue(nativeType == .DecimalAttributeType)
                
            default:
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatCountSelectTerms_ConfigureCorrectly() {
        
        do {
            
            let term = SelectTerm.Count("attribute")
            XCTAssertEqual(term, SelectTerm.Count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute", As: "alias"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.Attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.ObjectID())
            switch term {
                
            case ._Aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "count:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "count(attribute)")
                XCTAssertTrue(nativeType == .Integer64AttributeType)
                
            default:
                XCTFail()
            }
        }
        do {
            
            let term = SelectTerm.Count("attribute", As: "alias")
            XCTAssertEqual(term, SelectTerm.Count("attribute", As: "alias"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute", As: "alias2"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.Attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.ObjectID())
            switch term {
                
            case ._Aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "count:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "alias")
                XCTAssertTrue(nativeType == .Integer64AttributeType)
                
            default:
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatMaximumSelectTerms_ConfigureCorrectly() {
        
        do {
            
            let term = SelectTerm.Maximum("attribute")
            XCTAssertEqual(term, SelectTerm.Maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute", As: "alias"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.Attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.ObjectID())
            switch term {
                
            case ._Aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "max:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "max(attribute)")
                XCTAssertTrue(nativeType == .UndefinedAttributeType)
                
            default:
                XCTFail()
            }
        }
        do {
            
            let term = SelectTerm.Maximum("attribute", As: "alias")
            XCTAssertEqual(term, SelectTerm.Maximum("attribute", As: "alias"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute", As: "alias2"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.Attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.ObjectID())
            switch term {
                
            case ._Aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "max:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "alias")
                XCTAssertTrue(nativeType == .UndefinedAttributeType)
                
            default:
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatMinimumSelectTerms_ConfigureCorrectly() {
        
        do {
            
            let term = SelectTerm.Minimum("attribute")
            XCTAssertEqual(term, SelectTerm.Minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute", As: "alias"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.Attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.ObjectID())
            switch term {
                
            case ._Aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "min:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "min(attribute)")
                XCTAssertTrue(nativeType == .UndefinedAttributeType)
                
            default:
                XCTFail()
            }
        }
        do {
            
            let term = SelectTerm.Minimum("attribute", As: "alias")
            XCTAssertEqual(term, SelectTerm.Minimum("attribute", As: "alias"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute", As: "alias2"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.Attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.ObjectID())
            switch term {
                
            case ._Aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "min:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "alias")
                XCTAssertTrue(nativeType == .UndefinedAttributeType)
                
            default:
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatSumSelectTerms_ConfigureCorrectly() {
        
        do {
            
            let term = SelectTerm.Sum("attribute")
            XCTAssertEqual(term, SelectTerm.Sum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute", As: "alias"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.Attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.ObjectID())
            switch term {
                
            case ._Aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "sum:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "sum(attribute)")
                XCTAssertTrue(nativeType == .DecimalAttributeType)
                
            default:
                XCTFail()
            }
        }
        do {
            
            let term = SelectTerm.Sum("attribute", As: "alias")
            XCTAssertEqual(term, SelectTerm.Sum("attribute", As: "alias"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute", As: "alias2"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute2"))
            XCTAssertNotEqual(term, SelectTerm.Attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.ObjectID())
            switch term {
                
            case ._Aggregate(let function, let keyPath, let alias, let nativeType):
                XCTAssertEqual(function, "sum:")
                XCTAssertEqual(keyPath, "attribute")
                XCTAssertEqual(alias, "alias")
                XCTAssertTrue(nativeType == .DecimalAttributeType)
                
            default:
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatObjectIDSelectTerms_ConfigureCorrectly() {
        
        do {
            
            let term = SelectTerm.ObjectID()
            XCTAssertEqual(term, SelectTerm.ObjectID())
            XCTAssertNotEqual(term, SelectTerm.ObjectID(As: "alias"))
            XCTAssertNotEqual(term, SelectTerm.Attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute"))
            switch term {
                
            case ._Identity(let alias, let nativeType):
                XCTAssertEqual(alias, "objectID")
                XCTAssertTrue(nativeType == .ObjectIDAttributeType)
                
            default:
                XCTFail()
            }
        }
        do {
            
            let term = SelectTerm.ObjectID(As: "alias")
            XCTAssertEqual(term, SelectTerm.ObjectID(As: "alias"))
            XCTAssertNotEqual(term, SelectTerm.ObjectID(As: "alias2"))
            XCTAssertNotEqual(term, SelectTerm.ObjectID())
            XCTAssertNotEqual(term, SelectTerm.Attribute("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Average("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Count("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Maximum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Minimum("attribute"))
            XCTAssertNotEqual(term, SelectTerm.Sum("attribute"))
            switch term {
                
            case ._Identity(let alias, let nativeType):
                XCTAssertEqual(alias, "alias")
                XCTAssertTrue(nativeType == .ObjectIDAttributeType)
                
            default:
                XCTFail()
            }
        }
    }
    
    @objc
    dynamic func test_ThatSelectClauses_ConfigureCorrectly() {
        
        let term1 = SelectTerm.Attribute("attribute1")
        let term2 = SelectTerm.Attribute("attribute2")
        let term3 = SelectTerm.Attribute("attribute3")
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
