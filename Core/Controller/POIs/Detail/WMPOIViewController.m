//
//  WMPOIViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 09.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "WMPOIViewController.h"
#import "Node.h"
#import "NodeType.h"
#import "Image.h"
#import "Photo.h"
#import "WMEditPOIStateViewController.h"
#import "WMShareSocialViewController.h"
#import "WMEditPOICommentViewController.h"
#import "WMEditPOIViewController.h"
#import "WMMapAnnotation.h"
#import "WMInfinitePhotoViewController.h"
#import "UIImageView+AFNetworking.h"
#import "WMCategory.h"
#import "WMPOIsListViewController.h"
#import "WMPOIIPadNavigationController.h"
#import "WMResourceManager.h"
#import "WMSmallGalleryImageCollectionViewCell.h"
#import "WMSmallGalleryButtonCollectionViewCell.h"

#define K_GALLEY_BUTTON_INDEX_OFFSET	1

#define K_MAP_HEIGHT_SMALL				120
#define K_MAP_HEIGHT_LARGE				360

#define K_ASK_FRIENDS_HEIGHT			60

@interface WMPOIViewController()
@property (weak, nonatomic) IBOutlet UIButton *centerMapButton;
@end

@implementation WMPOIViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    
    // data manager
    dataManager = [[WMDataManager alloc] init];
    dataManager.delegate = self;
    
    // request photo urls
    [dataManager fetchPhotosForNode:self.node];

    NSAssert(self.node, @"You need to set a node before this view controller can be presented");
    
	[self initMapView];
	[self initPOIStateButtons];
	[self initAskFriendsView];
	[self initAddressView];
	[self initGalleryView];
	[self initAdditionalButtons];

	if (UIDevice.currentDevice.isIPad == YES) {
		self.scrollViewContentWidthConstraint.constant = K_POPOVER_VIEW_WIDTH;
	} else {
		self.scrollViewContentWidthConstraint.constant = self.view.frameWidth;
	}
	self.scrollViewContentHeightConstraint.constant = self.noteButtonTitleLabel.frameY + self.noteButtonTitleLabel.frameHeight + self.notButtonTitleLabelBottomConstraint.constant;

	// Set the preferred content size to make sure the popover controller has the right size.
	self.preferredContentSize = CGSizeMake(self.scrollViewContentWidthConstraint.constant, self.scrollViewContentHeightConstraint.constant);

	// Set Berlin as default location before getting data from GPS
	self.currentLocation = [[CLLocation alloc] initWithLatitude:K_DEFAULT_LATITUDE longitude:K_DEFAULT_LONGITUDE];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"NavBarTitleDetail", nil);
    self.navigationBarTitle = self.title;
    
    // MAP
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.annotation = [[WMMapAnnotation alloc] initWithNode:self.node];
    [self.mapView addAnnotation:self.annotation];
    
    [self updateFields];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.poiLocation = CLLocationCoordinate2DMake(self.node.lat.doubleValue, self.node.lon.doubleValue);
    [self checkForStatusOfButtons];
    
    // region to display
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.poiLocation, K_REGION_LATITUDE, K_REGION_LONGITUDE);
    viewRegion.center = self.poiLocation;
    
    // display the region
    [self.mapView setRegion:viewRegion animated:NO];
    
    // change view configuration according to the network status
    [self networkStatusChanged:nil];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

#pragma mark - Initialization


- (void)initMapView {
	self.mapView.scrollEnabled = NO;
	[self.mapView setUserTrackingMode:MKUserTrackingModeFollow];

	UITapGestureRecognizer *enlargeMapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enlargeMapButtonPressed)];
	[self.mapView addGestureRecognizer:enlargeMapGestureRecognizer];
}

