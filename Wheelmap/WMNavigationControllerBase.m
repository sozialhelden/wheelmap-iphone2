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
#import "WMDetailViewController.h"
#import "WMWheelchairStatusViewController.h"
#import "WMDashboardViewController.h"
#import "WMEditPOIViewController.h"
#import "WMShareSocialViewController.h"
#import "WMCategoryViewController.h"
#import "WMLoginViewController.h"
#import "WMSetMarkerViewController.h"
#import "WMNodeTypeTableViewController.h"
#import "Node.h"
#import "NodeType.h"
#import "Category.h"


@implementation WMNavigationControllerBase
{
    NSArray *nodes;
    WMDataManager *dataManager;
    
    WMWheelChairStatusFilterPopoverView* wheelChairFilterPopover;
    WMCategoryFilterPopoverView* categoryFilterPopover;
    
    UIView* loadingWheelContainer;  // this view will show loading whell on the center and cover child view controllers so that we avoid interactions interuptting data loading
    UIActivityIndicatorView* loadingWheel;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    dataManager = [[WMDataManager alloc] init];
    dataManager.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 50.0f;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    self.lastVisibleMapCenterLat = nil;
    self.lastVisibleMapCenterLng = nil;
    self.lastVisibleMapSpanLat = nil;
    self.lastVisibleMapSpanLng = nil;
    
    // configure initial vc from storyboard. this is necessary for iPad, since iPad's topVC is not the Dashboard!
    if ([self.topViewController conformsToProtocol:@protocol(WMNodeListView)]) {
        id<WMNodeListView> initialNodeListView = (id<WMNodeListView>)self.topViewController;
        initialNodeListView.dataSource = self;
        initialNodeListView.delegate = self;
    }
    
    self.wheelChairFilterStatus = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"yes",
                                   [NSNumber numberWithBool:YES], @"limited",
                                   [NSNumber numberWithBool:YES], @"no",
                                   [NSNumber numberWithBool:YES], @"unknown",nil];
    self.categoryFilterStatus = [[NSMutableDictionary alloc] init];
    for (Category* c in dataManager.categories) {
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
    
    CGSize expectedLabelSize = [loadingLabel.text sizeWithFont:loadingLabel.font constrainedToSize:maximumLabelSize lineBreakMode:loadingLabel.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = loadingLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    loadingLabel.frame = newFrame;
    
    loadingLabel.frame = CGRectMake(loadingLabel.frame.origin.x, loadingWheel.frame.origin.y + loadingWheel.frame.size.height + 10.0f, loadingLabel.frame.size.width, loadingLabel.frame.size.height);
    
    [loadingWheelContainer addSubview:loadingLabel];
    
    [loadingWheelContainer addSubview:loadingWheel];
    [self.view addSubview:loadingWheelContainer];
    
    // set custom nagivation and tool bars
    self.navigationBar.frame = CGRectMake(0, self.navigationBar.frame.origin.y, self.view.frame.size.width, 50);
    self.customNavigationBar = [[WMNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.navigationBar.frame.size.width, 50)];
    self.customNavigationBar.delegate = self;
    [self.navigationBar addSubview:self.customNavigationBar];
    self.toolbar.frame = CGRectMake(0, self.toolbar.frame.origin.y, self.view.frame.size.width, 60);
    self.toolbar.backgroundColor = [UIColor whiteColor];
    self.customToolBar = [[WMToolBar alloc] initWithFrame:CGRectMake(0, 0, self.toolbar.frame.size.width, 60)];
    self.customToolBar.delegate = self;
    [self.toolbar addSubview:self.customToolBar];
    
    // set filter popovers.
    wheelChairFilterPopover = [[WMWheelChairStatusFilterPopoverView alloc] initWithOrigin:CGPointMake(self.customToolBar.middlePointOfWheelchairFilterButton-170, self.toolbar.frame.origin.y-60)];
    wheelChairFilterPopover.hidden = YES;
    wheelChairFilterPopover.delegate = self;
    [self.view addSubview:wheelChairFilterPopover];
    
    categoryFilterPopover = [[WMCategoryFilterPopoverView alloc] initWithRefPoint:CGPointMake(self.customToolBar.middlePointOfCategoryFilterButton, self.toolbar.frame.origin.y) andCategories:dataManager.categories];
    categoryFilterPopover.delegate = self;
    categoryFilterPopover.hidden = YES;
    [self.view addSubview:categoryFilterPopover];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = UIColorFromRGB(0x304152);
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        return YES;
    else
        return NO;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Data Manager Delegate

- (void) dataManager:(WMDataManager *)dataManager didReceiveNodes:(NSArray *)nodesParam
{
    [self hideLoadingWheel];
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
    [self hideLoadingWheel];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"FetchNodesFails", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alert show];
    
    NSLog(@"error %@", error.localizedDescription);
    [self refreshNodeList];
}

- (void)dataManagerDidFinishSyncingResources:(WMDataManager *)aDataManager
{
    NSLog(@"dataManagerDidFinishSyncingResources");
    
    if ([self.topViewController isKindOfClass:[WMDashboardViewController class]]) {
        WMDashboardViewController* vc = (WMDashboardViewController*)self.topViewController;
        [vc showUIObjectsAnimated:YES];
    }
    
    [categoryFilterPopover refreshViewWithCategories:aDataManager.categories];
    [self.categoryFilterStatus removeAllObjects];
    for (Category* c in dataManager.categories) {
        [self.categoryFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:c.id];
    }
    
}

-(void)dataManager:(WMDataManager *)dataManager syncResourcesFailedWithError:(NSError *)error
{
    NSLog(@"syncResourcesFailedWithError");
    
    if ([self.topViewController isKindOfClass:[WMDashboardViewController class]]) {
        WMDashboardViewController* vc = (WMDashboardViewController*)self.topViewController;
        [vc showUIObjectsAnimated:YES];
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

- (NSArray*) filteredNodeList
{
    // filter nodes here
    NSMutableArray* newNodeList = [[NSMutableArray alloc] init];
    for (Node* node in nodes) {
        NSNumber* categoryID = node.node_type.category.id;
        NSString* wheelChairStatus = node.wheelchair;
        if ([[self.wheelChairFilterStatus objectForKey:wheelChairStatus] boolValue] == YES &&
            [[self.categoryFilterStatus objectForKey:categoryID] boolValue] == YES) {
            [newNodeList addObject:node];
        }
    }
    
    return newNodeList;
}

-(void)updateNodesNear:(CLLocationCoordinate2D)coord
{
    [self showLoadingWheel];
    [dataManager fetchNodesNear:coord];
    
}

-(void)updateNodesWithRegion:(MKCoordinateRegion)region
{
    // we do not show here the loading wheel since this methods is always called by map view controller, and the vc has its own loading wheel,
    // which allows user interaction while loading nodes.
   // [self showLoadingWheel];
    CLLocationCoordinate2D southWest;
    CLLocationCoordinate2D northEast;
    southWest = CLLocationCoordinate2DMake(region.center.latitude-region.span.latitudeDelta/2.0f, region.center.longitude+region.span.longitudeDelta/2.0f);
    northEast = CLLocationCoordinate2DMake(region.center.latitude+region.span.latitudeDelta/2.0f, region.center.longitude-region.span.longitudeDelta/2.0f);
    
    [dataManager fetchNodesBetweenSouthwest:southWest northeast:northEast query:nil];
}

-(void)updateNodesWithQuery:(NSString*)query
{
    [self showLoadingWheel];
    [dataManager fetchNodesWithQuery:query];
    
}

-(void)updateNodesWithQuery:(NSString*)query andRegion:(MKCoordinateRegion)region
{
    CLLocationCoordinate2D southWest;
    CLLocationCoordinate2D northEast;
    southWest = CLLocationCoordinate2DMake(region.center.latitude-region.span.latitudeDelta/2.0f, region.center.longitude+region.span.longitudeDelta/2.0f);
    northEast = CLLocationCoordinate2DMake(region.center.latitude+region.span.latitudeDelta/2.0f, region.center.longitude-region.span.longitudeDelta/2.0f);

    [self showLoadingWheel];
    [dataManager fetchNodesBetweenSouthwest:southWest northeast:northEast query:query];
    
}

#pragma mark - Node List Delegate

/**
 * Called only on the iPhone
 */
- (void)nodeListView:(id<WMNodeListView>)nodeListView didSelectNode:(Node *)node
{
    // we don"t want to push a detail view when selecting a node on the map view, so
    // we check if this message comes from a table view
    if (node && [nodeListView isKindOfClass:[WMNodeListViewController class]]) {
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

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* newLocation = [locations objectAtIndex:0];
    [self locationManager:manager didUpdateToLocation:newLocation fromLocation:nil];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location is updated!");
    [self updateNodesWithCurrentUserLocation];
}

-(void)updateUserLocation
{
    NSLog(@"CLLOCATIONMANAGER:%@ and delegate: %@", self.locationManager, self.locationManager.delegate);
    if ([CLLocationManager locationServicesEnabled]) {
        [self showLoadingWheel];
        [self.locationManager startUpdatingLocation];
    } else {
        NSLog(@"[CLLocataionManager] location service is disabled!");
        [self locationManager:self.locationManager didFailWithError:nil];
    }
}

-(CLLocation*)currentUserLocation
{
    return self.locationManager.location;
}

-(void)updateNodesWithCurrentUserLocation
{
    CLLocation* newLocation = self.locationManager.location;
    if ([self.topViewController isKindOfClass:[WMMapViewController class]]) {
        WMMapViewController* currentVC = (WMMapViewController*)self.topViewController;
        [currentVC relocateMapTo:newLocation.coordinate];   // this will automatically update node list!
    } else if ([self.topViewController isKindOfClass:[WMNodeListViewController class]]) {
        [self updateNodesNear:newLocation.coordinate];
        self.lastVisibleMapCenterLat = [NSNumber numberWithDouble:newLocation.coordinate.latitude];
        self.lastVisibleMapCenterLng = [NSNumber numberWithDouble:newLocation.coordinate.longitude];
        self.lastVisibleMapSpanLat = [NSNumber numberWithDouble:0.005];
        self.lastVisibleMapSpanLng = [NSNumber numberWithDouble:0.005];
    } else {
        
    }
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

- (void)applicationWillResignActive:(NSNotification*)notification
{
	[self.locationManager stopUpdatingLocation];
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
    
    if ([viewController conformsToProtocol:@protocol(WMNodeListView)]) {
        id<WMNodeListView> nodeListViewController = (id<WMNodeListView>)viewController;
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
        self.customToolBar.toggleButton.selected = YES;
        if (self.viewControllers.count == 3) {
            leftButtonStyle = kWMNavigationBarLeftButtonStyleDashboardButton;   // single exception. this is the first level!
        }
        rightButtonStyle = kWMNavigationBarRightButtonStyleContributeButton;
    } else if ([vc isKindOfClass:[WMNodeListViewController class]]) {
        WMNodeListViewController* nodeListVC = (WMNodeListViewController*)vc;
        rightButtonStyle = kWMNavigationBarRightButtonStyleContributeButton;
        self.customToolBar.toggleButton.selected = NO;
        switch (nodeListVC.useCase) {
            case kWMNodeListViewControllerUseCaseNormal:
                nodeListVC.navigationBarTitle = NSLocalizedString(@"PlacesNearby", nil);
                [self.customToolBar showAllButtons];
                break;
            case kWMNodeListViewControllerUseCaseContribute:
                nodeListVC.navigationBarTitle = NSLocalizedString(@"TitleHelp", nil);
                [self.customToolBar hideButton:kWMToolBarButtonWheelChairFilter];
                //[self.customToolBar hideButton:kWMToolBarButtonCategoryFilter];
                rightButtonStyle = kWMNavigationBarRightButtonStyleNone;
                break;
            case kWMNodeListViewControllerUseCaseCategory:
                [self.customToolBar showButton:kWMToolBarButtonWheelChairFilter];
                [self.customToolBar hideButton:kWMToolBarButtonCategoryFilter];
                break;
            case kWMNodeListViewControllerUseCaseGlobalSearch:
            case kWMNodeListViewControllerUseCaseSearchOnDemand:
                nodeListVC.navigationBarTitle = NSLocalizedString(@"SearchResult", nil);
                rightButtonStyle = kWMNavigationBarRightButtonStyleNone;
            default:
                break;
        }
        
    } else if ([vc isKindOfClass:[WMDetailViewController class]]) {
        rightButtonStyle = kWMNavigationBarRightButtonStyleEditButton;
        [self hidePopover:wheelChairFilterPopover];
        [self hidePopover:categoryFilterPopover];
    } else if ([vc isKindOfClass:[WMWheelchairStatusViewController class]]) {
        WMWheelchairStatusViewController* wheelchairStatusVC = (WMWheelchairStatusViewController*)vc;
        NSLog(@"WheelChairStatusViewController usecase: %d", wheelchairStatusVC.useCase);
        if (wheelchairStatusVC.useCase == kWMWheelChairStatusViewControllerUseCasePutNode) {
            rightButtonStyle = kWMNavigationBarRightButtonStyleNone;
            leftButtonStyle = kWMNavigationBarLeftButtonStyleBackButton;
        } else {
            rightButtonStyle = kWMNavigationBarRightButtonStyleSaveButton;
            leftButtonStyle = kWMNavigationBarLeftButtonStyleCancelButton;
        }
        [self hidePopover:wheelChairFilterPopover];
        [self hidePopover:categoryFilterPopover];
    } else if ([vc isKindOfClass:[WMEditPOIViewController class]] ||
               [vc isKindOfClass:[WMCommentViewController class]]) {
        rightButtonStyle = kWMNavigationBarRightButtonStyleSaveButton;
        leftButtonStyle = kWMNavigationBarLeftButtonStyleCancelButton;
        [self hidePopover:wheelChairFilterPopover];
        [self hidePopover:categoryFilterPopover];
        
    }  else if ([vc isKindOfClass:[WMShareSocialViewController class]]) {
        rightButtonStyle = kWMNavigationBarRightButtonStyleNone;
        leftButtonStyle = kWMNavigationBarLeftButtonStyleCancelButton;
        [self hidePopover:wheelChairFilterPopover];
        [self hidePopover:categoryFilterPopover];
        
    } else if ([vc isKindOfClass:[WMCategoryViewController class]] ||
               [vc isKindOfClass:[WMSetMarkerViewController class]] ||
               [vc isKindOfClass:[WMNodeTypeTableViewController class]]) {
        rightButtonStyle = kWMNavigationBarRightButtonStyleNone;
    }
    
    self.customNavigationBar.leftButtonStyle = leftButtonStyle;
    self.customNavigationBar.rightButtonStyle = rightButtonStyle;
    if ([vc respondsToSelector:@selector(navigationBarTitle)]) {
        self.customNavigationBar.title = [vc performSelector:@selector(navigationBarTitle)];
    }
}

#pragma mark - WMNavigationBar Delegate
-(void)pressedDashboardButton:(WMNavigationBar *)navigationBar
{
    [self.customToolBar deselectSearchButton];
    [self popToRootViewControllerAnimated:YES];
    [self hidePopover:wheelChairFilterPopover];
    [self hidePopover:categoryFilterPopover];
}

-(void)pressedBackButton:(WMNavigationBar *)navigationBar
{
    if ([self.topViewController isKindOfClass:[WMMapViewController class]]) {
        // we should pop twice due to the node list view controller!
        WMViewController* targetVC = [self.viewControllers objectAtIndex:self.viewControllers.count-3];
        [self popToViewController:targetVC animated:YES];
    } else {
        [self popViewControllerAnimated:YES];
    }
    [self hidePopover:wheelChairFilterPopover];
    [self hidePopover:categoryFilterPopover];
    
}

-(void)pressedCancelButton:(WMNavigationBar *)navigationBar
{
    [self popViewControllerAnimated:YES];
    
}

-(void)pressedContributeButton:(WMNavigationBar *)navigationBar
{
    NSLog(@"[NavigationControllerBase] pressed contribute button!");
    
    if (![dataManager userIsAuthenticated]) {
        [self presentLoginScreen];
        return;
    }
    WMEditPOIViewController* vc = [[UIStoryboard storyboardWithName:@"WMDetailView" bundle:nil] instantiateViewControllerWithIdentifier:@"WMEditPOIViewController"];
    vc.title = self.title = NSLocalizedString(@"EditPOIViewHeadline", @"");
    [self pushViewController:vc animated:YES];
}

-(void)pressedEditButton:(WMNavigationBar *)navigationBar
{
    WMViewController* currentViewController = [self.viewControllers lastObject];
    if ([currentViewController isKindOfClass:[WMDetailViewController class]]) {
        [(WMDetailViewController*)currentViewController pushEditViewController];
    }
}

-(void)pressedSaveButton:(WMNavigationBar *)navigationBar
{
    WMViewController* currentViewController = [self.viewControllers lastObject];
    if ([currentViewController isKindOfClass:[WMWheelchairStatusViewController class]]) {
        [(WMWheelchairStatusViewController*)currentViewController saveAccessStatus];
    }
    if ([currentViewController isKindOfClass:[WMEditPOIViewController class]]) {
        [(WMEditPOIViewController*)currentViewController saveEditedData];
    }
}

-(void)pressedSearchCancelButton:(WMNavigationBar *)navigationBar
{
    [self.customToolBar deselectSearchButton];
    
}

-(void)searchStringIsGiven:(NSString *)query
{
    if ([self.topViewController isKindOfClass:[WMNodeListViewController class]]) {
        WMNodeListViewController* vc = (WMNodeListViewController*)self.topViewController;
        vc.useCase = kWMNodeListViewControllerUseCaseSearchOnDemand;
        vc.navigationBarTitle = NSLocalizedString(@"SearchResult", nil);
        self.customNavigationBar.title = vc.navigationBarTitle;
        [self updateNodesWithQuery:query];
      
    } else if ([self.topViewController isKindOfClass:[WMMapViewController class]]) {
        WMMapViewController* vc = (WMMapViewController*)self.topViewController;
        vc.useCase = kWMNodeListViewControllerUseCaseSearchOnDemand;
        vc.navigationBarTitle = NSLocalizedString(@"SearchResult", nil);;
        self.customNavigationBar.title = vc.navigationBarTitle;
        
        WMNodeListViewController* nodeListVC = (WMNodeListViewController*)[self.viewControllers objectAtIndex:self.viewControllers.count-2];
        nodeListVC.useCase = kWMNodeListViewControllerUseCaseSearchOnDemand;
        nodeListVC.navigationBarTitle = NSLocalizedString(@"SearchResult", nil);;
        self.customNavigationBar.title = nodeListVC.navigationBarTitle;
        
        [self updateNodesWithQuery:query andRegion:vc.mapView.region];
       
    }
    
    
}

#pragma mark - WMToolBar Delegate
-(void)pressedToggleButton:(WMButton *)sender
{
    if ([self.topViewController isKindOfClass:[WMNodeListViewController class]]) {
        //  the node list view is on the screen. push the map view controller
        WMMapViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMMapViewController"];
        WMViewController* currentVC = (WMViewController*)self.topViewController;
        vc.navigationBarTitle = currentVC.navigationBarTitle;
        if ([currentVC respondsToSelector:@selector(useCase)])
            vc.useCase = (WMNodeListViewControllerUseCase)[currentVC performSelector:@selector(useCase)];
        [self pushFadeViewController:vc];
        
    } else if ([self.topViewController isKindOfClass:[WMMapViewController class]]) {
        //  the map view is on the screen. pop the map view controller
        [self popFadeViewController];
    }
    
}

-(void)pressedCurrentLocationButton:(WMToolBar *)toolBar
{
    NSLog(@"[ToolBar] update current location button is pressed!");
    [self updateNodesWithCurrentUserLocation];
    
    [self.customToolBar deselectSearchButton];
    
    if ([self.topViewController isKindOfClass:[WMNodeListViewController class]]) {
        WMNodeListViewController* currentVC = (WMNodeListViewController*)self.topViewController;
        if (currentVC.useCase == kWMNodeListViewControllerUseCaseCategory || currentVC.useCase == kWMNodeListViewControllerUseCaseContribute) {
            return;
        }
        currentVC.useCase = kWMNodeListViewControllerUseCaseNormal;
        currentVC.navigationBarTitle = NSLocalizedString(@"PlacesNearby", nil);
        self.customNavigationBar.title = currentVC.navigationBarTitle;
    } else if ([self.topViewController isKindOfClass:[WMMapViewController class]]) {
        WMMapViewController* currentVC = (WMMapViewController*)self.topViewController;
        if (currentVC.useCase == kWMNodeListViewControllerUseCaseCategory || currentVC.useCase == kWMNodeListViewControllerUseCaseContribute) {
            return;
        }
        WMNodeListViewController* nodeListVC = (WMNodeListViewController*)[self.viewControllers objectAtIndex:self.viewControllers.count-2];
        currentVC.useCase = kWMNodeListViewControllerUseCaseNormal;
        nodeListVC.useCase = kWMNodeListViewControllerUseCaseNormal;
        currentVC.navigationBarTitle = NSLocalizedString(@"PlacesNearby", nil);
        nodeListVC.navigationBarTitle = NSLocalizedString(@"PlacesNearby", nil);
        self.customNavigationBar.title = currentVC.navigationBarTitle;
    }

    
}
-(void)pressedSearchButton:(BOOL)selected
{
    NSLog(@"[ToolBar] global search button is pressed!");
    if (selected) {
        [self.customNavigationBar showSearchBar];
        
    } else {
        if ([self.topViewController isKindOfClass:[WMNodeListViewController class]]) {
            WMNodeListViewController* currentVC = (WMNodeListViewController*)self.topViewController;
            currentVC.useCase = kWMNodeListViewControllerUseCaseNormal;
            currentVC.navigationBarTitle = NSLocalizedString(@"PlacesNearby", nil);
            self.customNavigationBar.title = currentVC.navigationBarTitle;
        } else if ([self.topViewController isKindOfClass:[WMMapViewController class]]) {
            WMMapViewController* currentVC = (WMMapViewController*)self.topViewController;
            WMNodeListViewController* nodeListVC = (WMNodeListViewController*)[self.viewControllers objectAtIndex:self.viewControllers.count-2];
            currentVC.useCase = kWMNodeListViewControllerUseCaseNormal;
            nodeListVC.useCase = kWMNodeListViewControllerUseCaseNormal;
            currentVC.navigationBarTitle = NSLocalizedString(@"PlacesNearby", nil);
            nodeListVC.navigationBarTitle = NSLocalizedString(@"PlacesNearby", nil);
            self.customNavigationBar.title = currentVC.navigationBarTitle;
        }
        
        if (self.lastVisibleMapCenterLat) {
            [self updateNodesWithRegion:MKCoordinateRegionMake(
                                                               CLLocationCoordinate2DMake([self.lastVisibleMapCenterLat doubleValue],
                                                                                          [self.lastVisibleMapCenterLng doubleValue]),
                                                               MKCoordinateSpanMake([self.lastVisibleMapSpanLat doubleValue],
                                                                                    [self.lastVisibleMapSpanLng doubleValue])
                                                               )];
        } else {
            [self updateNodesWithRegion:MKCoordinateRegionMake(self.locationManager.location.coordinate, MKCoordinateSpanMake(0.005, 0.005))];
        }
        
        
    }
}

-(void)pressedWheelChairStatusFilterButton:(WMToolBar *)toolBar
{
    NSLog(@"[ToolBar] wheelchair status filter buttton is pressed!");
    if (!categoryFilterPopover.hidden) {
        [self hidePopover:categoryFilterPopover];
    }
    
    if (wheelChairFilterPopover.hidden) {
        [self showPopover:wheelChairFilterPopover];
    } else {
        [self hidePopover:wheelChairFilterPopover];
    }
}

-(void)pressedCategoryFilterButton:(WMToolBar *)toolBar
{
    NSLog(@"[ToolBar] category filter button is pressed!");
    
    if (!wheelChairFilterPopover.hidden) {
        [self hidePopover:wheelChairFilterPopover];
    }
    
    if (categoryFilterPopover.hidden) {
        [self showPopover:categoryFilterPopover];
    } else {
        [self hidePopover:categoryFilterPopover];
    }
}

#pragma mark - Popover Management
-(void)showPopover:(UIView*)popover
{
    if (popover.hidden == NO)
        return;
    
    popover.alpha = 0.0;
    popover.transform = CGAffineTransformMakeTranslation(0, 10);
    popover.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         popover.alpha = 1.0;
         popover.transform = CGAffineTransformMakeTranslation(0, 0);
     }
                     completion:^(BOOL finished)
     {
         
     }
     ];
}

-(void)hidePopover:(UIView*)popover
{
    if (popover.hidden == YES)
        return;
    
    popover.alpha = 1.0;
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         popover.alpha = 0.0;
         popover.transform = CGAffineTransformMakeTranslation(0, 10);
     }
                     completion:^(BOOL finished)
     {
         popover.hidden = YES;
         popover.transform = CGAffineTransformMakeTranslation(0, 0);
         
     }
     ];
}

#pragma mark - WMWheelchairStatusFilter Delegate
-(void)pressedButtonOfDotType:(DotType)type selected:(BOOL)selected
{
    NSString* wheelchairStatusString = @"unknown";
    switch (type) {
        case kDotTypeGreen:
            self.customToolBar.wheelChairStatusFilterButton.selectedGreenDot = selected;
            wheelchairStatusString = @"yes";
            break;
            
        case kDotTypeYellow:
            self.customToolBar.wheelChairStatusFilterButton.selectedYellowDot = selected;
            wheelchairStatusString = @"limited";
            break;
            
        case kDotTypeRed:
            self.customToolBar.wheelChairStatusFilterButton.selectedRedDot = selected;
            wheelchairStatusString = @"no";
            break;
            
        case kDotTypeNone:
            self.customToolBar.wheelChairStatusFilterButton.selectedNoneDot = selected;
            wheelchairStatusString = @"unknown";
            break;
            
        default:
            break;
    }
    
    if (selected) {
        [self.wheelChairFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:wheelchairStatusString];
    } else {
        [self.wheelChairFilterStatus setObject:[NSNumber numberWithBool:NO] forKey:wheelchairStatusString];
    }
    
    [self refreshNodeList];
    
}

-(void)clearWheelChairFilterStatus
{
    for (NSNumber* key in [self.wheelChairFilterStatus allKeys]) {
        [self.wheelChairFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:key];
    }
}

#pragma mark -WMCategoryFilterPopoverView Delegate
-(void)categoryFilterStatusDidChangeForCategoryID:(NSNumber *)categoryID selected:(BOOL)selected
{
    if (selected) {
        [self.categoryFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:categoryID];
    } else {
        [self.categoryFilterStatus setObject:[NSNumber numberWithBool:NO] forKey:categoryID];
    }
    
    [self refreshNodeList];
}

-(void)clearCategoryFilterStatus
{
    for (NSNumber* key in [self.categoryFilterStatus allKeys]) {
        [self.categoryFilterStatus setObject:[NSNumber numberWithBool:YES] forKey:key];
    }
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
    if ([viewController isKindOfClass:[WMNodeListViewController class]] || [viewController isKindOfClass:[WMMapViewController class]]) {
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
     
     
}

#pragma mark - Show Login screen
-(void)presentLoginScreen
{
    WMLoginViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMLoginViewController"];
    [self presentModalViewController:vc animated:YES];
}
@end




