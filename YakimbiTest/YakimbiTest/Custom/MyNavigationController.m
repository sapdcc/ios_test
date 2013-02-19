//
//  MyNavigationController.m
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/19/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import "MyNavigationController.h"

@interface MyNavigationController ()

@end

@implementation MyNavigationController

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
