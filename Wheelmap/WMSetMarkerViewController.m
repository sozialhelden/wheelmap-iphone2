//
//  WMSetMarkerViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 04.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMSetMarkerViewController.h"
#import "WMMapAnnotation.h"

@interface WMSetMarkerViewController ()

@end

@implementation WMSetMarkerViewController

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
	// Do any additional setup after loading the view.
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.mapView.delegate = self;
    WMMapAnnotation *annotation = [[WMMapAnnotation alloc] initWithNode:self.node];
    [self.mapView addAnnotation:annotation];
    // location to zoom in
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = self.node.lat.doubleValue;  // increase to move upwards
    zoomLocation.longitude = self.node.lon.doubleValue; // increase to move to the right
    // region to display
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 100, 320);
    // display the region
    [self.mapView setRegion:viewRegion animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"SetMarker", nil);
    self.navigationBarTitle = self.title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

#pragma mark - Map View Delegate

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[WMMapAnnotation class]]) {
        Node *node = [(WMMapAnnotation*)annotation node];
        NSString *reuseId = @"";
        //[node.wheelchair stringByAppendingString:node.node_type.identifier];
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(6, -14);
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        annotationView.image = [UIImage imageNamed:[@"marker_" stringByAppendingString:node.wheelchair]];
        return annotationView;
    }
    return nil;
}

@end
