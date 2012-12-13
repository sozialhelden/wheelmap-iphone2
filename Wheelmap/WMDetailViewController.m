//
//  WMDetailViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 09.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "WMDetailViewController.h"
#import "Node.h"
#import "NodeType.h"
#import "WMWheelchairStatusViewController.h"
#import "WMShareSocialViewController.h"
#import "WMCommentViewController.h"
#import "WMEditPOIViewController.h"
#import "WMMapAnnotation.h"
#import "WMCompassView.h"
#import "WMPhotoViewController.h"
#import "WMInfinitePhotoViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Category.h"
#import "WMPOIMapViewController.h"


#define STARTLEFT 15

@implementation WMDetailViewController



- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.imageURLArray = [NSMutableArray new];
        
        [self.imageURLArray addObject:@"http://1.bp.blogspot.com/_zdaKzlmvgJc/SLjcZhKw16I/AAAAAAAAADQ/_PuqR3GJmko/s400/golden%2Bgirls%2Bmm.jpg"];
        [self.imageURLArray addObject:@"http://images1.wikia.nocookie.net/__cb20120725020018/creepypasta/images/6/66/The-golden-girls.jpg"];
        [self.imageURLArray addObject:@"http://upload.wikimedia.org/wikipedia/en/thumb/5/58/Golden_Girls_cast_miami_song.jpg/220px-Golden_Girls_cast_miami_song.jpg"];
        [self.imageURLArray addObject:@"http://images4.fanpop.com/image/photos/23500000/Golden-Girls-the-golden-girls-23583048-750-458.jpg"];
        [self.imageURLArray addObject:@"http://2ndfloorliving.com/wp-content/uploads/2009/10/Golden-Girls-tv-show-16.jpg"];
        [self.imageURLArray addObject:@"http://images5.fanpop.com/image/photos/30700000/Dorothy-the-golden-girls-30775692-1741-2560.jpg"];

    }
    return self;
}


#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // data manager
    dataManager = [[WMDataManager alloc] init];
    dataManager.delegate = self;

    self.gabIfStatusUnknown = 0;

    NSAssert(self.node, @"You need to set a node before this view controller can be presented");
    
    
    // SCROLLVIEW
    [self.view addSubview:self.scrollView];
    
    
    // MAPVIEW
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 110)];
    self.mapView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.mapView.layer.borderWidth = 1.0f;
    self.mapView.delegate = self;
    self.mapView.userInteractionEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewTapped:)];
    [self.mapView addGestureRecognizer:tapRecognizer];
   
    // location to zoom in
    [self.scrollView addSubview:self.mapView];
    self.mapView.showsUserLocation=YES;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    
    // SHARE LOCATION BUTTON
    UIImage *shareLocationImage = [UIImage imageNamed:@"details_share-location.png"];
    self.shareLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shareLocationButton.frame = CGRectMake(275, 70, shareLocationImage.size.width, shareLocationImage.size.height);
    [self.shareLocationButton setImage: shareLocationImage forState: UIControlStateNormal];
    [self.shareLocationButton addTarget:self action:@selector(shareLocationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.shareLocationButton];
    
    int startY = 125;
    
    // NAME
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, startY, self.view.bounds.size.width-STARTLEFT*2, 20)];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.titleLabel];
    
    startY += 22;

    // CATEGORY / NOTE TYPE
    self.nodeTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, startY, self.view.bounds.size.width-STARTLEFT*2, 16)];
    self.nodeTypeLabel.textColor = [UIColor darkGrayColor];
    self.nodeTypeLabel.font = [UIFont systemFontOfSize:12];
    self.nodeTypeLabel.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.nodeTypeLabel];
    
    startY += 23;
    
    // WHEEL ACCESS BUTTON
    [self setWheelAccessButton];
    self.wheelAccessButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.wheelAccessButton.frame = CGRectMake(10, startY, self.accessImage.size.width, self.accessImage.size.height);
    self.wheelAccessButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.wheelAccessButton.titleLabel.textColor = [UIColor whiteColor];
    [self.wheelAccessButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.wheelAccessButton setContentEdgeInsets:UIEdgeInsetsMake(0, 40, 0, 0)];
    [self.wheelAccessButton addTarget:self action:@selector(showAccessOptions) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.wheelAccessButton];
    
    startY += 64;
    
    // CONTACT INFO
    self.contactInfoView = [self createContactInfoView];
    self.contactInfoView.frame = CGRectMake(10, startY+self.gabIfStatusUnknown, 300, self.contactInfoView.bounds.size.height);
    self.contactInfoView.backgroundColor = [UIColor whiteColor];
    self.contactInfoView.layer.borderWidth = 1.0f;
    self.contactInfoView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.contactInfoView.layer setCornerRadius:5.0f];
    [self.scrollView addSubview:self.contactInfoView];
    
    startY += self.contactInfoView.bounds.size.height + 16;
    
    // IMAGESCROLLVIEW
    [self createAndAddImageScrollView];
    self.imageScrollView.frame = CGRectMake(0, startY+self.gabIfStatusUnknown, self.view.bounds.size.width, 80);
    
    startY += self.imageScrollView.frame.size.height+14;
    
    // UIVIEW with 4 Buttons
    [self createAndAddFourButtonView];
    self.fourButtonView.frame = CGRectMake(10, startY+self.gabIfStatusUnknown, 300, 100);

    startY += 85;
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.fourButtonView.frame.origin.y + self.fourButtonView.frame.size.height + 20 + self.gabIfStatusUnknown);
    [self.view addSubview:self.scrollView];
    
}

