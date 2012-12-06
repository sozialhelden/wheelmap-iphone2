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
#import "WMCategoryViewController.h"

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
    
    self.nearbyButton = [[WMDashboardButton alloc] initWithFrame:CGRectMake(20.0f, 130.0f, 130.0f, 121.0f) andType:WMDashboardButtonTypeNearby];
    [self.nearbyButton addTarget:self action:@selector(pressedNodeListButton:) forControlEvents:UIControlEventTouchUpInside];
    self.mapButton = [[WMDashboardButton alloc] initWithFrame:CGRectMake(170.0f, 130.0f, 130.0f, 121.0f) andType:WMDashboardButtonTypeMap];
    [self.mapButton addTarget:self action:@selector(pressedMapButton:) forControlEvents:UIControlEventTouchUpInside];
    self.categoriesButton = [[WMDashboardButton alloc] initWithFrame:CGRectMake(20.0f, 273.0f, 130.0f, 121.0f) andType:WMDashboardButtonTypeCategories];
    [self.categoriesButton addTarget:self action:@selector(pressedCategoriesButton:) forControlEvents:UIControlEventTouchUpInside];
    self.helpButton = [[WMDashboardButton alloc] initWithFrame:CGRectMake(170.0f, 273.0f, 130.0f, 121.0f) andType:WMDashboardButtonTypeHelp];
    [self.helpButton addTarget:self action:@selector(pressedContributeButton:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.nearbyButton];
    [self.view addSubview:self.mapButton];
    [self.view addSubview:self.categoriesButton];
    [self.view addSubview:self.helpButton];

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
    WMCategoryViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMCategoryViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
