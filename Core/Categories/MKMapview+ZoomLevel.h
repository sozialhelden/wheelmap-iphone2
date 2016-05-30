//
//  MKMapView+ZoomLevel.h
//
//  https://gist.github.com/d2burke/ad29811b07ae31b378ff
//
//  Created by Daniel.Burke on 7/3/14 via Nikita Galayko @ StackOverflow
//  Copyright (c) 2014 Forrent.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define MERCATOR_RADIUS 85445659.44705395
#define MAX_GOOGLE_LEVELS 20

@import UIKit;

@interface MKMapView (ZoomLevel)

- (double)zoomLevel;

@end