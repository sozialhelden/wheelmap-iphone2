//
//  WMAnalytics.m
//  Wheelmap
//
//  Created by Mauricio Torres Mejia on 14/09/16.
//  Copyright © 2016 Sozialhelden e.V. All rights reserved.
//

#import "WMAnalytics.h"
#import <Google/Analytics.h>

@implementation WMAnalytics

+ (void)setup {
	// Configure tracker from plist.
	[GAI.sharedInstance trackerWithTrackingId:K_GOOGLE_ANALYTICS_ID];

	// Optional: configure GAI options.
	GAI.sharedInstance.trackUncaughtExceptions = YES;
}

+ (void)trackScreen:(NSString *) screenName {

	id<GAITracker> tracker = GAI.sharedInstance.defaultTracker;
	[tracker set:kGAIScreenName value:screenName];
	[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
	[GAI.sharedInstance dispatch];
}

+ (void)trackTap:(NSString *) tapId {

	[GAI.sharedInstance.defaultTracker send:[[GAIDictionaryBuilder createEventWithCategory:K_ACTION_TAP
														  							action:tapId
																					 label:nil
																					 value:nil] build]];
	[GAI.sharedInstance dispatch];
}

@end
