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


#define STARTLEFT 15

@implementation WMDetailViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"DetailsViewHeadline", @"");

    self.gabIfStatusUnknown = 0;

    NSAssert(self.node, @"You need to set a node before this view controller can be presented");
    
    
    // SCROLLVIEW
    [self.view addSubview:self.scrollView];
    
    
    // MAPVIEW
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 110)];
    self.mapView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.mapView.layer.borderWidth = 1.0f;
    self.mapView.delegate = self;
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
    [self.scrollView addSubview:self.titleLabel];
    
    startY += 22;

    // CATEGORY / NOTE TYPE
    self.nodeTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, startY, self.view.bounds.size.width-STARTLEFT*2, 16)];
    self.nodeTypeLabel.textColor = [UIColor darkGrayColor];
    self.nodeTypeLabel.font = [UIFont systemFontOfSize:12];
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
    
    // STREET
    self.streetLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, startY+self.gabIfStatusUnknown, 225, 16)];
    self.streetLabel.textColor = [UIColor darkGrayColor];
    self.streetLabel.font = [UIFont systemFontOfSize:12];
    [self.scrollView addSubview:self.streetLabel];
    
    
    startY += 16;
  
        // POSTCODE AND CITY
    self.postcodeAndCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, startY+self.gabIfStatusUnknown, 225, 16)];
    self.postcodeAndCityLabel.textColor = [UIColor darkGrayColor];
    self.postcodeAndCityLabel.font = [UIFont systemFontOfSize:12];
    [self.scrollView addSubview:self.postcodeAndCityLabel];
    
    startY += 18;
    
    // COMPASS
    UIImage *compassImage = [UIImage imageNamed:@"details_compass.png"];
    WMCompassView *compassView = [[WMCompassView alloc] initWithFrame:CGRectMake(265, startY+self.gabIfStatusUnknown-10, compassImage.size.width, compassImage.size.height)];
    compassView.node = self.node;
   
    [self.scrollView addSubview:compassView];
    
    // WEBSITE
    self.websiteLabel = [[UITextView alloc] initWithFrame:CGRectMake(STARTLEFT, startY+self.gabIfStatusUnknown, 225, 22)];
    self.websiteLabel.textColor = [UIColor darkGrayColor];
    self.websiteLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    self.websiteLabel.editable = NO;
    self.websiteLabel.scrollEnabled = NO;
    self.websiteLabel.font = [UIFont systemFontOfSize:12];
    self.websiteLabel.backgroundColor = [UIColor orangeColor];
    [self.scrollView addSubview:self.websiteLabel];
    
    
    startY += 23;

    // Phone
    self.phoneLabel = [[UITextView alloc] initWithFrame:CGRectMake(STARTLEFT, startY+self.gabIfStatusUnknown, 225, 42)];
    self.phoneLabel.textColor = [UIColor darkGrayColor];
    self.phoneLabel.font = [UIFont systemFontOfSize:12];
    self.phoneLabel.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
    self.phoneLabel.editable = NO;
    self.phoneLabel.scrollEnabled = NO;
    self.phoneLabel.backgroundColor = [UIColor greenColor];
    [self.scrollView addSubview:self.phoneLabel];
    
     // DISTANCE
    self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-75, startY+self.gabIfStatusUnknown, 70, 16)];
    self.distanceLabel.textColor = [UIColor darkGrayColor];
    self.distanceLabel.font = [UIFont systemFontOfSize:12];
    self.distanceLabel.textAlignment = UITextAlignmentCenter;
    [self.scrollView addSubview:self.distanceLabel];
 
    startY += 30;
    
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
    
    // TEST
    self.headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 250, 130, 30)];
    self.headingLabel.backgroundColor = [UIColor orangeColor];
  //  [self.scrollView addSubview:self.headingLabel];
    
}

