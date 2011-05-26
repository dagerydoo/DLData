//
//  DLImageValueTransformer.m
//  DataStoreLib
//
//  Created by Andrew Hannon on 12/13/10.
//  Copyright 2010 Diabolical Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLImageValueTransformer.h"


@implementation DLImageValueTransformer

+ (BOOL)allowsReverseTransformation { 
  return YES;
}

+ (Class)transformedValueClass { 
  return [NSData class];
}

- (id)transformedValue:(id)value {
  return (value == nil) ? nil : UIImagePNGRepresentation((UIImage*)value);
}

- (id)reverseTransformedValue:(id)value {
  return (value == nil) ? nil : [UIImage imageWithData:(NSData*)value];
}

@end
