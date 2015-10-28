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
{
    WMLabel* titleLabel;
    UIImageView* checkIcon; // this will be shown, if the cell is selected
}

@property (nonatomic, strong) NSString* title;
@property (nonatomic) BOOL isSelected;  // we need another boolean to avoid radio-button-like behavior of the tableview.
@end
