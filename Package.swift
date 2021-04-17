// swift-tools-version:5.3
//
//  Package.swift
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

import PackageDescription

let package = Package(
    name: "CoreStore",
    platforms: [
           .macOS(.v10_13), .iOS(.v11), .tvOS(.v11), .watchOS(.v4)
    ],
    products: [
        .library(name: "CoreStore", type: .static, targets: ["CoreStore"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CoreStore",
            dependencies: [],
            path: "Sources",
            exclude: ["CoreStoreBridge.h", "CoreStoreBridge.m", "ObjectPublisher+Rective.swift"]
        ),
        .testTarget(
            name: "CoreStoreTests",
            dependencies: ["CoreStore"],
            path: "CoreStoreTests",
            exclude: ["BridgingTests.h", "BridgingTests.m"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
