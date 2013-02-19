//
//  NSDictionary+Addition.h
//  
//
//  Created by Syed Arsalan Pervez on 3/14/12.
//  Copyright (c) 2012 SAPLogix. All rights reserved.
//

@interface NSDictionary (ADDITION)

- (BOOL)containsKey:(NSString *)key;
- (BOOL)containsKeys:(NSArray *)keys;
- (id)valueForKey:(NSString *)key;

@end
