//
//  WMCategoryFilterTableViewCell.h
//  Wheelmap
//
//  Created by npng on 11/29/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#define CELL_HEIGHT 30.0

@interface WMCategoryFilterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet MarqueeLabel *			titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *			checkmarkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	checkmarkWidthConstraint;

@property (nonatomic, strong) NSString *					title;
@property (nonatomic) BOOL									checked;  // we need another boolean to avoid radio-button-like behavior of the tableview.
@end