- (void)initPOIStateButtons {
	self.wheelchairStateButtonView = [[WMPOIStateButtonView alloc] initFromNibToView:self.wheelchairStateButtonViewContainer];
	self.wheelchairStateButtonView.statusType = WMPOIStateTypeWheelchair;
	self.wheelchairStateButtonView.statusString = self.node.wheelchair;
	self.wheelchairStateButtonView.showStateDelegate = self;

	self.toiletStateButtonView = [[WMPOIStateButtonView alloc] initFromNibToView:self.toiletStateButtonViewContainer];
	self.toiletStateButtonView.statusType = WMPOIStateTypeToilet;
	self.toiletStateButtonView.statusString = self.node.wheelchair_toilet;
	self.toiletStateButtonView.showStateDelegate = self;
}

- (void)initAskFriendsView {
	if (self.askFriendsButton.isRightToLeftDirection == YES) {
		[self.askFriendsButton setImage:[UIImage imageNamed:@"details_unknown-info.png"].rightToLeftMirrowedImage forState:UIControlStateNormal];
	}
	self.askFriendsButtonTitleLabel.text = L(@"DetailsViewAskFriendsButtonLabel");

	if ([self.node.wheelchair isEqualToString:K_STATE_UNKNOWN] == NO
		&& [self.node.wheelchair_toilet isEqualToString:K_STATE_UNKNOWN] == NO) {
		self.askFriendsViewHeightConstraint.constant = 0;
		[self.askFriendsView layoutIfNeeded];
	}
}

- (void)initAddressView {
	self.addressView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.addressCompassView.node = self.node;

	if (self.view.isRightToLeftDirection == YES && SYSTEM_VERSION_LESS_THAN(@"9.0") == YES) {
		// As Marquee label doesn't support right to left automatically on prior iOS9 devices, we have to do it on our own.
		self.addressStreetLabel.textAlignment = NSTextAlignmentRight;
		self.addressPLZCityLabel.textAlignment = NSTextAlignmentRight;
		self.addressWebsiteLabel.textAlignment = NSTextAlignmentRight;
		self.addressPhoneTextLabel.textAlignment = NSTextAlignmentRight;
	}
}

- (void)initGalleryView {
	UIImage *uploadBackgroundImage = [UIImage imageNamed:@"details_background-photoupload.png"];
	self.galleryCollectionView.backgroundColor = [UIColor colorWithPatternImage:uploadBackgroundImage];

	self.thumbnailURLArray = [[NSMutableArray alloc] init];
	self.originalImageURLArray = [[NSMutableArray alloc] init];
}

- (void)initAdditionalButtons {
	self.shareButtonTitleLabel.text = L(@"DetailsView4ButtonViewShareLabel");
	self.noteButtonTitleLabel.text = L(@"DetailsView4ButtonViewInfoLabel");
	self.directionButtonTitleLabel.text = L(@"DetailsView4ButtonViewRouteLabel");
}

#pragma mark - UICollectionView delegates

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewCell *cell;
	if (indexPath.row == 0) {
		WMSmallGalleryButtonCollectionViewCell *buttonCell = [collectionView dequeueReusableCellWithReuseIdentifier:K_POI_DETAIL_GALLERY_BUTTON_CELL_IDENTIFIER forIndexPath:indexPath];
		buttonCell.delegate = self;
		cell = buttonCell;
	} else {
		WMSmallGalleryImageCollectionViewCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:K_POI_DETAIL_GALLERY_IMAGE_CELL_IDENTIFIER forIndexPath:indexPath];
		if ((indexPath.row - K_GALLEY_BUTTON_INDEX_OFFSET) < self.thumbnailURLArray.count) {
			[imageCell.imageView setImageWithURL: [NSURL URLWithString:[self.thumbnailURLArray objectAtIndex:indexPath.row - K_GALLEY_BUTTON_INDEX_OFFSET]] placeholderImage:[UIImage imageNamed:@"details_background-thumbnail.png"]];
		}
		cell = imageCell;
	}
	return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return K_GALLEY_BUTTON_INDEX_OFFSET + self.thumbnailURLArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
	if (indexPath.row > 0) {
		[self selectedThumbnailImage:indexPath.row - K_GALLEY_BUTTON_INDEX_OFFSET];
	}
}

