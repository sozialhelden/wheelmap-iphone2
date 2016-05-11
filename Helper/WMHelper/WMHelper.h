//
//  WMHelper.h
//  Wheelmap
//
//  Created by Hans Seiffert on 20.11.15.
//  Copyright © 2015 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WMHelper : NSObject

+ (BOOL)shouldShowIntroViewController;

#pragma mark - CLLocation

+ (CLLocationCoordinate2D)locationCoordinate:(CLLocationCoordinate2D)coordinate WithLatitudeOffset:(CLLocationDistance)latitudeOffset longitudeOffset:(CLLocationDistance)longitudeOffset;

@end
