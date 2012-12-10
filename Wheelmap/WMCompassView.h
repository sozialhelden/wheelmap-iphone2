//
//  WMCompassView.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 10.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Node.h"


@interface WMCompassView : UIView <CLLocationManagerDelegate> {}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) UIView *compassContainer;
@property (nonatomic, strong) Node *node;
@property (nonatomic, strong) CLLocation *nodeLocation;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, assign) CGFloat currentAngle;

@end
