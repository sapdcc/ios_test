//
//  Folder.h
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/18/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File, User;

@interface Folder : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * fid;
@property (nonatomic, retain) NSSet *files;
@property (nonatomic, retain) User *user;
@end

@interface Folder (CoreDataGeneratedAccessors)

- (void)addFilesObject:(File *)value;
- (void)removeFilesObject:(File *)value;
- (void)addFiles:(NSSet *)values;
- (void)removeFiles:(NSSet *)values;

@end
