//
//  WMAppDelegate.m
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMAppDelegate.h"
#import "UAirship.h"
#import "UAPush.h"
#import <HockeySDK/HockeySDK.h>
#import "AFNetworkActivityIndicatorManager.h"
#import "Constants.h"

@interface WMAppDelegate (HockeySDK) <BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate>

@end

@implementation WMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMOpenConfigFilename ofType:@"plist"]];
    NSString *hockeyID = config[@"hockey_id"];
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:hockeyID
                                                           delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    //Init Airship launch options
    NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    // Create Airship singleton that's used to talk to Urban Airship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    
    // Register for notifications
    [[UAPush shared]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert)];
    
    // start listening to AFNetworking operations and show/hide activity indicator
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // check for the existence of last run version in defaults
	// and create it if necessary
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	
	NSString *lastRunVersion = [defaults objectForKey:LastRunVersion];
	
	BOOL firstRun = ![lastRunVersion isEqualToString: appVersion];
	if (firstRun) {
		// save current version
		[defaults setObject: appVersion forKey:LastRunVersion];
	}
    
    // check for existence of installation Id in defaults
    // and create it if necessary.
    // note: this id is unique for the curent installation of this app on the current device.
    // it can not be used to track the user across installs, devices, or apps and
    // is not the same as the deprecated UDID
    NSString *installId = [defaults objectForKey:InstallId];
    if (!installId || [installId isEqualToString:@""]) {
        CFUUIDRef installIdRef = CFUUIDCreate(NULL);
        CFStringRef installIdStringRef = CFUUIDCreateString(NULL, installIdRef);
        CFRelease(installIdRef);
        installId = (NSString *)CFBridgingRelease(installIdStringRef);
        [defaults setObject:installId forKey:InstallId];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [UAirship land];
}

#pragma mark - BITUpdateManagerDelegate
- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
#ifndef CONFIGURATION_AppStore
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
    return nil;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Updates the device token and registers the token with UA
    [[UAPush shared] registerDeviceToken:deviceToken];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"URL = %@", url.absoluteString);
    return YES;
}

@end
