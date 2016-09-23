//
//  WMNavigationControllerBaseViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "WMNavigationControllerBase.h"
#import "WMDataManager.h"
#import "WMPOIViewController.h"
#import "WMEditPOIStateViewController.h"
#import "WMDashboardViewController.h"
#import "WMEditPOIViewController.h"
#import "WMShareSocialViewController.h"
#import "WMCategoriesListViewController.h"
#import "WMOSMOnboardingViewController.h"
#import "WMEditPOIPositionViewController.h"
#import "WMEditPOITypeViewController.h"
#import "Node.h"
#import "NodeType.h"
#import "WMCategory.h"
#import "WMAcceptTermsViewController.h"
#import "WMIPadRootViewController.h"
#import "WMPOIsListViewController.h"
#import "WMPOIIPadNavigationController.h"
#import "WMAcceptTermsViewController.h"
#import "WMCreditsViewController.h"
#import "WMOSMLogoutViewController.h"
#import "WMToolbar_iPad.h"

#import "WMOSMDescriptionViewController.h"

@implementation WMNavigationControllerBase
{
    NSArray *nodes;
    WMDataManager *dataManager;
    
    WMPOIStateFilterPopoverView *		wheelchairStateFilterPopoverView;
	WMPOIStateFilterPopoverView *		toiletStateFilterPopoverView;
    WMCategoryFilterPopoverView *		categoryFilterPopoverView;
    
    WMPOIsListViewController* listViewController;
    
    UIView* loadingWheelContainer;  // this view will show loading whell on the center and cover child view controllers so that we avoid interactions interuptting data loading
    UIActivityIndicatorView* loadingWheel;
    
    BOOL fetchNodesAlertShowing;
    
    BOOL contributePressed;
    
    BOOL mapViewWasMoved;
    
    NSString *lastQuery;
    
    BOOL refreshing;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;

	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    
    // preload map to avoid long loading times on toggle
    if (UIDevice.currentDevice.isIPad == NO) {
        self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WMMapViewController"];
        self.mapViewController.baseController = self;
        CLLocation* newLocation = self.locationManager.location ?: [[CLLocation alloc] initWithLatitude:K_DEFAULT_LATITUDE longitude:K_DEFAULT_LONGITUDE];
        [self.mapViewController relocateMapTo:newLocation.coordinate andSpan:MKCoordinateSpanMake(0.005, 0.005)];
		[self updateNodesWithRegion:self.mapViewController.region];
    }
    
    dataManager = [[WMDataManager alloc] init];
    dataManager.delegate = self;
    
    if ([self.topViewController isKindOfClass:[WMIPadRootViewController class]]) {
        WMIPadRootViewController* vc = (WMIPadRootViewController*)self.topViewController;
        vc.controllerBase = self;
    }

	// Set Berlin as default / initial location before receiving the first GPS data
    self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.distanceFilter = 10.0f;
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if (IS_OS_8_OR_LATER)
    {
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];

    self.lastVisibleMapCenterLat = nil;
    self.lastVisibleMapCenterLng = nil;
    self.lastVisibleMapSpanLat = nil;
    self.lastVisibleMapSpanLng = nil;
    
    // configure initial vc from storyboard. this is necessary for iPad, since iPad's topVC is not the Dashboard!
    if ([self.topViewController conformsToProtocol:@protocol(WMPOIsListViewDelegate)]) {
        id<WMPOIsListViewDelegate> initialNodeListView = (id<WMPOIsListViewDelegate>)self.topViewController;
        initialNodeListView.dataSource = self;
        initialNodeListView.delegate = self;
    }
    
    self.wheelchairStateFilterStatus = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], K_STATE_YES,
										[NSNumber numberWithBool:YES], K_STATE_LIMITED,
										[NSNumber numberWithBool:YES], K_STATE_NO,
										[NSNumber numberWithBool:YES], K_STATE_UNKNOWN,nil];
	self.toiletStateFilterStatus = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], K_STATE_YES,
									[NSNumber numberWithBool:NO], K_STATE_LIMITED,
									[NSNumber numberWithBool:YES], K_STATE_NO,
									[NSNumber numberWithBool:YES], K_STATE_UNKNOWN,nil];
	self.categoryFilterStatus = [[NSMutableDictionary alloc] init];
    for (WMCategory* c in dataManager.categories) {
        [self.categoryFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:c.id];
    }
    
    
    loadingWheelContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    loadingWheelContainer.backgroundColor = [UIColor clearColor];
    loadingWheel = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    loadingWheel.backgroundColor = [UIColor blackColor];
    loadingWheel.layer.cornerRadius = 5.0;
    loadingWheel.layer.masksToBounds = YES;
    loadingWheel.center = loadingWheelContainer.center;
    loadingWheelContainer.hidden = YES;
    
    WMLabel *loadingLabel = [[WMLabel alloc] initWithFrame:CGRectMake(100, 100, 220, 150)];
    loadingLabel.numberOfLines = 0;
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.center = loadingWheelContainer.center;
    loadingLabel.backgroundColor = [UIColor blackColor];
    loadingLabel.layer.cornerRadius = 10.0f;
    loadingLabel.layer.masksToBounds = YES;
    [loadingLabel setText:NSLocalizedString(@"LoadingWheelText", nil)];
    
    CGSize maximumLabelSize = CGSizeMake(loadingLabel.frame.size.width, FLT_MAX);
    
    CGSize expectedLabelSize = [loadingLabel.text boundingRectWithSize:maximumLabelSize
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:@{NSFontAttributeName:loadingLabel.font}
                                                                     context:nil].size;
//                                sizeWithFont:loadingLabel.font constrainedToSize:maximumLabelSize lineBreakMode:loadingLabel.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = loadingLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    loadingLabel.frame = newFrame;
    
    loadingLabel.frame = CGRectMake(loadingLabel.frame.origin.x, loadingWheel.frame.origin.y + loadingWheel.frame.size.height + 10.0f, loadingLabel.frame.size.width, loadingLabel.frame.size.height);
    
    [loadingWheelContainer addSubview:loadingLabel];
    
    [loadingWheelContainer addSubview:loadingWheel];
    [self.view addSubview:loadingWheelContainer];
    
    // set custom nagivation and tool bars
    self.navigationBar.frame = CGRectMake(0, self.navigationBar.frame.origin.y, self.view.frame.size.width, K_NAVIGATION_BAR_HEIGHT);
    
    if (UIDevice.currentDevice.isIPad == YES) {
        self.customNavigationBar = [[WMIPadMapNavigationBar alloc] initFromNibWithFrame:CGRectMake(0, 0, self.navigationBar.frame.size.width, K_NAVIGATION_BAR_HEIGHT)];
        self.customNavigationBar.searchBarEnabled = YES;
    } else {
        self.customNavigationBar = [[WMNavigationBar alloc] initFromNibWithFrame:CGRectMake(0, 0, self.navigationBar.frame.size.width, K_NAVIGATION_BAR_HEIGHT)];
    }
    self.customNavigationBar.delegate = self;
    [self.navigationBar addSubview:self.customNavigationBar];
    self.toolbar.frame = CGRectMake(0, self.view.bounds.size.height-K_TOOLBAR_BAR_HEIGHT, self.view.frame.size.width, K_TOOLBAR_BAR_HEIGHT);
    self.toolbar.backgroundColor = [UIColor whiteColor];
    
    if (UIDevice.currentDevice.isIPad == YES) {
        self.customToolBar = [[WMToolbar_iPad alloc] initFromNibWithFrame:CGRectMake(0, 0, self.toolbar.frame.size.width, K_TOOLBAR_BAR_HEIGHT)];
    } else {
        self.customToolBar = [[WMToolbar alloc] initFromNibWithFrame:CGRectMake(0, self.toolbar.frame.size.height-K_TOOLBAR_BAR_HEIGHT, self.toolbar.frame.size.width, K_TOOLBAR_BAR_HEIGHT)];
    }
    self.customToolBar.delegate = self;
    [self.toolbar addSubview:self.customToolBar];
    
    // set filter popovers.
	[self createPopoverViews];
    
    if (UIDevice.currentDevice.isIPad == YES) {
        if ([self.customToolBar isKindOfClass:[WMToolbar_iPad class]]) {
            [(WMToolbar_iPad *)self.customToolBar updateLoginButton];
        }
        
        self.customNavigationBar.title = NSLocalizedString(@"Places.Nearby.Navigation.Title", nil);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor colorFromHexString:@"304152"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // this will update screen
    [self networkStatusChanged:nil];
    
    if (UIDevice.currentDevice.isIPad == YES) {
        [self refreshPopoverPositions:[[UIApplication sharedApplication] statusBarOrientation]];
    }
    
}

