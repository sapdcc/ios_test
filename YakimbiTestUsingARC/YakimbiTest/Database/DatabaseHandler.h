//
//  DatabaseHandler.h
//  
//
//  Created by Syed Arsalan Pervez on 8/2/11.
//  Copyright 2011 SAPLogix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define DBHandler [DatabaseHandler sharedHandler]

@interface DatabaseHandler : NSObject 
{    
    __strong NSManagedObjectContext *_manageContext;
    __strong NSPersistentStoreCoordinator *_storeCordinator;
    __strong NSPersistentStore *_persistentStore;
}

@property (readonly, nonatomic) NSManagedObjectContext *_manageContext;

// Insert Records
- (BOOL) insertObject:(id)manageObject;
- (BOOL) insertObject:(id)manageObject andSave:(BOOL)save;

// Delete Object
- (BOOL) deleteObject:(id)manageObject;
- (BOOL) deleteObject:(id)manageObject andSave:(BOOL)save;

// Fetch Records
- (id) fetchObjectsOfEntity:(NSString *)entity;
- (id) fetchObjectsOfEntity:(NSString *)entity withExpressionDescription:(NSArray *)expDesc;
- (id) fetchObjectsOfEntity:(NSString *)entity usingPredicate:(NSPredicate *)predicate;
- (id) fetchObjectsOfEntity:(NSString *)entity usingPredicate:(NSPredicate *)predicate uniqueResult:(BOOL)unique;
- (id) fetchObjectsOfEntity:(NSString *)entity usingPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDesc withExpressionDescription:(NSArray *)expDesc withResultType:(NSFetchRequestResultType)resultType;
- (id) fetchObjectsOfEntity:(NSString *)entity usingPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDesc withExpressionDescription:(NSArray *)expDesc withResultType:(NSFetchRequestResultType)resultType uniqueResult:(BOOL)unique;

// Get Entity Description
- (NSEntityDescription *) entityDescriptionForName:(NSString *)name;

// Save Context
- (BOOL) saveContext;

// Singleton Accessor
+ (DatabaseHandler *) sharedHandler;
+ (void)deleteSQLiteFile;

// ManageObject for Entity
- (id) manageObjectForEntity:(id)entityName;
- (id) manageObjectForEntity:(id)entityName autorelease:(BOOL)autorelease;

// Undo & Redo
- (BOOL) undoChanges;
- (BOOL) redoChanges;

@end
