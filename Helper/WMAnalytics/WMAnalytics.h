//
//  WMAnalytics.h
//  Wheelmap
//
//  Created by Mauricio Torres Mejia on 14/09/16.
//  Copyright © 2016 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>

#define K_SPLASH_SCREEN								@"SplashScreen"
#define K_HOME_SCREEN								@"HomeScreen"
#define K_NEARBY_SCREEN								@"NearbyScreen"
#define K_MAP_SCREEN								@"MapScreen"
#define K_CATEGORIES_SCREEN							@"CategoriesScreen"
#define K_CONTRIBUTE_SCREEN							@"ContributeScreen"
#define K_OSM_ONBOARDING_SCREEN						@"OSMOnboardingScreen"
#define K_OSM_LOGOUT_SCREEN							@"OSMLogoutScreen"
#define K_INFO_SCREEN								@"InfoScreen"

#define K_ACTION_TAP								@"Tap"

@interface WMAnalytics : NSObject

+ (void)setup;
+ (void)trackScreen:(NSString *) screenName;
+ (void)trackTap:(NSString *) tapId;

@end
