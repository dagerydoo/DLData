//
//  DLUniqueIDGeneratorTest.m
//  DLData
//
//  Created by Andrew Hannon on 9/15/10.
//  Copyright (C) 2011 by Andrew Hannon
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <GHUnitIOS/GHUnitIOS.h>
#import <DLData/DLData.h>

@interface DLUniqueIDGeneratorTest : GHTestCase
@end

@implementation DLUniqueIDGeneratorTest

- (void)setUp {
}

- (void)tearDown {
  [DLDataStore rollbackAllStores];
}

- (void)testBaseUniqueID {
  NSUInteger uID = [DLUniqueIDGenerator generateUniqueID];
  GHAssertGreaterThan(uID, (NSUInteger)0, @"Unique ID should be greater than 0!");
}

- (void)testUniqueIDWithCommits {
  NSUInteger firstID = [DLUniqueIDGenerator generateUniqueID];
  GHAssertGreaterThan(firstID, (NSUInteger)0, @"Unique ID should be greater than 0!");
  NSUInteger secondID = [DLUniqueIDGenerator generateUniqueID];
  // I write the test like this to allow for non-monotonicity: 
  GHAssertGreaterThan(secondID, (NSUInteger)0, @"Unique ID should be greater than 0!");
  GHAssertNotEquals(firstID, secondID, @"Unique ID should not be equal!");
  [DLDataStore commitAllStores];
  NSUInteger thirdID = [DLUniqueIDGenerator generateUniqueID];
  GHAssertGreaterThan(thirdID, (NSUInteger)0, @"Unique ID should be greater than 0!");
  GHAssertNotEquals(firstID, thirdID, @"Unique IDs should not be equal!");
  GHAssertNotEquals(firstID, secondID, @"Unique IDs should not be equal!");
}

- (void)testManyUniqueIDs {
  NSMutableSet *observedUniqueIDs = [NSMutableSet set];
  NSUInteger generateCount = 10000;
  for (NSUInteger i=0; i<generateCount; i++) {
    NSUInteger uID = [DLUniqueIDGenerator generateUniqueID];
    NSNumber *nID = [NSNumber numberWithUnsignedInteger:uID];
    [observedUniqueIDs addObject:nID];
  }
  GHAssertEquals(generateCount, [observedUniqueIDs count], @"Duplicate IDs found!");
}

@end
