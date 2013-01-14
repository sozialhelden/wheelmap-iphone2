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
#import "WMCommentViewController.h"
#import "WMWheelchairStatusViewController.h"
#import "WMWheelChairStatusFilterPopoverView.h"
#import "WMCategoryFilterPopoverView.h"

@class WMDataManager;

@interface WMNavigationControllerBase : UINavigationController
<WMDataManagerDelegate, WMNodeListDataSource,
WMNodeListDelegate, CLLocationManagerDelegate,
WMNavigationBarDelegate, WMToolBarDelegate,
WMWheelChairStatusFilterPopoverViewDelegate,
WMCategoryFilterPopoverViewDelegate,
UINavigationControllerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) WMNavigationBar* customNavigationBar;
@property (nonatomic, strong) WMToolBar* customToolBar;
@property (nonatomic, strong) NSMutableDictionary* wheelChairFilterStatus;
@property (nonatomic, strong) NSMutableDictionary* categoryFilterStatus;
@property (nonatomic, strong) NSNumber* lastVisibleMapCenterLat;  // this will store last visible map region, so that we can restore last nodes.
@property (nonatomic, strong) NSNumber* lastVisibleMapCenterLng;
@property (nonatomic, strong) NSNumber* lastVisibleMapSpanLat;
@property (nonatomic, strong) NSNumber* lastVisibleMapSpanLng;

-(void)updateNodesNear:(CLLocationCoordinate2D)coord;
-(void)updateNodesWithoutLoadingWheelNear:(CLLocationCoordinate2D)coord;
-(void)updateNodesWithRegion:(MKCoordinateRegion)region;
-(void)updateNodesWithQuery:(NSString*)query;
-(void)updateNodesWithQuery:(NSString*)query andRegion:(MKCoordinateRegion)region;
-(void)updateNodesWithCurrentUserLocation;

- (void) refreshNodeListWithArray:(NSArray*)array;  // use this method if you want to refresh list and maps with custom node array

-(void)clearWheelChairFilterStatus;
-(void)clearCategoryFilterStatus;

-(void)showLoadingWheel;
-(void)hideLoadingWheel;

-(void)presentLoginScreen;

-(CLLocation*)currentUserLocation;
@end
