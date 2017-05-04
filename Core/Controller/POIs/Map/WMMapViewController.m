//
//  WMMapViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMMapViewController.h"
#import "WMMapAnnotation.h"
#import "WMPOIViewController.h"
#import "Node.h"
#import "NodeType.h"
#import "WMNavigationControllerBase.h"
#import "WMPOIIPadNavigationController.h"
#import "WMResourceManager.h"
#import "WMAnalytics.h"
#import <QuartzCore/QuartzCore.h>

#define MIN_SPAN_DELTA 				0.01

#define MIN_ZOOM_LEVEL_CHANGE		0.6
#define MIN_MAP_MOVEMENT			0.2

// TODO: re-position popover after orientation change

@interface WMMapViewController()

@property (strong, nonatomic) CLLocation *userCurrentLocation;

@end

@implementation WMMapViewController
{
    dispatch_queue_t backgroundQueue;
    
    NSArray *nodes;
    UIPopoverController *popover;
    
    CLLocationCoordinate2D lastDisplayedMapCenter;
	double lastZoomLevel;

    BOOL dontUpdateNodeList;
    BOOL loadingNodes;
    
    float invisibleMapInteractionInfoLabelConstraint;
    float visibleMapInteractionInfoLabelConstraint;
}

@synthesize dataSource, delegate;

- (MKCoordinateRegion)region {
    
	double lat;
	double lon;

    WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.baseController;
    
    if (navCtrl.lastVisibleMapCenterLat == nil) {
        
        lat = navCtrl.currentLocation.coordinate.latitude;
        lon = navCtrl.currentLocation.coordinate.longitude;
        
    } else {
        lat = [navCtrl.lastVisibleMapCenterLat doubleValue];
        lon = [navCtrl.lastVisibleMapCenterLng doubleValue];
    }

    return MKCoordinateRegionMake(CLLocationCoordinate2DMake(lat, lon) , MKCoordinateSpanMake(DEFAULT_SEARCH_SPAN_LAT, DEFAULT_SEARCH_SPAN_LONG));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    backgroundQueue = dispatch_queue_create("de.sozialhelden.wheelmap", NULL);
    dataManager = [[WMDataManager alloc] init];
    
    [self.view layoutIfNeeded];
    
    [self initMapView];
}

// Initiliaze Map View
- (void) initMapView{
	self.mapView.showsBuildings = NO;
    self.mapView.rotateEnabled = NO;
    self.mapView.pitchEnabled = NO;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;
	self.mapView.showsPointsOfInterest = NO;
    
    // configure mapInteractionInfoLabel
    self.mapInteractionInfoLabel.tag = 0;   // tag 0 means that the indicator is not visible
    self.mapInteractionInfoLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.mapInteractionInfoLabel.layer.borderWidth = 2.0;
    self.mapInteractionInfoLabel.layer.cornerRadius = 10.0;
    self.mapInteractionInfoLabel.layer.masksToBounds = YES;
    self.mapInteractionInfoLabel.numberOfLines = 2;
    
    // set the map interaction info label visible/invisible constraint values
    visibleMapInteractionInfoLabelConstraint = self.mapInteractionInfoLabelTopVerticalSpaceConstraint.constant;
    invisibleMapInteractionInfoLabelConstraint = -CGRectGetHeight(self.mapInteractionInfoLabel.frame)-20.0f;
    
    // initially hide the map interaction info label
    self.mapInteractionInfoLabelTopVerticalSpaceConstraint.constant = invisibleMapInteractionInfoLabelConstraint;

	// Set the default location to Berlin
	self.userCurrentLocation = [[CLLocation alloc] initWithLatitude:K_DEFAULT_LATITUDE longitude:K_DEFAULT_LONGITUDE];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
	if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
		[self.locationManager requestWhenInUseAuthorization];
	}

    self.locationManager.distanceFilter = 50.0f;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startMonitoringSignificantLocationChanges];

	if (self.locationManager.location != nil) {
		self.userCurrentLocation = self.locationManager.location;
	}

    [self relocateMapTo:self.userCurrentLocation.coordinate andSpan:MKCoordinateSpanMake(0.003, 0.003)];
}



- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.mapView.delegate = self;
    
    self.loadingLabel.numberOfLines = 0;
    self.loadingLabel.textColor = [UIColor whiteColor];
    self.loadingLabel.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    self.loadingLabel.layer.cornerRadius = 10.0f;
    self.loadingLabel.layer.masksToBounds = YES;
    [self.loadingLabel setText:NSLocalizedString(@"LoadingWheelText", nil)];
    [self.loadingLabel adjustHeightToContent];
    
    [self hideActivityIndicator];
    
    self.mapView.frame = self.view.bounds;
	[WMAnalytics trackScreen:K_MAP_SCREEN];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // we set the delegate in viewDidAppear to avoid node updates by map initialisation
    // while init the map, mapView:regionDidChange:animated called multiple times
    self.mapView.delegate = self;
    
    if (UIDevice.currentDevice.isIPad == YES) {
        NSMutableArray* oldAnnotations = [NSMutableArray arrayWithArray:self.mapView.annotations];
        for (id<MKAnnotation> annotation in oldAnnotations) {
            if (![annotation isKindOfClass:[MKUserLocation class]])
                [self.mapView removeAnnotation:annotation];
        }
    }
    
    WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.dataSource;
    MKCoordinateRegion initRegion;
    
    if (!navCtrl.lastVisibleMapCenterLat || !navCtrl.lastVisibleMapSpanLat) {
        navCtrl.lastVisibleMapCenterLat = [NSNumber numberWithDouble:self.mapView.region.center.latitude];
        navCtrl.lastVisibleMapCenterLng = [NSNumber numberWithDouble:self.mapView.region.center.longitude];
        navCtrl.lastVisibleMapSpanLat = [NSNumber numberWithDouble:self.mapView.region.span.latitudeDelta];
        navCtrl.lastVisibleMapSpanLng = [NSNumber numberWithDouble:self.mapView.region.span.longitudeDelta];
        
        CLLocation* userLocation = navCtrl.currentLocation;
        initRegion = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.004, 0.004));
        [self.mapView setRegion:initRegion animated:NO];
        [self mapView:self.mapView regionDidChangeAnimated:NO];
        
    } else {
        
        initRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake([navCtrl.lastVisibleMapCenterLat doubleValue],
                                                                       [navCtrl.lastVisibleMapCenterLng doubleValue]),
                                            MKCoordinateSpanMake([navCtrl.lastVisibleMapSpanLat doubleValue],
                                                                 [navCtrl.lastVisibleMapSpanLng doubleValue])
                                            );
        [self.mapView setRegion:initRegion animated:NO];
    }
    
    if (self.useCase == kWMPOIsListViewControllerUseCaseGlobalSearch ||
        self.useCase == kWMPOIsListViewControllerUseCaseSearchOnDemand)
    {
        // show current location button, if it is hidden
        [((WMNavigationControllerBase *)self.navigationController).customToolBar showButton:kWMToolbarButtonCurrentLocation];
    }
        [self loadNodes];// load nodes from the dataSource
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.mapView.delegate = nil;
    [self slideOutMapInteractionAdvisor];
}

