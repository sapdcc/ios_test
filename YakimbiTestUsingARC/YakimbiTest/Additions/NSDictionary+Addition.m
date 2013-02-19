//
//  NSDictionary+Addition.m
//  
//
//  Created by Syed Arsalan Pervez on 3/14/12.
//  Copyright (c) 2012 SAPLogix. All rights reserved.
//

#import "NSDictionary+Addition.h"

@implementation NSDictionary (ADDITION)

- (BOOL)containsKey:(NSString *)key
{
    return [[self allKeys] containsObject:key];
}

- (BOOL)containsKeys:(NSArray *)keys
{
    for (NSString *key in keys)
    {
        if (![self containsKey:key])
            return NO;
    }
    
    return YES;
}

- (id)valueForKey:(NSString *)key
{
    int index = [[self allKeys] indexOfObject:key];
    if (index != NSNotFound)
    {
        id val = [[self allValues] objectAtIndex:index];
    
        if (![val isKindOfClass:[NSNull class]])
            return val;
    }
    
    return nil;
}

@end
