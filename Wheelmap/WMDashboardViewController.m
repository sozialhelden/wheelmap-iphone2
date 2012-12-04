//
//  WMDashboardViewController.m
//  Wheelmap
//
//  Created by npng on 12/2/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMDashboardViewController.h"
#import "WMNodeListViewController.h"
#import "WMMapViewController.h"
#import "WMNavigationControllerBase.h"

@interface WMDashboardViewController ()

@end

@implementation WMDashboardViewController

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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)pressedNodeListButton:(id)sender
{
    // set the filters here
    WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.navigationController;
    [navCtrl clearWheelChairFilterStatus];
    [navCtrl clearCategoryFilterStatus];
    WMNodeListViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMNodeListViewController"];
    vc.useCase = kWMNodeListViewControllerUseCaseNormal;
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

-(IBAction)pressedMapButton:(id)sender
{
    // set the filters here
    WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.navigationController;
    [navCtrl clearWheelChairFilterStatus];
    [navCtrl clearCategoryFilterStatus];
    
    WMNodeListViewController* nodeListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WMNodeListViewController"];
    WMMapViewController* mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WMMapViewController"];
    mapVC.navigationBarTitle = @"Orte in deiner Nähe";
    [self.navigationController pushViewController:nodeListVC animated:NO];
    [self.navigationController pushViewController:mapVC animated:YES];
    
}

-(IBAction)pressedContributeButton:(id)sender
{
    // set the filters here
    WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.navigationController;
    [navCtrl clearWheelChairFilterStatus];
    [navCtrl clearCategoryFilterStatus];
    for (NSString* key in [navCtrl.wheelChairFilterStatus allKeys]) {
        if ([key isEqualToString:@"unknown"]) {
            [navCtrl.wheelChairFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:key];
        } else {
            [navCtrl.wheelChairFilterStatus setObject:[NSNumber numberWithBool:NO] forKey:key];
        }
    }
    
    
    WMNodeListViewController* nodeListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WMNodeListViewController"];
    nodeListVC.useCase = kWMNodeListViewControllerUseCaseContribute;
    [self.navigationController pushViewController:nodeListVC animated:YES];
}

-(IBAction)pressedCategoriesButton:(id)sender
{
    
}

@end
