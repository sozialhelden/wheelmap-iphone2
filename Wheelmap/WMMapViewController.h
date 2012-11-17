//
//  WMMapViewController.h
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WMNodeListView.h"


@class MKMapView;

@interface WMMapViewController : UIViewController <WMNodeListView, MKMapViewDelegate>


@property (nonatomic) IBOutlet MKMapView *mapView;

- (void) showDetailPopoverForNode:(NSDictionary*)node;

- (IBAction) toggleMapTypeChanged:(id)sender;
- (IBAction) returnToListViewTouched:(id)sender;


@end