- (void) loadNodes
{
    if (loadingNodes) {
        return;
    }
    
    loadingNodes = YES;
    
    if (self.useCase == kWMPOIsListViewControllerUseCaseContribute) {
        NSArray* unfilteredNodes = [self.dataSource filteredNodeListForUseCase:self.useCase];
        NSMutableArray* newNodeList = [[NSMutableArray alloc] init];
        
        for (Node* node in unfilteredNodes) {
            if ([node.wheelchair caseInsensitiveCompare:K_STATE_UNKNOWN] == NSOrderedSame
				|| [node.wheelchair_toilet caseInsensitiveCompare:K_STATE_UNKNOWN] == NSOrderedSame) {
                [newNodeList addObject:node];
            }
        }
        nodes = newNodeList;
    } else {
        nodes = [self.dataSource filteredNodeListForUseCase:self.useCase];
    }

	NSArray *mapViewAnnotations = self.mapView.annotations.copy;
	if (mapViewAnnotations == nil) {
		mapViewAnnotations = NSArray.new;
	}

    dispatch_async(backgroundQueue, ^(void) {
        
        NSMutableArray* newAnnotations = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray* oldAnnotations = [NSMutableArray arrayWithArray:mapViewAnnotations];
        
        [nodes enumerateObjectsUsingBlock:^(Node *node, NSUInteger idx, BOOL *stop) {
            
            WMMapAnnotation *annotationForNode = [self annotationForNode:node comparisonNodes:mapViewAnnotations];
            if (annotationForNode != nil) {
				// this node is already shown on the map
                [oldAnnotations removeObject:annotationForNode];
            } else {
				// this node is new
                WMMapAnnotation *annotation = [[WMMapAnnotation alloc] initWithNode:node];
                [newAnnotations addObject:annotation];
            }
            
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [newAnnotations enumerateObjectsUsingBlock:^(WMMapAnnotation *annotation, NSUInteger idx, BOOL *stop) {
                [self.mapView addAnnotation:annotation];
            }];
            
            for (id<MKAnnotation> annotation in oldAnnotations) {
                if (![annotation isKindOfClass:[MKUserLocation class]])
                    [self.mapView removeAnnotation:annotation];
            }
            
            if (self.refreshingForFilter) {
                self.refreshingForFilter = NO;
                [self hideActivityIndicator];
            }
            loadingNodes = NO;
        });
    });
}

- (WMMapAnnotation*) annotationForNode:(Node*)node comparisonNodes:(NSArray *)comparisonNodes {

    for (WMMapAnnotation* annotation in comparisonNodes) {
        // filter out MKUserLocation annotation
        if ([annotation isKindOfClass:[WMMapAnnotation class]] && [annotation.node isEqual:node]) {
            return annotation;
        }
    }
    return nil;
}

#pragma mark - Node List View Protocol

- (void) nodeListDidChange
{
    [self loadNodes];
}

- (void)selectNode:(Node *)node
{
    WMMapAnnotation *annotation = [self annotationForNode:node comparisonNodes:self.mapView.annotations.copy];
    [self.mapView selectAnnotation:annotation animated:YES];
}

- (void)showActivityIndicator
{
    self.loadingLabel.hidden = NO;
    self.loadingWheel.hidden = NO;
    [self.loadingWheel startAnimating];
}

-(void)hideActivityIndicator
{
    self.loadingLabel.hidden = YES;
    [self.loadingWheel stopAnimating];
    self.loadingWheel.hidden = YES;
}

- (void)zoomInForNode:(Node *)node {
    dontUpdateNodeList = YES;
    [self relocateMapTo:CLLocationCoordinate2DMake(node.lat.doubleValue, node.lon.doubleValue  - 0.0005) andSpan:MKCoordinateSpanMake(0.001, 0.001)];
}