- (void)pushList {
    if (listViewController == nil) {
        listViewController = [UIStoryboard instantiatedPOIsListViewController];
    }
    listViewController.useCase = kWMPOIsListViewControllerUseCaseNormal;
	listViewController.navigationBarTitle = NSLocalizedString(@"Places.Nearby.Navigation.Title", nil);
	[self pushViewController:listViewController animated:YES];
}

- (void)pushMap {
    
    if (listViewController == nil) {
        listViewController = [UIStoryboard instantiatedPOIsListViewController];
    }
    if (self.mapViewController == nil) {
        self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WMMapViewController"];
        self.mapViewController.baseController = self;
    }
    [self pushViewController:self.mapViewController animated:YES];
}

- (void)setMapControllerToContribute {
    self.mapViewController.useCase = kWMPOIsListViewControllerUseCaseContribute;
}

- (void)setMapControllerToNormal {
    self.mapViewController.useCase = kWMPOIsListViewControllerUseCaseNormal;
	self.mapViewController.navigationBarTitle = NSLocalizedString(@"Places.Nearby.Navigation.Title", nil);
	[self.customToolBar showAllButtons];
}

- (void)setListViewControllerToNormal {
	listViewController.useCase = kWMPOIsListViewControllerUseCaseNormal;
	listViewController.navigationBarTitle = NSLocalizedString(@"Places.Nearby.Navigation.Title", nil);
	[self.customToolBar showAllButtons];
}

- (void)resetMapAndListToNormalUseCase {
    self.mapViewController.useCase = kWMPOIsListViewControllerUseCaseNormal;
    listViewController.useCase = kWMPOIsListViewControllerUseCaseNormal;
    [self clearCategoryFilterStatus];
    
    [categoryFilterPopoverView removeFromSuperview];
    categoryFilterPopoverView = [[WMCategoryFilterPopoverView alloc] initWithRefPoint:CGPointMake(self.customToolBar.middlePointOfCategoryFilterButton, self.toolbar.frame.origin.y) andCategories:dataManager.categories];
    categoryFilterPopoverView.delegate = self;
    categoryFilterPopoverView.hidden = YES;
    [self.view addSubview:categoryFilterPopoverView];
    
    [self.customToolBar deselectCategoryButton];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UIDevice.currentDevice.isIPad == YES) {
        return YES;
    }
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        return YES;
    else
        return NO;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self refreshPopoverPositions:toInterfaceOrientation];
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Data Manager Delegate

- (void) dataManager:(WMDataManager *)dataManager didReceiveNodes:(NSArray *)nodesParam
{
    nodes = [nodes arrayByAddingObjectsFromArray:nodesParam];
    
    if ([self.topViewController conformsToProtocol:@protocol(WMPOIsListViewDelegate)]) {
        [(id<WMPOIsListViewDelegate>)self.topViewController nodeListDidChange];
    }
}

- (void) refreshNodeListFromCreateNode
{
    if ([self.topViewController conformsToProtocol:@protocol(WMPOIsListViewDelegate)]) {
        [(id<WMPOIsListViewDelegate>)self.topViewController nodeListDidChange];
    }
}

- (void)resetNodesList {
	nodes = @[];
	[self refreshNodeList];
}

- (void) refreshNodeList {
    if ([self.topViewController conformsToProtocol:@protocol(WMPOIsListViewDelegate)]) {
        [(id<WMPOIsListViewDelegate>)self.topViewController nodeListDidChange];
    }
}

- (void) refreshNodeListWithArray:(NSArray*)array
{
    nodes = array;
    for (UIViewController* vc in self.viewControllers) {
        if ([vc conformsToProtocol:@protocol(WMPOIsListViewDelegate)]) {
            [(id<WMPOIsListViewDelegate>)self.topViewController nodeListDidChange];
        }
    }
}

