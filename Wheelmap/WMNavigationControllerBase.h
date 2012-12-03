//
//  WMNavigationControllerBaseViewController.h
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WMDataManagerDelegate.h"
#import "WMNodeListView.h"
#import "WMNavigationBar.h"
#import "WMToolBar.h"
#import "WMMapViewController.h"
#import "WMNodeListViewController.h"
#import "WMDetailViewController.h"
#import "WMWheelchairStatusViewController.h"
#import "WMWheelChairStatusFilterPopoverView.h"
#import "WMCateogryFilterPopoverView.h"

@class WMDataManager;

@interface WMNavigationControllerBase : UINavigationController
<WMDataManagerDelegate, WMNodeListDataSource,
WMNodeListDelegate, CLLocationManagerDelegate,
WMNavigationBarDelegate, WMToolBarDelegate,
WMWheelChairStatusFilterPopoverViewDelegate>

@property (nonatomic, strong) WMNavigationBar* customNavigationBar;
@property (nonatomic, strong) WMToolBar* customToolBar;

-(void)updateNodesNear:(CLLocationCoordinate2D)coord;
-(void)updateNodesWithRegion:(MKCoordinateRegion)region;
@end
