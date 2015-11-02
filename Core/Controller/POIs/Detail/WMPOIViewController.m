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
#import "WMEditPOIWheelchairStatusViewController.h"
#import "WMShareSocialViewController.h"
#import "WMEditPOICommentViewController.h"
#import "WMEditPOIViewController.h"
#import "WMMapAnnotation.h"
#import "WMCompassView.h"
#import "WMInfinitePhotoViewController.h"
#import "UIImageView+AFNetworking.h"
#import "WMCategory.h"
#import "WMNavigationControllerBase.h"
#import "WMPOIsListViewController.h"
#import "WMPOIIPadNavigationController.h"
#import "WMResourceManager.h"

#define GABIFSTATUSUNKNOWN 62
#define MAPOPENADDITION 266
#define MAPVIEWCLOSEDSTATE CGRectMake(0, 0, 320, 110)
#define MAPVIEWOPENSTATE CGRectMake(0, 0, 320, 110+MAPOPENADDITION)
#define CONTENTVIEWCLOSEDMAPSTATE CGRectMake(0, 110+2, 320, 420)
#define CONTENTVIEWOPENMAPSTATE CGRectMake(0, 110+MAPOPENADDITION+2, 320, 420)
#define CONTENTVIEWCLOSEDMAPSTATEGAB CGRectMake(0, 110+2, 320, 420+GABIFSTATUSUNKNOWN)
#define CONTENTVIEWOPENMAPSTATEGAB CGRectMake(0, 110+MAPOPENADDITION+2, 320, 420+GABIFSTATUSUNKNOWN)


#define STARTLEFT 15

@implementation WMPOIViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    
    // data manager
    dataManager = [[WMDataManager alloc] init];
    dataManager.delegate = self;
    
    // request photo urls
    [dataManager fetchPhotosForNode:self.node];
    
    self.gabIfStatusUnknown = 0;
    
    NSAssert(self.node, @"You need to set a node before this view controller can be presented");
    
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.scrollsToTop = YES;
    self.mainView = [UIView new];
    self.mainView.backgroundColor = [UIColor clearColor];
    
    // MAPVIEW
    [MBXMapKit setAccessToken:K_MBX_TOKEN];
    
    self.mapView = [[MKMapView alloc] initWithFrame:MAPVIEWCLOSEDSTATE];

    self.mapView.showsBuildings = NO;
    self.mapView.rotateEnabled = NO;
    self.mapView.pitchEnabled = NO;
    self.mapView.mapType = MKMapTypeStandard;
    
    self.rasterOverlay = [[MBXRasterTileOverlay alloc] initWithMapID:K_MBX_MAP_ID];
    self.rasterOverlay.delegate = self;
    
    [self.mapView addOverlay:self.rasterOverlay];
    
    self.mapView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.mapView.layer.borderWidth = 1.0f;
    self.mapView.delegate = self;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.showsUserLocation=YES;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    [self.mainView addSubview:self.mapView];

    // ENLARGE MAP BUTTON
    UIImage *enlargeMapImage = [UIImage imageNamed:@"details-expand-map.png"];
    self.enlargeMapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.enlargeMapButton.frame = CGRectMake(10, 10, enlargeMapImage.size.width, enlargeMapImage.size.height);
    [self.enlargeMapButton setImage: enlargeMapImage forState: UIControlStateNormal];
    [self.enlargeMapButton addTarget:self action:@selector(enlargeMapButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.enlargeMapButton];
    
    // CONTENT VIEW
    self.contentView = [UIView new];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.mainView addSubview:self.contentView];
    
    self.startY = 0;
    
    // MAIN INFO VIEW
    self.mainInfoView = [self createMainInfoView];
    self.mainInfoView.frame = CGRectMake(0, self.startY, 320, 50);
    [self.contentView addSubview:self.mainInfoView];
    
    self.startY += self.mainInfoView.bounds.size.height+2;
    
    // WHEEL ACCESS AND ASK FRIENDS BUTTON VIEW
    self.wheelAccessView = [self createWheelAccessView];
    self.wheelAccessView.frame = CGRectMake(0, self.startY, 320, 65 + self.gabIfStatusUnknown);
    [self.contentView addSubview:self.wheelAccessView];
    
    self.startY += self.wheelAccessView.bounds.size.height+2;
    
    // CONTACT INFO VIEW
    self.contactInfoView = [self createContactInfoView];
    self.contactInfoView.frame = CGRectMake(10, self.startY, 300, 100);
    [self.contentView addSubview:self.contactInfoView];
    
    self.startY += self.contactInfoView.bounds.size.height+10;
    
    // IMAGESCROLLVIEW
    self.imageScrollView = [self createImageScrollView];
    self.imageScrollView.frame = CGRectMake(0, self.startY, 320, 80);
    [self.contentView addSubview:self.imageScrollView];
    // [self createThumbnails];    // this will creat thumbnails with old image array. will be updated after fetching photo urls
    
    self.thumbnailURLArray = [[NSMutableArray alloc] init];
    self.originalImageURLArray = [[NSMutableArray alloc] init];
    self.startY += self.imageScrollView.bounds.size.height+2;
    
    // ADDITIONALINFOVIEW
    self.additionalButtonView = [self createAdditionalButtonView];
    self.additionalButtonView.frame = CGRectMake(320/2-self.threeButtonWidth/2, self.startY, self.threeButtonWidth, 95);
    [self.contentView addSubview:self.additionalButtonView];
    
    if ([self.node.wheelchair isEqualToString:K_STATE_UNKNOWN]) {
        self.contentView.frame = CONTENTVIEWCLOSEDMAPSTATEGAB;
    } else {
        self.contentView.frame = CONTENTVIEWCLOSEDMAPSTATE;
    }
    self.mainView.frame = CGRectMake(0, 0, 320, self.mapView.bounds.size.height+self.contentView.bounds.size.height);
    self.scrollView.contentSize = self.mainView.frame.size;
    
    UITapGestureRecognizer *enlargeMapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enlargeMapButtonPressed)];
    [self.mapView addGestureRecognizer:enlargeMapRecognizer];
    
    [self.scrollView addSubview:self.mainView];

	// Set the preferred content size to make sure the popover controller has the right size.
	self.preferredContentSize = self.scrollView.contentSize;
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
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.poiLocation, 100, 50);
    viewRegion.center = self.poiLocation;
    
    // display the region
    [self.mapView setRegion:viewRegion animated:NO];
    
    // change view configuration according to the network status
    [self networkStatusChanged:nil];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

