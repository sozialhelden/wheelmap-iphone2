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
	// Configure tracker from GoogleService-Info.plist.
	NSError *configureError;
	[[GGLContext sharedInstance] configureWithError:&configureError];
	NSAssert(configureError != nil, @"Error configuring Google services: %@", configureError);

	// Optional: configure GAI options.
	GAI *gai = [GAI sharedInstance];
	gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
	gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
}

+ (void)trackScreen:(NSString *) screenName {

	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker set:kGAIScreenName value:screenName];
	[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

+ (void)trackTap:(NSString *) tapId {

	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:K_ACTION_TAP
														  action:tapId
														   label:nil
														   value:nil] build]];
}

@end
