//
//  WMPOIMapViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 13.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMPOIMapViewController.h"
#import "WMMapAnnotation.h"

@interface WMPOIMapViewController ()

@end

@implementation WMPOIMapViewController

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
    self.mapView.delegate = self;
    self.mapView.userInteractionEnabled = YES;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.annotation = [[WMMapAnnotation alloc] initWithNode:self.node];
    [self.mapView addAnnotation:self.annotation];
    self.mapView.showsUserLocation=YES;
    

    
}

- (void)viewDidAppear:(BOOL)animated{
    
     self.poiLocation = CLLocationCoordinate2DMake(self.node.lat.doubleValue, self.node.lon.doubleValue);
    // region to display
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.poiLocation, 500, 1000);
    viewRegion.center = self.poiLocation;
    
    // display the region
    [self.mapView setRegion:viewRegion animated:YES];

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

#pragma mark - Map

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[WMMapAnnotation class]]) {
        Node *node = [(WMMapAnnotation*)annotation node];
        NSString *reuseId = @"";
       // NSString *reuseId = [node.wheelchair stringByAppendingString:node.node_type.identifier];
        self.annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        if (!self.annotationView) {
            self.annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
            self.annotationView.canShowCallout = NO;
            self.annotationView.centerOffset = CGPointMake(6, -14);
            self.annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        self.annotationView.image = [UIImage imageNamed:[@"marker_" stringByAppendingString:node.wheelchair]];
        return self.annotationView;
    }
    return nil;
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

@end