#pragma mark - UI element creation

- (UIView*) createMainInfoView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    
    // NAME
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, 10, self.view.bounds.size.width-STARTLEFT*2, 20)];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [view addSubview:self.titleLabel];
    
    // CATEGORY / NOTE TYPE
    self.nodeTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, 32, self.view.bounds.size.width-STARTLEFT*2, 16)];
    self.nodeTypeLabel.textColor = [UIColor darkGrayColor];
    self.nodeTypeLabel.font = [UIFont systemFontOfSize:14];
    self.nodeTypeLabel.backgroundColor = [UIColor clearColor];
    [view addSubview:self.nodeTypeLabel];
    
    return view;
}

- (UIView*) createWheelAccessView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    
    [self setWheelAccessButton];
    self.wheelAccessButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.wheelAccessButton.frame = CGRectMake(10, 10, self.accessImage.size.width, self.accessImage.size.height);
    self.wheelAccessButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.wheelAccessButton.titleLabel.textColor = [UIColor whiteColor];
    [self.wheelAccessButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    self.wheelAccessButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.wheelAccessButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.wheelAccessButton setContentEdgeInsets:UIEdgeInsetsMake(0, 40, 0, 0)];
    [self.wheelAccessButton addTarget:self action:@selector(showAccessOptions) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.wheelAccessButton];
    
    if ([self.node.wheelchair isEqualToString:K_STATE_UNKNOWN]) {
        self.gabIfStatusUnknown = GABIFSTATUSUNKNOWN;
        
        self.askFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *buttonImage = [UIImage imageNamed:@"details_unknown-info.png"];
        [self.askFriendsButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.askFriendsButton setTitle:NSLocalizedString(@"DetailsViewAskFriendsButtonLabel", @"") forState:UIControlStateNormal];
        self.askFriendsButton.titleLabel.font = [UIFont systemFontOfSize:13];
        self.askFriendsButton.titleLabel.numberOfLines = 2;
        [self.askFriendsButton setContentEdgeInsets:UIEdgeInsetsMake(5, 55, 0, 10)];
        [self.askFriendsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        self.askFriendsButton.titleLabel.textColor = [UIColor darkGrayColor];
        self.askFriendsButton.frame = CGRectMake(20, self.gabIfStatusUnknown, 320.0f-40.0f, buttonImage.size.height);
        [self.askFriendsButton addTarget:self action:@selector(askFriendsForStatusButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:self.askFriendsButton];
    }
    return  view;
}

- (UIView*)createContactInfoView {
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    
    view.layer.borderWidth = 1.0f;
    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [view.layer setCornerRadius:5.0f];
    
    int startY = 10;
    
    // STREET
    self.streetLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, startY, 225, 16)];
    self.streetLabel.textColor = [UIColor darkGrayColor];
    self.streetLabel.font = [UIFont boldSystemFontOfSize:13];
    self.streetLabel.backgroundColor = [UIColor clearColor];
    [view addSubview:self.streetLabel];
    
    
    startY += 16;
    
    // POSTCODE AND CITY
    self.postcodeAndCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, startY, 225, 22)];
    self.postcodeAndCityLabel.textColor = [UIColor darkGrayColor];
    self.postcodeAndCityLabel.font = [UIFont boldSystemFontOfSize:13];
    self.postcodeAndCityLabel.backgroundColor = [UIColor clearColor];
    [view addSubview:self.postcodeAndCityLabel];
    
    startY += 20;
    
    // COMPASS
    UIImage *compassImage = [UIImage imageNamed:@"details_compass.png"];
    WMCompassView *compassView = [[WMCompassView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-62, startY-10, compassImage.size.width, compassImage.size.height)];
    compassView.node = self.node;
    compassView.backgroundColor = [UIColor clearColor];
    [view addSubview:compassView];
    
    // WEBSITE
    self.websiteLabel = [[UITextView alloc] initWithFrame:CGRectMake(STARTLEFT, startY, 225, 22)];
    self.websiteLabel.textColor = [UIColor darkGrayColor];
    self.websiteLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    self.websiteLabel.editable = NO;
    self.websiteLabel.scrollEnabled = NO;
    self.websiteLabel.font = [UIFont systemFontOfSize:13];
    self.websiteLabel.backgroundColor = [UIColor clearColor];
    self.websiteLabel.contentInset = UIEdgeInsetsMake(-5,-4,0,0);
    [view addSubview:self.websiteLabel];
    
    startY += 25;
    
    // PHONE
    self.phoneLabel = [[UITextView alloc] initWithFrame:CGRectMake(STARTLEFT, startY, 225, 22)];
    self.phoneLabel.textColor = [UIColor darkGrayColor];
    self.phoneLabel.font = [UIFont systemFontOfSize:13];
    self.phoneLabel.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
    self.phoneLabel.editable = NO;
    self.phoneLabel.scrollEnabled = NO;
    self.phoneLabel.backgroundColor = [UIColor clearColor];
    self.phoneLabel.contentInset = UIEdgeInsetsMake(-5,-4,0,0);
    [view addSubview:self.phoneLabel];
    
    // DISTANCE
    self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-80, startY, 60, 20)];
    self.distanceLabel.textColor = [UIColor darkGrayColor];
    self.distanceLabel.font = [UIFont systemFontOfSize:12];
    self.distanceLabel.backgroundColor = [UIColor clearColor];
    self.distanceLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:self.distanceLabel];
    
    return view;
}

