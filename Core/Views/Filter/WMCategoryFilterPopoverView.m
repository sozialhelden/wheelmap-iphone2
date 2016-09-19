//
//  WMCateogryFilterPopoverView.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMCategoryFilterPopoverView.h"
#import "WMCategoryFilterTableViewCell.h"
#import "WMCategory.h"

@implementation WMCategoryFilterPopoverView

#define K_FRAME_WIDTH				172.0f
#define K_ARROW_X_OFFSET			22.0f
#define K_ARROW_X_OFFSET_RTL		30.0f
#define K_TABLE_VIEW_Y_OFSSET		10.0f

#pragma mark - Initialization

- (id)initWithRefPoint:(CGPoint)refPoint andCategories:(NSArray*)categories {
    self = (WMCategoryFilterPopoverView *) [WMCategoryFilterPopoverView loadFromNib:@"WMCategoryFilterPopoverView"];

    if (self) {
        refOrigin = refPoint;

		self.tableView.delegate = self;
		self.tableView.dataSource = self;
        self.tableView.scrollsToTop = NO;
		[self.tableView registerNib:[UINib nibWithNibName:@"WMCategoryFilterCell" bundle:nil] forCellReuseIdentifier:K_CATEGORY_FILTER_CELL];

        [self refreshViewWithCategories:categories];

		if (self.isRightToLeftDirection == YES) {
			self.backgroundImageView.image = [UIImage imageNamed:@"toolbar_category-popup-rtl.png"];
		}
    }
    return self;
}

#pragma mark - Public methods

- (void)refreshViewWithRefPoint:(CGPoint)refPoint andCategories:(NSArray *)categories {
    refOrigin = refPoint;
    [self refreshViewWithCategories:categories];
}

- (void)refreshViewWithCategories:(NSArray*)categories {
    // get category list
    self.categoryList = categories;
    
    CGFloat tableViewHeight;
    if (UIDevice.currentDevice.isIPad == YES) {
        if (self.categoryList.count > 15) {
            tableViewHeight = CELL_HEIGHT * 15;
        } else {
            tableViewHeight = CELL_HEIGHT * self.categoryList.count;
        }
    } else {
        if (self.categoryList.count > 10) {
            tableViewHeight = CELL_HEIGHT * 10;
        } else {
            tableViewHeight = CELL_HEIGHT * self.categoryList.count;
        }
    }
    
    CGFloat frameHeight = tableViewHeight + K_TABLE_VIEW_Y_OFSSET;
	if (self.isRightToLeftDirection == YES) {
        self.frame = CGRectMake(refOrigin.x - K_ARROW_X_OFFSET_RTL, refOrigin.y - frameHeight, K_FRAME_WIDTH, frameHeight);
    } else {
		self.frame = CGRectMake(refOrigin.x - K_FRAME_WIDTH + K_ARROW_X_OFFSET, refOrigin.y - frameHeight, K_FRAME_WIDTH, frameHeight);
    }
    
	[self layoutIfNeeded];
    [self.tableView reloadData];
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
    return self.categoryList.count;
}

- (UITableViewCell*)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WMCategoryFilterTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:K_CATEGORY_FILTER_CELL];
    if (cell == nil) {
        cell = [[WMCategoryFilterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:K_CATEGORY_FILTER_CELL];
    }

	WMCategory* category = [self.categoryList objectAtIndex:indexPath.row];
	cell.title = category.localized_name;
	cell.checked = category.selected.boolValue;

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WMCategory* category = [self.categoryList objectAtIndex:indexPath.row];
	category.selected = @(!category.selected.boolValue);
    if ([self.delegate respondsToSelector:@selector(categoryFilterStatusDidChangeForCategoryID:selected:)]) {
        [self.delegate categoryFilterStatusDidChangeForCategoryID:category.id selected:category.selected.boolValue];
    }
    [self refreshViewWithCategories:self.categoryList];
}

@end