#pragma mark - Map View Delegate

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[WMMapAnnotation class]]) {
		
        Node *node = [(WMMapAnnotation*)annotation node];
        NSString *reuseId = [node.wheelchair stringByAppendingString:[node.id stringValue]];
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(6, -14);
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        annotationView.image = [UIImage imageNamed:[@"marker_" stringByAppendingString:node.wheelchair]];

        UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake(1, 3, 19, 14)];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.backgroundColor = [UIColor clearColor];
        icon.image = [[WMResourceManager sharedManager] iconForName:node.node_type.icon];

        [annotationView addSubview:icon];

        return annotationView;
	}

    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
        return;
    }
    
    if (UIDevice.currentDevice.isIPad == YES) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(nodeListView:didSelectNode:)]) {
        WMMapAnnotation *annotation = (WMMapAnnotation*)view.annotation;
        [self.delegate nodeListView:self didSelectNode:annotation.node];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([self.delegate respondsToSelector:@selector(nodeListView:didSelectNode:)]) {
        [self.delegate nodeListView:self didSelectNode:nil];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    WMMapAnnotation *annotation = (WMMapAnnotation*)view.annotation;
    [self.delegate nodeListView:self didSelectDetailsForNode:annotation.node];
}

- (IBAction)toggleMapTypeChanged:(UIButton *)sender
{
    switch (sender.tag) {
        case 0: self.mapView.mapType = MKMapTypeStandard; break;
        case 1: self.mapView.mapType = MKMapTypeHybrid; break;
        case 2: self.mapView.mapType = MKMapTypeSatellite; break;
    }
}

- (IBAction)pressedCenterLocationButton:(id)sender {
	if ([self.navigationController isKindOfClass:[WMNavigationControllerBase class]] == YES) {
		// Forward the button press to the navigation cotnroller. If it's not kind of WMNavigationControllerBase, we don't have to forward the event as we are in the POI detail view controller.
		[((WMNavigationControllerBase *)self.navigationController) pressedCurrentLocationButton:nil];
	}
}

#pragma mark - Map Interactions
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    if ([self.navigationController isKindOfClass:[WMNavigationControllerBase class]]) {
        [(WMNavigationControllerBase *)self.navigationController mapWasMoved];
    } else if ([self.navigationController isKindOfClass:[WMPOIViewController class]]) {
        [(WMPOIIPadNavigationController *)self.navigationController mapWasMoved:mapView.region.center];
    }
    
    DKLog(K_VERBOSE_MAP, @"Current Use Case %d", self.useCase);
    
    if (mapView.region.span.latitudeDelta > MIN_SPAN_DELTA || mapView.region.span.longitudeDelta > MIN_SPAN_DELTA) {
        DKLog(K_VERBOSE_MAP, @"Map is not enough zoomed in to show POIs.");
        
        NSMutableArray* oldAnnotations = [NSMutableArray arrayWithArray:self.mapView.annotations];
        for (id<MKAnnotation> annotation in oldAnnotations) {
            if (![annotation isKindOfClass:[MKUserLocation class]]) {
                [self.mapView removeAnnotation:annotation];
            }
        }
        
        [self slideInMapInteractionAdvisorWithText:NSLocalizedString(@"Zoom Closer", nil)];
        [(WMNavigationControllerBase*)self.dataSource refreshNodeListWithArray:[NSArray array]];
        lastDisplayedMapCenter = CLLocationCoordinate2DMake(0, 0);

    } else {
        [self slideOutMapInteractionAdvisor];
        
        BOOL shouldUpdateMap = YES;
        
        //
        // if map region change is smaller then threshold, then we do not update the map!
        //

		// Get the shown map corners
		CLLocation *northEastLocation = self.northEastMapLocation;
		CLLocation *southWestLocation = self.soutWestMapLocation;

        // check how much the region has changed
        CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:self.mapView.region.center.latitude longitude:self.mapView.region.center.longitude];
        CLLocation *oldCenter = [[CLLocation alloc] initWithLatitude:lastDisplayedMapCenter.latitude longitude:lastDisplayedMapCenter.longitude];
        CLLocationDistance centerDistance = [newCenter distanceFromLocation:oldCenter] /1000.0; // km

        CLLocationDistance mapRectDiagonalSize = [northEastLocation distanceFromLocation:southWestLocation] / 1000.0; // km

		if (mapRectDiagonalSize > 0.0) {
            CGFloat portionOfChangedCenter = centerDistance / mapRectDiagonalSize;

            // if delta is small and the zoomLevel hasn't changed enough, do nothing
			double zommLevelDifference = fabs(lastZoomLevel - mapView.zoomLevel);
			if (portionOfChangedCenter < MIN_MAP_MOVEMENT && zommLevelDifference < MIN_ZOOM_LEVEL_CHANGE) {
                DKLog(K_VERBOSE_MAP, @"MINIMAL CHANGE. DO NOT UPDATE MAP! portionOfChangedCenter: %f, zoomLevel: %f", portionOfChangedCenter, mapView.zoomLevel);
                shouldUpdateMap = NO;
            }
        }

        if (shouldUpdateMap && !dontUpdateNodeList) {

            if (self.useCase == kWMPOIsListViewControllerUseCaseGlobalSearch || self.useCase == kWMPOIsListViewControllerUseCaseSearchOnDemand) {
                [(WMNavigationControllerBase*)self.dataSource updateNodesWithLastQueryAndRegion:mapView.region];
                lastDisplayedMapCenter = self.mapView.region.center;
            } else {
				[(WMNavigationControllerBase*)self.dataSource updateNodesWithSouthWest:southWestLocation.coordinate andNorthEast:northEastLocation.coordinate];
                lastDisplayedMapCenter = self.mapView.region.center;
            }

			lastZoomLevel = mapView.zoomLevel;
        }
    }

    [(WMNavigationControllerBase*)self.dataSource setLastVisibleMapCenterLat:[NSNumber numberWithDouble:self.mapView.region.center.latitude]];
    [(WMNavigationControllerBase*)self.dataSource setLastVisibleMapCenterLng:[NSNumber numberWithDouble:self.mapView.region.center.longitude]];
    [(WMNavigationControllerBase*)self.dataSource setLastVisibleMapSpanLat:[NSNumber numberWithDouble:self.mapView.region.span.latitudeDelta]];
    [(WMNavigationControllerBase*)self.dataSource setLastVisibleMapSpanLng:[NSNumber numberWithDouble:self.mapView.region.span.longitudeDelta]];
    
    dontUpdateNodeList = NO;
}

