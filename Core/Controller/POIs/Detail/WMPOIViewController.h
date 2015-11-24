//
//  WMPOIViewController.h
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
#import "MBXMapKit.h"
#import "WMPOIStateButtonView.h"
#import "WMCompassView.h"

@class Node;

@interface WMPOIViewController : WMViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, UIActionSheetDelegate, CLLocationManagerDelegate, WMDataManagerDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate, MBXRasterTileOverlayDelegate, MBXOfflineMapDownloaderDelegate, WMEditPOIStateDelegate, WMPOIStateButtonViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, WMSmallGalleryButtonCollectionViewCellDelegate> {
    WMDataManager* dataManager;
    UIImage* imageReadyToUpload;
}

@property (nonatomic, strong) IBOutlet UIScrollView *			scrollView;

@property (weak, nonatomic) IBOutlet UILabel *					poiNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *					poiCategoryLabel;

@property (weak, nonatomic) IBOutlet UIView *					wheelchairStateButtonViewContainer;
@property (weak, nonatomic) IBOutlet UIView *					toiletStateButtonViewContainer;

@property (weak, nonatomic) IBOutlet UIView	*					askFriendsView;
@property (weak, nonatomic) IBOutlet UIButton *					askFriendsButton;
@property (weak, nonatomic) IBOutlet UILabel *					askFriendsButtonTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *		askFriendsViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *					addressView;
@property (weak, nonatomic) IBOutlet MarqueeLabel *				addressStreetLabel;
@property (weak, nonatomic) IBOutlet MarqueeLabel *				addressPLZCityLabel;
@property (weak, nonatomic) IBOutlet MarqueeLabel *				addressWebsiteLabel;
@property (weak, nonatomic) IBOutlet MarqueeLabel *				addressPhoneTextLabel;
@property (weak, nonatomic) IBOutlet WMCompassView *			addressCompassView;
@property (weak, nonatomic) IBOutlet UILabel *					addressDistanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *					shareButton;
@property (weak, nonatomic) IBOutlet UILabel *					shareButtonTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *					noteButton;
@property (weak, nonatomic) IBOutlet UILabel *					noteButtonTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *		notButtonTitleLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *					directionButton;
@property (weak, nonatomic) IBOutlet UILabel *					directionButtonTitleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *		scrollViewContentHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *		scrollViewContentWidthConstraint;


@property (nonatomic, strong) Node *							node;
@property (nonatomic, strong) UIPopoverController *				popOverController;

#pragma mark - MAP VIEW

@property (nonatomic, strong) IBOutlet MKMapView *				mapView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *		mapViewViewHeightConstraint;
@property (nonatomic) MBXRasterTileOverlay *					rasterOverlay;
@property (assign) BOOL											mapViewOpen;

#pragma mark - WHEEL ACCESS AND ASK FRIENDS BUTTON VIEW

@property (nonatomic, strong) WMPOIStateButtonView *			wheelchairStateButtonView;
@property (nonatomic, strong) WMPOIStateButtonView *			toiletStateButtonView;

#pragma mark - IMAGESCROLLVIEW

@property (nonatomic, strong) UIImagePickerController *			imagePicker;
@property (nonatomic, strong) NSMutableArray *					imageViewsInScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *			galleryCollectionView;

@property (nonatomic, strong) NSMutableArray *					thumbnailURLArray;
@property (nonatomic, strong) NSMutableArray *					originalImageURLArray;


@property (nonatomic) CLLocationCoordinate2D					poiLocation;
@property (nonatomic, strong) MKUserLocation *					currentLocation;
@property (nonatomic, strong) MKAnnotationView *				annotationView;
@property (nonatomic, strong) WMMapAnnotation *					annotation;

- (void) pushEditViewController;

@end
