//
//  DLUniqueIDGenerator.h
//  DataStore
//
//  Created by Andrew Hannon on 9/14/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DLUniqueID;

@interface DLUniqueIDGenerator : NSObject  

+ (unsigned long)generateUniqueID;
+ (NSNumber*)generateUniqueNumber;

@end
