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
#import "WMNavigationBar.h"
#import "WMIPadMapNavigationBar.h"
#import "WMToolbar.h"
#import "WMToolbar_iPad.h"
#import "WMMapViewController.h"
#import "WMPOIViewController.h"
#import "WMEditPOICommentViewController.h"
#import "WMEditPOIStateViewController.h"
#import "WMPOIStateFilterPopoverView.h"
#import "WMCategoryFilterPopoverView.h"

@class WMDataManager, WMPOIsListViewController;

@interface WMNavigationControllerBase : UINavigationController
<WMDataManagerDelegate, WMPOIsListDataSourceDelegate,
WMPOIsListDelegate, CLLocationManagerDelegate,
WMNavigationBarDelegate, WMToolbarDelegate,
WMPOIStateFilterPopoverViewDelegate,
WMCategoryFilterPopoverViewDelegate,
UINavigationControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) CLLocationManager *		locationManager;
@property (nonatomic, strong) CLLocation *				currentLocation;
@property (nonatomic, strong) WMNavigationBar *			customNavigationBar;
@property (nonatomic, strong) WMToolbar *				customToolBar;
@property (nonatomic, strong) NSMutableDictionary *		wheelchairStateFilterStatus;
@property (nonatomic, strong) NSMutableDictionary *		toiletStateFilterStatus;
@property (nonatomic, strong) NSMutableDictionary *		categoryFilterStatus;
@property (nonatomic, strong) NSNumber *				lastVisibleMapCenterLat;  // this will store last visible map region, so that we can restore last nodes.
@property (nonatomic, strong) NSNumber *				lastVisibleMapCenterLng;
@property (nonatomic, strong) NSNumber *				lastVisibleMapSpanLat;
@property (nonatomic, strong) NSNumber *				lastVisibleMapSpanLng;
@property (nonatomic, strong) WMMapViewController *		mapViewController;

@property (nonatomic, strong)  WMViewController *		popoverVC;

- (void)pushList;
- (void)pushMap;
- (void)setMapControllerToContribute;
- (void)setMapControllerToNormal;
- (void)setListViewControllerToNormal;
- (void)resetMapAndListToNormalUseCase;
- (void)mapWasMoved;

-(void)updateNodesWithRegion:(MKCoordinateRegion)region;
-(void)updateNodesWithQuery:(NSString*)query;
-(void)updateNodesWithQuery:(NSString*)query andRegion:(MKCoordinateRegion)region;
-(void)updateNodesWithCurrentUserLocation;
-(void)updateNodesWithLastQueryAndRegion:(MKCoordinateRegion)region;

- (void)refreshNodeListWithArray:(NSArray*)array;  // use this method if you want to refresh list and maps with custom node array

- (void)clearCategoryFilterStatus;

-(void)showLoadingWheel;
-(void)hideLoadingWheel;

- (void)showAcceptTermsViewController;

- (void)presentLoginScreen;
- (void)presentLoginScreenWithButtonFrame:(CGRect)frame;

@end
