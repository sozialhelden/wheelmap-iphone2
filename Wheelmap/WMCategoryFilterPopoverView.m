//
//  WMCateogryFilterPopoverView.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMCategoryFilterPopoverView.h"
#import "WMCategoryFilterTableViewCell.h"
#import "Category.h"

@implementation WMCategoryFilterPopoverView

- (id)initWithRefPoint:(CGPoint)refPoint andCategories:(NSArray*)categories
{
    self = [super init];
    if (self) {
        
        refOrigin = refPoint;
        bgImg = [[UIImageView alloc] initWithFrame:self.bounds];
        bgImg.image = [[UIImage imageNamed:@"toolbar_category-popup.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 20, 10)];
        [self addSubview:bgImg];
        
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(2, 5, 128, 100)];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.showsVerticalScrollIndicator = NO;
        tableView.dataSource = self;
        tableView.delegate = self;
        [self addSubview:tableView];
        
        [self refreshViewWithCategories:categories];
        
    }
    return self;
}

- (void)refreshViewWithCategories:(NSArray*)categories
{
    self.categoryList = categories;
    // get category list
    self.categoryList = categories;
    
    CGFloat tableViewHeight;
    if (self.categoryList.count > 10) {
        tableViewHeight = CELL_HEIGHT*10;
    } else {
        tableViewHeight = CELL_HEIGHT*self.categoryList.count;
    }
    CGFloat frameHeight = tableViewHeight+10;
    self.frame = CGRectMake(refOrigin.x-110, refOrigin.y-frameHeight-5, 132, frameHeight);
    
    bgImg.frame = self.bounds;
    tableView.frame = CGRectMake(2, 5, 128, tableViewHeight-10);
    [tableView reloadData];
    
}

#pragma mark - UITableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categoryList.count;
}

-(UITableViewCell*)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Category* c = [self.categoryList objectAtIndex:indexPath.row];
    NSString* cellID = [NSString stringWithFormat:@"CategoryListCell-%@", c.localized_name];
    WMCategoryFilterTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];    // TODO: is this ID OK?
    if (!cell) {
        cell = [[WMCategoryFilterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        Category* c = [self.categoryList objectAtIndex:indexPath.row];
        cell.title = c.localized_name;
        cell.selected = YES;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Category* c = [self.categoryList objectAtIndex:indexPath.row];
    WMCategoryFilterTableViewCell* cell = (WMCategoryFilterTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(categoryFilterStatusDidChangeForCategoryID:selected:)]) {
        [self.delegate categoryFilterStatusDidChangeForCategoryID:c.id selected:cell.isSelected];
    }
}

@end