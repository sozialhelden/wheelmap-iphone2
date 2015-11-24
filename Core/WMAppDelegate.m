//
//  WMAppDelegate.m
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMAppDelegate.h"
#import <HockeySDK/HockeySDK.h>

@implementation WMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [application setStatusBarStyle:UIStatusBarStyleLightContent];

	[self setupHockeyApp];

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
    
    // new UserAgent Defaults
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0f)], @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	[UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];

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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return YES;
}

# pragma mark - Helper

- (void)setupHockeyApp {
	[BITHockeyManager.sharedHockeyManager configureWithIdentifier:K_HOCKEY_APP_ID];
	[BITHockeyManager.sharedHockeyManager startManager];
	[BITHockeyManager.sharedHockeyManager.crashManager setCrashManagerStatus: BITCrashManagerStatusAutoSend];
	[BITHockeyManager.sharedHockeyManager.authenticator authenticateInstallation];
}

@end