- (UIScrollView*)createImageScrollView {
    self.imageViewsInScrollView = [NSMutableArray new];
    UIImage *uploadBackground = [UIImage imageNamed:@"details_background-photoupload.png"];
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.backgroundColor = [UIColor colorWithPatternImage:uploadBackground];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    
    UIImage *cameraButtonImage = [UIImage imageNamed:@"details_btn-photoupload.png"];
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraButton.frame = CGRectMake(10, 9, cameraButtonImage.size.width, cameraButtonImage.size.height);
    [self.cameraButton setImage: cameraButtonImage forState: UIControlStateNormal];
    [self.cameraButton addTarget:self action:@selector(cameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:self.cameraButton];
    return scrollView;
}

- (void)createThumbnails {
    for (UIView* imageView in self.imageViewsInScrollView) {
        [imageView removeFromSuperview];
    }
    
    self.start = 22+[UIImage imageNamed:@"details_btn-photoupload.png"].size.width;
    self.gab = 16;
    
    for (int i = 0; i < self.thumbnailURLArray.count; i++) {
        [self addThumbnail:i];
    }
    
    int scrollWidth = ((self.thumbnailURLArray.count+1)*([UIImage imageNamed:@"details_btn-photoupload.png"].size.width + self.gab))+self.gab;
    self.imageScrollView.contentSize = CGSizeMake(scrollWidth, self.imageScrollView.frame.size.height);
}

- (void)addThumbnail: (int) i {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.start+i*80+i*self.gab, 10, 85, 60)];
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 2;
    imageView.tag = i;
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [imageView setImageWithURL: [NSURL URLWithString:[self.thumbnailURLArray objectAtIndex:i]] placeholderImage:[UIImage imageNamed:@"details_background-thumbnail.png"]];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbnailTapped:)];
    [imageView addGestureRecognizer:tapRecognizer];
    
    [self.imageScrollView addSubview:imageView];
    [self.imageViewsInScrollView addObject:imageView];
}

