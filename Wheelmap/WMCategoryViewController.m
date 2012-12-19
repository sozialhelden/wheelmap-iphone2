//
//  WMCategoryViewController.m
//  Wheelmap
//
//  Created by npng on 12/4/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMCategoryViewController.h"
#import "WMNodeListViewController.h"
#import "WMNavigationControllerBase.h"

@interface WMCategoryViewController ()

@end

@implementation WMCategoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"NavBarTitleCategory", nil);
    self.navigationBarTitle = self.title;
    
    dataManager = [[WMDataManager alloc] init];
    categories = dataManager.categories;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    if (!self.navigationController.toolbarHidden) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource and Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return categories.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Category* c = [categories objectAtIndex:indexPath.row];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Category* c = [categories objectAtIndex:indexPath.row];
    NSString* categoryName = c.localized_name;
    NSNumber* categoryID = c.id;
    
    // set the filters here
    WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.navigationController;
    [navCtrl clearWheelChairFilterStatus];
    [navCtrl clearCategoryFilterStatus];
    for (NSNumber* key in [navCtrl.categoryFilterStatus allKeys]) {
        if ([key intValue] == [categoryID intValue]) {
            [navCtrl.categoryFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:key];
        } else {
            [navCtrl.categoryFilterStatus setObject:[NSNumber numberWithBool:NO] forKey:key];
        }
    }
    
    
    WMNodeListViewController* nodeListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WMNodeListViewController"];
    nodeListVC.useCase = kWMNodeListViewControllerUseCaseCategory;
    nodeListVC.navigationBarTitle = categoryName;
    
    [self.navigationController pushViewController:nodeListVC animated:YES];
}

@end