- (void)updateFields {
    // TEXTFIELDS
    self.poiNameLabel.text = self.node.name ?: @"";
    NSString *nodeTypeString = self.node.node_type.localized_name ?: @"";
    NSString *catString = self.node.node_type.category.localized_name ?: @"";
    NSString *nodeTypeAndCatString = [NSString stringWithFormat:@"%@ / %@", nodeTypeString, catString];
    self.poiCategoryLabel.text = nodeTypeAndCatString;
    
    
    if (self.node.street == nil && self.node.housenumber == nil && self.node.postcode == nil && self.node.city == nil) {
        self.addressPLZCityLabel.text = NSLocalizedString(@"NoAddress", nil);
    } else {
        NSString *street = self.node.street ?: @"";
        NSString *houseNumber = self.node.housenumber ?: @"";
        self.addressStreetLabel.text = [NSString stringWithFormat:@"%@ %@", street, houseNumber];
        NSString *postcode = self.node.postcode ?: @"";
        NSString *city = self.node.city ?: @"";
        self.addressPLZCityLabel.text = [NSString stringWithFormat:@"%@ %@", postcode, city];
    }
    
    self.addressWebsiteLabel.text = self.node.website ?: NSLocalizedString(@"NoWebsite", nil);
    self.addressPhoneTextLabel.text = self.node.phone ?: NSLocalizedString(@"NoPhone", nil);
    
    [self checkForStatusOfButtons];
    [self updatePOIStateButtonViews];
    [self updateDistanceToAnnotation];
    
    self.annotationView.image = [UIImage imageNamed:[@"marker_" stringByAppendingString:self.node.wheelchair]];
}

- (void)checkForStatusOfButtons {
    if(self.currentLocation == nil) {
        self.directionButton.enabled = NO;
    } else {
        self.directionButton.enabled = YES;
    }
}

- (void)updatePOIStateButtonViews {
	if ([self.node.wheelchair isEqualToString:K_STATE_UNKNOWN] == NO
		&& [self.node.wheelchair_toilet isEqualToString:K_STATE_UNKNOWN] == NO) {
		// No state is unknow, so we don't have to show the ask friends view
		if (self.askFriendsViewHeightConstraint.constant == K_ASK_FRIENDS_HEIGHT) {
			self.scrollViewContentHeightConstraint.constant -= K_ASK_FRIENDS_HEIGHT;
		}
		self.askFriendsViewHeightConstraint.constant = 0;
	} else {
		// At least one state is unknow, so we do have to show the ask friends view
		if (self.askFriendsViewHeightConstraint.constant == 0) {
			self.scrollViewContentHeightConstraint.constant += K_ASK_FRIENDS_HEIGHT;
		}
		self.askFriendsViewHeightConstraint.constant = K_ASK_FRIENDS_HEIGHT;
	}
	[self.askFriendsView layoutIfNeeded];

	self.wheelchairStateButtonView.statusString = self.node.wheelchair;
	self.toiletStateButtonView.statusString = self.node.wheelchair_toilet;
}

#pragma mark - Map

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[WMMapAnnotation class]]) {
        Node *node = [(WMMapAnnotation*)annotation node];
        NSString *reuseId = [node.wheelchair stringByAppendingString:[node.id stringValue]];
        self.annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        if (!self.annotationView) {
            self.annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
            self.annotationView.canShowCallout = NO;
            self.annotationView.centerOffset = CGPointMake(6, -14);
            self.annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        self.annotationView.image = [UIImage imageNamed:[@"marker_" stringByAppendingString:node.wheelchair]];
        UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake(1, 3, 19, 14)];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.backgroundColor = [UIColor clearColor];
        icon.image = [[WMResourceManager sharedManager] iconForName:node.node_type.icon];  // node.node_type.iconPath is sometimes null. this is a hot fix.
        [self.annotationView addSubview:icon];
        
        return self.annotationView;
    }
    return nil;
}

