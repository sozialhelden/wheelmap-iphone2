//
//  MKMapView+ZoomLevel.m
//
//  Created by Daniel.Burke on 7/3/14 via Nikita Galayko @ StackOverflow
//  Copyright (c) 2014 Forrent.com. All rights reserved.
//

#import "MKMapView+ZoomLevel.h"

@implementation MKMapView (ZoomLevel)

- (double)zoomLevel {
	CLLocationDegrees longitudeDelta = self.region.span.longitudeDelta;
	CGFloat mapWidthInPixels = self.bounds.size.width;
	if (mapWidthInPixels != 0.0) {
		double zoomScale = longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * mapWidthInPixels);
		double zoomer = MAX_GOOGLE_LEVELS - log2( zoomScale );
		if (zoomer < 0) {
			zoomer = 0;
		}
		return zoomer;
	} else {
		return 0;
	}
}

@end