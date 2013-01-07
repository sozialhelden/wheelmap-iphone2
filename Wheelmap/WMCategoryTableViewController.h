//
//  WMCategoryTableViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 12.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"

@interface WMCategoryTableViewController : WMTableViewController

@property (nonatomic, strong) NSArray *categoryArray;
@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) Category *currentCategory;

- (id)initWithStyle:(UITableViewStyle)style andCategory:(Category*)c;
@end
