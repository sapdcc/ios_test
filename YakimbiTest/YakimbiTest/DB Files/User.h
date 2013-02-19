//
//  User.h
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/18/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Folder;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * totalSpace;
@property (nonatomic, retain) NSNumber * lastRevId;
@property (nonatomic, retain) NSNumber * usedSpace;
@property (nonatomic, retain) NSNumber * availableSpace;
@property (nonatomic, retain) NSString * mode;
@property (nonatomic, retain) NSNumber * pendingRequests;
@property (nonatomic, retain) NSNumber * revId;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSSet *folders;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addFoldersObject:(Folder *)value;
- (void)removeFoldersObject:(Folder *)value;
- (void)addFolders:(NSSet *)values;
- (void)removeFolders:(NSSet *)values;

@end
