//
//  WMCateogryFilterPopoverView.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMCateogryFilterPopoverView.h"
#import "WMCategoryFilterTableViewCell.h"


@implementation WMCateogryFilterPopoverView

- (id)initWithRefPoint:(CGPoint)refPoint
{
    self = [super init];
    if (self) {
        // get category list
        //categoryList = self.dataSource.categoryList;
        // dummy categories!
        categoryList = @[@"Restaurants", @"Bar & Kneipen", @"Cafe", @"Hotel", @"Verkehr", @"Behörden"];
        CGFloat tableViewHeight;
        if (categoryList.count > 10) {
            tableViewHeight = CELL_HEIGHT*10;
        } else {
            tableViewHeight = CELL_HEIGHT*categoryList.count;
        }
        CGFloat frameHeight = tableViewHeight+10;
        self.frame = CGRectMake(refPoint.x-110, refPoint.y-frameHeight-5, 132, frameHeight);
        
        bgImg = [[UIImageView alloc] initWithFrame:self.bounds];
        bgImg.image = [[UIImage imageNamed:@"toolbar_category-popup.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 20, 10)];
        [self addSubview:bgImg];
        
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(2, 5, 128, tableViewHeight-10)];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.showsVerticalScrollIndicator = NO;
        tableView.dataSource = self;
        tableView.delegate = self;
        [self addSubview:tableView];
        
    }
    return self;
}

#pragma mark - UITableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return categoryList.count;
}

-(UITableViewCell*)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellID = @"CategoryListCell";
    WMCategoryFilterTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];    // TODO: is this ID OK?
    if (!cell) {
        cell = [[WMCategoryFilterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.title = [categoryList objectAtIndex:indexPath.row];
    }
    
    return cell;
}

@end