- (void)viewDidUnload {
    [self setStreetLabel:nil];
    [self setPostcodeAndCityLabel:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.title = NSLocalizedString(@"DetailViewHeadline", @"");
    self.navigationBarTitle = self.title;
    
    if (!self.navigationController.toolbarHidden) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
    
    // MAP
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.annotation = [[WMMapAnnotation alloc] initWithNode:self.node];
    [self.mapView addAnnotation:self.annotation];
    
    [self updateFields];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    
    self.fourButtonView.frame = CGRectMake(10, self.imageScrollView.frame.origin.y+self.imageScrollView.frame.size.height+14, 300, 75);
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.fourButtonView.frame.origin.y + self.fourButtonView.frame.size.height + 20);
    
    
    self.poiLocation = CLLocationCoordinate2DMake(self.node.lat.doubleValue, self.node.lon.doubleValue);
    [self checkForStatusOfButtons];

    // region to display
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.poiLocation, 100, 50);
    viewRegion.center = self.poiLocation;
    
    // display the region
    [self.mapView setRegion:viewRegion animated:YES];
    
}

#pragma mark - UI element creation

- (UIView*) createContactInfoView {
    
    UIView *infoView = [UIView new];
    int startY = 10;
    
    // STREET
    self.streetLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, startY, 225, 16)];
    self.streetLabel.textColor = [UIColor darkGrayColor];
    self.streetLabel.font = [UIFont boldSystemFontOfSize:12];
    self.streetLabel.backgroundColor = [UIColor clearColor];
    [infoView addSubview:self.streetLabel];
    
    
    startY += 16;
    
    // POSTCODE AND CITY
    self.postcodeAndCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, startY, 225, 16)];
    self.postcodeAndCityLabel.textColor = [UIColor darkGrayColor];
    self.postcodeAndCityLabel.font = [UIFont boldSystemFontOfSize:12];
    self.postcodeAndCityLabel.backgroundColor = [UIColor clearColor];
    [infoView addSubview:self.postcodeAndCityLabel];
    
    startY += 30;
    
    // COMPASS
    UIImage *compassImage = [UIImage imageNamed:@"details_compass.png"];
    WMCompassView *compassView = [[WMCompassView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-62, startY-10, compassImage.size.width, compassImage.size.height)];
    compassView.node = self.node;
    compassView.backgroundColor = [UIColor clearColor];
    [infoView addSubview:compassView];
    
    // WEBSITE
    self.websiteLabel = [[UITextView alloc] initWithFrame:CGRectMake(STARTLEFT, startY, 225, 16)];
    self.websiteLabel.textColor = [UIColor darkGrayColor];
    self.websiteLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    self.websiteLabel.editable = NO;
    self.websiteLabel.scrollEnabled = NO;
    self.websiteLabel.font = [UIFont systemFontOfSize:12];
    self.websiteLabel.backgroundColor = [UIColor clearColor];
    self.websiteLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
    
    infoView.frame = CGRectMake(0, 0, 300, startY+30);
    [infoView addSubview:self.websiteLabel];
    
    
    startY += 20;
    
    // Phone
    self.phoneLabel = [[UITextView alloc] initWithFrame:CGRectMake(STARTLEFT, startY, 225, 16)];
    self.phoneLabel.textColor = [UIColor darkGrayColor];
    self.phoneLabel.font = [UIFont systemFontOfSize:12];
    self.phoneLabel.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
    self.phoneLabel.editable = NO;
    self.phoneLabel.scrollEnabled = NO;
    self.phoneLabel.backgroundColor = [UIColor clearColor];
    self.phoneLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
    [infoView addSubview:self.phoneLabel];
    
    // DISTANCE
    self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-80, startY, 60, 16)];
    self.distanceLabel.textColor = [UIColor darkGrayColor];
    self.distanceLabel.font = [UIFont systemFontOfSize:12];
    self.distanceLabel.backgroundColor = [UIColor clearColor];
    self.distanceLabel.textAlignment = UITextAlignmentCenter;
    [infoView addSubview:self.distanceLabel];
    
    infoView.frame = CGRectMake(0, 0, 300, startY+26);
    return infoView;
}

