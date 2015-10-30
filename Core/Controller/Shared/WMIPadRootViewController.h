//
//  WMIPadRootViewController.h
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMPOIsListViewController.h"
#import "WMMapViewController.h"
#import "WMNavigationControllerBase.h"

@class WMPOIsListViewController, WMMapViewController;

@interface WMIPadRootViewController : UIViewController<WMPOIsListViewDelegate,WMPOIsListDataSourceDelegate, WMPOIsListDelegate>

@property (nonatomic) IBOutlet UIView<WMPOIsListViewDelegate> *listContainerView;
@property (nonatomic) IBOutlet UIView<WMPOIsListViewDelegate> *mapContainerView;

@property (nonatomic) WMPOIsListViewController *listViewController;
@property (nonatomic) WMMapViewController *mapViewController;
@property (nonatomic) WMNavigationControllerBase *controllerBase;

- (IBAction)toggleListButtonTouched:(id)sender;

- (void)gotNewUserLocation:(CLLocation *)location;
//-(void)updateNodesNear:(CLLocationCoordinate2D)coord;
-(void)updateNodesWithRegion:(MKCoordinateRegion)region;
- (void)pressedSearchButton:(BOOL)selected;

- (void)toggleMapTypeChanged:(UIButton *)sender;

@end
