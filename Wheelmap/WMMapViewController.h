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

@class MKMapView, Node;

@interface WMMapViewController : WMViewController <WMNodeListView, MKMapViewDelegate>

@property (nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) IBOutlet UIActivityIndicatorView* loadingWheel;
@property (nonatomic) IBOutlet UILabel *mapInteractionInfoLabel;
@property WMNodeListViewControllerUseCase useCase;

- (void) showDetailPopoverForNode:(Node*)node;

- (IBAction) toggleMapTypeChanged:(UIButton *)sender;

- (void) relocateMapTo:(CLLocationCoordinate2D)coord;
- (void) relocateMapTo:(CLLocationCoordinate2D)coord andSpan:(MKCoordinateSpan)span;

//- (IBAction) returnToListViewTouched:(id)sender;


@end
