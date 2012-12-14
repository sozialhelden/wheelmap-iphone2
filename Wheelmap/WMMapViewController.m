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
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
}

- (void) viewWillAppear:(BOOL)animated
{
    
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    if (self.navigationController.toolbarHidden) {
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
     
     
    self.loadingWheel.hidden = YES;
    [self loadNodes];
}

- (void) loadNodes
{
    nodes = [self.dataSource filteredNodeList];
    
    // TODO: optimization: don't remove annotations that will be added again
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [nodes enumerateObjectsUsingBlock:^(Node *node, NSUInteger idx, BOOL *stop) {
        WMMapAnnotation *annotation = [[WMMapAnnotation alloc] initWithNode:node];
        [self.mapView addAnnotation:annotation];
    }];
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
        NSString *reuseId = [node.wheelchair stringByAppendingString:node.node_type.identifier];
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(6, -14);
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        annotationView.image = [UIImage imageNamed:[@"marker_" stringByAppendingString:node.wheelchair]];
        UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 17, 13)];
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
    if (self.useCase != kWMNodeListViewControllerUseCaseSearch) {
        self.loadingWheel.hidden = NO;
        [self.loadingWheel startAnimating];
        [(WMNavigationControllerBase*)self.dataSource updateNodesWithRegion:mapView.region];
    }
}

- (void) relocateMapTo:(CLLocationCoordinate2D)coord
{
    MKCoordinateRegion newRegion;
    newRegion.center = coord;
    newRegion.span = self.mapView.region.span;
    
    [self.mapView setRegion:newRegion animated:YES];
    
}

@end




