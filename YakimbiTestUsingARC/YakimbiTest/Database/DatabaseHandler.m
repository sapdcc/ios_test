//
//  DatabaseHandler.m
//  
//
//  Created by Syed Arsalan Pervez on 8/2/11.
//  Copyright 2011 SAPLogix. All rights reserved.
//

#import "DatabaseHandler.h"

// Toggle to clear db on startup
static const BOOL SQLITE_TESTING = NO;

// Changed to match the user model fileaname
static NSString *SQLITE_FILE = @"YakimbiTest.sqlite";
static NSString *SQLITE_FILE_NAME = @"YakimbiTest";

// Should not be changed
//static NSString *SQLITE_FILE_EXT = @"sqlite";
static NSString *COREDATA_DATAMODEL_EXT = @"momd";


@implementation DatabaseHandler

@synthesize _manageContext;

static DatabaseHandler *sharedObject;

- (id) initWithDBName:(NSString *)name FileName:(NSString *)file
{
    self = [super init];
    if (self)
    {
        NSError *error = nil;
        
//        if (SQLITE_TESTING)
//        {
//            if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:file]])
//            {
//                [[NSFileManager defaultManager] removeItemAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:file] error:&error];
//                
//                if (error)
//                    Log(@"Error: %@", error);
//                
//                error = nil;
//            }
//        }
//        
//        if (![[NSFileManager defaultManager] fileExistsAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:file]])
//        {
//            [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:name ofType:SQLITE_FILE_EXT] toPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:file] error:&error];
//            
//            if (error)
//                Log(@"Error: %@", error);
//            
//            error = nil;
//        }
        
        NSManagedObjectModel *_model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:name ofType:COREDATA_DATAMODEL_EXT]]];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                              [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, 
                                 nil];
        
        _storeCordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        error = nil;
        if ([_storeCordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:file]] options:options error:&error])
        {
            _manageContext = [[NSManagedObjectContext alloc] init];
            [_manageContext setPersistentStoreCoordinator:_storeCordinator];   
        }
        else
        {
            Log(@"Error %@", error);
        }
    }
    
    return self;
}

+ (DatabaseHandler *) sharedHandler
{
    @synchronized(sharedObject)
    {
        if (!sharedObject)
        {
            sharedObject = [[DatabaseHandler alloc] initWithDBName:SQLITE_FILE_NAME FileName:SQLITE_FILE];
        }
    }
    
    return sharedObject;
}

- (id) manageObjectForEntity:(id)entityName
{
    return [self manageObjectForEntity:entityName autorelease:YES];
}

- (id) manageObjectForEntity:(id)entityName autorelease:(BOOL)autorelease
{
    if ([entityName isKindOfClass:[NSString class]])
    {
        Class cls = NSClassFromString(entityName);
        
        id _manageObject = [[cls alloc] initWithEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:[DBHandler _manageContext]] insertIntoManagedObjectContext:[DBHandler _manageContext]];
        
        return _manageObject;
    }
    
    return nil;
}

#pragma mark
#pragma mark Undo & Redo

// Does a rollback
- (BOOL) undoChanges
{
    if ([_manageContext tryLock])
    {
        [_manageContext rollback];
        [_manageContext unlock];
        
        return YES;
    }
    
    return NO;
}

- (BOOL) redoChanges
{
    if ([_manageContext tryLock])
    {
        [_manageContext redo];
        [_manageContext unlock];
        
        return YES;
    }
    
    return NO;
}

#pragma mark
#pragma mark Insert Record

/*
 
 Insert Record
 
 */

- (BOOL) insertObject:(id)manageObject
{
    return [self insertObject:manageObject andSave:NO];
}

- (BOOL) insertObject:(id)manageObject andSave:(BOOL)save
{
    [_manageContext insertObject:manageObject];
    
    if (save)
    {
        return [self saveContext];
    }
    else
        return true;
    
    return false;
}

