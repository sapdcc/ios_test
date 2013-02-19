//
//  ListViewController.h
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/18/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate>
{
    Folder *_folder;
    
    NSArray *_items;
    
    IBOutlet UITableView *_tableView;
    IBOutlet UILabel *_pageLabel;
    IBOutlet UIBarButtonItem *_nextBarBtn;
    IBOutlet UIBarButtonItem *_previousBarBtn;
    
    int currentPage;
    int noOfPages;
    
    __strong UIPopoverController *_popOverViewController;
}

@property (retain, nonatomic) Folder *folder;

@end
