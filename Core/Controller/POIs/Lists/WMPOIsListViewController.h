//
//  WMListViewController.h
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMNavigationControllerBase.h"

@interface WMPOIsListViewController : WMViewController <WMPOIsListViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopVerticalSpaceConstraint;

@property (nonatomic, strong) NSNumber* selectedCategoryID;
@property (nonatomic) WMPOIsListViewControllerUseCase useCase;
@property (nonatomic, strong) WMNavigationControllerBase *controllerBase;

- (void) showDetailPopoverForNode:(Node *)node;

@end