//
//  FolderViewCell.h
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/19/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FolderViewCell : UITableViewCell
{
    IBOutlet UILabel *_nameLabel;
    IBOutlet UILabel *_pathLabel;
}

@property (readonly, nonatomic) UILabel *nameLabel;
@property (readonly, nonatomic) UILabel *pathLabel;

@end
