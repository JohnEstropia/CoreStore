//
//  VersionLockTests.swift
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


//MARK: - VersionLockTests

final class VersionLockTests: XCTestCase {

    @objc
    dynamic func test_ThatVersionLocksProduceCorrectHashes() {
        
        let versionLock: VersionLock = [
            "Animal": [0x1b59d511019695cf, 0xdeb97e86c5eff179, 0x1cfd80745646cb3, 0x4ff99416175b5b9a],
            "Dog": [0xe3f0afeb109b283a, 0x29998d292938eb61, 0x6aab788333cfc2a3, 0x492ff1d295910ea7],
            "Person": [0x2831cf046084d96d, 0xbe19b13ace54641, 0x635a082728b0f6f0, 0x3d4ef2dd4b74a87c]
        ]
        XCTAssertEqual(
            versionLock.description,
            """
            [
                "Animal": [0x1b59d511019695cf, 0xdeb97e86c5eff179, 0x1cfd80745646cb3, 0x4ff99416175b5b9a],
                "Dog": [0xe3f0afeb109b283a, 0x29998d292938eb61, 0x6aab788333cfc2a3, 0x492ff1d295910ea7],
                "Person": [0x2831cf046084d96d, 0xbe19b13ace54641, 0x635a082728b0f6f0, 0x3d4ef2dd4b74a87c]
            ]
            """
        )
    }
}
