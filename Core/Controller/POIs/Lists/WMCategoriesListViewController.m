//
//  WMCategoriesListViewController.m
//  Wheelmap
//
//  Created by npng on 12/4/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMCategoriesListViewController.h"
#import "WMPOIsListViewController.h"
#import "WMNavigationControllerBase.h"
#import "WMAnalytics.h"

@implementation WMCategoriesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"NavBarTitleCategory", nil);
    self.navigationBarTitle = self.title;
    
    dataManager = [[WMDataManager alloc] init];
    categories = dataManager.categories;
    
    // correct cell separator insets
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.tableView.scrollsToTop = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	[WMAnalytics trackScreen:K_CATEGORIES_SCREEN];
    if ([self.baseController isKindOfClass:[WMNavigationControllerBase class]]) {
        [(WMNavigationControllerBase *)self.baseController resetMapAndListToNormalUseCase];
    }
    
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    if (!self.navigationController.toolbarHidden) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

#pragma mark - UITableView Datasource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return categories.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WMCategory* c = [categories objectAtIndex:indexPath.row];
    NSString* cellID = [NSString stringWithFormat:@"CategoryVCCell-%@", c.id];
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.text = c.localized_name;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WMCategory* c = [categories objectAtIndex:indexPath.row];
    NSString* categoryName = c.localized_name;
    NSNumber* categoryID = c.id;
    
    // set the filters here
    WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.navigationController;
    for (NSNumber* key in [navCtrl.categoryFilterStatus allKeys]) {
        if ([key intValue] == [categoryID intValue]) {
            [navCtrl.categoryFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:key];
        } else {
            [navCtrl.categoryFilterStatus setObject:[NSNumber numberWithBool:NO] forKey:key];
        }
    }
    
    WMPOIsListViewController* nodeListVC = [UIStoryboard instantiatedPOIsListViewController];
    nodeListVC.useCase = kWMPOIsListViewControllerUseCaseCategory;
    nodeListVC.navigationBarTitle = categoryName;
    
    [self.navigationController pushViewController:nodeListVC animated:YES];
}

@end
