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
    __weak UIPopoverController *_popOverViewController;
}

@property (weak, nonatomic) UIPopoverController *popOverViewController;

@end
