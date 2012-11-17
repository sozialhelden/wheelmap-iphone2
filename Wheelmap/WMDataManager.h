//
//  WMDataManager.h
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMDataManagerDelegate.h"
#import <CoreLocation/CoreLocation.h>


@interface WMDataManager : NSObject

@property (nonatomic, weak) id<WMDataManagerDelegate> delegate;

- (void) fetchNodesNear:(CLLocationCoordinate2D)location;

- (void) fetchNodesBetweenSouthwest:(CLLocationCoordinate2D)southwest northeast:(CLLocationCoordinate2D)northeast;

@end
