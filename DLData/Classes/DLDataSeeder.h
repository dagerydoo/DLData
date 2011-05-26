//
//  DLDataSeeder.h
//  DataStoreLib
//
//  Created by Andrew Hannon on 11/12/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLDataStore.h"

extern NSString *const DLDataSeederException;

@interface DLDataSeeder : NSObject
+ (NSSet*)seedDataStore:(DLDataStore*)dataStore
            fromSeedURL:(NSURL*)seedURL;
@end