-(void)dataManager:(WMDataManager *)dataManager fetchNodesFailedWithError:(NSError *)error
{
    if (!fetchNodesAlertShowing) {
        fetchNodesAlertShowing = YES;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"FetchNodesFails", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
    
    [self refreshNodeList];
}

- (void)dataManagerDidFinishSyncingResources:(WMDataManager *)aDataManager
{
    if ([self.topViewController isKindOfClass:[WMDashboardViewController class]]) {
        WMDashboardViewController* vc = (WMDashboardViewController*)self.topViewController;
        [vc showUIObjectsAnimated:YES];
    }
    
    [categoryFilterPopoverView refreshViewWithCategories:aDataManager.categories];
    [self.categoryFilterStatus removeAllObjects];
    for (WMCategory* c in dataManager.categories) {
        [self.categoryFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:c.id];
    }
    
    [self updateNodesWithCurrentUserLocation];
}

-(void)dataManager:(WMDataManager *)dataManager didFinishSyncingResourcesWithErrors:(NSArray *)errors
{
    if (!fetchNodesAlertShowing) {
        fetchNodesAlertShowing = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"FetchNodesFails", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
    
    if ([self.topViewController isKindOfClass:[WMDashboardViewController class]]) {
        WMDashboardViewController* vc = (WMDashboardViewController*)self.topViewController;
        [vc showUIObjectsAnimated:YES];
    }
    
    [self updateNodesWithCurrentUserLocation];
}

-(void)dataManagerDidStartOperation:(WMDataManager *)dataManager
{
    if ([self.topViewController isKindOfClass:[WMPOIsListViewController class]])
        [self showLoadingWheel];
    
    if ([self.topViewController respondsToSelector:@selector(showActivityIndicator)]) {
        [(id<WMPOIsListViewDelegate>)self.topViewController showActivityIndicator];
    }
    
    if ([self.topViewController isKindOfClass:[WMIPadRootViewController class]]) {
        [((WMIPadRootViewController *)self.topViewController).mapViewController showActivityIndicator];
    }
    
}

-(void)dataManagerDidStopAllOperations:(WMDataManager *)dataManager
{
    if ([self.topViewController isKindOfClass:[WMPOIsListViewController class]])
        [self hideLoadingWheel];
    
    if ([self.topViewController respondsToSelector:@selector(hideActivityIndicator)]) {
        [(id<WMPOIsListViewDelegate>)self.topViewController hideActivityIndicator];
    }
    
    if ([self.topViewController isKindOfClass:[WMIPadRootViewController class]]) {
        [((WMIPadRootViewController *)self.topViewController).mapViewController hideActivityIndicator];
    }
}

#pragma mark - Network Status Changes
-(void)networkStatusChanged:(NSNotification*)notice
{
    NetworkStatus networkStatus = [[dataManager internetReachble] currentReachabilityStatus];
    
    switch (networkStatus)
    {
        case NotReachable:
            [self.customToolBar hideButton:kWMToolbarButtonSearch];
            
            break;
            
        default:
            [self.customToolBar showButton:kWMToolbarButtonSearch];
            
            break;
    }
}

#pragma mark - category data source
-(NSArray*) categories
{
    return dataManager.categories;
}

#pragma mark - Node List Data Source

- (NSArray*) nodeList
{
    return nodes;
}

- (NSArray*)filteredNodeListForUseCase:(WMPOIsListViewControllerUseCase)useCase {
    // filter nodes here
    NSMutableArray* newNodeList = [[NSMutableArray alloc] init];

    NSArray *nodesCopy = [NSArray arrayWithArray:nodes];
    
    for (Node* node in nodesCopy) {
        NSNumber* categoryID = node.node_type.category.id;
        if (((useCase == kWMPOIsListViewControllerUseCaseContribute && ([node.wheelchair isEqualToString:K_STATE_UNKNOWN] == YES || [node.wheelchair_toilet isEqualToString:K_STATE_UNKNOWN] == YES)) //Is contribute mode and unknown wheelchair or toilet state?
			|| ([[self.wheelchairStateFilterStatus objectForKey:node.wheelchair] boolValue] == YES
				&& [[self.toiletStateFilterStatus objectForKey:node.wheelchair_toilet] boolValue] == YES)) // Are the wheelchair and toilet states filter selected?
			&& [[self.categoryFilterStatus objectForKey:categoryID] boolValue] == YES) { // Is the category filter selected?
				if (![newNodeList containsObject:node]) {
					[newNodeList addObject:node];
				}
        }
    }
    
    return newNodeList;
}

#pragma mark - Node Update

- (void)updateNodesWithCurrentUserLocation {
	CLLocation* newLocation = self.currentLocation;
	if (UIDevice.currentDevice.isIPad == YES) {
		if ([self.topViewController isKindOfClass:WMIPadRootViewController.class]) {
			[(WMIPadRootViewController *)self.topViewController gotNewUserLocation:newLocation];
		}
	}

	MKCoordinateSpan span = MKCoordinateSpanMake(0.003, 0.003);

	if ([self.topViewController isKindOfClass:[WMMapViewController class]]) {
		WMMapViewController* currentVC = (WMMapViewController*)self.topViewController;
		[currentVC relocateMapTo:newLocation.coordinate andSpan:span];   // this will automatically update node list!
	} else if ([self.topViewController isKindOfClass:[WMPOIsListViewController class]]) {
		WMPOIsListViewController *currentVC = (WMPOIsListViewController*)self.topViewController;
		if (currentVC.useCase == kWMPOIsListViewControllerUseCaseSearchOnDemand || (currentVC.useCase == kWMPOIsListViewControllerUseCaseGlobalSearch)) {
			[self updateNodesWithQuery:lastQuery andRegion:self.mapViewController.region];
		} else {
			[self updateNodesWithRegion:MKCoordinateRegionMake(newLocation.coordinate, span)];
		}
	} else {
		[self updateNodesWithRegion:MKCoordinateRegionMake(newLocation.coordinate, span)];
	}

	self.lastVisibleMapCenterLat = [NSNumber numberWithDouble:newLocation.coordinate.latitude];
	self.lastVisibleMapCenterLng = [NSNumber numberWithDouble:newLocation.coordinate.longitude];
	self.lastVisibleMapSpanLat = @(span.latitudeDelta);
	self.lastVisibleMapSpanLng = @(span.longitudeDelta);
}

- (void)updateNodesWithRegion:(MKCoordinateRegion)region {
	[self updateNodesWithQuery:nil andRegion:region];
}

- (void)updateNodesWithSouthWest:(CLLocationCoordinate2D)southWest andNorthEast:(CLLocationCoordinate2D)northEast {
	// we do not show here the loading wheel since this methods is always called by map view controller, and the vc has its own loading wheel,
    // which allows user interaction while loading nodes.
    // [self showLoadingWheel];

	[dataManager fetchNodesForSouthWestCoordinate:southWest northEastCoordinate:northEast query:nil];
	[self resetNodesList];
}

- (void)updateNodesWithQuery:(NSString*)query {
    self->lastQuery = query;
    [dataManager fetchNodesWithQuery:query];
	[self resetNodesList];
}

- (void)updateNodesWithQuery:(NSString*)query andRegion:(MKCoordinateRegion)region {
	CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(region.center.latitude-region.span.latitudeDelta/2.0f, region.center.longitude-region.span.longitudeDelta/2.0f);
	CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(region.center.latitude+region.span.latitudeDelta/2.0f, region.center.longitude+region.span.longitudeDelta/2.0f);

	self->lastQuery = query;
	[dataManager fetchNodesForSouthWestCoordinate:southWest northEastCoordinate:northEast query:query];
	[self resetNodesList];
}

- (void)updateNodesWithQuery:(NSString*)query andSouthWest:(CLLocationCoordinate2D)southWest andNorthEast:(CLLocationCoordinate2D)northEast {
    self->lastQuery = query;
	[dataManager fetchNodesForSouthWestCoordinate:southWest northEastCoordinate:northEast query:query];
	[self resetNodesList];
}

- (void)updateNodesWithLastQueryAndRegion:(MKCoordinateRegion)region {
	[self updateNodesWithQuery:lastQuery andRegion:region];
}

- (void)updateNodesWithLastQueryAndSouthWest:(CLLocationCoordinate2D)southWest andNorthEast:(CLLocationCoordinate2D)northEast {
	[dataManager fetchNodesForSouthWestCoordinate:southWest northEastCoordinate:northEast query:lastQuery];
	[self resetNodesList];
}

#pragma mark - Node List Delegate

/**
 * Called only on the iPhone
 */
- (void)nodeListView:(id<WMPOIsListViewDelegate>)nodeListView didSelectNode:(Node *)node
{
    
    if (UIDevice.currentDevice.isIPad == YES) {
        if ([self.topViewController isKindOfClass:[WMIPadRootViewController class]]) {
            [(WMIPadRootViewController *)self.topViewController nodeListView:nodeListView didSelectNode:node];
        }
        return;
    }
    
    // we don"t want to push a detail view when selecting a node on the map view, so
    // we check if this message comes from a table view
    if (node && [nodeListView isKindOfClass:[WMPOIsListViewController class]]) {
        [self pushDetailsViewControllerForNode:node];
    }
}

/**
 * Called only on the iPhone
 */
- (void) nodeListView:(id<WMPOIsListViewDelegate>)nodeListView didSelectDetailsForNode:(Node *)node
{
    
    if (UIDevice.currentDevice.isIPad == YES) {
        if ([self.topViewController isKindOfClass:[WMIPadRootViewController class]]) {
            [(WMIPadRootViewController *)self.topViewController nodeListView:nodeListView didSelectDetailsForNode:node];
        }
        return;
    }
    
    if (node) {
        [self pushDetailsViewControllerForNode:node];
    }
}

- (void) pushDetailsViewControllerForNode:(Node*)node
{
    WMPOIViewController *detailViewController = [UIStoryboard instantiatedDetailViewController];
    detailViewController.baseController = self;
    detailViewController.node = node;
    [self pushViewController:detailViewController animated:YES];
}

#pragma mark - Location Manager Delegate

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	if ((locations != nil) && (locations.count > 0)) {
		self.currentLocation = locations.firstObject;
	}
}

-(void)updateUserLocation {
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

#pragma mark - Location Helper

-(CLLocation *)currentLocation {
	if (_currentLocation == nil) {
		_currentLocation = [[CLLocation alloc] initWithLatitude:K_DEFAULT_LATITUDE longitude:K_DEFAULT_LONGITUDE];
	}

	return _currentLocation;
}

- (void)mapWasMoved {
    mapViewWasMoved = YES;
}

#pragma mark - Application Notifications

- (void) applicationDidBecomeActive:(NSNotification*)notification
{
    if (self.locationManager) {
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
    
    // start sync if last sync happened over an hour ago
    static NSDate *lastSyncDate;
    if (!lastSyncDate || [lastSyncDate timeIntervalSinceNow] < -3600) {
        [dataManager syncResources];
    }
    lastSyncDate = [NSDate date];
    
}

-(void)applicationDidEnterBackground:(NSNotification*)notification
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)applicationWillResignActive:(NSNotification*)notification
{
    
}

#pragma mark - Push/Pop ViewControllers
- (void)pushFadeViewController:(UIViewController*)vc
{
    
    WMViewController* lastVC = [self.viewControllers lastObject];
    
    [UIView transitionFromView:lastVC.view
                        toView:vc.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:nil];
    
    [self pushViewController:vc animated:NO];
    
    
}

-(void)popFadeViewController
{
    
    
    
    WMViewController* fromVC = [self.viewControllers lastObject];
    WMViewController* toVC = [self.viewControllers objectAtIndex:self.viewControllers.count-2];
    
    [UIView transitionFromView:fromVC.view
                        toView:toVC.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:nil];
    
    [self popViewControllerAnimated:NO];
    
    
}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    if ([viewController conformsToProtocol:@protocol(WMPOIsListViewDelegate)]) {
        id<WMPOIsListViewDelegate> nodeListViewController = (id<WMPOIsListViewDelegate>)viewController;
        nodeListViewController.dataSource = self;
        nodeListViewController.delegate = self;
    }
    
    [super pushViewController:viewController animated:animated];
    [self changeScreenStatusFor:viewController];
}
-(UIViewController*)popViewControllerAnimated:(BOOL)animated
{
    UIViewController* lastViewController = [super popViewControllerAnimated:animated];
    [self changeScreenStatusFor:[self.viewControllers lastObject]];
    
    return lastViewController;
}

-(NSArray*)popToRootViewControllerAnimated:(BOOL)animated
{
    NSArray* lastViewControllers = [super popToRootViewControllerAnimated:animated];
    [self changeScreenStatusFor:[self.viewControllers lastObject]];
    return lastViewControllers;
}

-(NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    NSArray* lastViewControllers = [super popToViewController:viewController animated:animated];
    [self changeScreenStatusFor:[self.viewControllers lastObject]];
    
    return lastViewControllers;
}

-(void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    [super setViewControllers:viewControllers animated:animated];
    [self changeScreenStatusFor:[viewControllers lastObject]];
}

-(void)changeScreenStatusFor:(UIViewController*)vc
{
    // screen transition. we
    [self hideLoadingWheel];
    
    // if the current navigation stack size is 2,then we always show DashboardButton on the left
    WMNavigationBarLeftButtonStyle leftButtonStyle = 0;
    WMNavigationBarRightButtonStyle rightButtonStyle = 0;
    
    if (self.viewControllers.count == 2) {
        leftButtonStyle = kWMNavigationBarLeftButtonStyleDashboardButton;
    } else {
        // otherwise, default left button is BackButton. This will be changed according to the current screen later
        leftButtonStyle = kWMNavigationBarLeftButtonStyleBackButton;
    }
    
    // special left buttons and right button should be set according to the current screen
    
    if ([vc isKindOfClass:[WMMapViewController class]]) {
        self.customToolBar.mapListToggleButton.selected = YES;
        if (self.viewControllers.count == 3) {
            leftButtonStyle = kWMNavigationBarLeftButtonStyleDashboardButton;   // single exception. this is the first level!
        }
        rightButtonStyle = kWMNavigationBarRightButtonStyleCreatePOIButton;
    } else if ([vc isKindOfClass:[WMPOIsListViewController class]]) {
        WMPOIsListViewController* nodeListVC = (WMPOIsListViewController*)vc;
        rightButtonStyle = kWMNavigationBarRightButtonStyleCreatePOIButton;
        self.customToolBar.mapListToggleButton.selected = NO;
        switch (nodeListVC.useCase) {
            case kWMPOIsListViewControllerUseCaseNormal:
                nodeListVC.navigationBarTitle = NSLocalizedString(@"Places.Nearby.Navigation.Title", nil);
                [self.customToolBar showAllButtons];
                break;
            case kWMPOIsListViewControllerUseCaseContribute:
                nodeListVC.navigationBarTitle = NSLocalizedString(@"TitleHelp", nil);
                [self.customToolBar hideButton:kWMToolbarButtonWheelchairStateFilter];
				[self.customToolBar hideButton:kWMToolbarButtonToiletStateFilter];
                rightButtonStyle = kWMNavigationBarRightButtonStyleNone;
                break;
            case kWMPOIsListViewControllerUseCaseCategory:
                [self.customToolBar showButton:kWMToolbarButtonWheelchairStateFilter];
				[self.customToolBar showButton:kWMToolbarButtonToiletStateFilter];
                [self.customToolBar hideButton:kWMToolbarButtonCategoryFilter];
                break;
            case kWMPOIsListViewControllerUseCaseGlobalSearch:
            case kWMPOIsListViewControllerUseCaseSearchOnDemand:
                nodeListVC.navigationBarTitle = NSLocalizedString(@"SearchResult", nil);
                rightButtonStyle = kWMNavigationBarRightButtonStyleNone;
            default:
                break;
        }
        
    } else if ([vc isKindOfClass:[WMPOIViewController class]]) {
        rightButtonStyle = kWMNavigationBarRightButtonStyleEditButton;
		[self hidePopoverViews];
    } else if ([vc isKindOfClass:[WMEditPOIStateViewController class]]) {
        WMEditPOIStateViewController* wheelchairStatusVC = (WMEditPOIStateViewController*)vc;
        if (wheelchairStatusVC.useCase == WMEditPOIStateUseCasePOICreation) {
            rightButtonStyle = kWMNavigationBarRightButtonStyleNone;
            leftButtonStyle = kWMNavigationBarLeftButtonStyleBackButton;
        } else {
            rightButtonStyle = kWMNavigationBarRightButtonStyleSaveButton;
            leftButtonStyle = kWMNavigationBarLeftButtonStyleCancelButton;
        }
		[self hidePopoverViews];
    } else if ([vc isKindOfClass:[WMEditPOIViewController class]] ||
               [vc isKindOfClass:[WMEditPOICommentViewController class]]) {
        rightButtonStyle = kWMNavigationBarRightButtonStyleSaveButton;
        leftButtonStyle = kWMNavigationBarLeftButtonStyleCancelButton;
		[self hidePopoverViews];
    }  else if ([vc isKindOfClass:[WMShareSocialViewController class]]) {
        rightButtonStyle = kWMNavigationBarRightButtonStyleNone;
        leftButtonStyle = kWMNavigationBarLeftButtonStyleCancelButton;
		[self hidePopoverViews];
    } else if ([vc isKindOfClass:[WMCategoriesListViewController class]] ||
               [vc isKindOfClass:[WMEditPOIPositionViewController class]] ||
               [vc isKindOfClass:[WMEditPOITypeViewController class]]) {
        rightButtonStyle = kWMNavigationBarRightButtonStyleNone;
    }
    
    self.customNavigationBar.leftButtonStyle = leftButtonStyle;
    self.customNavigationBar.rightButtonStyle = rightButtonStyle;
    if ([vc respondsToSelector:@selector(navigationBarTitle)]) {
        self.customNavigationBar.title = [vc performSelector:@selector(navigationBarTitle)];
    }
    
    // change ui status for the network status
    [self networkStatusChanged:nil];
}

- (void)showAcceptTermsViewController {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    WMAcceptTermsViewController *termsViewController = [UIStoryboard instantiatedAcceptTermsViewController];
    termsViewController.popoverButtonFrame = CGRectMake(self.view.frame.size.width/2, 400.0f, 5.0f, 5.0f);
    
    [self presentViewController:termsViewController animated:YES];
}

#pragma mark - WMNavigationBar Delegate
- (void)pressedDashboardButton:(WMNavigationBar *)navigationBar {
    [self.customToolBar deselectSearchButton];
    [self popToRootViewControllerAnimated:YES];
	[self hidePopoverViews];
}

- (void)pressedBackButton:(WMNavigationBar *)navigationBar {
    if ([self.topViewController isKindOfClass:[WMMapViewController class]]) {
        // we should pop twice due to the node list view controller!
        WMViewController* targetVC = [self.viewControllers objectAtIndex:self.viewControllers.count-3];
        [self popToViewController:targetVC animated:YES];
    } else {
        [self popViewControllerAnimated:YES];
    }
	[self hidePopoverViews];
}

- (void)pressedCancelButton:(WMNavigationBar *)navigationBar {

    [self popViewControllerAnimated:YES];
    
}

- (void)pressedCreatePOIButton:(WMNavigationBar *)navigationBar {
    contributePressed = YES;
    
    if (![dataManager userIsAuthenticated]) {
        if ([self.customToolBar isKindOfClass:[WMToolbar_iPad class]]) {
            
			[self presentLoginScreen];
            return;
        } else {
            [self presentLoginScreenWithButtonFrame:CGRectZero];
            return;
        }
    }
    
    contributePressed = NO;

	WMEditPOIViewController *editPOIViewController = [UIStoryboard instantiatedEditPOIViewController];
    if (mapViewWasMoved) {
        
        if (UIDevice.currentDevice.isIPad == YES) {
            if ([self.topViewController isKindOfClass:[WMIPadRootViewController class]]) {
                editPOIViewController.initialCoordinate = ((WMIPadRootViewController *)self.topViewController).mapViewController.region.center;
            }
        } else {
            editPOIViewController.initialCoordinate = self.mapViewController.region.center;
        }
    } else {
        editPOIViewController.initialCoordinate = self.currentLocation.coordinate;
    }
    editPOIViewController.title = editPOIViewController.navigationBarTitle = self.title = NSLocalizedString(@"EditPOIViewHeadline", @"");
    if (UIDevice.currentDevice.isIPad == YES) {
        
        WMPOIIPadNavigationController *detailNavController = [[WMPOIIPadNavigationController alloc] initWithRootViewController:editPOIViewController];
        detailNavController.customNavigationBar.title = editPOIViewController.navigationBarTitle;
        
        editPOIViewController.isRootViewController = YES;
        editPOIViewController.popoverButtonFrame = CGRectMake(self.customNavigationBar.addButton.frame.origin.x + 20.0f, self.customNavigationBar.addButton.frame.origin.y + 20.0f, self.customNavigationBar.addButton.frame.size.width, self.customNavigationBar.addButton.frame.size.height);
        
        editPOIViewController.popover = [[WMPopoverController alloc] initWithContentViewController:detailNavController];
        editPOIViewController.baseController = self;
        
        [editPOIViewController.popover presentPopoverFromRect:editPOIViewController.popoverButtonFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        [self pushViewController:editPOIViewController animated:YES];
    }
}

- (void)pressedEditButton:(WMNavigationBar *)navigationBar {
    WMViewController* currentViewController = [self.viewControllers lastObject];
    if ([currentViewController isKindOfClass:[WMPOIViewController class]]) {
        [(WMPOIViewController*)currentViewController pushEditViewController];
    }
}

- (void)pressedSaveButton:(WMNavigationBar *)navigationBar {
    WMViewController* currentViewController = [self.viewControllers lastObject];
    if ([currentViewController isKindOfClass:[WMEditPOIStateViewController class]]) {
        [(WMEditPOIStateViewController*)currentViewController saveCurrentState];
    }
    if ([currentViewController isKindOfClass:[WMEditPOIViewController class]]) {
        [(WMEditPOIViewController*)currentViewController saveEditedData];
    }
    if ([currentViewController isKindOfClass:[WMEditPOICommentViewController class]]) {
        [(WMEditPOICommentViewController*)currentViewController saveEditedData];
    }
}

- (void)pressedSearchCancelButton:(WMNavigationBar *)navigationBar {

	if ((UIDevice.currentDevice.isIPad == YES) && ([self.topViewController isKindOfClass:[WMIPadRootViewController class]] == YES)) {
		WMIPadRootViewController* currentVC = (WMIPadRootViewController*)self.topViewController;
		[currentVC pressedSearchButton:NO];

		[self searchStringIsGiven:[self.customNavigationBar getSearchString]];
	}

	if ([self.topViewController isKindOfClass:[WMPOIsListViewController class]] == YES) {
		WMPOIsListViewController* currentVC = (WMPOIsListViewController*)self.topViewController;
		currentVC.useCase = kWMPOIsListViewControllerUseCaseNormal;
		currentVC.navigationBarTitle = NSLocalizedString(@"Places.Nearby.Navigation.Title", nil);
		self.customNavigationBar.title = currentVC.navigationBarTitle;
	} else if ([self.topViewController isKindOfClass:[WMMapViewController class]] == YES) {
		WMMapViewController* currentVC = (WMMapViewController*)self.topViewController;
		WMPOIsListViewController* nodeListVC = (WMPOIsListViewController*)[self.viewControllers objectAtIndex: (self.viewControllers.count - NODE_INDEX_GAP)];
		if ([nodeListVC isKindOfClass:[WMPOIsListViewController class]]) {
			nodeListVC.useCase = kWMPOIsListViewControllerUseCaseNormal;
			nodeListVC.navigationBarTitle = NSLocalizedString(@"Places.Nearby.Navigation.Title", nil);
		}

		currentVC.useCase = kWMPOIsListViewControllerUseCaseNormal;
		currentVC.navigationBarTitle = NSLocalizedString(@"Places.Nearby.Navigation.Title", nil);
		self.customNavigationBar.title = currentVC.navigationBarTitle;
	}

	if (self.lastVisibleMapCenterLat) {
		[self updateNodesWithRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake([self.lastVisibleMapCenterLat doubleValue], [self.lastVisibleMapCenterLng doubleValue]), MKCoordinateSpanMake([self.lastVisibleMapSpanLat doubleValue], [self.lastVisibleMapSpanLng doubleValue]))];
	} else {
		[self updateNodesWithRegion:MKCoordinateRegionMake(self.currentLocation.coordinate, MKCoordinateSpanMake(DEFAULT_SEARCH_SPAN_LAT, DEFAULT_SEARCH_SPAN_LONG))];
	}

    [self.customToolBar deselectSearchButton];
}

- (void)searchStringIsGiven:(NSString *)query {
    if (![dataManager isInternetConnectionAvailable]) {
        if (!fetchNodesAlertShowing) {
            fetchNodesAlertShowing = YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"FetchNodesFails", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
            
            [alert show];
        }
        [self.customToolBar deselectSearchButton];
        return;
    }
    
    if (UIDevice.currentDevice.isIPad == YES && [self.customToolBar isKindOfClass:WMToolbar_iPad.class]) {
        ((WMToolbar_iPad *)self.customToolBar).contributeButton.selected = NO;
    }
    
    if ([self.topViewController isKindOfClass:[WMIPadRootViewController class]]) {
        WMIPadRootViewController* vc = (WMIPadRootViewController*)self.topViewController;
        vc.listViewController.useCase = kWMPOIsListViewControllerUseCaseSearchOnDemand;
        vc.mapViewController.useCase = kWMPOIsListViewControllerUseCaseSearchOnDemand;
        [self updateNodesWithQuery:query andRegion:vc.mapViewController.region];
        
    } else if ([self.topViewController isKindOfClass:[WMPOIsListViewController class]]) {
        WMPOIsListViewController* vc = (WMPOIsListViewController*)self.topViewController;
        vc.useCase = kWMPOIsListViewControllerUseCaseSearchOnDemand;
        vc.navigationBarTitle = NSLocalizedString(@"SearchResult", nil);
        self.customNavigationBar.title = vc.navigationBarTitle;
        [self updateNodesWithQuery:query andRegion:self.mapViewController.region];
        
    } else if ([self.topViewController isKindOfClass:[WMMapViewController class]] == YES) {
        WMMapViewController* vc = (WMMapViewController*)self.topViewController;
        vc.useCase = kWMPOIsListViewControllerUseCaseSearchOnDemand;
        vc.navigationBarTitle = NSLocalizedString(@"SearchResult", nil);;
        self.customNavigationBar.title = vc.navigationBarTitle;

        [self updateNodesWithQuery:query andRegion:vc.region];
        
    }
    
    
}

#pragma mark - WMToolbar Delegate
- (void)pressedMapListToggleButton:(WMButton *)sender {
	[self hidePopoverViews];
    
    if ([self.topViewController isKindOfClass:[WMPOIsListViewController class]]) {
        //  the node list view is on the screen. push the map view controller
        
        WMViewController* currentVC = (WMViewController*)self.topViewController;
        self.mapViewController.navigationBarTitle = currentVC.navigationBarTitle;
		if ([currentVC respondsToSelector:@selector(useCase)]) {
            self.mapViewController.useCase = (WMPOIsListViewControllerUseCase)[currentVC performSelector:@selector(useCase)];
		}
		
		WMViewController* toVC = [self.viewControllers objectAtIndex:self.viewControllers.count-2];
		if ([toVC isKindOfClass:[WMMapViewController class]]) {
			// Map view controller is already there, we just have to pop fade
			((WMMapViewController*)toVC).useCase = ((WMPOIsListViewController*)self.topViewController).useCase;
			((WMMapViewController*)toVC).navigationBarTitle = ((WMPOIsListViewController*)self.topViewController).navigationBarTitle;
			[self popFadeViewController];
		} else {
			self.mapViewController.useCase = ((WMPOIsListViewController*)self.topViewController).useCase;
			self.mapViewController.navigationBarTitle = ((WMPOIsListViewController*)self.topViewController).navigationBarTitle;
			[self pushFadeViewController:self.mapViewController];
		}
		
    } else if ([self.topViewController isKindOfClass:[WMMapViewController class]] == YES) {
        //  the map view is on the screen. pop the map view controller
		WMViewController* toVC = [self.viewControllers objectAtIndex:self.viewControllers.count-2];
		if ([toVC isKindOfClass:[WMPOIsListViewController class]]) {
			((WMPOIsListViewController*)toVC).useCase = ((WMMapViewController*)self.topViewController).useCase;
			((WMPOIsListViewController*)toVC).navigationBarTitle = ((WMMapViewController*)self.topViewController).navigationBarTitle;
			[self popFadeViewController];
		} else {
			// List view controller is already there, we just have to pop fade
			listViewController.useCase = ((WMMapViewController*)self.topViewController).useCase;
			listViewController.navigationBarTitle = ((WMMapViewController*)self.topViewController).navigationBarTitle;
			[self pushFadeViewController:listViewController];
		}
    }
    
}

- (void)pressedCurrentLocationButton:(WMToolbar *)toolBar {
	[self hidePopoverViews];

    if ([CLLocationManager locationServicesEnabled] == NO) {
        return;
    }
    
    [self updateNodesWithCurrentUserLocation];
    
    [self.customToolBar deselectSearchButton];
    
    if ([self.topViewController isKindOfClass:[WMIPadRootViewController class]]) {
        WMIPadRootViewController* currentVC = (WMIPadRootViewController*)self.topViewController;
        if (currentVC.listViewController.useCase == kWMPOIsListViewControllerUseCaseCategory || currentVC.listViewController.useCase == kWMPOIsListViewControllerUseCaseContribute) {
            return;
        }
        currentVC.listViewController.useCase = kWMPOIsListViewControllerUseCaseNormal;
        currentVC.mapViewController.useCase = kWMPOIsListViewControllerUseCaseNormal;
    } else if ([self.topViewController isKindOfClass:[WMPOIsListViewController class]]) {
        WMPOIsListViewController* currentVC = (WMPOIsListViewController*)self.topViewController;
        if (currentVC.useCase == kWMPOIsListViewControllerUseCaseCategory || currentVC.useCase == kWMPOIsListViewControllerUseCaseContribute) {
            return;
        }
        currentVC.useCase = kWMPOIsListViewControllerUseCaseNormal;
        currentVC.navigationBarTitle = NSLocalizedString(@"Places.Nearby.Navigation.Title", nil);
        self.customNavigationBar.title = currentVC.navigationBarTitle;
    } else if ([self.topViewController isKindOfClass:[WMMapViewController class]] == YES) {
        WMMapViewController* currentVC = (WMMapViewController*)self.topViewController;
        if (currentVC.useCase == kWMPOIsListViewControllerUseCaseCategory || currentVC.useCase == kWMPOIsListViewControllerUseCaseContribute) {
            return;
        }
        currentVC.useCase = kWMPOIsListViewControllerUseCaseNormal;
        currentVC.navigationBarTitle = NSLocalizedString(@"Places.Nearby.Navigation.Title", nil);
        self.customNavigationBar.title = currentVC.navigationBarTitle;
	}
}

- (void)pressedSearchButton:(BOOL)selected {

	[self hidePopoverViews];
	[self.customNavigationBar showSearchBar];
}

- (void)pressedWheelchairStateFilterButton:(WMToolbar *)toolBar sourceView:(UIView *)view {
	[self hidePopoverViews];

    if (wheelchairStateFilterPopoverView.hidden) {
		wheelchairStateFilterPopoverView.stateType = wheelchairStateFilterPopoverView.stateType;

		if (view.isRightToLeftDirection == YES) {
			[wheelchairStateFilterPopoverView refreshPositionWithOrigin:CGPointMake(view.frameX, self.toolbar.frame.origin.y-K_TOOLBAR_BAR_HEIGHT-10)];
		} else {
			[wheelchairStateFilterPopoverView refreshPositionWithOrigin:CGPointMake(view.frameX+(view.frameWidth/2)-wheelchairStateFilterPopoverView.frameWidth+K_POI_STATUS_FILTER_POPOVER_MARKER_X_OFFSET, self.toolbar.frame.origin.y-K_TOOLBAR_BAR_HEIGHT-10)];
		}
        [self showPopover:wheelchairStateFilterPopoverView];
    } else {
        [self hidePopover:wheelchairStateFilterPopoverView];
    }
}

- (void)pressedToiletStateFilterButton:(WMToolbar *)toolBar sourceView:(UIView *)view {
	[self hidePopoverViews];

	if (toiletStateFilterPopoverView.hidden) {
		toiletStateFilterPopoverView.stateType = toiletStateFilterPopoverView.stateType;
		if (view.isRightToLeftDirection == YES) {
			[toiletStateFilterPopoverView refreshPositionWithOrigin:CGPointMake(view.frameX, self.toolbar.frame.origin.y-K_TOOLBAR_BAR_HEIGHT-10)];
		} else {
			[toiletStateFilterPopoverView refreshPositionWithOrigin:CGPointMake(view.frameX+(view.frameWidth/2)-toiletStateFilterPopoverView.frameWidth+K_POI_STATUS_FILTER_POPOVER_MARKER_X_OFFSET, self.toolbar.frame.origin.y-K_TOOLBAR_BAR_HEIGHT-10)];
		}
		[self showPopover:toiletStateFilterPopoverView];
	} else {
		[self hidePopover:toiletStateFilterPopoverView];
	}
}


- (void)pressedCategoryFilterButton:(WMToolbar *)toolBar sourceView:(UIView *)view {
	[self hidePopoverViews];
    
    if (categoryFilterPopoverView.hidden) {
		// Set the ref point. This right-to-left upport is implemented in the WMCategoryFilterPopoverView itself
		[categoryFilterPopoverView refreshViewWithRefPoint:CGPointMake(view.frameX+(view.frameWidth/2), self.toolbar.frame.origin.y) andCategories:dataManager.categories];
		[self showPopover:categoryFilterPopoverView];
    } else {
        [self hidePopover:categoryFilterPopoverView];
    }
}

- (void)pressedLoginButton:(WMToolbar*)toolBar {
    WMViewController* viewController;
    if (!dataManager.userIsAuthenticated) {
        viewController = [UIStoryboard instantiatedOSMOnboardingViewController];
    } else {
        viewController = [UIStoryboard instantiatedOSMLogoutViewController];
    }
    
    viewController.baseController = self;
    if ([toolBar isKindOfClass:[WMToolbar_iPad class]]) {
        
        CGRect buttonFrame = ((WMToolbar_iPad *)toolBar).loginButton.frame;
        CGFloat yPosition = 1024.0f - K_TOOLBAR_BAR_HEIGHT;
        
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            yPosition = 768.0f - K_TOOLBAR_BAR_HEIGHT;
        }
        
        viewController.popoverButtonFrame = CGRectMake(buttonFrame.origin.x, yPosition, buttonFrame.size.width, buttonFrame.size.height);
    }
    
    [self presentViewController:viewController animated:YES];
}

