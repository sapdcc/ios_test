//
//  File.h
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/18/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Folder;

@interface File : NSManagedObject

@property (nonatomic, retain) NSString * isShared;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * shareId;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sharedBy;
@property (nonatomic, retain) NSString * createdDate;
@property (nonatomic, retain) NSString * sharedDate;
@property (nonatomic, retain) NSNumber * shareLevel;
@property (nonatomic, retain) NSNumber * parentId;
@property (nonatomic, retain) NSString * lastUpdatedDate;
@property (nonatomic, retain) NSString * lastUpdatedBy;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * transType;
@property (nonatomic, retain) NSNumber * itemId;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * pathById;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * mimeType;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSNumber * hidden;
@property (nonatomic, retain) Folder *folder;

@end
