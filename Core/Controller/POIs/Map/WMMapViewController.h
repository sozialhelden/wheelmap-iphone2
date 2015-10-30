//
//  WMMapViewController.h
//  Wheelmap
//
//  Created by Dorian Roy on 07.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WMDataManager.h"
#import <MBXMapKit/MBXMapKit.h>
#import <CoreLocation/CoreLocation.h>

@class MKMapView, Node;

@interface WMMapViewController : WMViewController <WMPOIsListViewDelegate, MKMapViewDelegate, MBXRasterTileOverlayDelegate>
{
    WMDataManager *dataManager;
}
@property (nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) MBXRasterTileOverlay *rasterOverlay;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic) IBOutlet UIView* loadingContainer;
@property (nonatomic) IBOutlet UIActivityIndicatorView* loadingWheel;
@property (nonatomic) IBOutlet WMLabel* loadingLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mapInteractionInfoLabelTopVerticalSpaceConstraint;
@property (nonatomic) IBOutlet UILabel *mapInteractionInfoLabel;

@property (nonatomic) MKCoordinateRegion region;
@property WMPOIsListViewControllerUseCase useCase;
@property BOOL refreshingForFilter;

- (IBAction) toggleMapTypeChanged:(UIButton *)sender;

- (void)zoomInForNode:(Node *)node;
- (void) relocateMapTo:(CLLocationCoordinate2D)coord;
- (void) relocateMapTo:(CLLocationCoordinate2D)coord andSpan:(MKCoordinateSpan)span;

@end