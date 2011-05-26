//
//  DLValueTransformerTest.m
//  DataStoreLib
//
//  Created by Andrew Hannon on 12/13/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
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
