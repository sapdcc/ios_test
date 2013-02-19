//
//  InfoViewController.m
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/20/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad
{
    [self setContentSizeForViewInPopover:CGSizeMake(320, 320)];
    
    [_spaceLabel setText:[NSString stringWithFormat:@"Using %@ of your %@", FORMAT_BYTES([[_user usedSpace] floatValue]), FORMAT_BYTES([[_user totalSpace] floatValue])]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    float progress = (([_user.usedSpace floatValue] / [_user.totalSpace floatValue]) * 1.0);
    [_progressView setProgress:progress animated:YES];
}

- (void)dealloc
{
    _user = nil;
    
    [super dealloc];
}

@end
