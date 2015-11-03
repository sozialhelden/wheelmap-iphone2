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

@class Node;

@interface WMPOIViewController : WMViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, UIActionSheetDelegate, CLLocationManagerDelegate, WMDataManagerDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate, MBXRasterTileOverlayDelegate, MBXOfflineMapDownloaderDelegate, WMEditPOIStateDelegate, WMPOIStateButtonViewDelegate> {
    WMDataManager* dataManager;
    UIImage* imageReadyToUpload;
}

@property (nonatomic, strong) IBOutlet UIScrollView *	scrollView;
@property (nonatomic, strong) UIView *					mainView;
@property (nonatomic, strong) Node *					node;
@property (nonatomic, strong) UIPopoverController *		popOverController;

#pragma mark - MAP VIEW
@property (nonatomic, strong) MKMapView *				mapView;
@property (nonatomic) MBXRasterTileOverlay *			rasterOverlay;
@property (assign) BOOL									mapViewOpen;

#pragma mark - MAIN INFO VIEW
@property (nonatomic, strong) UIView *					mainInfoView;
@property (nonatomic, strong) UILabel *					titleLabel;
@property (nonatomic, strong) UILabel *					nodeTypeLabel;

#pragma mark - WHEEL ACCESS AND ASK FRIENDS BUTTON VIEW
@property (nonatomic, strong) WMPOIStateButtonView *	wheelchairStateButtonView;
@property (nonatomic, strong) WMPOIStateButtonView *	toiletStateButtonView;
@property (nonatomic, strong) UIView *					toiletStateButtonContainerView;
@property (nonatomic, strong) UIButton *				askFriendsButton;
@property (assign) int									gabIfStatusUnknown;

#pragma mark - CONTACT INFO VIEW
@property (nonatomic, strong) UIView *					contactInfoView;
@property (nonatomic, strong) UILabel *					streetLabel;
@property (nonatomic, strong) UILabel *					postcodeAndCityLabel;
@property (nonatomic, strong) UITextView *				websiteLabel;
@property (nonatomic, strong) UITextView *				phoneLabel;
@property (nonatomic, strong) UILabel *					distanceLabel;
@property (nonatomic, strong) UIImageView *				compassView;

#pragma mark - IMAGESCROLLVIEW
@property (nonatomic, strong) UIScrollView *			imageScrollView;
@property (nonatomic, strong) UIImagePickerController *	imagePicker;
@property (nonatomic, strong) NSMutableArray *			imageViewsInScrollView;
@property (nonatomic, strong) NSMutableArray *			thumbnailURLArray;
@property (nonatomic, strong) NSMutableArray *			originalImageURLArray;
@property (nonatomic, strong) UIButton *				cameraButton;
@property (nonatomic, assign) int						start;
@property (nonatomic, assign) int						gab;

#pragma mark - ADDITIONALINFOVIEW
@property (nonatomic, strong) UIView *					additionalButtonView;
@property (nonatomic, strong) UIButton *				shareLocationButton;
@property (nonatomic, strong) UIButton *				moreInfoButton;
@property (nonatomic, strong) UIButton *				naviButton;
@property (assign) int									threeButtonWidth;

@property (nonatomic) CLLocationCoordinate2D			poiLocation;
@property (nonatomic, strong) MKUserLocation *			currentLocation;
@property (nonatomic, strong) MKAnnotationView *		annotationView;
@property (nonatomic, strong) WMMapAnnotation *			annotation;

@property (nonatomic, assign) int						startY;
@property (nonatomic, strong) UIButton *				enlargeMapButton;

- (void) pushEditViewController;

@end