- (void) createAskFriendsForStatusButton {
    self.askFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"details_unknown-info.png"];
    [self.askFriendsButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.askFriendsButton setTitle:NSLocalizedString(@"DetailViewAskFriendsButtonLabel", @"") forState:UIControlStateNormal];
    self.askFriendsButton.titleLabel.font = [UIFont systemFontOfSize:13];
    self.askFriendsButton.titleLabel.numberOfLines = 2;
    [self.askFriendsButton setContentEdgeInsets:UIEdgeInsetsMake(5, 55, 0, 10)];
    [self.askFriendsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.askFriendsButton.titleLabel.textColor = [UIColor darkGrayColor];

    self.askFriendsButton.frame = CGRectMake(20, 220, self.view.bounds.size.width-40, buttonImage.size.height);
    [self.askFriendsButton addTarget:self action:@selector(askFriendsForStatusButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.askFriendsButton];
}

/* Set a fixed size for view in popovers */

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(320, 480);
}




- (void) updateFields {
    
    
    // TEXTFIELDS
    
    self.titleLabel.text = self.node.name ?: @"?";
    NSString *nodeTypeString = self.node.node_type.localized_name ?: @"?";
    NSString *catString = self.node.category.localized_name ?: @"?";
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


- (void) checkForStatusOfButtons {
    /*
     if(self.node.phone == nil || [self.node.phone isEqualToString:@""]) {
     self.callButton.enabled = NO;
     } else {
     self.callButton.enabled = YES;
     }
     if(self.node.website == nil || [self.node.website isEqualToString:@""]) {
     self.websiteButton.enabled = NO;
     } else {
     self.websiteButton.enabled = YES;
     } */
    if(self.node.wheelchair_description == nil || [self.node.wheelchair_description isEqualToString:@""]) {
        self.commentButton.enabled = NO;
    } else {
        self.commentButton.enabled = YES;
    }
    if(self.currentLocation == nil) {
        self.naviButton.enabled = NO;
    } else {
        self.naviButton.enabled = YES;
    }
    
}

- (void)setWheelAccessButton {
    
    if (![self.node.wheelchair isEqualToString:@"unknown"] && self.askFriendsButton != nil) {
        [self.askFriendsButton removeFromSuperview];
        self.contactInfoView.frame = CGRectMake(self.contactInfoView.frame.origin.x, self.contactInfoView.frame.origin.y-self.gabIfStatusUnknown, self.contactInfoView.frame.size.width, self.contactInfoView.frame.size.height);
        self.imageScrollView.frame = CGRectMake(self.imageScrollView.frame.origin.x, self.imageScrollView.frame.origin.y-self.gabIfStatusUnknown, self.imageScrollView.frame.size.width, self.imageScrollView.frame.size.height);
        self.fourButtonView.frame = CGRectMake(self.fourButtonView.frame.origin.x, self.fourButtonView.frame.origin.y-self.gabIfStatusUnknown, self.fourButtonView.frame.size.width, self.fourButtonView.frame.size.height);
        self.askFriendsButton = nil;
    }
    if ([self.node.wheelchair isEqualToString:@"yes"]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-yes.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessYes", @"");
    } else if ([self.node.wheelchair isEqualToString:@"no"]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-no.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessNo", @"");
    } else if ([self.node.wheelchair isEqualToString:@"limited"]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-limited.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessLimited", @"");
    } else if ([self.node.wheelchair isEqualToString:@"unknown"]) {
        self.accessImage = [UIImage imageNamed:@"details_btn-status-unknown.png"];
        self.wheelchairAccess = NSLocalizedString(@"WheelchairAccessUnknown", @"");
        if (self.askFriendsButton == nil) {
            self.gabIfStatusUnknown = 62;
            [self createAskFriendsForStatusButton];
        }
        
    }
    
    [self.wheelAccessButton setBackgroundImage: self.accessImage forState: UIControlStateNormal];
    [self.wheelAccessButton setTitle:self.wheelchairAccess forState:UIControlStateNormal];
    
}



#pragma mark - Phone, Website, Comment, Navi

- (void)createAndAddFourButtonView {
  
    UIImage *buttonBackgroundImage = [UIImage imageNamed:@"details_btn-more-active.png"];
    UIImage *buttonBackgroundImageDisabled = [UIImage imageNamed:@"details_btn-more-inactive.png"];
    

    self.fourButtonView = [UIView new];
       
    int buttonWidth = 68;
    int buttonHeight = 62;
    int imagePlusGab = buttonWidth + (((300)-(4*buttonWidth)) / 3);
    int gabBetweenLabels = 3;
    int labelWidth = 300 / 4 - gabBetweenLabels;
    int startLabelX = (labelWidth-buttonWidth)/2;
    
    // COMMENT
    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentButton.frame = CGRectMake(2*imagePlusGab+0, 0,buttonWidth,buttonHeight);
    [self.commentButton setImage: [UIImage imageNamed:@"more-buttons_info.png"] forState: UIControlStateNormal];
    [self.commentButton setImage: [UIImage imageNamed:@"more-buttons_info-deactive.png"] forState: UIControlStateDisabled];
    [self.commentButton addTarget:self action:@selector(showCommentView) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *infoLabel = [self createBelowButtonLabel:NSLocalizedString(@"DetailView4ButtonViewInfoLabel", @"")];
    infoLabel.frame = CGRectMake(self.commentButton.frame.origin.x-startLabelX,buttonHeight+5,labelWidth, 16);

    // ROUTE
    self.naviButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.naviButton.frame = CGRectMake(3*imagePlusGab+0, 0,buttonWidth,buttonHeight);
    [self.naviButton setBackgroundImage:buttonBackgroundImage forState: UIControlStateNormal];
    [self.naviButton setBackgroundImage:buttonBackgroundImageDisabled forState: UIControlStateDisabled];
    [self.naviButton setImage: [UIImage imageNamed:@"more-buttons_route.png"] forState: UIControlStateNormal];
    [self.naviButton setImage: [UIImage imageNamed:@"more-buttons_route-deactive.png"] forState: UIControlStateDisabled];
    [self.naviButton addTarget:self action:@selector(openMap) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *routeLabel = [self createBelowButtonLabel:NSLocalizedString(@"DetailView4ButtonViewRouteLabel", @"")];
    routeLabel.frame = CGRectMake(self.naviButton.frame.origin.x-startLabelX,buttonHeight+5,labelWidth, 16);

    // add all buttons and labels
    [self.fourButtonView addSubview:self.commentButton];
    [self.fourButtonView addSubview:self.naviButton];
    [self.fourButtonView addSubview:infoLabel];
    [self.fourButtonView addSubview:routeLabel];
    
    
    [self.scrollView addSubview:self.fourButtonView];
}

- (UILabel*) createBelowButtonLabel: (NSString*) title {
    
    UILabel *belowButtonLabel = [UILabel new];
   // belowButtonLabel.backgroundColor = [UIColor orangeColor];
    belowButtonLabel.text = title;
    belowButtonLabel.font = [UIFont systemFontOfSize:11];
    belowButtonLabel.textColor = [UIColor darkGrayColor];
    belowButtonLabel.textAlignment = UITextAlignmentCenter;
    return belowButtonLabel;
}


- (void) call {
    
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

- (void) showCommentView {
    WMCommentViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMCommentViewController"];
    vc.currentNode = self.node;
    vc.title = NSLocalizedString(@"DetailView4ButtonViewInfoLabel", @"");
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)openMap {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"LeaveApp", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}


#pragma mark - Map

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[WMMapAnnotation class]]) {
        Node *node = [(WMMapAnnotation*)annotation node];
        NSString *reuseId = [node.wheelchair stringByAppendingString:node.node_type.identifier];
        self.annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        if (!self.annotationView) {
            self.annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
            self.annotationView.canShowCallout = NO;
            self.annotationView.centerOffset = CGPointMake(6, -14);
            self.annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        self.annotationView.image = [UIImage imageNamed:[@"marker_" stringByAppendingString:node.wheelchair]];
        UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 17, 13)];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.backgroundColor = [UIColor clearColor];
        icon.image = [UIImage imageWithContentsOfFile:node.node_type.iconPath];
        [self.annotationView addSubview:icon];
        
        return self.annotationView;
    }
    return nil;
}



