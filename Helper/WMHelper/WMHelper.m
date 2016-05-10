//
//  WMHelper.m
//  Wheelmap
//
//  Created by Hans Seiffert on 20.11.15.
//  Copyright © 2015 Sozialhelden e.V. All rights reserved.
//

#import "WMHelper.h"

@implementation WMHelper

+ (BOOL)shouldShowIntroViewController {
	return ([NSUserDefaults.standardUserDefaults boolForKey:K_UD_INTRO_ALREADY_SEEN] == NO);
}

#pragma mark - CLLocation

/**
 Creates a new location which is x meters away from the given one
 */
+ (CLLocationCoordinate2D)locationCoordinate:(CLLocationCoordinate2D)coordinate WithLatitudeOffset:(CLLocationDistance)latitudeOffset longitudeOffset:(CLLocationDistance)longitudeOffset {
	MKMapPoint offsetPoint = MKMapPointForCoordinate(coordinate);

	CLLocationDistance metersPerPoint = MKMetersPerMapPointAtLatitude(coordinate. latitude);
	double latPoints = latitudeOffset / metersPerPoint;
	offsetPoint.y += latPoints;
	double longPoints = longitudeOffset / metersPerPoint;
	offsetPoint.x += longPoints;

	return MKCoordinateForMapPoint(offsetPoint);
}

@end
