//
//  WMDetailViewController.h
//  Wheelmap
//
//  Created by Dorian Roy on 09.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WMMapAnnotation.h"

@class Node;

@interface WMDetailViewController : WMViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSMutableArray *imageViewsInScrollView;
@property (assign) int gabIfStatusUnknown;
@property (assign) int imageCount;
@property (nonatomic) Node *node;
@property (nonatomic, strong) UIImage *accessImage;
@property (nonatomic, strong) NSString *wheelchairAccess;
@property (nonatomic, strong) UIView *fourButtonView;

@property (nonatomic, strong) WMMapAnnotation *annotation;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *nodeTypeLabel;
@property (nonatomic, strong) UILabel *streetLabel;
@property (nonatomic, strong) UILabel *postcodeAndCityLabel;
@property (nonatomic, strong) UILabel *distanceLabel;

@property (nonatomic, strong) UIButton *wheelAccessButton;
@property (nonatomic, strong) UIButton *moreInfoButton;
@property (nonatomic, strong) UIButton *callButton;
@property (nonatomic, strong) UIButton *websiteButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *naviButton;
@property (nonatomic, strong) UIButton *shareLocationButton;


- (void) pushEditViewController;
- (void) setUpdatedNode: (Node*) node;

@end
