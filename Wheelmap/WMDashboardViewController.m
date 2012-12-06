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
    self.helpButton = [[WMDashboardButton alloc] initWithFrame:CGRectMake(170.0f, 273.0f, 130.0f, 121.0f) andType:WMDashboardButtonTypeHelp];

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
    
    WMNodeListViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMNodeListViewController"];

    [self.navigationController pushViewController:vc animated:YES];
    
    
}

-(IBAction)pressedMapButton:(id)sender
{
    WMNodeListViewController* nodeListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WMNodeListViewController"];
    WMMapViewController* mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WMMapViewController"];
    
    [self.navigationController pushViewController:nodeListVC animated:NO];
    [self.navigationController pushViewController:mapVC animated:YES];
    
}

@end
