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
    
    self.currentAnnotation = (MKPointAnnotation*)[WMMapAnnotation new];
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
    
    self.title = NSLocalizedString(@"NavBarTitleSetMarker", nil);
    self.navigationBarTitle = self.title;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIImageView* accesoryHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 80, self.view.frame.size.width-20, 60)];
    accesoryHeader.image = [[UIImage imageNamed:@"misc_position-info.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    accesoryHeader.center = CGPointMake(self.view.center.x, accesoryHeader.center.y);
    
    WMLabel* headerTextLabel = [[WMLabel alloc] initWithFrame:CGRectMake(10, 0, accesoryHeader.frame.size.width-20, 60)];
    headerTextLabel.fontSize = 13.0;
    headerTextLabel.textAlignment = UITextAlignmentLeft;
    headerTextLabel.numberOfLines = 3;
    headerTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
    headerTextLabel.textColor = [UIColor whiteColor];
    headerTextLabel.text = NSLocalizedString(@"SetMarkerInstruction", nil);
    [accesoryHeader addSubview:headerTextLabel];
    
    accesoryHeader.alpha = 0.0;
    accesoryHeader.transform = CGAffineTransformMakeTranslation(0, 10);
    [self.view addSubview:accesoryHeader];
    
    [UIView animateWithDuration:0.5 animations:^(void)
    {
        accesoryHeader.alpha = 1.0;
        accesoryHeader.transform = CGAffineTransformMakeTranslation(0, 0);
    }
                    completion:^(BOOL finished)
    {
              
    }
    ];

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
    if (self.currentCoordinate.latitude < 0.001 && self.currentCoordinate.longitude < 0.001) {
        self.currentAnnotation.coordinate = CLLocationCoordinate2DMake(newLocation.coordinate.latitude+0.001, newLocation.coordinate.longitude+0.001);
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding) {
        self.currentCoordinate = view.annotation.coordinate;
        if ([self.delegate respondsToSelector:@selector(markerSet:)]) {
            [self.delegate markerSet:self.currentCoordinate];
        }
    }
}
- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[WMMapAnnotation class]]) {
        NSString *reuseId = @"";
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
            annotationView.centerOffset = CGPointMake(10, -14);
        }
        annotationView.image = [UIImage imageNamed:@"marker_position.png"];
        annotationView.draggable = YES;
        return annotationView;
   }
   return nil;
}

@end
