//
//  WMDetailViewController.h
//  Wheelmap
//
//  Created by Dorian Roy on 09.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Node;

@interface WMDetailViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIButton *wheelAccessButton;
@property (nonatomic, strong) UIButton *moreInfoButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *nodeTypeLabel;
@property (nonatomic, strong) UILabel *streetLabel;
@property (nonatomic, strong) UILabel *postcodeAndCityLabel;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSMutableArray *imageViewsInScrollView;

@property (nonatomic) Node *node;

@end