-(void)pressedCreditsButton:(WMToolbar*)toolBar {
    
    WMViewController* creditsViewController = [UIStoryboard instantiatedCreditsViewController];
    
    if ([toolBar isKindOfClass:[WMToolbar_iPad class]]) {
        
        CGRect buttonFrame = ((WMToolbar_iPad *)toolBar).creditsButton.frame;
        CGFloat yPosition = 1024.0f - K_TOOLBAR_BAR_HEIGHT;
        
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            yPosition = 768.0f - K_TOOLBAR_BAR_HEIGHT;
        }
        creditsViewController.popoverButtonFrame = CGRectMake(buttonFrame.origin.x, yPosition, buttonFrame.size.width, buttonFrame.size.height);
    }

	creditsViewController.lastKnownLocation = self.currentLocation;
    [self presentViewController:creditsViewController animated:YES];
}

- (void)pressedContributeButton:(WMToolbar*)toolBar {
    
    if ([self.topViewController isKindOfClass:[WMIPadRootViewController class]]) {
        if ([toolBar isKindOfClass:[WMToolbar_iPad class]]) {
            if (( (WMToolbar_iPad *)toolBar).contributeButton.selected == NO) {
                ((WMIPadRootViewController *)self.topViewController).listViewController.useCase = kWMPOIsListViewControllerUseCaseNormal;
                ((WMIPadRootViewController *)self.topViewController).mapViewController.useCase = kWMPOIsListViewControllerUseCaseNormal;
                [self pressedCurrentLocationButton:self.customToolBar];
            } else {
                ((WMIPadRootViewController *)self.topViewController).listViewController.useCase = kWMPOIsListViewControllerUseCaseContribute;
                ((WMIPadRootViewController *)self.topViewController).mapViewController.useCase = kWMPOIsListViewControllerUseCaseContribute;
                [self pressedCurrentLocationButton:self.customToolBar];
            }
        }
    }
}

