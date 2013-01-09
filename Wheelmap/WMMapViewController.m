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

// TODO: re-position popover after orientation change

@implementation WMMapViewController
{
    NSArray *nodes;
    UIPopoverController *popover;
}

@synthesize dataSource, delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mapView.showsUserLocation = YES;
    //[self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:NO];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.loadingWheel.hidden = YES;
    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // we set the delegate in viewDidAppear to avoid node updates by map initialisation
    // while init the map, mapView:regionDidChange:animated called multiple times
    self.mapView.delegate = self;
    
    WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.dataSource;
    MKCoordinateRegion initRegion;
    if (!navCtrl.lastVisibleMapCenterLat || !navCtrl.lastVisibleMapSpanLat) {
        navCtrl.lastVisibleMapCenterLat = [NSNumber numberWithDouble:self.mapView.region.center.latitude];
        navCtrl.lastVisibleMapCenterLng = [NSNumber numberWithDouble:self.mapView.region.center.longitude];
        navCtrl.lastVisibleMapSpanLat = [NSNumber numberWithDouble:self.mapView.region.span.latitudeDelta];
        navCtrl.lastVisibleMapSpanLng = [NSNumber numberWithDouble:self.mapView.region.span.longitudeDelta];
        
        CLLocation* userLocation = [navCtrl currentUserLocation];
        initRegion = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.005, 0.005));
        [self.mapView setRegion:initRegion animated:NO];
        [self mapView:self.mapView regionDidChangeAnimated:NO];
        
    } else {
        initRegion = MKCoordinateRegionMake(
                                            CLLocationCoordinate2DMake([navCtrl.lastVisibleMapCenterLat doubleValue],
                                                                       [navCtrl.lastVisibleMapCenterLng doubleValue]),
                                            MKCoordinateSpanMake([navCtrl.lastVisibleMapSpanLat doubleValue],
                                                                 [navCtrl.lastVisibleMapSpanLng doubleValue])
                                            );
        [self.mapView setRegion:initRegion animated:NO];
    }
    
    if (self.useCase == kWMNodeListViewControllerUseCaseGlobalSearch || self.useCase == kWMNodeListViewControllerUseCaseSearchOnDemand) {
        // show current location button, if it is hidden
        [((WMNavigationControllerBase *)self.navigationController).customToolBar showButton:kWMToolBarButtonCurrentLocation];
        [self loadNodes];   // load nodes from the dataSource
        
    }

       
}

- (void) loadNodes
{
    nodes = [self.dataSource filteredNodeList];
    NSMutableArray* oldAnnotations = [NSMutableArray arrayWithArray:self.mapView.annotations];
    
    [nodes enumerateObjectsUsingBlock:^(Node *node, NSUInteger idx, BOOL *stop) {
        WMMapAnnotation *annotationForNode = [self annotationForNode:node];
        if (annotationForNode) {
            // this node is already shown on the map
            [oldAnnotations removeObject:annotationForNode];
        } else {
            // this node is new
            WMMapAnnotation *annotation = [[WMMapAnnotation alloc] initWithNode:node];
            [self.mapView addAnnotation:annotation];
        }
        
    }];
    for (id<MKAnnotation> annotation in oldAnnotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]])
            [self.mapView removeAnnotation:annotation];
    }
}

- (void) showDetailPopoverForNode:(Node *)node
{
    WMMapAnnotation *annotation = [self annotationForNode:node];
    MKAnnotationView *annotationView = [self.mapView viewForAnnotation:annotation];

    WMDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"WMDetailView" bundle:nil] instantiateInitialViewController];
    detailViewController.node = node;
    
    UINavigationController *detailNavController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    
    popover = [[UIPopoverController alloc] initWithContentViewController:detailNavController];
    
    CGRect annotationViewRect = [self.view convertRect:annotationView.bounds fromView:annotationView];
    [popover presentPopoverFromRect:annotationViewRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    [self.loadingWheel stopAnimating];
    self.loadingWheel.hidden = YES;
    [self loadNodes];
}

- (void)selectNode:(Node *)node
{
    WMMapAnnotation *annotation = [self annotationForNode:node];
    [self.mapView selectAnnotation:annotation animated:YES];
}


#pragma mark - Map View Delegate

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
        UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake(4, 7, 20, 15)];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.backgroundColor = [UIColor clearColor];
        icon.image = [UIImage imageWithContentsOfFile:node.node_type.iconPath];
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
    
    NSLog(@"Current Use Case %d", self.useCase);
    if (self.useCase == kWMNodeListViewControllerUseCaseGlobalSearch || self.useCase == kWMNodeListViewControllerUseCaseSearchOnDemand) {
        // do nothing
    } else {
        self.loadingWheel.hidden = NO;
        [self.loadingWheel startAnimating];
        [(WMNavigationControllerBase*)self.dataSource updateNodesWithRegion:mapView.region];
    }

    [(WMNavigationControllerBase*)self.dataSource setLastVisibleMapCenterLat:[NSNumber numberWithDouble:self.mapView.region.center.latitude]];
    [(WMNavigationControllerBase*)self.dataSource setLastVisibleMapCenterLng:[NSNumber numberWithDouble:self.mapView.region.center.longitude]];
    [(WMNavigationControllerBase*)self.dataSource setLastVisibleMapSpanLat:[NSNumber numberWithDouble:self.mapView.region.span.latitudeDelta]];
    [(WMNavigationControllerBase*)self.dataSource setLastVisibleMapSpanLng:[NSNumber numberWithDouble:self.mapView.region.span.longitudeDelta]];
}

- (void) relocateMapTo:(CLLocationCoordinate2D)coord
{
    MKCoordinateRegion newRegion;
    newRegion.center = coord;
    newRegion.span = self.mapView.region.span;
    
    [self.mapView setRegion:newRegion animated:YES];
    
}


@end