-(void)updateDistanceToAnnotation {
    
        
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
    
    if (distance > 999) {
         [self.distanceLabel setText: [NSString stringWithFormat:@"%.1f km", distance/1000.0f]];
    } else {
        [self.distanceLabel setText: [NSString stringWithFormat:@"%.0f m", distance]];        
    }
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
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

- (WMMapAnnotation*) annotationForNode:(Node*)node
{
    for (WMMapAnnotation* annotation in  self.mapView.annotations) {
        
        // filter out MKUserLocation annotation
        if ([annotation isKindOfClass:[WMMapAnnotation class]] && [annotation.node isEqual:node]) {
            return annotation;
        }
    }
    return nil;
}

- (void)mapViewTapped:(UITapGestureRecognizer*)sender {
    
    WMPOIMapViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMPOIMapViewController"];
    vc.node = self.node;
    [self presentModalViewController:vc animated:YES];
}


#pragma mark - ActionSheets

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (actionSheet.tag == 0) { // WEBSITE
        if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.node.website]];
        }
    } else if (actionSheet.tag == 1) { // MAP
        if (buttonIndex == 0) {
           
            CLLocationCoordinate2D start = { self.currentLocation.location.coordinate.latitude, self.currentLocation.location.coordinate.longitude };
            CLLocationCoordinate2D destination = { self.poiLocation.latitude, self.poiLocation.longitude };
            
            NSString *googleMapsURLString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f",
                                             start.latitude, start.longitude, destination.latitude, destination.longitude];
            NSURL *url = [NSURL URLWithString:googleMapsURLString];
            
            [[UIApplication sharedApplication] openURL:url];
 
        }
    } else if (actionSheet.tag == 2) { // PHOTOUPLOAD
        if (buttonIndex == 0) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentModalViewController:self.imagePicker animated:YES];
        } else if (buttonIndex == 1) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentModalViewController:self.imagePicker animated:YES];
        }
    } else if (actionSheet.tag == 3) {
        NSString *phoneLinkString = [NSString stringWithFormat:@"tel:%@", self.node.phone];
        NSURL *phoneLinkURL = [NSURL URLWithString:phoneLinkString];
        [[UIApplication sharedApplication] openURL:phoneLinkURL];
        
    }
}