#pragma mark - Popover Management

- (void)createPopoverViews {
	wheelchairStateFilterPopoverView = [[WMPOIStateFilterPopoverView alloc] initWithOrigin:
										CGPointMake(self.customToolBar.middlePointOfWheelchairStateFilterButton-wheelchairStateFilterPopoverView.frameWidth,
													CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.customToolBar.frame)*2-10)];
	wheelchairStateFilterPopoverView.stateType = WMPOIStateTypeWheelchair;
	wheelchairStateFilterPopoverView.hidden = YES;
	wheelchairStateFilterPopoverView.delegate = self;
	[wheelchairStateFilterPopoverView updateFilterButtons];
	[self.view addSubview:wheelchairStateFilterPopoverView];

	toiletStateFilterPopoverView = [[WMPOIStateFilterPopoverView alloc] initWithOrigin:
										CGPointMake(self.customToolBar.middlePointOfToiletStateFilterButton-toiletStateFilterPopoverView.frameWidth,
													CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.customToolBar.frame)*2-10)];
	toiletStateFilterPopoverView.stateType = WMPOIStateTypeToilet;
	toiletStateFilterPopoverView.hidden = YES;
	toiletStateFilterPopoverView.delegate = self;
	[toiletStateFilterPopoverView updateFilterButtons];
	[self.view addSubview:toiletStateFilterPopoverView];

	categoryFilterPopoverView = [[WMCategoryFilterPopoverView alloc] initWithRefPoint:
							 CGPointMake(self.customToolBar.middlePointOfCategoryFilterButton,
										 CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.customToolBar.frame))
																	andCategories:dataManager.categories];

	categoryFilterPopoverView.delegate = self;
	categoryFilterPopoverView.hidden = YES;
	[self.view addSubview:categoryFilterPopoverView];
}

