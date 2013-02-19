//
//  ListViewController.m
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/18/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import "ListViewController.h"
#import "TableViewController.h"
#import "FileViewCell.h"

#define DISPLAY_NO_OF_ITEMS 20

static NSString *identifier = @"FileCell";

@interface ListViewController ()

@end

@implementation ListViewController

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
    
    if (DEVICE_iPAD)
    {
        [_tableView registerNib:[UINib nibWithNibName:@"FileViewCell_iPad" bundle:nil] forCellReuseIdentifier:identifier];
    }
    else
    {
        [_tableView registerNib:[UINib nibWithNibName:@"FileViewCell" bundle:nil] forCellReuseIdentifier:identifier];
    }
    
    [[self navigationItem] setRightBarButtonItems:@[_nextBarBtn, _previousBarBtn]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_folder)
    {
        [self setTitle:[_folder name]];
        
        currentPage = 1;
        noOfPages = ceil((double)[[self files] count] / (double)DISPLAY_NO_OF_ITEMS);
        
        [self refreshData];
    }
    
    [self setFrameBaseOnOrientation];
}

#pragma mark - Refresh Data

- (void)refreshData
{
    NSSortDescriptor *asc = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    SAFE_RELEASE(_items);
    
    int loc = 0;
    int len = 0;
    NSRange range;
    
    // Calculate start location and no. of records to be shown
    // If less records than min no. to be displayed at once
    if ((currentPage * DISPLAY_NO_OF_ITEMS) > [[_folder files] count])
    {
        loc = (currentPage - 1) * DISPLAY_NO_OF_ITEMS;
        len = [[self files] count] - loc;
        range = NSMakeRange(loc, len);
    }
    else
        {
            loc = (currentPage - 1) * DISPLAY_NO_OF_ITEMS;
            len = DISPLAY_NO_OF_ITEMS;
            range = NSMakeRange(loc, len);
        }
    
    // Get subarray and sort it
    _items = [[[[self files] subarrayWithRange:range] sortedArrayUsingDescriptors:@[asc]] retain];
    
    // Show range of records shown from the total no. of records
    _pageLabel.text = [NSString stringWithFormat:@"Showing %i - %i of %i", ++loc, loc+[_items count]-1, [[self files] count]];
    
    // Reload data
    [_tableView reloadData];
    
    // Scroll to top
    [_tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (NSArray *)files
{
    return [[[_folder files] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"self.hidden == 0"]] allObjects];
}

#pragma mark - Event Handlers

- (IBAction)next:(id)sender
{
    if (currentPage == noOfPages)
        return;
    
    ++currentPage;
    [self refreshData];
}

- (IBAction)previous:(id)sender
{
    if (currentPage <= 1)
        return;
    
    --currentPage;
    [self refreshData];
}

#pragma mark - UITableView Delegate & Datasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileViewCell *cell = (FileViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    File *_file = [_items objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [_file name];
    cell.pathLabel.text = [NSString stringWithFormat:@"Path: %@", [_file path]];
    
    if (DEVICE_iPAD)
    {
        cell.sharedByLabel.text = [NSString stringWithFormat:@"Created on: %@ by %@", [_file createdDate], [_file lastUpdatedBy]];
        cell.sharedByLabel2.text = [NSString stringWithFormat:@"Link: %@", [_file link]];
    }
    else
    {
        cell.sharedByLabel.text = [NSString stringWithFormat:@"Created on: %@", [_file createdDate]];
        cell.sharedByLabel2.text = [NSString stringWithFormat:@"Last Updated By: %@", [_file lastUpdatedBy]];
    }
    
    if ([[_file type] isEqualToString:@"1"])
    {
        cell.fileCountLabel.text = @"file";
        cell.folderCountLabel.text = FORMAT_BYTES([[_file size] floatValue]);
    }
    else
    {
        cell.fileCountLabel.text = @"folder";
        cell.folderCountLabel.text = @"";
        cell.sharedByLabel2.text = @"";
    }
    
    _file = nil;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (DEVICE_iPAD)
    {
        TableViewController *_mainViewController = [TableViewController new];
        UIPopoverController *popOverController = [[UIPopoverController alloc] initWithContentViewController:_mainViewController];
        [_mainViewController setPopOverViewController:popOverController];
        SAFE_RELEASE(_mainViewController);
        [popOverController setDelegate:self];

        // Calculate the location to show the UIPopoverController
        CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
        [popOverController presentPopoverFromRect:CGRectMake(rect.origin.x + rect.size.width-25, CGRectGetMidY(rect)+ (int)(rect.size.height/2) - 18 - tableView.contentOffset.y, 1, 1) inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        popOverController = nil;
    }
    else
    {
        UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Test" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Row1", @"Row2", @"Row3", @"Row4", nil] autorelease];
        [actionSheet showInView:[self view]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 94;
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
            [_pageLabel setFrame:CGRectMake(0, 3, 1024, 30)];
        }
        else
        {
            [_pageLabel setFrame:CGRectMake(0, 3, 480, 30)];
        }
    }
    else
    {
        if (DEVICE_iPAD)
        {
            [_pageLabel setFrame:CGRectMake(0, 3, 768, 30)];
        }
        else
        {
            [_pageLabel setFrame:CGRectMake(0, 3, 320, 30)];
        }
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
    SAFE_RELEASE(_folder);
    SAFE_RELEASE(_items);
    
    [super dealloc];
}

@end
