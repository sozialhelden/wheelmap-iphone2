//
//  WMEditPOIPositionViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 04.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Node.h"

@interface WMEditPOIPositionViewController : WMViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) id						delegate;
@property (weak, nonatomic) IBOutlet MKMapView *		mapView;
@property (nonatomic, strong) Node *					node;
@property (nonatomic, strong) MKPointAnnotation *		currentAnnotation;
@property (nonatomic, assign) CLLocationCoordinate2D	currentCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D	initialCoordinate;

- (void)setMapToCoordinate:(CLLocationCoordinate2D)coordinate;
- (IBAction)pressedCenterLocationButton:(id)sender;

@end
