//
//  Parser.m
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/16/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import "Parser.h"

@implementation Parser

#pragma mark - Parse Data

- (void)parseData:(NSData *)data inBackground:(BOOL)inBackground
{
    if (inBackground)
        [self performSelectorInBackground:@selector(parseData:) withObject:data];
    else
        [self parseData:data];
}

- (void)parseData:(NSData *)data
{
    @autoreleasepool
    {
        if (data == nil)
        {
            if (_delegate && [_delegate conformsToProtocol:@protocol(ParserResponseDelegate)])
            {
                [_delegate parsingFailed:self withError:[NSError errorWithDomain:@"com.Yakimbi" code:1000 userInfo:@{NSLocalizedDescriptionKey:@"Data is nil."}]];
            }
            return;
        }
        
        [data retain];
        
        NSError *error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if (!error)
        {
            User *_user = nil;
        
            NSArray *_users = [DBHandler fetchObjectsOfEntity:USER_TABLE];
            if ([_users count] > 0)
                _user = [_users objectAtIndex:0];
            else
                _user = [DBHandler manageObjectForEntity:USER_TABLE];
            
            [_user setLastUpdated:[NSDate date]];
            [_user setTotalSpace:[dictionary valueForKey:@"totalSpace"]];
            [_user setLastRevId:[dictionary valueForKey:@"last_rev_id"]];
            [_user setUsedSpace:[dictionary valueForKey:@"usedSpace"]];
            [_user setAvailableSpace:[dictionary valueForKey:@"availableSpace"]];
            [_user setMode:[dictionary valueForKey:@"mode"]];
            [_user setPendingRequests:[dictionary valueForKey:@"pendingRequests"]];
            [_user setRevId:[dictionary valueForKey:@"rev_id"]];
            
            // Check rev_id, if same then return
            if ([_user.revId isEqualToNumber:[dictionary valueForKey:@"rev_id"]])
            {
                // My Files
                [self addOrUpdateFoldersFromDictionary:[dictionary valueForKey:@"my_files"] forUser:_user];
                // SharedFiles
                [self addOrUpdateFoldersFromDictionary:[dictionary valueForKey:@"shared_files"] forUser:_user];
            }
                
            [DBHandler performSelectorOnMainThread:@selector(saveContext) withObject:nil waitUntilDone:NO];
        }
        else
        {
            Log(@"Parsing Error: %@", error);
            
            if (_delegate && [_delegate conformsToProtocol:@protocol(ParserResponseDelegate)])
            {
                [_delegate parsingFailed:self withError:[NSError errorWithDomain:@"com.Yakimbi" code:1001 userInfo:@{NSLocalizedDescriptionKey:@"Failed to parse the given data."}]];
            }
            return;
        }
        
        if (_delegate && [_delegate conformsToProtocol:@protocol(ParserResponseDelegate)])
        {
            [_delegate parsingFinished:self];
        }
        
        [data release];
    }
}

#pragma mark - Support Methods

- (void)addOrUpdateFoldersFromDictionary:(NSDictionary *)myfiles forUser:(User *)_user
{
    Folder *_folder = nil;
    
    BOOL found = NO;
    
    NSSet *folderSet = [[_user folders] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"self.fid == %@", [myfiles valueForKey:@"id"]]];
    
    // Check if user already has folders and were we able to find the folder we are about to add/update
    if ([[_user folders] count] > 0 && [folderSet count] > 0)
    {
        _folder = [[folderSet allObjects] objectAtIndex:0];
        found = YES;
    }
    else // if not found then add the folder
    {
        _folder = [DBHandler manageObjectForEntity:FOLDER_TABLE];
        [_folder setFid:[myfiles valueForKey:@"id"]];
    }
    
    [_folder setName:[myfiles valueForKey:@"name"]];
    
    // Hide all before adding/updating
    [[_folder files] setValue:[NSNumber numberWithBool:YES] forKey:@"hidden"];
    
    for (NSDictionary *fileDictionary in [myfiles valueForKey:@"content"])
    {
        File *_file = nil;
        
        // If folder already exists then check if file already exists or not
        if (found)
        {
            NSSet *fileSet = [[_folder files] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"self.itemId == %@", [fileDictionary valueForKey:@"item_id"]]];
            if ([fileSet count] > 0)
                _file = [[fileSet allObjects] objectAtIndex:0];
        }
        
        // If file not found then create
        if (!_file)
        {
            _file = [DBHandler manageObjectForEntity:FILE_TABLE];
            [_file setFolder:_folder];
            [_folder addFilesObject:_file];
        }
        
        // Replace all the fields with respective values received from server
        [self assignFileObject:_file valuesFromDictionary:fileDictionary];

        // Unhide the ones that were received from the server
        [_file setHidden:[NSNumber numberWithBool:NO]];
    }
    
    // If folder not found then add it
    if (!found)
    {
        [_folder setUser:_user];
        [_user addFoldersObject:_folder];
    }
}

- (void)assignFileObject:(File *)file valuesFromDictionary:(NSDictionary *)dictionary
{
    [file setStatus:[dictionary valueForKey:@"status"]];
    [file setIsShared:[dictionary valueForKey:@"is_shared"]];
    [file setShareId:[dictionary valueForKey:@"share_id"]];
    [file setUserId:[dictionary valueForKey:@"user_id"]];
    [file setName:[dictionary valueForKey:@"name"]];
    [file setSharedBy:[dictionary valueForKey:@"shared_by"]];
    [file setCreatedDate:[dictionary valueForKey:@"created_date"]];
    [file setSharedDate:[dictionary valueForKey:@"shared_date"]];
   
    // Note: in json response my_files->content->"share_level" is of type string and in shared_files->content->"share_level" if of type number (issue or intentional?)
    // stored in local DB as number
    if ([[dictionary valueForKey:@"share_level"] isKindOfClass:[NSString class]])
        [file setShareLevel:[NSNumber numberWithInt:[[dictionary valueForKey:@"share_level"] intValue]]];
    else
        [file setShareLevel:[dictionary valueForKey:@"share_level"]];
    
    if ([[dictionary allKeys] containsObject:@"parent_id"])
        [file setParentId:[dictionary valueForKey:@"parent_id"]];
    
    [file setLastUpdatedDate:[dictionary valueForKey:@"last_updated_date"]];
    [file setLastUpdatedBy:[dictionary valueForKey:@"last_updated_by"]];
    [file setLink:[dictionary valueForKey:@"link"]];
    [file setTransType:[dictionary valueForKey:@"trans_type"]];
    [file setItemId:[dictionary valueForKey:@"item_id"]];
    [file setPath:[dictionary valueForKey:@"path"]];
    [file setPathById:[dictionary valueForKey:@"path_by_id"]];
    [file setType:[dictionary valueForKey:@"type"]];
    [file setMimeType:[dictionary valueForKey:@"mime_type"]];
    [file setSize:[dictionary valueForKey:@"size"]];
}

#pragma mark - Memory Management

- (void)dealloc
{
    _delegate = nil;
    
    [super dealloc];
}

@end
