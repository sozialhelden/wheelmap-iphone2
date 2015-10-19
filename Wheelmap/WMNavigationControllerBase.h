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
#import "WMNavigationBar_iPad.h"
#import "WMToolBar.h"
#import "WMToolBar_iPad.h"
#import "WMMapViewController.h"
#import "WMDetailViewController.h"
#import "WMCommentViewController.h"
#import "WMWheelchairStatusViewController.h"
#import "WMWheelChairStatusFilterPopoverView.h"
#import "WMCategoryFilterPopoverView.h"

@class WMDataManager, WMNodeListViewController;

@interface WMNavigationControllerBase : UINavigationController
<WMDataManagerDelegate, WMNodeListDataSource,
WMNodeListDelegate, CLLocationManagerDelegate,
WMNavigationBarDelegate, WMToolBarDelegate,
WMWheelChairStatusFilterPopoverViewDelegate,
WMCategoryFilterPopoverViewDelegate,
UINavigationControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) CLLocationManager *		locationManager;
@property (nonatomic, strong) CLLocation *				currentLocation;
@property (nonatomic, strong) WMNavigationBar *			customNavigationBar;
@property (nonatomic, strong) WMToolBar *				customToolBar;
@property (nonatomic, strong) NSMutableDictionary *		wheelChairFilterStatus;
@property (nonatomic, strong) NSMutableDictionary *		categoryFilterStatus;
@property (nonatomic, strong) NSNumber *				lastVisibleMapCenterLat;  // this will store last visible map region, so that we can restore last nodes.
@property (nonatomic, strong) NSNumber *				lastVisibleMapCenterLng;
@property (nonatomic, strong) NSNumber *				lastVisibleMapSpanLat;
@property (nonatomic, strong) NSNumber *				lastVisibleMapSpanLng;
@property (nonatomic, strong) WMMapViewController *		mapViewController;

@property (nonatomic, strong)  WMViewController *		popoverVC;

//- (void)showFirstStartScreen;

- (void)pushList;
- (void)pushMap;
- (void)setMapControllerToContribute;
- (void)setMapControllerToNormal;
- (void)setListViewControllerToNormal;
- (void)resetMapAndListToNormalUseCase;
- (void)mapWasMoved;

//-(void)updateNodesNear:(CLLocationCoordinate2D)coord;
//-(void)updateNodesWithoutLoadingWheelNear:(CLLocationCoordinate2D)coord;
-(void)updateNodesWithRegion:(MKCoordinateRegion)region;
-(void)updateNodesWithQuery:(NSString*)query;
-(void)updateNodesWithQuery:(NSString*)query andRegion:(MKCoordinateRegion)region;
-(void)updateNodesWithCurrentUserLocation;
-(void)updateNodesWithLastQueryAndRegion:(MKCoordinateRegion)region;

- (void) refreshNodeListWithArray:(NSArray*)array;  // use this method if you want to refresh list and maps with custom node array

-(void)clearWheelChairFilterStatus;
-(void)clearCategoryFilterStatus;

-(void)showLoadingWheel;
-(void)hideLoadingWheel;

- (void)showAcceptTermsViewController;

- (void)presentLoginScreen;
- (void)presentLoginScreenWithButtonFrame:(CGRect)frame;

@end