- (void) relocateMapTo:(CLLocationCoordinate2D)coord
{
    MKCoordinateRegion newRegion;
    newRegion.center = coord;
    newRegion.span = self.mapView.region.span;
    
    [self.mapView setRegion:newRegion animated:YES];
    
}

- (void) relocateMapTo:(CLLocationCoordinate2D)coord andSpan:(MKCoordinateSpan)span
{
    MKCoordinateRegion newRegion;
    newRegion.center = coord;
    newRegion.span = span;
    
    [self.mapView setRegion:newRegion animated:YES];
    
}

#pragma mark - Map Helper

- (CLLocation *)northEastMapLocation {
	CLLocationCoordinate2D northEastCoordinates = [self.mapView convertPoint:CGPointMake(self.mapView.frameWidth, 0) toCoordinateFromView:self.mapView];
	return [[CLLocation alloc] initWithLatitude:northEastCoordinates.latitude longitude:northEastCoordinates.longitude];
}

- (CLLocation *)soutWestMapLocation {
	CLLocationCoordinate2D southWestCoordinates = [self.mapView convertPoint:CGPointMake(0, self.mapView.frameHeight) toCoordinateFromView:self.mapView];
	return [[CLLocation alloc] initWithLatitude:southWestCoordinates.latitude longitude:southWestCoordinates.longitude];
}

#pragma mark - Map Interaction Advisor
-(void)slideInMapInteractionAdvisorWithText:(NSString*)text
{
    if (self.mapInteractionInfoLabel.tag == 1)  // indicator is already visible
    {
        DKLog(K_VERBOSE_MAP, @"Map UI Advisor is already visibile");
        return;
    }
    
    self.mapInteractionInfoLabel.text = text;
    self.mapInteractionInfoLabelTopVerticalSpaceConstraint.constant = visibleMapInteractionInfoLabelConstraint;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.mapInteractionInfoLabel.tag = 1;
    }];
}

-(void)slideOutMapInteractionAdvisor
{
    if (self.mapInteractionInfoLabel.tag == 0)  // indicator is already invisible
        return;
    
    self.mapInteractionInfoLabelTopVerticalSpaceConstraint.constant = invisibleMapInteractionInfoLabelConstraint;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.mapInteractionInfoLabel.tag = 0;
    }];
}

#pragma mark - AlertView stuff
- (void)attribution:(NSString *)attribution
{
    NSString *title = @"Attribution";
    NSString *message = attribution;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Mapbox Details", @"OSM Details", nil];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"Attribution"])
    {
        // For the attribution alert dialog, open the Mapbox and OSM copyright pages when their respective buttons are pressed
        //
        if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Mapbox Details"])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.mapbox.com/tos/"]];
        }
        if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OSM Details"])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.openstreetmap.org/copyright"]];
        }
    }
}


@end