- (UIView*)createAdditionalButtonView {
    int buttonWidth = 68;
    int buttonHeight = 62;
    int gab = 10;
    
    self.threeButtonWidth = 3*buttonWidth + 2*gab;
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    
    // SHARELOCATION
    self.shareLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shareLocationButton.frame = CGRectMake(0, 10, buttonWidth, buttonHeight);
    [self.shareLocationButton setImage: [UIImage imageNamed:@"more-buttons_share.png"] forState: UIControlStateNormal];
    [self.shareLocationButton setImage: [UIImage imageNamed:@"more-buttons_share-deactive.png"] forState: UIControlStateDisabled];
    [self.shareLocationButton addTarget:self action:@selector(shareLocationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.shareLocationButton];
    UILabel *shareLocationLabel = [self createBelowButtonLabel:NSLocalizedString(@"DetailsView4ButtonViewShareLabel", @"")];
    shareLocationLabel.frame = CGRectMake(self.shareLocationButton.frame.origin.x,buttonHeight+15,buttonWidth, 16);
    [view addSubview:shareLocationLabel];
    
    // MOREINFO
    self.moreInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.moreInfoButton.frame = CGRectMake(buttonWidth+gab, 10,buttonWidth,buttonHeight);
    [self.moreInfoButton setImage: [UIImage imageNamed:@"more-buttons_info.png"] forState: UIControlStateNormal];
    [self.moreInfoButton setImage: [UIImage imageNamed:@"more-buttons_info-deactive.png"] forState: UIControlStateDisabled];
    [self.moreInfoButton addTarget:self action:@selector(showCommentView) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.moreInfoButton];
    UILabel *moreInfoLabel = [self createBelowButtonLabel:NSLocalizedString(@"DetailsView4ButtonViewInfoLabel", @"")];
    moreInfoLabel.frame = CGRectMake(self.moreInfoButton.frame.origin.x,buttonHeight+15,buttonWidth, 16);
    [view addSubview:moreInfoLabel];
    
    // ROUTE
    self.naviButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.naviButton.frame = CGRectMake(2*buttonWidth+2*gab, 10,buttonWidth,buttonHeight);
    [self.naviButton setImage: [UIImage imageNamed:@"more-buttons_route.png"] forState: UIControlStateNormal];
    [self.naviButton setImage: [UIImage imageNamed:@"more-buttons_route-deactive.png"] forState: UIControlStateDisabled];
    [self.naviButton addTarget:self action:@selector(openMap) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.naviButton];
    UILabel *routeLabel = [self createBelowButtonLabel:NSLocalizedString(@"DetailsView4ButtonViewRouteLabel", @"")];
    routeLabel.frame = CGRectMake(self.naviButton.frame.origin.x,buttonHeight+15,buttonWidth, 16);
    [view addSubview:routeLabel];
    
    return view;
}

- (UILabel*)createBelowButtonLabel: (NSString*) title {
    UILabel *belowButtonLabel = [UILabel new];
    belowButtonLabel.backgroundColor = [UIColor clearColor];
    belowButtonLabel.text = title;
    belowButtonLabel.font = [UIFont systemFontOfSize:11];
    belowButtonLabel.textColor = [UIColor darkGrayColor];
    belowButtonLabel.textAlignment = NSTextAlignmentCenter;
    return belowButtonLabel;
}

- (void)updateFields {
    // TEXTFIELDS
    self.titleLabel.text = self.node.name ?: @"";
    NSString *nodeTypeString = self.node.node_type.localized_name ?: @"";
    NSString *catString = self.node.node_type.category.localized_name ?: @"";
    NSString *nodeTypeAndCatString = [NSString stringWithFormat:@"%@ / %@", nodeTypeString, catString];
    self.nodeTypeLabel.text = nodeTypeAndCatString;
    
    
    if (self.node.street == nil && self.node.housenumber == nil && self.node.postcode == nil && self.node.city == nil) {
        self.postcodeAndCityLabel.text = NSLocalizedString(@"NoAddress", nil);
    } else {
        NSString *street = self.node.street ?: @"";
        NSString *houseNumber = self.node.housenumber ?: @"";
        self.streetLabel.text = [NSString stringWithFormat:@"%@ %@", street, houseNumber];
        NSString *postcode = self.node.postcode ?: @"";
        NSString *city = self.node.city ?: @"";
        self.postcodeAndCityLabel.text = [NSString stringWithFormat:@"%@ %@", postcode, city];
    }
    
    self.websiteLabel.text = self.node.website ?: NSLocalizedString(@"NoWebsite", nil);
    self.phoneLabel.text = self.node.phone ?: NSLocalizedString(@"NoPhone", nil);
    
    [self checkForStatusOfButtons];
    [self setWheelAccessButton];
    [self updateDistanceToAnnotation];
    
    self.annotationView.image = [UIImage imageNamed:[@"marker_" stringByAppendingString:self.node.wheelchair]];
}

- (void)checkForStatusOfButtons {
    if(self.currentLocation == nil) {
        self.naviButton.enabled = NO;
    } else {
        self.naviButton.enabled = YES;
    }
}

- (void)setWheelAccessButton {
    if (![self.node.wheelchair isEqualToString:K_STATE_UNKNOWN] && self.askFriendsButton != nil) {
        [self.askFriendsButton removeFromSuperview];
        self.wheelAccessView.frame = CGRectMake(self.wheelAccessView.frame.origin.x, self.wheelAccessView.frame.origin.y, self.wheelAccessView.frame.size.width, self.wheelAccessView.frame.size.height-self.gabIfStatusUnknown);
        self.contactInfoView.frame = CGRectMake(self.contactInfoView.frame.origin.x, self.contactInfoView.frame.origin.y-self.gabIfStatusUnknown, self.contactInfoView.frame.size.width, self.contactInfoView.frame.size.height);
        self.imageScrollView.frame = CGRectMake(self.imageScrollView.frame.origin.x, self.imageScrollView.frame.origin.y-self.gabIfStatusUnknown, self.imageScrollView.frame.size.width, self.imageScrollView.frame.size.height);
        self.additionalButtonView.frame = CGRectMake(self.additionalButtonView.frame.origin.x, self.additionalButtonView.frame.origin.y-self.gabIfStatusUnknown, self.additionalButtonView.frame.size.width, self.additionalButtonView.frame.size.height);
        self.askFriendsButton = nil;
    }

    if ([self.node.wheelchair isEqualToString:K_STATE_YES]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-yes.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessYes", @"");
    } else if ([self.node.wheelchair isEqualToString:K_STATE_NO]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-no.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessNo", @"");
    } else if ([self.node.wheelchair isEqualToString:K_STATE_LIMITED]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-limited.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessLimited", @"");
    } else if ([self.node.wheelchair isEqualToString:K_STATE_UNKNOWN]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-unknown.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessUnknown", @"");
    }
    
    [self.wheelAccessButton setBackgroundImage: self.accessImage forState: UIControlStateNormal];
    [self.wheelAccessButton setTitle:self.wheelchairAccess forState:UIControlStateNormal];
}


#pragma mark - Phone, Website, Comment, Navi

- (void)call {
    NSString *callString = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Call", @""), self.node.phone];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:callString delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    actionSheet.tag = 3;
    [actionSheet showInView:self.view];
    
    
}

- (void)openWebpage {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"LeaveApp", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    actionSheet.tag = 0;
    [actionSheet showInView:self.view];
    
}

- (void)showCommentView {
	if (dataManager.userIsAuthenticated == NO) {
		WMNavigationControllerBase *navigationController = (WMNavigationControllerBase*) self.navigationController;
		if ([navigationController isKindOfClass:[WMPOIIPadNavigationController class]]) {
			[(WMPOIIPadNavigationController*)navigationController showLoginViewController];
		} else {
			[navigationController presentLoginScreenWithButtonFrame:self.moreInfoButton.frame];
		}
		return;
	}

    WMEditPOICommentViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMEditPOICommentViewController"];
    vc.currentNode = self.node;
    vc.title = NSLocalizedString(@"DetailsView4ButtonViewInfoLabel", @"");
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openMap {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"LeaveApp", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}


#pragma mark - Map
// And this somewhere in your class that’s mapView’s delegate (most likely a view controller).
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    // This is boilerplate code to connect tile overlay layers with suitable renderers
    //
    if ([overlay isKindOfClass:[MBXRasterTileOverlay class]])
    {
        MBXRasterTileRenderer *renderer = [[MBXRasterTileRenderer alloc] initWithTileOverlay:overlay];
        return renderer;
    }
    return nil;
}

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
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
        self.distanceLabel.text = @"n/a";
        return;
    }
    
    CLLocation *pinLocation = [[CLLocation alloc]
                               initWithLatitude:self.annotation.coordinate.latitude
                               longitude:self.annotation.coordinate.longitude];
    
    CLLocation *userLocation = [[CLLocation alloc]
                                initWithLatitude:self.mapView.userLocation.coordinate.latitude
                                longitude:self.mapView.userLocation.coordinate.longitude];
    
    CLLocationDistance distance = [pinLocation distanceFromLocation:userLocation];
    
    self.distanceLabel.text = [NSString localizedDistanceStringFromMeters:distance];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    self.currentLocation = userLocation;
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