- (void)updateDistanceToAnnotation {
    if (self.mapView.userLocation.location == nil) {
        self.addressDistanceLabel.text = @"n/a";
        return;
    }
    
    CLLocation *pinLocation = [[CLLocation alloc]
                               initWithLatitude:self.annotation.coordinate.latitude
                               longitude:self.annotation.coordinate.longitude];
    
    CLLocation *userLocation = [[CLLocation alloc]
                                initWithLatitude:self.mapView.userLocation.coordinate.latitude
                                longitude:self.mapView.userLocation.coordinate.longitude];
    
    CLLocationDistance distance = [pinLocation distanceFromLocation:userLocation];
    
    self.addressDistanceLabel.text = [NSString localizedDistanceStringFromMeters:distance];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    self.currentLocation = userLocation.location;
    if (mapView.selectedAnnotations.count == 0)
        //no annotation is currently selected
        [self updateDistanceToAnnotation];
    else
        //first object in array is currently selected annotation
        [self updateDistanceToAnnotation];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
        return;
    }
    [self updateDistanceToAnnotation];
}

- (WMMapAnnotation*)annotationForNode:(Node*)node comparisonNodes:comparisonNodes {
    for (WMMapAnnotation* annotation in  comparisonNodes) {
        
        // filter out MKUserLocation annotation
        if ([annotation isKindOfClass:[WMMapAnnotation class]] && [annotation.node isEqual:node]) {
            return annotation;
        }
    }
    return nil;
}

- (IBAction)enlargeMapButtonPressed {
    if (self.mapViewOpen) {
		self.mapViewViewHeightConstraint.constant = K_MAP_HEIGHT_SMALL;
		self.scrollViewContentHeightConstraint.constant += K_MAP_HEIGHT_SMALL - K_MAP_HEIGHT_LARGE;

		[UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
							 self.centerMapButton.alpha = 0;
							 [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             self.mapViewOpen = NO;
                             self.mapView.scrollEnabled = NO;
                             self.mapView.zoomEnabled = NO;
                         }];
        
    } else {
		self.mapViewViewHeightConstraint.constant = K_MAP_HEIGHT_LARGE;
		self.scrollViewContentHeightConstraint.constant -= K_MAP_HEIGHT_SMALL - K_MAP_HEIGHT_LARGE;

		[UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
							 self.centerMapButton.alpha = 1;
							 [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             self.mapViewOpen = YES;
                             self.mapView.scrollEnabled = YES;
                             self.mapView.zoomEnabled = YES;
                         }];
	}
}

#pragma mark - IBActions

- (IBAction)centerMapPressed:(id)sender {
	MKCoordinateRegion userRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, K_REGION_LATITUDE, K_REGION_LONGITUDE);

	[self.mapView setRegion:userRegion animated:YES];
}

- (IBAction)didPressAskFriendButton:(id)sender {
	WMShareSocialViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMShareSocialViewController"];
	vc.baseController = self.baseController;
	vc.title = vc.navigationBarTitle = NSLocalizedString(@"ShareLocationViewHeadline", @"");

	if (UIDevice.currentDevice.isIPad == YES) {
		[self.navigationController pushViewController:vc animated:YES];
		vc.titleView.hidden = YES;
	} else {
		[self presentViewController:vc animated:YES];
	}
	NSString *shareLocationLabel = NSLocalizedString(@"AskFriendsLabel", @"");
	NSString *urlString = [NSString stringWithFormat:@"http://wheelmap.org/nodes/%@", self.node.id];
	NSURL *url = [NSURL URLWithString: urlString];
	vc.shareURlString = url.absoluteString;
	vc.shareTextString = [NSString stringWithFormat:@"%@ \n\"%@\" - %@", shareLocationLabel, self.node.name, url];
}

- (IBAction)didPressAddressWebsiteButton:(id)sender {
	if (self.node.website != nil && self.node.website.length > 0) {
		NSURL *url = [NSURL URLWithString:self.node.website];
		if ([UIApplication.sharedApplication canOpenURL:url]) {
			[UIApplication.sharedApplication openURL:url];
		}
	}
}

- (IBAction)didPressAddressPhoneButton:(id)sender {
	if (self.node.phone != nil && self.node.phone.length > 0) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", [self.node.phone stringByReplacingOccurrencesOfString:@" " withString:@""]]];
		if ([UIApplication.sharedApplication canOpenURL:url]) {
			[UIApplication.sharedApplication openURL:url];
		}
	}
}