#pragma mark - PhotoUpload (UI, imagepicker, delegates etc.)

- (void) createAndAddImageScrollView {
    
    self.imageViewsInScrollView = [NSMutableArray new];
    
    
    UIImage *uploadBackground = [UIImage imageNamed:@"details_background-photoupload.png"];
    
    self.imageScrollView = [UIScrollView new];
    self.imageScrollView.backgroundColor = [UIColor colorWithPatternImage:uploadBackground];
    [self.imageScrollView setShowsHorizontalScrollIndicator:NO];
    
    UIImage *cameraButtonImage = [UIImage imageNamed:@"details_btn-photoupload.png"];
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake(10, 9, cameraButtonImage.size.width, cameraButtonImage.size.height);
    [cameraButton setImage: cameraButtonImage forState: UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(cameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self createThumbnails];
    
    [self.imageScrollView addSubview:cameraButton];
    [self.scrollView addSubview:self.imageScrollView];
}

- (void)createThumbnails {
    
    self.start = 22+[UIImage imageNamed:@"details_btn-photoupload.png"].size.width;
    self.gab = 16;
    
    for (int i = 0; i < self.imageURLArray.count; i++) {
        [self addThumbnail:i];
    }
    
    int scrollWidth = ((self.imageURLArray.count+1)*([UIImage imageNamed:@"details_btn-photoupload.png"].size.width + self.gab))+self.gab;
    self.imageScrollView.contentSize = CGSizeMake(scrollWidth, self.imageScrollView.frame.size.height);
}

- (void) addThumbnail: (int) i {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.start+i*80+i*self.gab, 10, 85, 60)];
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 2;
    imageView.tag = i;
    imageView.userInteractionEnabled = YES;
    [imageView setImageWithURL: [NSURL URLWithString:[self.imageURLArray objectAtIndex:i]] placeholderImage:[UIImage imageNamed:@"details_background-thumbnail.png"]];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbnailTapped:)];
    [imageView addGestureRecognizer:tapRecognizer];
    
    [self.imageScrollView addSubview:imageView];
    [self.imageViewsInScrollView addObject:imageView];
}

