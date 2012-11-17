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


@class WMDataManager;

@interface WMNavigationControllerBase : UINavigationController <WMDataManagerDelegate, WMNodeListDataSource, WMNodeListDelegate, CLLocationManagerDelegate>

@end
