//
//  TableViewController.h
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/19/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UITableViewController
{
    UIPopoverController *_popOverViewController;
}

@property (assign, nonatomic) UIPopoverController *popOverViewController;

@end