- (void)thumbnailTapped:(UITapGestureRecognizer*)sender {
    
    WMInfinitePhotoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMInfinitePhotoViewController"];
    vc.imageURLArray = self.imageURLArray;
    vc.tappedImage = sender.view.tag;
    [self presentModalViewController:vc animated:YES];
}

- (void) cameraButtonPressed {
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"DetailViewChoosePhotoSource", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"DetailViewUploadOptionCamera", @""), NSLocalizedString(@"DetailViewUploadOptionPhotoAlbum", @""), nil];
        actionSheet.tag = 2;
        [actionSheet showInView:self.view];
    } else {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:self.imagePicker animated:YES];
    }
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
   
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];

    NSLog(@"[LOG] UPLOAD THE PICKED IMAGE!");
    [dataManager uploadImage:chosenImage forNode:self.node];
    
    [self dismissModalViewControllerAnimated:YES];
    
}

#pragma mark - WMDataManager Delegates
-(void)dataManager:(WMDataManager *)dataManager didFinishPostingImageWithMsg:(NSString *)msg
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"PHOTO_UPLOAD_SUCCESS", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];
    
    NSLog(@"[LOG] photo upload success! %@", msg);
}

-(void)dataManager:(WMDataManager *)dataManager failedPostingImageWithError:(NSError *)error
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"PHOTO_UPLOAD_FAILD", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];
    
    NSLog(@"[LOG] photo upload failed! %@", error);
}

#pragma mark - Other Button Handlers

- (void) shareLocationButtonPressed {
    WMShareSocialViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMShareSocialViewController"];
    vc.title = NSLocalizedString(@"ShareLocationViewHeadline", @"");
    [self.navigationController pushViewController:vc animated:YES];
    NSString *shareLocationLabel = NSLocalizedString(@"ShareLocationLabel", @"");
    NSString *urlString = [NSString stringWithFormat:@"http://wheelmap.org/nodes/%@", self.node.id];
    NSURL *url = [NSURL URLWithString: urlString];
    vc.shareLocationLabel.text = [NSString stringWithFormat:@"%@ \n\"%@\" - %@", shareLocationLabel, self.node.name, url];
    
}

- (void) askFriendsForStatusButtonPressed {
    WMShareSocialViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMShareSocialViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    NSString *shareLocationLabel = NSLocalizedString(@"AskFriendsLabel", @"");
    NSString *urlString = [NSString stringWithFormat:@"http://wheelmap.org/nodes/%@", self.node.id];
    NSURL *url = [NSURL URLWithString: urlString];
    vc.shareLocationLabel.text = [NSString stringWithFormat:@"%@ \n\"%@\" - %@", shareLocationLabel, self.node.name, url];
    vc.smsButton.hidden = YES;
    
}

- (void) showAccessOptions {
    WMWheelchairStatusViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMWheelchairStatusViewController"];
    vc.delegate = self;
    vc.node = self.node;
    vc.title = NSLocalizedString(@"WheelAccessStatusViewHeadline", @"");
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)accessButtonPressed:(NSString*)wheelchairAccess {
    self.node.wheelchair = wheelchairAccess;
}


- (void) pushEditViewController {
    WMEditPOIViewController* vc = [[UIStoryboard storyboardWithName:@"WMDetailView" bundle:nil] instantiateViewControllerWithIdentifier:@"WMEditPOIViewController"];
    vc.node = self.node;
    vc.title = self.title = NSLocalizedString(@"EditPOIViewHeadline", @"");
    [self.navigationController pushViewController:vc animated:YES];
}

@end

