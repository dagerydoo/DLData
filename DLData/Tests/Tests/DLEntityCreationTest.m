//
//  DLEntityCreationTest.m
//  DLData
//
//  Created by Andrew Hannon on 3/25/11.
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

@interface DLEntityCreationTest : GHTestCase {
  CorporateStore *corporateStore;
}
@end

@implementation DLEntityCreationTest

- (void)setUp {
  [corporateStore release];
  corporateStore = [[CorporateStore alloc] init];
}

- (void)tearDown {
  [corporateStore rollback];
  [corporateStore release];
  corporateStore = nil;
}

- (void)testEntityCreation {
  Employee *employee = [corporateStore entityWithName:@"Employee"];
  GHAssertNotNil(employee, @"Employee is nil!");
}

@end
