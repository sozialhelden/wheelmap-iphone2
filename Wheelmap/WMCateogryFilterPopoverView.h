//
//  WMCateogryFilterPopoverView.h
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMCateogryFilterPopoverView : UIView <UITableViewDataSource, UITableViewDelegate>
{
    UIImageView* bgImg;
    NSArray* categoryList;
    UITableView* tableView;
}

@property (nonatomic, strong) id dataSource;    // datasource for the current categorylist
- (id)initWithRefPoint:(CGPoint)refPoint;
@end
