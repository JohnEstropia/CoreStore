//
//  BridgingTests.m
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

#import "BridgingTests.h"
#import <CoreStore/CoreStore-Swift.h>

@import CoreData;


@implementation BridgingTests

- (void)testFlags {
    
    XCTAssertEqual([CSLocalStorageOptions none], 0);
    XCTAssertEqual([CSLocalStorageOptions recreateStoreOnModelMismatch], 1);
    XCTAssertEqual([CSLocalStorageOptions preventProgressiveMigration], 2);
    XCTAssertEqual([CSLocalStorageOptions allowSynchronousLightweightMigration], 4);
}

- (void)testDataStack {
    
    CSDataStack *dataStack = [[CSDataStack alloc]
                              initWithModelName:@"Model"
                              bundle:[NSBundle bundleForClass:[self class]]
                              versionChain:nil];
    XCTAssertNotNil(dataStack);
    
    [CSCoreStore setDefaultStack:dataStack];
    XCTAssertTrue([dataStack isEqual:[CSCoreStore defaultStack]]);
    
    NSError *memoryError;
    CSInMemoryStore *memoryStorage = [CSCoreStore
                                      addInMemoryStorageAndWait:[CSInMemoryStore new]
                                      error:&memoryError];
    XCTAssertNotNil(memoryStorage);
    XCTAssertEqualObjects([[memoryStorage class] storeType], [CSInMemoryStore storeType]);
    XCTAssertEqualObjects([[memoryStorage class] storeType], NSInMemoryStoreType);
    XCTAssertNil(memoryStorage.configuration);
    XCTAssertNil(memoryStorage.storeOptions);
    XCTAssertNil(memoryError);
    
    NSError *sqliteError;
    CSSQLiteStore *sqliteStorage = [CSCoreStore
                                    addSQLiteStorageAndWait:[CSSQLiteStore new]
                                    error:&sqliteError];
    XCTAssertNotNil(sqliteStorage);
    XCTAssertEqualObjects([[sqliteStorage class] storeType], [CSSQLiteStore storeType]);
    XCTAssertEqualObjects([[sqliteStorage class] storeType], NSSQLiteStoreType);
    XCTAssertNil(sqliteStorage.configuration);
    XCTAssertEqualObjects(sqliteStorage.storeOptions, @{ NSSQLitePragmasOption: @{ @"journal_mode": @"WAL" } });
    XCTAssertNil(sqliteError);
}

@end
