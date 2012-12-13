//
//  WMDetailViewController.h
//  Wheelmap
//
//  Created by Dorian Roy on 09.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "WMMapAnnotation.h"

@class Node;

@interface WMDetailViewController : WMViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, UIActionSheetDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSMutableArray *imageViewsInScrollView;
@property (nonatomic, strong) NSMutableArray *imageURLArray;
@property (nonatomic, strong) UIView *contactInfoView;

@property (assign) int gabIfStatusUnknown;
@property (nonatomic) Node *node;
@property (nonatomic, strong) UIImage *accessImage;
@property (nonatomic, strong) NSString *wheelchairAccess;
@property (nonatomic, strong) UIView *fourButtonView;
@property (nonatomic, strong) MKAnnotationView *annotationView;

@property (nonatomic, strong) UIImageView *compassView;
@property (nonatomic, assign) int startY;
@property (nonatomic, assign) int start;
@property (nonatomic, assign) int gab;

@property (nonatomic, strong) WMMapAnnotation *annotation;

@property (nonatomic, strong) UILabel *headingLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *nodeTypeLabel;
@property (nonatomic, strong) UILabel *streetLabel;
@property (nonatomic, strong) UILabel *postcodeAndCityLabel;
@property (nonatomic, strong) UITextView *websiteLabel;
@property (nonatomic, strong) UITextView *phoneLabel;
@property (nonatomic, strong) UILabel *distanceLabel;

@property (nonatomic, strong) UIButton *wheelAccessButton;
@property (nonatomic, strong) UIButton *moreInfoButton;
@property (nonatomic, strong) UIButton *callButton;
@property (nonatomic, strong) UIButton *websiteButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *naviButton;
@property (nonatomic, strong) UIButton *shareLocationButton;
@property (nonatomic, strong) UIButton *askFriendsButton;

@property (nonatomic) CLLocationCoordinate2D poiLocation;
@property (nonatomic, strong) MKUserLocation *currentLocation;



- (void) pushEditViewController;
- (void) setUpdatedNode: (Node*) node;

@end