- (IBAction)didPressShareButton:(id)sender {
	WMShareSocialViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMShareSocialViewController"];
	vc.baseController = self.baseController;
	CGFloat xPosition = (768.0f / 2.0f) - 160.0f;
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
		xPosition = (1024.0f / 2.0f) - 160.0f;
	}
	vc.popoverButtonFrame = CGRectMake( xPosition, 150.0f, 320.0f, 500.0f);
	vc.title = vc.navigationBarTitle = NSLocalizedString(@"ShareLocationViewHeadline", @"");
	vc.node = self.node;

	if (UIDevice.currentDevice.isIPad == YES) {
		[self.navigationController pushViewController:vc animated:YES];
		vc.titleView.hidden = YES;
	} else {
		[self presentViewController:vc animated:YES];
	}
	NSString *shareLocationLabel = L(@"ShareLocationLabel");
	NSString *urlString = [NSString stringWithFormat:@"http://wheelmap.org/nodes/%@", self.node.id];
	NSURL *url = [NSURL URLWithString: urlString];
	vc.shareURlString = url.absoluteString;
	vc.shareTextString = [NSString stringWithFormat:@"%@ \n\"%@\" - %@ #MapMyDay", shareLocationLabel, self.node.name, url];

}

- (IBAction)didPresseNotesButton:(id)sender {
	WMEditPOICommentViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMEditPOICommentViewController"];
	vc.currentNode = self.node;
	vc.title = NSLocalizedString(@"DetailsView4ButtonViewInfoLabel", @"");
	[self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didPressDirectionButton:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"LeaveApp", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
	actionSheet.tag = 1;
	[actionSheet showInView:self.view];
}

#pragma mark - EditPOIState delegate

- (void)didSelectStatus:(NSString*)wheelchairAccess forStatusType:(WMPOIStateType)statusType {
	if (statusType == WMPOIStateTypeWheelchair) {
		self.node.wheelchair = wheelchairAccess;
	} else if (statusType == WMPOIStateTypeToilet) {
		self.node.wheelchair_toilet = wheelchairAccess;
	}
}


#pragma mark - ActionSheets

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) { // WEBSITE
        if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.node.website]];
        }
    } else if (actionSheet.tag == 1) { // MAP
        if (buttonIndex == 0) {
            CLLocationCoordinate2D start = { self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude };
            CLLocationCoordinate2D destination = { self.poiLocation.latitude, self.poiLocation.longitude };
            
			// Create an MKMapItem to pass to the Maps app
			MKPlacemark *placemarkStart = [[MKPlacemark alloc] initWithCoordinate:start addressDictionary:nil];
			MKPlacemark *placemarkDest = [[MKPlacemark alloc] initWithCoordinate:destination addressDictionary:nil];
			MKMapItem *mapItemStart = [[MKMapItem alloc] initWithPlacemark:placemarkStart];
			MKMapItem *mapItemDest = [[MKMapItem alloc] initWithPlacemark:placemarkDest];

			[MKMapItem openMapsWithItems:@[mapItemStart, mapItemDest] launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking}];
        }
    } else if (actionSheet.tag == 2) { // PHOTOUPLOAD
        if (buttonIndex == 0) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            if (UIDevice.currentDevice.isIPad == YES) {

				[self performBlockAfterDelay:0.3 block:^{
					self.popOverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];
					[self.popOverController presentPopoverFromRect:CGRectMake(60, 0, 0, 0) inView:self.galleryCollectionView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
				}];
            } else {
                [self presentViewController:self.imagePicker animated:YES];
            }
        } else if (buttonIndex == 1) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            if (UIDevice.currentDevice.isIPad == YES) {

				[self performBlockAfterDelay:0.3 block:^{
					self.popOverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];
					[self.popOverController presentPopoverFromRect:CGRectMake(60, 0, 0, 0) inView:self.galleryCollectionView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
				}];
            } else {
                [self presentViewController:self.imagePicker animated:YES];
            }
        }
    } else if (actionSheet.tag == 3) {
        NSString *phoneLinkString = [NSString stringWithFormat:@"tel:%@", self.node.phone];
        NSURL *phoneLinkURL = [NSURL URLWithString:phoneLinkString];
        [[UIApplication sharedApplication] openURL:phoneLinkURL];
        
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // change status bar colors
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.imagePicker setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - PhotoUpload

- (void)selectedThumbnailImage:(NSUInteger)index {
    WMInfinitePhotoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMInfinitePhotoViewController"];
    vc.imageURLArray = self.originalImageURLArray;
    vc.tappedImage = index;
    [self presentForcedModalViewController:vc animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    // reset status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.imagePicker setNeedsStatusBarAppearanceUpdate];
    
    if (UIDevice.currentDevice.isIPad == YES) {
        [self.popOverController dismissPopoverAnimated:YES];
    }
    
    [self dismissViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // reset status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.imagePicker setNeedsStatusBarAppearanceUpdate];
    
    if (UIDevice.currentDevice.isIPad == YES) {
        [self.popOverController dismissPopoverAnimated:YES];
    }
    
    imageReadyToUpload = [info objectForKey:UIImagePickerControllerOriginalImage];

    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"ConfirmImageUpload", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            // cancel
            // if the source type was camere, we should dismiss camera view.
            // otherwise we do not need to dismiss view controller (photo gallery) programatically
            if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera)
                [self dismissViewControllerAnimated:YES];
            break;
        case 1:
            // confirmed
            [dataManager uploadImage:imageReadyToUpload forNode:self.node];
            [self dismissViewControllerAnimated:YES];
            WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.navigationController;
            [navCtrl showLoadingWheel];
            break;
    }
}

#pragma mark - WMDataManager Delegates

- (void)dataManager:(WMDataManager *)aDataManager didUploadImageForNode:(Node *)node {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"PhotoUuploadSuccess", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];

    WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.navigationController;
    [navCtrl hideLoadingWheel];

	// Remove current photos and reload them
	[self.thumbnailURLArray removeAllObjects];
	[self.originalImageURLArray removeAllObjects];
	[self.galleryCollectionView reloadData];
	[dataManager fetchPhotosForNode:self.node];
}

