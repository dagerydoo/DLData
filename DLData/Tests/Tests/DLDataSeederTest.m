//
//  DLDataSeederTest.m
//  DLData
//
//  Created by Andrew Hannon on 11/15/10.
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

@interface DLDataSeederTest : GHTestCase {
  CorporateStore *corporateStore;
}
@end

@implementation DLDataSeederTest

- (void)setUp {
  [corporateStore release];
  corporateStore = [[CorporateStore alloc] init];
}

- (void)tearDown {
  [corporateStore rollback];
  [corporateStore release];
  corporateStore = nil;
}

- (void)testDataSeeding {
  NSURL *seedURL = [[NSBundle mainBundle] URLForResource:@"Main.seed" withExtension:@"json"];
  [corporateStore seedDataStore:seedURL];
  
  NSMutableSet *allIDs = [NSMutableSet set];

  NSArray *employees = [corporateStore allEmployees];
  NSArray *companies = [corporateStore allCompanies];
  NSMutableDictionary *employeesByCompany = [NSMutableDictionary dictionary];
  for (Company *company in companies) {
    [allIDs addObject:company.companyID];
    [employeesByCompany setObject:[corporateStore allEmployeesForCompanyNamed:company.companyName]
                           forKey:company.companyName];
  }
  for (Employee *employee in employees) {
    [allIDs addObject:employee.employeeID];
  }
  NSUInteger expectedCompanyCount = 2;
  NSUInteger expectedEmployeeCount = 6;
  NSUInteger expectedDiabolicalEmployeedCount = 1;
  
  // Verify the seeding
  GHAssertEquals([employees count], expectedEmployeeCount, @"Unexpected number of employees!");
  GHAssertEquals([companies count], expectedCompanyCount, @"Unexpected number of companies!");
  GHAssertEquals([employeesByCompany count], expectedCompanyCount, @"Unexpected number of companies!");
  GHAssertEquals([[employeesByCompany objectForKey:@"Diabolical Labs, LLC"] count],
                 expectedDiabolicalEmployeedCount,
                 @"Unexpected number of Diabolical employees");
  GHAssertEquals([[employeesByCompany objectForKey:@"Foo Inc."] count],
                 expectedEmployeeCount - expectedDiabolicalEmployeedCount,
                 @"Unexpected number of Foo Inc. employees");

  for (NSString *companyName in employeesByCompany) {
    Company *company = [corporateStore companyNamed:companyName];
    GHAssertEquals([[employeesByCompany objectForKey:companyName] count],
                   [company.employees count],
                   @"Company employee count is wrong!");
    for (Employee *e in company.employees) {
      GHAssertEqualObjects(company, e.company, @"Employee company is wrong!");
    }
  }
  
  GHAssertEquals([allIDs count], expectedCompanyCount+expectedEmployeeCount,
                 @"Not all IDs are unique!");
}

@end