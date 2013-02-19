//
//  MainViewController.m
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/16/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import "MainViewController.h"
#import "FolderViewCell.h"

static NSString *identifier = @"FolderCell";

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (DEVICE_iPAD)
    {
        self = [super initWithNibName:[NSStringFromClass([self class]) stringByAppendingString:@"_iPad"] bundle:nibBundleOrNil];
    }
    else
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
    }
    return self;
}

#pragma mark - UIViewController Overridden Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _fetchOperation = [[HTTPRequestOperation requestWithURL:SAMPLE_JSON_URL andDelegate:self] retain];
    [_fetchOperation registerParserClass:[Parser class]];
    [self fetchData];
    
    if (DEVICE_iPAD)
    {
        [_tableView registerNib:[UINib nibWithNibName:@"FolderViewCell_iPad" bundle:nil] forCellReuseIdentifier:identifier];
    }
    else
    {
        [_tableView registerNib:[UINib nibWithNibName:@"FolderViewCell" bundle:nil] forCellReuseIdentifier:identifier];
    }
    
    [_statusLabel setText:@""];

    [[self navigationItem] setRightBarButtonItem:_infoBtn];
    
    [self refreshData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setFrameBaseOnOrientation];
}

#pragma mark - Refresh Data

- (void)refreshData
{
    NSArray *_users = [DBHandler fetchObjectsOfEntity:USER_TABLE];
    if ([_users count] > 0)
    {
        SAFE_RELEASE(_user);
        _user = [[_users objectAtIndex:0] retain];
        
        if (_user)
        {
            NSSortDescriptor *asc = [NSSortDescriptor sortDescriptorWithKey:@"fid" ascending:YES];
            SAFE_RELEASE(_items);
            _items = [[[[_user folders] allObjects] sortedArrayUsingDescriptors:@[asc]] retain];
        }
        
        [_tableView reloadData];
    }
}

#pragma mark - Fetch Data

- (void)fetchData
{
    @try
    {
        [_fetchOperation startAsynchronously];
    }
    @catch (NSException *exception)
    {
        Log(@"Exception %@", exception);
    }
    @finally
    {
    }
}

#pragma mark - HTTPRequestOperationDelegate Methods

- (void)HTTPOperationStarted:(HTTPRequestOperation *)operation
{
    Log(@"Started!");
}

- (void)HTTPOperationFinished:(HTTPRequestOperation *)operation
{
    Log(@"Finished!");

    [self refreshData];
    
    [_statusLabel setText:[NSString stringWithFormat:@"Last Updated: %@", [_user lastUpdated]]];
    
    [self performSelector:@selector(fetchData) withObject:nil afterDelay:REFRESH_INTERVAL];
}

- (void)HTTPOperationFailed:(HTTPRequestOperation *)operation withError:(NSError *)error
{
    Log(@"Failed!");
    
    [_statusLabel setText:[NSString stringWithFormat:@"Last Updated: %@", [_user lastUpdated]]];

    [self performSelector:@selector(fetchData) withObject:nil afterDelay:REFRESH_INTERVAL];
}

#pragma mark - UITableView Delegate & Datasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_user.folders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FolderViewCell *cell = (FolderViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    Folder *_folder = [_items objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [_folder name];
    
    int folders = [[[_folder files] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"self.type == '0'"]] count];
    int files = [[[_folder files] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"self.type == '1'"]] count];
    
    cell.pathLabel.text = [NSString stringWithFormat:@"Files: %i   Folders: %i", files, folders];
    
    _folder = nil;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!_listViewController)
        _listViewController = [ListViewController new];
    
    Folder *folder = [_items objectAtIndex:indexPath.row];
    [_listViewController setFolder:folder];
    folder = nil;
    [[self navigationController] pushViewController:_listViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

#pragma mark - View Rotation Handler

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setFrameBaseOnOrientation];
}

- (void)setFrameBaseOnOrientation
{
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        if (DEVICE_iPAD)
        {
            [_statusLabel setFrame:CGRectMake(0, _tableView.frame.size.height, 1024, 30)];
        }
        else
        {
            [_statusLabel setFrame:CGRectMake(0, _tableView.frame.size.height, 480, 30)];
        }
    }
    else
    {
        if (DEVICE_iPAD)
        {
            [_statusLabel setFrame:CGRectMake(0, _tableView.frame.size.height, 768, 30)];
        }
        else
        {
            [_statusLabel setFrame:CGRectMake(0, _tableView.frame.size.height, 320, 30)];
        }
    }
}

#pragma mark - Event Handlers

- (IBAction)showInfo:(id)sender
{
    InfoViewController *_infoViewController = [[InfoViewController new] autorelease];
    [_infoViewController setUser:_user];
    
    if (DEVICE_iPAD)
    {
        UIPopoverController *popOverController = [[UIPopoverController alloc] initWithContentViewController:_infoViewController];
        [popOverController setDelegate:self];
        
        [popOverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        popOverController = nil;
    }
    else
    {
        [[self navigationController] pushViewController:_infoViewController animated:YES];
    }
}

#pragma mark - UIPopoverControllerDelegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    SAFE_RELEASE(popoverController);
}

#pragma mark - Memory Management

- (void)dealloc
{
    [_fetchOperation setDelegate:nil];
    [_fetchOperation cancel];
    SAFE_RELEASE(_fetchOperation);
    SAFE_RELEASE(_user);
    SAFE_RELEASE(_items);
    SAFE_RELEASE(_listViewController);
    
    [super dealloc];
}

@end
