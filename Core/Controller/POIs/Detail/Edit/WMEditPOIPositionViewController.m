//
//  WMEditPOIPositionViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 04.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMEditPOIPositionViewController.h"
#import "WMMapAnnotation.h"
#import "WMNavigationControllerBase.h"
#import "WMEditPOIViewController.h"

@interface WMEditPOIPositionViewController ()

@property (strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) CLLocationManager * locationManager;
@property (weak, nonatomic) IBOutlet UIView *	infoView;
@property (weak, nonatomic) IBOutlet WMLabel *	infoTextLabel;
@property (nonatomic) Boolean shouldReCenterPinOnBeginning;
@property (nonatomic) Boolean diddReCenterPinOnBeginning;

@end

@implementation WMEditPOIPositionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.shouldReCenterPinOnBeginning = YES;
	self.diddReCenterPinOnBeginning = NO;
	
    self.mapView.showsBuildings = NO;
    self.mapView.rotateEnabled = NO;
    self.mapView.pitchEnabled = NO;
    self.mapView.mapType = MKMapTypeStandard;
	self.mapView.showsPointsOfInterest = NO;

    [self.mapView removeAnnotations:self.mapView.annotations];

    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    [self.mapView addGestureRecognizer:tapRecognizer];
    
    self.currentAnnotation = (MKPointAnnotation*)[WMMapAnnotation new];
    [self. mapView addAnnotation:self.currentAnnotation];
    self.currentAnnotation.coordinate = self.currentCoordinate;

	if (CLLocationCoordinate2DIsValid(self.currentCoordinate) == YES) {
		self.userLocation = [[CLLocation alloc] initWithLatitude:self.currentCoordinate.latitude longitude:self.currentCoordinate.longitude];
		// As the user lcoation was already set we don't want to recenter it during the opening
		self.shouldReCenterPinOnBeginning = NO;
	} else if (self.mapView.userLocation != nil && (self.mapView.userLocation.coordinate.longitude != 0 && self.mapView.userLocation.coordinate.latitude != 0)) {
		self.userLocation = [[CLLocation alloc] initWithLatitude:self.mapView.userLocation.coordinate.latitude longitude:self.mapView.userLocation.coordinate.longitude];
	} else {
		self.userLocation = [[CLLocation new] initWithLatitude:K_DEFAULT_LATITUDE longitude:K_DEFAULT_LONGITUDE];
	}
	[self setMapToCoordinate:self.userLocation.coordinate];
	if ([self.delegate respondsToSelector:@selector(markerSet:)]) {
		[self.delegate markerSet:self.userLocation.coordinate];
	}

	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	self.locationManager.delegate = self;
	[self.locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"NavBarTitleSetMarker", nil);
    self.navigationBarTitle = self.title;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.infoTextLabel.text = NSLocalizedString(@"SetMarkerInstruction", nil);

    self.infoView.alpha = 0.0;

    [UIView animateWithDuration:0.5 animations:^(void) {
		self.infoView.alpha = 1.0;
	} completion:nil];
}

- (void)setMapToCoordinate:(CLLocationCoordinate2D)coordinate {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, K_REGION_LATITUDE, K_REGION_LONGITUDE);
    // display the region
    [self.mapView setRegion:viewRegion animated:NO];
    if ([self isDeltaEnoughFrom:self.currentCoordinate toLocation:coordinate] == YES) {
        self.currentAnnotation.coordinate = coordinate;
		self.currentCoordinate = coordinate;
    }
}

#pragma mark - CLLocationManager Delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

	CLLocation *newLocation = (CLLocation *)locations.firstObject;
	BOOL shouldUpdate = (self.shouldReCenterPinOnBeginning == YES && self.diddReCenterPinOnBeginning == NO);
    self.userLocation = newLocation;
    // region to display
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.userLocation.coordinate, K_REGION_LATITUDE, K_REGION_LONGITUDE);
    // display the region
    if (shouldUpdate == YES) {
		self.diddReCenterPinOnBeginning = YES;
		[self.mapView setRegion:viewRegion animated:YES];
        self.currentAnnotation.coordinate = CLLocationCoordinate2DMake(self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude);
		if ([self.delegate respondsToSelector:@selector(markerSet:)]) {
			[self.delegate markerSet:self.currentAnnotation.coordinate];
		}
    }
}

#pragma mark - Actions

/**
 *  Move the map to the last location received by the GPS
 *
 *  @param sender The object which triggered the behaviour
 */
- (IBAction)pressedCenterLocationButton:(id)sender {
	MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, K_REGION_LATITUDE, K_REGION_LONGITUDE);
	[self.mapView setRegion:viewRegion animated:YES];
}

#pragma mark - MKMapView Delegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (newState == MKAnnotationViewDragStateEnding) {
        self.currentCoordinate = view.annotation.coordinate;
        if ([self.delegate respondsToSelector:@selector(markerSet:)]) {
            [self.delegate markerSet:self.currentCoordinate];
        }
        if ([view isKindOfClass:[MKPinAnnotationView class]]) {
            [(MKPinAnnotationView*)view setSelected:YES animated:NO];
        }
    }
}

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[WMMapAnnotation class]]) {
        NSString *reuseId = @"";
        MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        }
        annotationView.animatesDrop=YES;
        annotationView.draggable = YES;
        [annotationView setSelected:YES animated:NO];
        return annotationView;
   }
   return nil;
}

#pragma mark - Helpers

- (BOOL)isDeltaEnoughFrom:(CLLocationCoordinate2D)oldLocation toLocation:(CLLocationCoordinate2D)newLocation {

	float latitudeDelta = fabs(oldLocation.latitude - newLocation.latitude);
	float longitudeDelta = fabs(oldLocation.longitude - newLocation.longitude);
	return (latitudeDelta > 0.001 || longitudeDelta > 0.001);
}

@end