- (void) createAskFriendsForStatusButton {
    self.askFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"details_unknown-info.png"];
    [self.askFriendsButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.askFriendsButton setTitle:NSLocalizedString(@"DetailsViewAskFriendsButtonLabel", @"") forState:UIControlStateNormal];
    self.askFriendsButton.titleLabel.font = [UIFont systemFontOfSize:13];
    self.askFriendsButton.titleLabel.numberOfLines = 2;
    [self.askFriendsButton setContentEdgeInsets:UIEdgeInsetsMake(5, 55, 0, 10)];
    [self.askFriendsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.askFriendsButton.titleLabel.textColor = [UIColor darkGrayColor];

    self.askFriendsButton.frame = CGRectMake(20, 220, self.view.bounds.size.width-40, buttonImage.size.height);
    [self.askFriendsButton addTarget:self action:@selector(askFriendsForStatusButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.askFriendsButton];
}

- (void)createThumbnails {
    int start = 22+[UIImage imageNamed:@"details_btn-photoupload.png"].size.width;
    int gab = 16;
    
    for (int i = 0; i < self.imageCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(start+i*80+i*gab, 10, 85, 60)];
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 2;
        [self.imageScrollView addSubview:imageView];
        [self.imageViewsInScrollView addObject:imageView];
    }
    
    int scrollWidth = (self.imageCount+1)*[UIImage imageNamed:@"details_btn-photoupload.png"].size.width+(self.imageCount+3)*gab;
    self.imageScrollView.contentSize = CGSizeMake(scrollWidth, self.imageScrollView.frame.size.height);
}

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
    
    UILabel *infoLabel = [self createBelowButtonLabel:NSLocalizedString(@"DetailsView4ButtonViewInfoLabel", @"")];
    infoLabel.frame = CGRectMake(self.commentButton.frame.origin.x-startLabelX,buttonHeight+5,labelWidth, 16);

    // ROUTE
    self.naviButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.naviButton.frame = CGRectMake(3*imagePlusGab+0, 0,buttonWidth,buttonHeight);
    [self.naviButton setBackgroundImage:buttonBackgroundImage forState: UIControlStateNormal];
    [self.naviButton setBackgroundImage:buttonBackgroundImageDisabled forState: UIControlStateDisabled];
    [self.naviButton setImage: [UIImage imageNamed:@"more-buttons_route.png"] forState: UIControlStateNormal];
    [self.naviButton setImage: [UIImage imageNamed:@"more-buttons_route-deactive.png"] forState: UIControlStateDisabled];
    [self.naviButton addTarget:self action:@selector(openMap) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *routeLabel = [self createBelowButtonLabel:NSLocalizedString(@"DetailsView4ButtonViewRouteLabel", @"")];
    routeLabel.frame = CGRectMake(self.naviButton.frame.origin.x-startLabelX,buttonHeight+5,labelWidth, 16);

    // add all buttons and labels
    [self.fourButtonView addSubview:self.callButton];
    [self.fourButtonView addSubview:self.websiteButton];
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


/* Set a fixed size for view in popovers */

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(320, 480);
}


