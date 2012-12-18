//
//  WMSetMarkerViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 04.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMSetMarkerViewController.h"
#import "WMMapAnnotation.h"
#import "WMNavigationControllerBase.h"
#import "WMEditPOIViewController.h"

@interface WMSetMarkerViewController ()
{
    CLLocationManager* locationManager;
}
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
    self.mapView.showsUserLocation = YES;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    [self.mapView addGestureRecognizer:tapRecognizer];
    
    self.currentAnnotation = [WMMapAnnotation new];
    [self. mapView addAnnotation:self.currentAnnotation];
    self.currentAnnotation.coordinate = self.currentCoordinate;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 50.0f;
	locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
    
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
    

#pragma mark - CLLocationManager Delegates
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* newLocation = [locations objectAtIndex:0];
    // region to display
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 100, 320);
    // display the region
    [self.mapView setRegion:viewRegion animated:NO];

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    // Get the specific point that was touched
    CGPoint touchLocation = [touch locationInView:self.view];
    self.currentCoordinate = [self.mapView convertPoint:touchLocation toCoordinateFromView:self.mapView];
    self.currentAnnotation.coordinate = self.currentCoordinate;
    [self.delegate markerSet:self.currentCoordinate];
}

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[WMMapAnnotation class]]) {
        NSString *reuseId = @"";
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
            annotationView.centerOffset = CGPointMake(6, -14);
        }
        annotationView.image = [UIImage imageNamed:[@"marker_" stringByAppendingString:self.node.wheelchair]];
        return annotationView;
   }
   return nil;
}

@end
