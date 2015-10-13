//
//  WMMapViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMMapViewController.h"
#import "WMMapAnnotation.h"
#import "WMDetailViewController.h"
#import "Node.h"
#import "NodeType.h"
#import "WMNavigationControllerBase.h"
#import "WMMapSettingsViewController.h"
#import "WMDetailNavigationController.h"
#import "WMResourceManager.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

#define MIN_SPAN_DELTA 0.01

#define DEFAULT_SEARCH_SPAN_LAT 0.005
#define DEFAULT_SEARCH_SPAN_LONG 0.006

// TODO: re-position popover after orientation change

@implementation WMMapViewController
{
    dispatch_queue_t backgroundQueue;
    
    NSArray *nodes;
    UIPopoverController *popover;
    
    CLLocationCoordinate2D lastDisplayedMapCenter;
    
    BOOL dontUpdateNodeList;
    BOOL loadingNodes;
    
    float invisibleMapInteractionInfoLabelConstraint;
    float visibleMapInteractionInfoLabelConstraint;
    
    CLLocation* userCurrentLocation;
}

@synthesize dataSource, delegate;

- (MKCoordinateRegion)region {
    
    double lat = 0.0;
    double lon = 0.0;
    
    WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.baseController;
    
    if (navCtrl.lastVisibleMapCenterLat == nil) {
        
        lat = navCtrl.currentLocation.coordinate.latitude;
        lon = navCtrl.currentLocation.coordinate.longitude;
        
    } else {
        lat = [navCtrl.lastVisibleMapCenterLat doubleValue];
        lon = [navCtrl.lastVisibleMapCenterLng doubleValue];
    }
    NSLog(@"Get region center = %f %f", lat, lon);
    
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
    
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMConfigFilename ofType:@"plist"]];
    [MBXMapKit setAccessToken:[config valueForKey:K_ACESSS_TOKEN]];
    self.mapView.showsBuildings = NO;
    self.mapView.rotateEnabled = NO;
    self.mapView.pitchEnabled = NO;
    self.mapView.mapType = MKMapTypeStandard;
    self.rasterOverlay = [[MBXRasterTileOverlay alloc] initWithMapID:[config valueForKey:K_MAP_ID]];
    self.rasterOverlay.delegate = self;
    [self.mapView addOverlay:self.rasterOverlay];
    self.mapView.showsUserLocation = YES;
    
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
    
 
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if (IS_OS_8_OR_LATER)
    {
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    
    self.locationManager.distanceFilter = 50.0f;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startMonitoringSignificantLocationChanges];
    
    userCurrentLocation = self.locationManager.location;
    [self relocateMapTo:userCurrentLocation.coordinate andSpan:MKCoordinateSpanMake(0.001, 0.001)];
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
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // we set the delegate in viewDidAppear to avoid node updates by map initialisation
    // while init the map, mapView:regionDidChange:animated called multiple times
    self.mapView.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
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
    
    if (self.useCase == kWMNodeListViewControllerUseCaseGlobalSearch ||
        self.useCase == kWMNodeListViewControllerUseCaseSearchOnDemand)
    {
        // show current location button, if it is hidden
        [((WMNavigationControllerBase *)self.navigationController).customToolBar showButton:kWMToolBarButtonCurrentLocation];
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
    
    if (self.useCase == kWMNodeListViewControllerUseCaseContribute) {
        NSArray* unfilteredNodes = [self.dataSource filteredNodeList];
        NSMutableArray* newNodeList = [[NSMutableArray alloc] init];
        
        for (Node* node in unfilteredNodes) {
            if ([node.wheelchair caseInsensitiveCompare:@"unknown"] == NSOrderedSame) {
                [newNodeList addObject:node];
            }
        }
        nodes = newNodeList;
    } else {
        nodes = [self.dataSource filteredNodeList];
    }
    
    NSLog(@"NEW NODE LIST: %lu", (unsigned long)nodes.count);
    
    dispatch_async(backgroundQueue, ^(void) {
        
        NSMutableArray* newAnnotations = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray* oldAnnotations = [NSMutableArray arrayWithArray:self.mapView.annotations];
        
        [nodes enumerateObjectsUsingBlock:^(Node *node, NSUInteger idx, BOOL *stop) {
            
            WMMapAnnotation *annotationForNode = [self annotationForNode:node];
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

- (IBAction)iPhoneInfoButtonAction:(id)sender {
    // This responds to the info button from the iPhone storyboard getting pressed
    //
    [self attribution:_rasterOverlay.attribution];
}

- (WMMapAnnotation*) annotationForNode:(Node*)node
{
    for (WMMapAnnotation* annotation in  self.mapView.annotations) {
        
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
    WMMapAnnotation *annotation = [self annotationForNode:node];
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
// And this somewhere in your class that’s mapView’s delegate (most likely a view controller).
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    // This is boilerplate code to connect tile overlay layers with suitable renderers
    //
    if ([overlay isKindOfClass:[MBXRasterTileOverlay class]])
    {
        MBXRasterTileRenderer *renderer = [[MBXRasterTileRenderer alloc] initWithTileOverlay:overlay];
        return renderer;
    }
    return nil;
}

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
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

#pragma mark - Map Interactions
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    if ([self.navigationController isKindOfClass:[WMNavigationControllerBase class]]) {
        [(WMNavigationControllerBase *)self.navigationController mapWasMoved];
    } else if ([self.navigationController isKindOfClass:[WMDetailViewController class]]) {
        [(WMDetailNavigationController *)self.navigationController mapWasMoved:mapView.region.center];
    }
    
    NSLog(@"Current Use Case %d", self.useCase);
    //    if (self.useCase == kWMNodeListViewControllerUseCaseGlobalSearch || self.useCase == kWMNodeListViewControllerUseCaseSearchOnDemand) {
    //        // do nothing
    //        return;
    //    }
    
    if (mapView.region.span.latitudeDelta > MIN_SPAN_DELTA || mapView.region.span.longitudeDelta > MIN_SPAN_DELTA) {
        NSLog(@"Map is not enough zoomed in to show POIs.");
        
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
        
        // check how much the region has changed
        
        CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:self.mapView.region.center.latitude longitude:self.mapView.region.center.longitude];
        CLLocation *oldCenter = [[CLLocation alloc] initWithLatitude:lastDisplayedMapCenter.latitude longitude:lastDisplayedMapCenter.longitude];
        CLLocationDistance centerDistance = [newCenter distanceFromLocation:oldCenter] /1000.0; // km
        
        MKCoordinateRegion coordinateRegion = self.mapView.region;
        CLLocationCoordinate2D ne =
        CLLocationCoordinate2DMake(coordinateRegion.center.latitude
                                   + (coordinateRegion.span.latitudeDelta/2.0),
                                   coordinateRegion.center.longitude
                                   - (coordinateRegion.span.longitudeDelta/2.0));
        CLLocationCoordinate2D sw =
        CLLocationCoordinate2DMake(coordinateRegion.center.latitude
                                   - (coordinateRegion.span.latitudeDelta/2.0),
                                   coordinateRegion.center.longitude
                                   + (coordinateRegion.span.longitudeDelta/2.0));
        
        CLLocation *neLocation = [[CLLocation alloc] initWithLatitude:ne.latitude longitude:ne.longitude];
        CLLocation *swLocation = [[CLLocation alloc] initWithLatitude:sw.latitude longitude:sw.longitude];
        CLLocationDistance mapRectDiagonalSize = [neLocation distanceFromLocation:swLocation] / 1000.0; // km
        if (mapRectDiagonalSize > 0.0) {
            CGFloat portionOfChangedCenter = centerDistance / mapRectDiagonalSize;
            
            // if delta is small, do nothing
            if (portionOfChangedCenter  < 0.24) {
                NSLog(@"MINIMAL CHANGE. DO NOT UPDATE MAP! %f", portionOfChangedCenter);
                shouldUpdateMap = NO;
            }
        }
        
        if (shouldUpdateMap && !dontUpdateNodeList) {
            
            if (self.useCase == kWMNodeListViewControllerUseCaseGlobalSearch || self.useCase == kWMNodeListViewControllerUseCaseSearchOnDemand) {
                [(WMNavigationControllerBase*)self.dataSource updateNodesWithLastQueryAndRegion:mapView.region];
                lastDisplayedMapCenter = self.mapView.region.center;
            } else {
                [(WMNavigationControllerBase*)self.dataSource updateNodesWithRegion:mapView.region];
                lastDisplayedMapCenter = self.mapView.region.center;
            }
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
#pragma mark - MBXRasterTileOverlayDelegate implementation

- (void)tileOverlay:(MBXRasterTileOverlay *)overlay didLoadMetadata:(NSDictionary *)metadata withError:(NSError *)error
{
    // This delegate callback is for centering the map once the map metadata has been loaded
    //
    if (error)
    {
        NSLog(@"Failed to load metadata for map ID %@ - (%@)", overlay.mapID, error?error:@"");
    }
    else
    {
        [self.mapView setCenterCoordinate:userCurrentLocation.coordinate];
    }
}


- (void)tileOverlay:(MBXRasterTileOverlay *)overlay didLoadMarkers:(NSArray *)markers withError:(NSError *)error
{
    // This delegate callback is for adding map markers to an MKMapView once all the markers for the tile overlay have loaded
    //
    if (error)
    {
        NSLog(@"Failed to load markers for map ID %@ - (%@)", overlay.mapID, error?error:@"");
    }
    else
    {
        [_mapView addAnnotations:markers];
    }
}

- (void)tileOverlayDidFinishLoadingMetadataAndMarkers:(MBXRasterTileOverlay *)overlay
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Map Interaction Advisor
-(void)slideInMapInteractionAdvisorWithText:(NSString*)text
{
    if (self.mapInteractionInfoLabel.tag == 1)  // indicator is already visible
    {
        NSLog(@"Map UI Advisor is already visibile");
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