- (void)viewDidUnload {
    [self setStreetLabel:nil];
    [self setPostcodeAndCityLabel:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
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
    

    CLLocationCoordinate2D poiLocation;
    poiLocation.latitude = self.node.lat.doubleValue;  // increase to move upwards
    poiLocation.longitude = self.node.lon.doubleValue; // increase to move to the right
    // region to display
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(poiLocation, 100, 50);
    viewRegion.center = poiLocation;

    // display the region
    [self.mapView setRegion:viewRegion animated:YES];

}


- (void) updateFields {
    
    
    // TEXTFIELDS
    
    self.titleLabel.text = self.node.name ?: @"?";
    self.nodeTypeLabel.text = self.node.node_type.localized_name ?: @"?";

    
    if (self.node.street == nil && self.node.housenumber == nil && self.node.postcode == nil && self.node.city == nil) {
        self.postcodeAndCityLabel.text = @"no address available";
    } else {
        NSString *street = self.node.street ?: @"";
        NSString *houseNumber = self.node.housenumber ?: @"";
        self.streetLabel.text = [NSString stringWithFormat:@"%@ %@", street, houseNumber];
        NSString *postcode = self.node.postcode ?: @"";
        NSString *city = self.node.city ?: @"";
        self.postcodeAndCityLabel.text = [NSString stringWithFormat:@"%@ %@", postcode, city];   
    }

    self.websiteLabel.text = self.node.website ?: @"no website available";
    self.phoneLabel.text = self.node.phone ?: @"no phone available";

    [self checkForStatusOfButtons];
    [self setWheelAccessButton];
    [self updateDistanceToAnnotation];
    
    self.annotationView.image = [UIImage imageNamed:[@"marker_" stringByAppendingString:self.node.wheelchair]];

      
}

- (void) checkForStatusOfButtons {
    
    if(self.node.phone == nil || [self.node.phone isEqualToString:@""]) {
        self.callButton.enabled = NO;
    } else {
        self.callButton.enabled = YES;
    }
    if(self.node.website == nil || [self.node.website isEqualToString:@""]) {
        self.websiteButton.enabled = NO;
    } else {
        self.websiteButton.enabled = YES;
    }
    if(self.node.wheelchair_description == nil || [self.node.wheelchair_description isEqualToString:@""]) {
        self.commentButton.enabled = NO;
    } else {
        self.commentButton.enabled = YES;
    }
    if(self.node.street == nil || [self.node.street isEqualToString:@""]) {
        self.naviButton.enabled = NO;
    } else {
        self.naviButton.enabled = YES;
    }
    
}

- (void)setWheelAccessButton {
    
    if (![self.node.wheelchair isEqualToString:@"unknown"] && self.askFriendsButton != nil) {
        [self.askFriendsButton removeFromSuperview];
        self.streetLabel.frame = CGRectMake(self.streetLabel.frame.origin.x, self.streetLabel.frame.origin.y-self.gabIfStatusUnknown, self.streetLabel.frame.size.width, self.streetLabel.frame.size.height);
        self.postcodeAndCityLabel.frame = CGRectMake(self.postcodeAndCityLabel.frame.origin.x, self.postcodeAndCityLabel.frame.origin.y-self.gabIfStatusUnknown, self.postcodeAndCityLabel.frame.size.width, self.postcodeAndCityLabel.frame.size.height);
        self.websiteLabel.frame = CGRectMake(self.websiteLabel.frame.origin.x, self.websiteLabel.frame.origin.y-self.gabIfStatusUnknown, self.websiteLabel.frame.size.width, self.websiteLabel.frame.size.height);
        self.phoneLabel.frame = CGRectMake(self.postcodeAndCityLabel.frame.origin.x, self.phoneLabel.frame.origin.y-self.gabIfStatusUnknown, self.phoneLabel.frame.size.width, self.phoneLabel.frame.size.height);
        self.compassView.frame = CGRectMake(self.compassView.frame.origin.x, self.compassView.frame.origin.y-self.gabIfStatusUnknown, self.compassView.frame.size.width, self.compassView.frame.size.height);
        self.distanceLabel.frame = CGRectMake(self.distanceLabel.frame.origin.x, self.distanceLabel.frame.origin.y-self.gabIfStatusUnknown, self.distanceLabel.frame.size.width, self.distanceLabel.frame.size.height);
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

#pragma mark - Map View Delegate

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
        return self.annotationView;
    }
    return nil;
}



-(void)updateDistanceToAnnotation {
    
        
    if (self.mapView.userLocation.location == nil) {
        self.distanceLabel.text = @"User location is unknown";
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

#pragma mark - imagePicker delegates

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.imageCount++;
    [self createThumbnails];
    UIImageView *selectedImage = [self.imageViewsInScrollView objectAtIndex:self.imageViewsInScrollView.count-1];
    selectedImage.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissModalViewControllerAnimated:YES];
    
}


#pragma mark - actionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (actionSheet.tag == 0) { // WEBSITE
        if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.node.website]];
        }
    } else if (actionSheet.tag == 1) { // MAP
        if (buttonIndex == 0) {
            NSLog(@"XXXXXXXX open map");
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

#pragma mark - button handlers

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
    vc.title = NSLocalizedString(@"DetailsView4ButtonViewInfoLabel", @"");
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)openMap {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"LeaveApp", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

- (void) cameraButtonPressed {
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"DetailsViewChoosePhotoSource", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"DetailsViewUploadOptionCamera", @""), NSLocalizedString(@"DetailsViewUploadOptionPhotoAlbum", @""), nil];
        actionSheet.tag = 2;
        [actionSheet showInView:self.view];
    } else {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:self.imagePicker animated:YES];
    }

    
}

- (void) setUpdatedNode: (Node*) node {
    self.node = node;
}

- (void) pushEditViewController {
    WMEditPOIViewController* vc = [[UIStoryboard storyboardWithName:@"WMDetailView" bundle:nil] instantiateViewControllerWithIdentifier:@"WMEditPOIViewController"];
    vc.node = self.node;
    vc.title = self.title = NSLocalizedString(@"EditPOIViewHeadline", @"");
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}



@end

