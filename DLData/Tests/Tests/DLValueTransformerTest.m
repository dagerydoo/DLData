//
//  DLValueTransformerTest.m
//  DLData
//
//  Created by Andrew Hannon on 12/13/10.
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
#import "CorporateStore.h"


@interface DLValueTransformerTest : GHTestCase {
  CorporateStore *corporateStore;
}

@end


@implementation DLValueTransformerTest

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

- (void)testImageValueTransformer {
  Employee *someEmployee = [[corporateStore allEmployees] lastObject];
  GHAssertNil(someEmployee.employeePhoto, @"Photo is not nil!");
  UIImage *employeeImage = [UIImage imageNamed:@"EmployeePhoto"];
  someEmployee.employeePhoto = employeeImage;
  NSData *originalImageData = UIImagePNGRepresentation(employeeImage);
  GHAssertTrue([originalImageData length] > 0, @"Image data is empty!");
  [corporateStore commit];
  Employee *thatSameEmployee = [corporateStore employeeNamed:someEmployee.employeeName 
                                                  forCompany:someEmployee.company];
  GHAssertEqualStrings(someEmployee.employeeName, thatSameEmployee.employeeName, @"Name mismatch!");
  GHAssertEqualObjects(someEmployee.employeeID, thatSameEmployee.employeeID, @"ID mismatch!");
  GHAssertNotNil(thatSameEmployee.employeePhoto, @"Photo is nil!");
  NSData *committedImageData = UIImagePNGRepresentation(thatSameEmployee.employeePhoto);
  GHAssertEquals([originalImageData length], [committedImageData length], @"Not the same image data!");
  GHAssertEqualObjects(originalImageData, committedImageData, @"Not the same image data!");
}

@end
