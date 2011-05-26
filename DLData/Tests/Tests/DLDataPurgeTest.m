//
//  DLDataPurgeTest.m
//  DLData
//
//  Created by Andrew Hannon on 12/10/10.
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
