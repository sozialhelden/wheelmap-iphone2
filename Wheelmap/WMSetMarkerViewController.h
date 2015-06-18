//
//  WMSetMarkerViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 04.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Node.h"
#import "MBXMapKit.h"

@interface WMSetMarkerViewController : WMViewController <MKMapViewDelegate, CLLocationManagerDelegate, MBXRasterTileOverlayDelegate>

@property (strong, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) MBXRasterTileOverlay *rasterOverlay;
@property (nonatomic, strong) Node *node;
@property (nonatomic, strong) MKPointAnnotation *currentAnnotation;
@property (nonatomic, assign) CLLocationCoordinate2D currentCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D initialCoordinate;

- (void)setMapToCoordinate:(CLLocationCoordinate2D)coordinate;

@end
