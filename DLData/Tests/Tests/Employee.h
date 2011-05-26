//
//  Employee.h
//  DataStoreLib
//
//  Created by Andrew Hannon on 11/15/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Company;

@interface Employee : NSManagedObject
@property (nonatomic, retain) NSString *employeeName;
@property (nonatomic, retain) NSNumber *employeeID;
@property (nonatomic, retain) NSNumber *employeeSalary;
@property (nonatomic, retain) Company *company;
@property (nonatomic, retain) UIImage *employeePhoto;
@end
