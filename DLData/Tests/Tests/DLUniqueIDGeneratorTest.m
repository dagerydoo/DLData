//
//  DLUniqueIDGeneratorTest.m
//  DiaPad
//
//  Created by Andrew Hannon on 9/15/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
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
