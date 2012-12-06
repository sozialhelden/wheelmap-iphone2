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

@interface WMSetMarkerViewController : WMViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) Node *node;

@end
