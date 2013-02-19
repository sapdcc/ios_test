//
//  FileViewCell.h
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/19/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolderViewCell.h"

@interface FileViewCell : FolderViewCell
{
    IBOutlet UILabel *_sharedByLabel;
    IBOutlet UILabel *_sharedByLabel2;
    IBOutlet UILabel *_fileCountLabel;
    IBOutlet UILabel *_folderCountLabel;
}

@property (readonly, nonatomic) UILabel *sharedByLabel;
@property (readonly, nonatomic) UILabel *sharedByLabel2;
@property (readonly, nonatomic) UILabel *fileCountLabel;
@property (readonly, nonatomic) UILabel *folderCountLabel;

@end