- (void)hidePopoverViews {
	if (categoryFilterPopoverView.hidden == NO) {
		[self hidePopover:categoryFilterPopoverView];
	}
	if (wheelchairStateFilterPopoverView.hidden == NO) {
		[self hidePopover:wheelchairStateFilterPopoverView];
	}
	if (toiletStateFilterPopoverView.hidden == NO) {
		[self hidePopover:toiletStateFilterPopoverView];
	}
}

- (void)showPopover:(UIView*)popover {
	if (popover.hidden == NO) {
        return;
	}

	[self refreshPopoverPositions:[[UIApplication sharedApplication] statusBarOrientation]];

    popover.alpha = 0.0;
    popover.transform = CGAffineTransformMakeTranslation(0, 10);
    popover.hidden = NO;
	
    [UIView animateWithDuration:0.3 animations:^(void) {
         popover.alpha = 1.0;
         popover.transform = CGAffineTransformMakeTranslation(0, 0);
	} completion:nil];
}

- (void)hidePopover:(UIView*)popover {
	if (popover.hidden == YES) {
        return;
	}

    popover.alpha = 1.0;

    [UIView animateWithDuration:0.3 animations:^(void) {
         popover.alpha = 0.0;
         popover.transform = CGAffineTransformMakeTranslation(0, 10);
     } completion:^(BOOL finished) {
         popover.hidden = YES;
         popover.transform = CGAffineTransformMakeTranslation(0, 0);
	 }];
}