- (void)dataManager:(WMDataManager *)dataManager uploadImageForNode:(Node *)node failedWithError:(NSError *)error {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"PhotoUploadFailed", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];

    WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.navigationController;
    [navCtrl hideLoadingWheel];
}

- (void)dataManager:(WMDataManager *)dataManager didReceivePhotosForNode:(Node *)node {
	for (Photo* photo in node.photos) {
        for (Image* image in photo.images) {
            if ([image.type caseInsensitiveCompare:@"thumb_iphone_retina"] == NSOrderedSame) {
                [self.thumbnailURLArray addObject:image.url];
            } else if ([image.type caseInsensitiveCompare:@"gallery_iphone_retina"] == NSOrderedSame) {
                [self.originalImageURLArray addObject:image.url];
            }
        }
    }
    
    [self.galleryCollectionView reloadData];
    
}

- (void)dataManager:(WMDataManager *)dataManager fetchPhotosFailedWithError:(NSError *)error {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"FetchingPhotoURLFailed", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    
    [alert show];
}

#pragma mark - WMSmallGalleryButtonCollectionViewCell delegate

- (void)didPressCameraButton {
	// Check if user is authenticated
	if (dataManager.userIsAuthenticated == NO) {
		if ([self.navigationController isKindOfClass:[WMPOIIPadNavigationController class]] == YES) {
			// The user isn't logged in. Present the login screen then. This will close the popover and open the login screen popover.
			WMPOIIPadNavigationController *detailNavigationController = (WMPOIIPadNavigationController *) self.navigationController;
			[((WMNavigationControllerBase *)detailNavigationController.listViewController.navigationController) presentLoginScreen];
		} else if ([self.navigationController isKindOfClass:[WMNavigationControllerBase class]] == YES) {
			WMNavigationControllerBase *baseNavigationController = (WMNavigationControllerBase *) self.navigationController;
			UICollectionViewCell *cameraButtonCell = [self.galleryCollectionView cellForItemAtIndexPath:[[NSIndexPath alloc] initWithIndex:0]];
			[baseNavigationController presentLoginScreenWithButtonFrame:cameraButtonCell.contentView.frame];
		}
		return;
	}

	self.imagePicker = [[UIImagePickerController alloc] init];
	self.imagePicker.delegate = self;

	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"DetailsViewChoosePhotoSource", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"DetailsViewUploadOptionCamera", @""), NSLocalizedString(@"DetailsViewUploadOptionPhotoAlbum", @""), nil];
		actionSheet.tag = 2;

		[actionSheet showInView:self.view];
	} else {
		self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

		if (UIDevice.currentDevice.isIPad == YES) {

			self.popOverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];

			UICollectionViewCell *cameraButtonCell = [self.galleryCollectionView cellForItemAtIndexPath:[[NSIndexPath alloc] initWithIndex:0]];
			[self.popOverController presentPopoverFromRect:cameraButtonCell.contentView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		} else {
			[self presentForcedModalViewController:self.imagePicker animated:YES];
		}
	}
}

