//
//  InfoViewController.h
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/20/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController
{
    IBOutlet UIProgressView *_progressView;
    IBOutlet UILabel *_spaceLabel;
    
    User *_user;
}

@property (assign, nonatomic) User *user;

@end