- (void)refreshPopoverPositions:(UIInterfaceOrientation)orientation {
	if (self.popoverVC.popover.isShowing == YES) {

		[self.popoverVC.popover dismissPopoverAnimated:NO];
		if ([self.popoverVC isKindOfClass:[WMCreditsViewController class]]) {
			CGRect buttonFrame = ((WMToolbar_iPad *)self.customToolBar).creditsButton.frame;
			CGFloat yPosition = 1024.0f - K_TOOLBAR_BAR_HEIGHT;
			if (UIInterfaceOrientationIsLandscape(orientation)) {
				yPosition = 768.0f - K_TOOLBAR_BAR_HEIGHT;
			}
			self.popoverVC.popoverButtonFrame = CGRectMake(buttonFrame.origin.x, yPosition, buttonFrame.size.width, buttonFrame.size.height);
		} else if ([self.popoverVC isKindOfClass:[WMOSMOnboardingViewController class]] || [self.popoverVC isKindOfClass:[WMOSMLogoutViewController class]]) {
			CGRect buttonFrame = ((WMToolbar_iPad *)self.customToolBar).loginButton.frame;
			CGFloat yPosition = 1024.0f - K_TOOLBAR_BAR_HEIGHT;
			if (UIInterfaceOrientationIsLandscape(orientation)) {
				yPosition = 768.0f - K_TOOLBAR_BAR_HEIGHT;
			}
			self.popoverVC.popoverButtonFrame = CGRectMake(buttonFrame.origin.x, yPosition, buttonFrame.size.width, buttonFrame.size.height);
		} else if ([self.popoverVC isKindOfClass:[WMEditPOIViewController class]]) {
			CGRect buttonFrame = ((WMIPadMapNavigationBar *)self.customNavigationBar).addButton.frame;
			CGFloat yPosition = 1024.0f - K_TOOLBAR_BAR_HEIGHT;
			if (UIInterfaceOrientationIsLandscape(orientation)) {
				yPosition = 768.0f - K_TOOLBAR_BAR_HEIGHT;
			}
			self.popoverVC.popoverButtonFrame = CGRectMake(buttonFrame.origin.x, yPosition, buttonFrame.size.width, buttonFrame.size.height);
		}
		[self presentPopover:self.popoverVC animated:NO];
	}
}