#pragma mark -

- (void)pushEditViewController {
    if (![dataManager userIsAuthenticated]) {
        WMNavigationControllerBase* navCtrl = (WMNavigationControllerBase*)self.navigationController;
        [navCtrl presentLoginScreenWithButtonFrame:navCtrl.customNavigationBar.editButton.frame];
        return;
    }

	WMEditPOIViewController *editPOIViewController = [UIStoryboard instantiatedEditPOIViewController];
    editPOIViewController.node = self.node;
    editPOIViewController.editView = YES;
    editPOIViewController.title = self.title = NSLocalizedString(@"EditPOIViewHeadline", @"");
    [self.navigationController pushViewController:editPOIViewController animated:YES];
}

#pragma mark - Network Status Changes
- (void)networkStatusChanged:(NSNotification*)notice {
    NetworkStatus networkStatus = [[dataManager internetReachble] currentReachabilityStatus];

	WMSmallGalleryButtonCollectionViewCell *cameraButtonCell = (WMSmallGalleryButtonCollectionViewCell *) [self.galleryCollectionView cellForItemAtIndexPath:[[NSIndexPath alloc] initWithIndex:0]];

    switch (networkStatus) {
        case NotReachable:
            cameraButtonCell.button.enabled = NO;
            break;
            
        default:
            cameraButtonCell.button.enabled = YES;
            break;
    }
}

#pragma mark - AlertView stuff
- (void)attribution:(NSString *)attribution {
    NSString *title = @"Attribution";
    NSString *message = attribution;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Mapbox Details", @"OSM Details", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if([alertView.title isEqualToString:@"Attribution"]) {
        // For the attribution alert dialog, open the Mapbox and OSM copyright pages when their respective buttons are pressed
        //
        if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Mapbox Details"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.mapbox.com/tos/"]];
        }
        if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OSM Details"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.openstreetmap.org/copyright"]];
        }
    }
}

#pragma mark - WMPOIStateButtonViewDelegate

- (void)didPressedEditStateButton:(NSString *)state forStateType:(WMPOIStateType)stateType {

	WMEditPOIStateViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMEditPOIStateViewController"];
	vc.title = NSLocalizedString(@"EditPOIStateHeadline", nil);
	vc.navigationBarTitle = vc.title;
	vc.delegate = self;
	vc.node = self.node;
	vc.useCase = WMEditPOIStateUseCasePOIUpdate;
	if (stateType == WMPOIStateTypeWheelchair) {
		vc.statusType = WMPOIStateTypeWheelchair;
		vc.originalState = self.node.wheelchair;
	} else if (stateType == WMPOIStateTypeToilet) {
		vc.statusType = WMPOIStateTypeToilet;
		vc.originalState = self.node.wheelchair_toilet;
	}
	[self.navigationController pushViewController:vc animated:YES];
}

@end

