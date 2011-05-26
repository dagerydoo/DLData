//
//  DLUniqueID.h
//  DiaPad
//
//  Created by Andrew Hannon on 9/14/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DLUniqueID : NSManagedObject 

@property (nonatomic, retain) NSNumber *currentID;

@end
