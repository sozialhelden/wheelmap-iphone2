//
//  WMPOIMapViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 13.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "WMViewController.h"
#import "Node.h"
#import "WMMapAnnotation.h"

@interface WMPOIMapViewController : WMViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet Node *node;
@property (nonatomic, strong) MKAnnotationView *annotationView;
@property (nonatomic, strong) WMMapAnnotation *annotation;
@property (nonatomic) CLLocationCoordinate2D poiLocation;

@end