- (WMMapAnnotation*) annotationForNode:(Node*)node {
    for (WMMapAnnotation* annotation in  self.mapView.annotations) {
        
        // filter out MKUserLocation annotation
        if ([annotation isKindOfClass:[WMMapAnnotation class]] && [annotation.node isEqual:node]) {
            return annotation;
        }
    }
    return nil;
}

- (void)enlargeMapButtonPressed {
    if (self.mapViewOpen) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             self.mapView.frame = MAPVIEWCLOSEDSTATE;
                             if ([self.node.wheelchair isEqualToString:K_STATE_UNKNOWN]) {
                                 self.contentView.frame = CONTENTVIEWCLOSEDMAPSTATEGAB;
                             } else {
                                 self.contentView.frame = CONTENTVIEWCLOSEDMAPSTATE;
                             }
                             self.mainView.frame = CGRectMake(0, 0, 320, self.mapView.bounds.size.height+self.contentView.bounds.size.height);
                             self.scrollView.contentSize = CGSizeMake(320, self.scrollView.contentSize.height-MAPOPENADDITION);
                         }
                         completion:^(BOOL finished) {
                             self.mapViewOpen = NO;
                             self.mapView.scrollEnabled = NO;
                             self.mapView.zoomEnabled = NO;
                         }
         ];
        
    } else {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.mapView.frame = MAPVIEWOPENSTATE;
                             if ([self.node.wheelchair isEqualToString:K_STATE_UNKNOWN]) {
                                 self.contentView.frame = CONTENTVIEWOPENMAPSTATEGAB;
                             } else {
                                 self.contentView.frame = CONTENTVIEWOPENMAPSTATE;
                             }
                             self.mainView.frame = CGRectMake(0, 0, 320, self.mapView.bounds.size.height+self.contentView.bounds.size.height);
                             self.scrollView.contentSize = CGSizeMake(320, self.scrollView.contentSize.height+MAPOPENADDITION);
                         }
                         completion:^(BOOL finished) {
                             self.mapViewOpen = YES;
                             self.mapView.scrollEnabled = YES;
                             self.mapView.zoomEnabled = YES;
                         }
         ];
	}
}

