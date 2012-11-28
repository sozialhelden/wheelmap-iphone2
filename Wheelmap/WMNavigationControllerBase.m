//
//  WMNavigationControllerBaseViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "WMNavigationControllerBase.h"
#import "WMDataManager.h"
#import "WMDetailViewController.h"
#import "Node.h"


@implementation WMNavigationControllerBase
{
    NSArray *nodes;
    WMDataManager *dataManager;
    CLLocationManager *locationManager;
}


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    dataManager = [[WMDataManager alloc] init];
    dataManager.delegate = self;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 50.0f;
	locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    // configure initial vc from storyboard
    if ([self.topViewController conformsToProtocol:@protocol(WMNodeListView)]) {
        id<WMNodeListView> initialNodeListView = (id<WMNodeListView>)self.topViewController;
        initialNodeListView.dataSource = self;
        initialNodeListView.delegate = self;
    }
    
    // TODO: use another image
    [self.toolbar setBackgroundImage:[UIImage imageNamed:@"temp"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES; // TODO: prevent upside down on iphone
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Data Manager Delegate

- (void) dataManager:(WMDataManager *)dataManager didReceiveNodes:(NSArray *)nodesParam
{
    nodes = nodesParam;
    
    [self refreshNodeList];
}

- (void) refreshNodeList
{
    if ([self.topViewController conformsToProtocol:@protocol(WMNodeListView)]) {
        [(id<WMNodeListView>)self.topViewController nodeListDidChange];
    }
}

-(void)dataManager:(WMDataManager *)dataManager fetchNodesFailedWithError:(NSError *)error
{
    NSLog(@"error %@", error.localizedDescription);
}

- (void)dataManagerDidFinishSyncingResources:(WMDataManager *)dataManager
{
    NSLog(@"dataManagerDidFinishSyncingResources");
}

-(void)dataManager:(WMDataManager *)dataManager syncResourcesFailedWithError:(NSError *)error
{
    NSLog(@"syncResourcesFailedWithError");
}


#pragma mark - Node List Data Source

- (NSArray*) nodeList
{
    return nodes;
}


#pragma mark - Node List Delegate

/**
 * Called only on the iPhone
 */
- (void)nodeListView:(id<WMNodeListView>)nodeListView didSelectNode:(Node *)node
{
    // we don"t want to push a detail view when selecting a node on the map view, so
    // we check if this message comes from a table view
    if (node && [nodeListView isKindOfClass:[UITableViewController class]]) {
        [self pushDetailsViewControllerForNode:node];
    }
}

/**
 * Called only on the iPhone
 */
- (void) nodeListView:(id<WMNodeListView>)nodeListView didSelectDetailsForNode:(Node *)node
{
    if (node) {
        [self pushDetailsViewControllerForNode:node];
    }
}

- (void) pushDetailsViewControllerForNode:(Node*)node
{
    WMDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"WMDetailView" bundle:nil] instantiateInitialViewController];
    detailViewController.node = node;
    [self pushViewController:detailViewController animated:YES];
}


#pragma mark - Location Manager Delegate

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Loc Error Title", @"")
                                                        message:NSLocalizedString(@"No Loc Error Message", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
	[alertView show];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [dataManager fetchNodesNear:newLocation.coordinate];
}


#pragma mark - Application Notifications

- (void) applicationDidBecomeActive:(NSNotification*)notification
{
    if (locationManager) {
        [locationManager startMonitoringSignificantLocationChanges];
    }
}

- (void)applicationWillResignActive:(NSNotification*)notification
{
	[locationManager stopUpdatingLocation];
}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController conformsToProtocol:@protocol(WMNodeListView)]) {
        id<WMNodeListView> nodeListViewController = (id<WMNodeListView>)viewController;
        nodeListViewController.dataSource = self;
        nodeListViewController.delegate = self;
    }
    
    [super pushViewController:viewController animated:animated];
}


@end




