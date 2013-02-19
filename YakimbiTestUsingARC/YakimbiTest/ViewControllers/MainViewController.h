//
//  MainViewController.h
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/16/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewController.h"
#import "InfoViewController.h"

@interface MainViewController : UIViewController <HTTPRequestOperationDelegate, UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate>
{
    User *_user;
    
    NSArray *_items;
    
    IBOutlet UILabel *_statusLabel;
    IBOutlet UITableView *_tableView;
    
    IBOutlet UIBarButtonItem *_infoBtn;
    
    ListViewController *_listViewController;
    
    __strong HTTPRequestOperation *_fetchOperation;
    
    __strong UIPopoverController *_popOverViewController;
}

@end
