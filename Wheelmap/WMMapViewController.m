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
#import <QuartzCore/QuartzCore.h>

#define MIN_SPAN_DELTA 0.02

// TODO: re-position popover after orientation change

@implementation WMMapViewController
{
    NSArray *nodes;
    UIPopoverController *popover;
    
    CLLocationCoordinate2D lastDisplayedMapCenter;
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
    
    // configure mapInteractionInfoLabel
    self.mapInteractionInfoLabel.transform = CGAffineTransformMakeTranslation(0, -self.mapInteractionInfoLabel.frame.size.height*3);
    self.mapInteractionInfoLabel.tag = 0;   // tag 0 means that the indicator is not visible
    self.mapInteractionInfoLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.mapInteractionInfoLabel.layer.borderWidth = 2.0;
    self.mapInteractionInfoLabel.layer.cornerRadius = 10.0;
    self.mapInteractionInfoLabel.layer.masksToBounds = YES;
    self.mapInteractionInfoLabel.numberOfLines = 2;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.mapInteractionInfoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    
    dataManager = [[WMDataManager alloc] init];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self slideOutMapInteractionAdvisor];
}

- (void) loadNodes
{
        
    if (self.useCase == kWMNodeListViewControllerUseCaseContribute) {
        NSArray* unfilteredNodes = [self.dataSource nodeList];
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

    
    NSMutableArray* oldAnnotations = [NSMutableArray arrayWithArray:self.mapView.annotations];
    
    // fix for map sometimes showing old annotations on ipad
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        for (id<MKAnnotation> annotation in oldAnnotations) {
//            if (![annotation isKindOfClass:[MKUserLocation class]])
//                [self.mapView removeAnnotation:annotation];
//        }
//    }
    
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
    self.loadingWheel.hidden = NO;
    [self.loadingWheel startAnimating];
}

-(void)hideActivityIndicator
{
    [self.loadingWheel stopAnimating];
    self.loadingWheel.hidden = YES;
}

- (void)zoomInForNode:(Node *)node {
    [self relocateMapTo:CLLocationCoordinate2DMake(node.lat.doubleValue, node.lon.doubleValue  - 0.0005) andSpan:MKCoordinateSpanMake(0.001, 0.001)];
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
        UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake(1, 3, 19, 14)];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.backgroundColor = [UIColor clearColor];
        icon.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@",dataManager.iconImageRootPath, node.node_type.icon]];
        annotationView.alpha = 0.0;
        [annotationView addSubview:icon];
        
        [UIView animateWithDuration:0.2f animations:^(void){
            annotationView.alpha = 1.0;
        }
                         completion:^(BOOL finished) {
            annotationView.alpha = 1.0;
                         
        }];
        
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
    NSLog(@"Current Use Case %d", self.useCase);
    if (self.useCase == kWMNodeListViewControllerUseCaseGlobalSearch || self.useCase == kWMNodeListViewControllerUseCaseSearchOnDemand) {
        // do nothing
        return;
    }
    
    if (mapView.region.span.latitudeDelta > MIN_SPAN_DELTA || mapView.region.span.longitudeDelta > MIN_SPAN_DELTA) {
        NSLog(@"Map is not enough zoomed in to show POIs.");
        
        NSMutableArray* oldAnnotations = [NSMutableArray arrayWithArray:self.mapView.annotations];
        for (id<MKAnnotation> annotation in oldAnnotations) {
            if (![annotation isKindOfClass:[MKUserLocation class]]) {
                MKAnnotationView *pinView = [self.mapView viewForAnnotation:annotation];
                [UIView animateWithDuration:0.2f animations:^{
                    pinView.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    [self.mapView removeAnnotation:annotation];
                }];
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
        
        if (shouldUpdateMap) {
            [(WMNavigationControllerBase*)self.dataSource updateNodesWithRegion:mapView.region];
            lastDisplayedMapCenter = self.mapView.region.center;
        }
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

- (void) relocateMapTo:(CLLocationCoordinate2D)coord andSpan:(MKCoordinateSpan)span
{
    MKCoordinateRegion newRegion;
    newRegion.center = coord;
    newRegion.span = span;
    
    [self.mapView setRegion:newRegion animated:YES];
    
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
    [UIView animateWithDuration:0.3f animations:^{
        self.mapInteractionInfoLabel.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        self.mapInteractionInfoLabel.tag = 1;
    }];
    
    
    
}

-(void)slideOutMapInteractionAdvisor
{
    if (self.mapInteractionInfoLabel.tag == 0)  // indicator is already invisible
        return;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.mapInteractionInfoLabel.transform = CGAffineTransformMakeTranslation(0, -self.mapInteractionInfoLabel.frame.size.height*3);
    } completion:^(BOOL finished) {
        self.mapInteractionInfoLabel.tag = 0;
    }];
}


@end




