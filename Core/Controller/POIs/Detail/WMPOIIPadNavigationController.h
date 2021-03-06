//
//  WMPOIIPadNavigationController.h
//  Wheelmap
//
//  Created by Michael Thomas on 23.01.13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMNavigationBar.h"
#import "WMToolbar.h"
#import <CoreLocation/CoreLocation.h>

@class WMPOIsListViewController;

@interface WMPOIIPadNavigationController : UINavigationController <WMNavigationBarDelegate>

@property (nonatomic, strong) WMPOIsListViewController *	listViewController;
@property (nonatomic, strong) WMNavigationBar *				customNavigationBar;
@property (nonatomic, assign) CLLocationCoordinate2D		initialCoordinate;

- (void)showLoadingWheel;
- (void)changeScreenStatusFor:(UIViewController *)viewController;
- (void)mapWasMoved:(CLLocationCoordinate2D)coordinate;

- (void)showLoginViewController;

@end