#pragma mark - MBXRasterTileOverlayDelegate implementation

- (void)tileOverlay:(MBXRasterTileOverlay *)overlay didLoadMetadata:(NSDictionary *)metadata withError:(NSError *)error {
    // This delegate callback is for centering the map once the map metadata has been loaded
    //
    if (error)
    {
        DKLog(K_VERBOSE_MAP, @"Failed to load metadata for map ID %@ - (%@)", overlay.mapID, error?error:@"");
    }
    else
    {
        [_mapView mbx_setCenterCoordinate:overlay.center zoomLevel:overlay.centerZoom animated:NO];
    }
}


- (void)tileOverlay:(MBXRasterTileOverlay *)overlay didLoadMarkers:(NSArray *)markers withError:(NSError *)error {
    // This delegate callback is for adding map markers to an MKMapView once all the markers for the tile overlay have loaded
    //
    if (error)
    {
        DKLog(K_VERBOSE_MAP, @"Failed to load markers for map ID %@ - (%@)", overlay.mapID, error?error:@"");
    }
    else
    {
        [_mapView addAnnotations:markers];
    }
}

- (void)tileOverlayDidFinishLoadingMetadataAndMarkers:(MBXRasterTileOverlay *)overlay {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - ActionSheets

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) { // WEBSITE
        if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.node.website]];
        }
    } else if (actionSheet.tag == 1) { // MAP
        if (buttonIndex == 0) {
            CLLocationCoordinate2D start = { self.currentLocation.location.coordinate.latitude, self.currentLocation.location.coordinate.longitude };
            CLLocationCoordinate2D destination = { self.poiLocation.latitude, self.poiLocation.longitude };
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
                // Create an MKMapItem to pass to the Maps app
                MKPlacemark *placemarkStart = [[MKPlacemark alloc] initWithCoordinate:start addressDictionary:nil];
                MKPlacemark *placemarkDest = [[MKPlacemark alloc] initWithCoordinate:destination addressDictionary:nil];
                MKMapItem *mapItemStart = [[MKMapItem alloc] initWithPlacemark:placemarkStart];
                MKMapItem *mapItemDest = [[MKMapItem alloc] initWithPlacemark:placemarkDest];
                
                [MKMapItem openMapsWithItems:@[mapItemStart, mapItemDest] launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking}];
                
            } else {
                
                NSString *googleMapsURLString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f",
                                                 start.latitude, start.longitude, destination.latitude, destination.longitude];
                NSURL *url = [NSURL URLWithString:googleMapsURLString];
                
                [[UIApplication sharedApplication] openURL:url];
            }
            
        }
    } else if (actionSheet.tag == 2) { // PHOTOUPLOAD
        if (buttonIndex == 0) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            if (UIDevice.isIPad == YES) {
                
                self.popOverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];
                
                [self.popOverController presentPopoverFromRect:self.cameraButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                [self presentViewController:self.imagePicker animated:YES];
            }
        } else if (buttonIndex == 1) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            if (UIDevice.isIPad == YES) {
                
                self.popOverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];
                
                [self.popOverController presentPopoverFromRect:self.cameraButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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

- (void)thumbnailTapped:(UITapGestureRecognizer*)sender {
    WMInfinitePhotoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMInfinitePhotoViewController"];
    vc.imageURLArray = self.originalImageURLArray;
    vc.tappedImage = sender.view.tag;
    [self presentForcedModalViewController:vc animated:YES];
}

- (void)cameraButtonPressed {
	// Check if user is authenticated
    if (dataManager.userIsAuthenticated == NO) {
		if ([self.navigationController isKindOfClass:[WMPOIIPadNavigationController class]] == YES) {
			// The user isn't logged in. Present the login screen then. This will close the popover and open the login screen popover.
			WMPOIIPadNavigationController *detailNavigationController = (WMPOIIPadNavigationController *) self.navigationController;
			[((WMNavigationControllerBase *)detailNavigationController.listViewController.navigationController) presentLoginScreen];
		} else if ([self.navigationController isKindOfClass:[WMNavigationControllerBase class]] == YES) {
			WMNavigationControllerBase *baseNavigationController = (WMNavigationControllerBase *) self.navigationController;
			[baseNavigationController presentLoginScreenWithButtonFrame:self.cameraButton.frame];
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
        
        if (UIDevice.isIPad == YES) {
            
            self.popOverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];
            
            [self.popOverController presentPopoverFromRect:self.cameraButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else {
            [self presentForcedModalViewController:self.imagePicker animated:YES];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    // reset status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.imagePicker setNeedsStatusBarAppearanceUpdate];
    
    if (UIDevice.isIPad == YES) {
        [self.popOverController dismissPopoverAnimated:YES];
    }
    
    [self dismissViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // reset status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.imagePicker setNeedsStatusBarAppearanceUpdate];
    
    if (UIDevice.isIPad == YES) {
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
    
    [self createThumbnails];
    
}

- (void)dataManager:(WMDataManager *)dataManager fetchPhotosFailedWithError:(NSError *)error {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"FetchingPhotoURLFailed", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    
    [alert show];
}

#pragma mark - Other Button Handlers

- (void) shareLocationButtonPressed {
    WMShareSocialViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMShareSocialViewController"];
    vc.baseController = self.baseController;
    CGFloat xPosition = (768.0f / 2.0f) - 160.0f;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        xPosition = (1024.0f / 2.0f) - 160.0f;
    }
    vc.popoverButtonFrame = CGRectMake( xPosition, 150.0f, 320.0f, 500.0f);
    vc.title = vc.navigationBarTitle = NSLocalizedString(@"ShareLocationViewHeadline", @"");
    
    if (UIDevice.isIPad == YES) {
        [self.navigationController pushViewController:vc animated:YES];
        vc.titleView.hidden = YES;
    } else {
        [self presentViewController:vc animated:YES];
    }
    NSString *shareLocationLabel = NSLocalizedString(@"ShareLocationLabel", @"");
    NSString *urlString = [NSString stringWithFormat:@"http://wheelmap.org/nodes/%@", self.node.id];
    NSURL *url = [NSURL URLWithString: urlString];
	vc.shareURlString = url.absoluteString;
    vc.shareLocationLabel.text = [NSString stringWithFormat:@"%@ \n\"%@\" - %@", shareLocationLabel, self.node.name, url];
    
}

- (void)askFriendsForStatusButtonPressed {
    WMShareSocialViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMShareSocialViewController"];
    vc.baseController = self.baseController;
    vc.title = vc.navigationBarTitle = NSLocalizedString(@"ShareLocationViewHeadline", @"");
    
    if (UIDevice.isIPad == YES) {
        [self.navigationController pushViewController:vc animated:YES];
        vc.titleView.hidden = YES;
    } else {
        [self presentViewController:vc animated:YES];
    }
    NSString *shareLocationLabel = NSLocalizedString(@"AskFriendsLabel", @"");
    NSString *urlString = [NSString stringWithFormat:@"http://wheelmap.org/nodes/%@", self.node.id];
    NSURL *url = [NSURL URLWithString: urlString];
    vc.shareLocationLabel.text = [NSString stringWithFormat:@"%@ \n\"%@\" - %@", shareLocationLabel, self.node.name, url];
    
}

- (void)showAccessOptions {
    WMEditPOIWheelchairStatusViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMEditPOIWheelchairStatusViewController"];
    vc.delegate = self;
    vc.node = self.node;
    vc.title = NSLocalizedString(@"WheelAccessStatusViewHeadline", @"");
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)accessButtonPressed:(NSString*)wheelchairAccess {
    self.node.wheelchair = wheelchairAccess;
}

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
    
    switch (networkStatus) {
        case NotReachable:
            self.cameraButton.enabled = NO;
            break;
            
        default:
            self.cameraButton.enabled = YES;
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

@end

