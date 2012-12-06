//
//  WMDashboardViewController.h
//  Wheelmap
//
//  Created by npng on 12/2/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMViewController.h"
#import "WMDashboardButton.h"

@interface WMDashboardViewController : WMViewController

@property (nonatomic, strong) WMDashboardButton *nearbyButton;
@property (nonatomic, strong) WMDashboardButton *mapButton;
@property (nonatomic, strong) WMDashboardButton *categoriesButton;
@property (nonatomic, strong) WMDashboardButton *helpButton;

-(IBAction)pressedNodeListButton:(id)sender;
-(IBAction)pressedMapButton:(id)sender;

@end