#pragma mark
#pragma mark Delete Record

/*
 
 Delete Record
 
 */

- (BOOL) deleteObject:(id)manageObject
{
    return [self deleteObject:manageObject andSave:NO];
}

- (BOOL) deleteObject:(id)manageObject andSave:(BOOL)save
{
    [_manageContext deleteObject:manageObject];
    
    if (save)
    {
        return [self saveContext];
    }
    else
        return true;
    
    return false;
}

#pragma mark
#pragma mark Save Record

/*
 
 Save Record
 
 */

- (BOOL) saveContext
{
    NSError *error = nil;
    if (![_manageContext save:&error])
    {
        Log(@"Error: %@", error);
        
        return false;
    }
    
    return true;
}

#pragma mark
#pragma mark Fetch Records

- (id) fetchObjectsOfEntity:(NSString *)entity
{
    return [self fetchObjectsOfEntity:entity usingPredicate:nil withSortDescriptors:nil withExpressionDescription:nil withResultType:NSManagedObjectResultType];
}

- (id) fetchObjectsOfEntity:(NSString *)entity withExpressionDescription:(NSArray *)expDesc
{
    return [self fetchObjectsOfEntity:entity usingPredicate:nil withSortDescriptors:nil withExpressionDescription:expDesc withResultType:NSDictionaryResultType];
}

- (id) fetchObjectsOfEntity:(NSString *)entity usingPredicate:(NSPredicate *)predicate
{
    return [self fetchObjectsOfEntity:entity usingPredicate:predicate withSortDescriptors:nil withExpressionDescription:nil withResultType:NSManagedObjectResultType];
}

- (id) fetchObjectsOfEntity:(NSString *)entity usingPredicate:(NSPredicate *)predicate uniqueResult:(BOOL)unique
{
    return [self fetchObjectsOfEntity:entity usingPredicate:predicate withSortDescriptors:nil withExpressionDescription:nil withResultType:NSManagedObjectResultType uniqueResult:unique];
}

- (id) fetchObjectsOfEntity:(NSString *)entity usingPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDesc withExpressionDescription:(NSArray *)expDesc withResultType:(NSFetchRequestResultType)resultType
{
    return [self fetchObjectsOfEntity:entity usingPredicate:predicate withSortDescriptors:sortDesc withExpressionDescription:expDesc withResultType:resultType uniqueResult:NO];
}

- (id) fetchObjectsOfEntity:(NSString *)entity usingPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDesc withExpressionDescription:(NSArray *)expDesc withResultType:(NSFetchRequestResultType)resultType uniqueResult:(BOOL)unique
{
    NSFetchRequest *_request = nil;
    NSArray *objects = nil;
    NSError *error = nil;
    
    @try 
    {
        _request = [[NSFetchRequest alloc] init];
        [_request setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:_manageContext]];
        
        if (predicate)
            [_request setPredicate:predicate]; // Predicate
        
        if (sortDesc)
            [_request setSortDescriptors:sortDesc]; // Sort Descriptors
        
        if (expDesc)
            [_request setPropertiesToFetch:expDesc]; // Expression Descriptions (for using aggregate functions in CoreData)
        
        [_request setResultType:resultType];
        
        if (unique)
            [_request setReturnsDistinctResults:unique];
        
        objects = [_manageContext executeFetchRequest:_request error:&error];
    }
    @catch(NSException *ex)
    {
        Log(@"Fetch Exception: %@", ex);
    }
    @finally 
    {
        if (!error)
        {
            return objects;
        }
        else
        {
            Log(@"Fetch Error: %@", error);
        }
    }
    
    // show fetch error
    
    return nil;
}

- (NSEntityDescription *) entityDescriptionForName:(NSString *)name
{
    return [NSEntityDescription entityForName:name inManagedObjectContext:_manageContext];
}

#pragma mark
#pragma mark Memory Management

+ (void)deleteSQLiteFile
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:SQLITE_FILE];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

@end