#pragma mark - WMWheelchairStatusFilter Delegate
- (void)didSelect:(BOOL)selected dot:(DotType)dotType forStateType:(WMPOIStateType)stateType {
    self.mapViewController.refreshingForFilter = YES;
    [self.mapViewController showActivityIndicator];
    
    NSString* wheelchairStatusString = K_STATE_UNKNOWN;
    switch (dotType) {
        case kDotTypeYes:
			if (stateType == WMPOIStateTypeWheelchair) {
				self.customToolBar.wheelchairStateFilterButton.selectedGreenDot = selected;
			} else if (stateType == WMPOIStateTypeToilet) {
				self.customToolBar.toiletStateFilterButton.selectedGreenDot = selected;
			}
            wheelchairStatusString = K_STATE_YES;
            break;
            
        case kDotTypeLimited:
			if (stateType == WMPOIStateTypeWheelchair) {
				self.customToolBar.wheelchairStateFilterButton.selectedYellowDot = selected;
			} else if (stateType == WMPOIStateTypeToilet) {
				self.customToolBar.toiletStateFilterButton.selectedYellowDot = selected;
			}
			wheelchairStatusString = K_STATE_LIMITED;
            break;
            
        case kDotTypeNo:
			if (stateType == WMPOIStateTypeWheelchair) {
				self.customToolBar.wheelchairStateFilterButton.selectedRedDot = selected;
			} else if (stateType == WMPOIStateTypeToilet) {
				self.customToolBar.toiletStateFilterButton.selectedRedDot = selected;
			}
			wheelchairStatusString = K_STATE_NO;
            break;
            
        case kDotTypeUnknown:
			if (stateType == WMPOIStateTypeWheelchair) {
				self.customToolBar.wheelchairStateFilterButton.selectedNoneDot = selected;
			} else if (stateType == WMPOIStateTypeToilet) {
				self.customToolBar.toiletStateFilterButton.selectedNoneDot = selected;
			}
			wheelchairStatusString = K_STATE_UNKNOWN;
            break;
            
        default:
            break;
    }

	if (stateType == WMPOIStateTypeWheelchair) {
		[self.wheelchairStateFilterStatus setObject:[NSNumber numberWithBool:selected] forKey:wheelchairStatusString];
	} else if (stateType == WMPOIStateTypeToilet) {
		[self.toiletStateFilterStatus setObject:[NSNumber numberWithBool:selected] forKey:wheelchairStatusString];
	}
    
    [self refreshNodeList];
}

#pragma mark - WMCategoryFilterPopoverView Delegate

- (void)categoryFilterStatusDidChangeForCategoryID:(NSNumber *)categoryID selected:(BOOL)selected {
    self.mapViewController.refreshingForFilter = YES;
    [self.mapViewController showActivityIndicator];
    
    if (selected) {
        [self.categoryFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:categoryID];
    } else {
        [self.categoryFilterStatus setObject:[NSNumber numberWithBool:NO] forKey:categoryID];
    }
    
    int numberOfSelectedCategories = 0;
    for (id key in self.categoryFilterStatus) {
        NSNumber *value = [self.categoryFilterStatus objectForKey:key];
        if ([value boolValue] == YES) {
            numberOfSelectedCategories++;
        }
    }
    
    if (numberOfSelectedCategories == self.categoryFilterStatus.count) {
        [self.customToolBar deselectCategoryButton];
    } else {
        [self.customToolBar selectCategoryButton];
    }

    [self refreshNodeList];
}

-(void)clearCategoryFilterStatus
{
    for (NSNumber* key in [self.categoryFilterStatus allKeys]) {
        [self.categoryFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:key];
    }
    
    [self.customToolBar clearWheelchairStateFilterButton];
	[self.customToolBar clearToiletStateFilterButton];
}

#pragma mark - Loading Wheel Management
- (void) showLoadingWheel
{
    loadingWheelContainer.hidden = NO;
    [loadingWheel startAnimating];
}

- (void) hideLoadingWheel
{
    loadingWheelContainer.hidden = YES;
    [loadingWheel stopAnimating];
}

#pragma mark - UINavigationController delegate
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (UIDevice.currentDevice.isIPad == NO) {
        
        if ([viewController isKindOfClass:[WMPOIsListViewController class]] || [viewController isKindOfClass:[WMMapViewController class]]) {
            if (navigationController.toolbarHidden == YES)
                [navigationController setToolbarHidden:NO animated:YES];
        } else {
            if (navigationController.toolbarHidden == NO)
                [navigationController setToolbarHidden:YES animated:YES];
        }
        
        if ([viewController isKindOfClass:[WMDashboardViewController class]]) {
            if (navigationController.navigationBarHidden == NO) {
                [navigationController setNavigationBarHidden:YES animated:YES];
            }
        } else {
            if (navigationController.navigationBarHidden == YES) {
                [navigationController setNavigationBarHidden:NO animated:YES];
            }
        }
        
    }else{
        [navigationController setNavigationBarHidden:NO animated:YES];
        [navigationController setToolbarHidden:YES];
    }
}

#pragma mark - Show Login screen

- (void)presentLoginScreen {
	CGRect buttonFrame = ((WMToolbar_iPad *)self.customToolBar).loginButton.frame;

	CGFloat yPosition = 1024.0f - K_TOOLBAR_BAR_HEIGHT;
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
		yPosition = 768.0f - K_TOOLBAR_BAR_HEIGHT;
	}
	[self presentLoginScreenWithButtonFrame:CGRectMake(buttonFrame.origin.x, yPosition, buttonFrame.size.width, buttonFrame.size.height)];
}

-(void)presentLoginScreenWithButtonFrame:(CGRect)frame;
{
    WMOSMOnboardingViewController* osmOnbaordingViewController = [UIStoryboard instantiatedOSMOnboardingViewController];
    osmOnbaordingViewController.popoverButtonFrame = frame;
    [self presentViewController:osmOnbaordingViewController animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    fetchNodesAlertShowing = NO;
}

-(BOOL)shouldAutoRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)presentViewController:(UIViewController *)modalViewController animated:(BOOL)animated{
    if (UIDevice.currentDevice.isIPad == YES) {
        
        if ([modalViewController isKindOfClass:[WMViewController class]]) {
            [self dismissViewControllerAnimated:NO completion:nil];
            [self presentPopover:modalViewController animated:animated];
        } else {
            [super presentViewController:modalViewController animated:animated completion:nil];
        }
    } else {
        [super presentViewController:modalViewController animated:animated completion:nil];
    }
}

- (void)presentPopover:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[WMAcceptTermsViewController class]]) {
        ((WMViewController *)viewController).popover = [[WMPopoverController alloc]
                                                        initWithContentViewController:viewController];
        self.popoverVC = (WMViewController *)viewController;
        ((WMViewController *)viewController).baseController = self;
        
        if ((((WMViewController *)viewController).popoverButtonFrame.size.width == 0) || (((WMViewController *)viewController).popoverButtonFrame.size.height == 0)) {
            ((WMViewController *)viewController).popoverButtonFrame = CGRectMake(((WMViewController *)viewController).popoverButtonFrame.origin.x, ((WMViewController *)viewController).popoverButtonFrame.origin.y, 10.0f, 10.0f);
        }
        
        [((WMViewController *)viewController).popover presentPopoverFromRect:((WMViewController *)viewController).popoverButtonFrame
                                                                      inView:self.view
                                                    permittedArrowDirections:0
                                                                    animated:animated];
        
    } else if ([viewController isKindOfClass:[WMOSMDescriptionViewController class]]) {
        ((WMViewController *)viewController).popover = [[WMPopoverController alloc]
                                                        initWithContentViewController:viewController];
        self.popoverVC = (WMViewController *)viewController;
        ((WMViewController *)viewController).baseController = self;
        
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            ((WMViewController *)viewController).popoverButtonFrame = CGRectMake(1024.0f/2 - 160.0f, 150.0f, 320.0f, 500.0f);
        } else {
            ((WMViewController *)viewController).popoverButtonFrame = CGRectMake(768.0f/2 - 160.0f, 150.0f, 320.0f, 500.0f);
        }
        
        [((WMViewController *)viewController).popover presentPopoverFromRect:((WMViewController *)viewController).popoverButtonFrame
                                                                      inView:self.view
                                                    permittedArrowDirections:0
                                                                    animated:animated];
        
    } else if ([viewController isKindOfClass:[WMViewController class]]) {
        ((WMViewController *)viewController).popover = [[WMPopoverController alloc]
                                                        initWithContentViewController:viewController];
        self.popoverVC = (WMViewController *)viewController;
        ((WMViewController *)viewController).baseController = self;
        
        [((WMViewController *)viewController).popover presentPopoverFromRect:((WMViewController *)viewController).popoverButtonFrame
                                                                      inView:self.view
                                                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                    animated:animated];
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
	[self hidePopoverViews];
}

@end