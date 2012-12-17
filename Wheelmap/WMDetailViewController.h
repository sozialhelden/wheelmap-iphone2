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
#import "WMDataManager.h"

@class Node;

@interface WMDetailViewController : WMViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, UIActionSheetDelegate, CLLocationManagerDelegate, WMDataManagerDelegate>
{
    WMDataManager* dataManager;
}
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) Node *node;

//// 2 MAIN COMPONENTS OF THE MAIN VIEW

//MAP VIEW
@property (nonatomic, strong) MKMapView *mapView;
@property (assign) BOOL mapViewOpen;
//CONTENT VIEW
@property (nonatomic, strong) UIView *contentView;

//// PARTS OF THE CONTENT VIEW

// MAIN INFO VIEW
@property (nonatomic, strong) UIView *mainInfoView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *nodeTypeLabel;
// WHEEL ACCESS AND ASK FRIENDS BUTTON VIEW
@property (nonatomic, strong) UIView *wheelAccessView;
@property (nonatomic, strong) UIButton *wheelAccessButton;
@property (nonatomic, strong) UIImage *accessImage;
@property (nonatomic, strong) NSString *wheelchairAccess;
@property (nonatomic, strong) UIButton *askFriendsButton;
@property (assign) int gabIfStatusUnknown;
// CONTACT INFO VIEW
@property (nonatomic, strong) UIView *contactInfoView;
@property (nonatomic, strong) UILabel *streetLabel;
@property (nonatomic, strong) UILabel *postcodeAndCityLabel;
@property (nonatomic, strong) UITextView *websiteLabel;
@property (nonatomic, strong) UITextView *phoneLabel;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UIImageView *compassView;
// IMAGESCROLLVIEW
@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSMutableArray *imageViewsInScrollView;
@property (nonatomic, strong) NSMutableArray* thumbnailURLArray;
@property (nonatomic, strong) NSMutableArray* originalImageURLArray;
@property (nonatomic, assign) int start;
@property (nonatomic, assign) int gab;
// ADDITIONALINFOVIEW
@property (nonatomic, strong) UIView *additionalButtonView;
@property (nonatomic, strong) UIButton *shareLocationButton;
@property (nonatomic, strong) UIButton *moreInfoButton;
@property (nonatomic, strong) UIButton *naviButton;
@property (assign) int threeButtonWidth;





@property (nonatomic) CLLocationCoordinate2D poiLocation;
@property (nonatomic, strong) MKUserLocation *currentLocation;
@property (nonatomic, strong) MKAnnotationView *annotationView;
@property (nonatomic, strong) WMMapAnnotation *annotation;

@property (nonatomic, assign) int startY;
@property (nonatomic, strong) UIButton *enlargeMapButton;




- (void) pushEditViewController;
- (void) setUpdatedNode: (Node*) node;

@end
