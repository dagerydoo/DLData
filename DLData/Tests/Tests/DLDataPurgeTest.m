//
//  DLDataPurgeTest.m
//  DataStoreLib
//
//  Created by Andrew Hannon on 12/10/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
//

#import <GHUnitIOS/GHUnitIOS.h>
#import <DLData/DLData.h>
#import "Company.h"
#import "Employee.h"
#import "CorporateStore.h"

@interface DLDataPurgeTest : GHTestCase {
  CorporateStore *corporateStore;
}

@end

@implementation DLDataPurgeTest

- (void)setUp {
  [corporateStore release];
  corporateStore = [[CorporateStore alloc] init];
}

- (void)testDataPurge {
  // This functionality is vetted elsewhere:
  NSURL *seedURL = [[NSBundle mainBundle] URLForResource:@"Main.seed" withExtension:@"json"];
  [corporateStore seedDataStore:seedURL];
  
  GHAssertGreaterThan([[corporateStore allCompanies] count], (NSUInteger)0, @"No companies found, can't test purge!");
  GHAssertGreaterThan([[corporateStore allEmployees] count], (NSUInteger)0, @"No employees found, can't test purge!");
  [corporateStore purgeDataStore];
  GHAssertEquals([[corporateStore allCompanies] count], (NSUInteger)0, @"There should be no companies after purge!");
  GHAssertEquals([[corporateStore allEmployees] count], (NSUInteger)0, @"There should be no employees after purge!");
}

- (void)testDataPurgeAndReSeed {
  [self testDataPurge];
  GHAssertEquals([[corporateStore allCompanies] count], (NSUInteger)0, @"There should be no companies after purge!");
  GHAssertEquals([[corporateStore allEmployees] count], (NSUInteger)0, @"There should be no employees after purge!");
  NSURL *seedURL = [[NSBundle mainBundle] URLForResource:@"Main.seed" withExtension:@"json"];
  [corporateStore seedDataStore:seedURL];
  GHAssertGreaterThan([[corporateStore allCompanies] count], (NSUInteger)0, @"No companies found after reseed!");
  GHAssertGreaterThan([[corporateStore allEmployees] count], (NSUInteger)0, @"No employees found after reseed!");
}

@end
