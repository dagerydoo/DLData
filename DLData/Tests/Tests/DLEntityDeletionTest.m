//
//  DLEntityDeletionTest.m
//  DLData
//
//  Created by Andrew Hannon on 4/19/11.
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
#import "Employee.h"
#import "Company.h"
#import "CorporateStore.h"

@interface DLEntityDeletionTest : GHTestCase {
  CorporateStore *corporateStore;
}
@end

@implementation DLEntityDeletionTest

- (void)setUp {
  [corporateStore release];
  corporateStore = [[CorporateStore alloc] init];
  // Seed the data store to ensure that we have something to test against other than "empty"
  NSURL *seedURL = [[NSBundle mainBundle] URLForResource:@"Main.seed" withExtension:@"json"];
  [corporateStore seedDataStore:seedURL];
}

- (void)tearDown {
  [corporateStore rollback];
  [corporateStore release];
  corporateStore = nil;
}

- (void)testEntityDeletion {
  NSArray *companies = [corporateStore fetchAll:@"Company" matching:nil sortedBy:nil];
  NSUInteger expectedCompanyCount = 2;
  GHAssertEquals([companies count], expectedCompanyCount, 
                 @"Unexpected number of companies!");
  [corporateStore deleteEntity:[companies lastObject]];
  companies = [corporateStore fetchAll:@"Company" matching:nil sortedBy:nil];
  expectedCompanyCount = 1;
  GHAssertEquals([companies count], expectedCompanyCount, 
                 @"Unexpected number of companies!");
}

- (void)testCascadingDeletion {
  NSArray *allCompanies = [corporateStore fetchAll:@"Company" matching:nil sortedBy:nil];
  NSArray *allEmployees = [corporateStore fetchAll:@"Employee" matching:nil sortedBy:nil];
  NSUInteger employeeCount = [allEmployees count];
  Company *companyToDelete = [allCompanies lastObject];
  NSUInteger companyToDeleteEmployeeCount = [companyToDelete.employees count];
  [corporateStore deleteEntity:companyToDelete];
  allEmployees = [corporateStore fetchAll:@"Employee" matching:nil sortedBy:nil];
  GHAssertEquals([allEmployees count], employeeCount - companyToDeleteEmployeeCount,
                 @"Unexpected number of employees deleted!");
}

@end
