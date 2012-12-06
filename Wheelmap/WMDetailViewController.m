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
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.mapView.delegate = self;
    self.annotation = [[WMMapAnnotation alloc] initWithNode:self.node];
    [self.mapView addAnnotation:self.annotation];
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
    
    // NAME
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, 125, self.view.bounds.size.width-STARTLEFT*2, 20)];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.scrollView addSubview:self.titleLabel];

    // CATEGORY / NOTE TYPE
    self.nodeTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, 147, self.view.bounds.size.width-STARTLEFT*2, 16)];
    self.nodeTypeLabel.textColor = [UIColor darkGrayColor];
    self.nodeTypeLabel.font = [UIFont systemFontOfSize:12];
    [self.scrollView addSubview:self.nodeTypeLabel];
    
    // WHEEL ACCESS BUTTON
    [self setWheelAccessButton];
    self.wheelAccessButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.wheelAccessButton.frame = CGRectMake(10, 170, self.accessImage.size.width, self.accessImage.size.height);
    self.wheelAccessButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.wheelAccessButton.titleLabel.textColor = [UIColor whiteColor];
    [self.wheelAccessButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.wheelAccessButton setContentEdgeInsets:UIEdgeInsetsMake(0, 40, 0, 0)];
    [self.wheelAccessButton addTarget:self action:@selector(showAccessOptions) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.wheelAccessButton];
    
    // STREET
    self.streetLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, 234+self.gabIfStatusUnknown, 225, 16)];
    self.streetLabel.textColor = [UIColor darkGrayColor];
    self.streetLabel.font = [UIFont systemFontOfSize:12];
    [self.scrollView addSubview:self.streetLabel];
    
    // POSTCODE AND CITY
    self.postcodeAndCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, 250+self.gabIfStatusUnknown, 225, 16)];
    self.postcodeAndCityLabel.textColor = [UIColor darkGrayColor];
    self.postcodeAndCityLabel.font = [UIFont systemFontOfSize:12];
    [self.scrollView addSubview:self.postcodeAndCityLabel];
    
    // DISTANCE
    self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-75, 265+self.gabIfStatusUnknown, 60, 20)];
    //self.distanceLabel.backgroundColor = [UIColor orangeColor];
    self.distanceLabel.textColor = [UIColor darkGrayColor];
    self.distanceLabel.font = [UIFont systemFontOfSize:12];
    self.distanceLabel.textAlignment = UITextAlignmentCenter;
    self.distanceLabel.text = @"3,5 km" ?: @"N/A";
    [self.scrollView addSubview:self.distanceLabel];
 
    // IMAGESCROLLVIEW
    [self createAndAddImageScrollView];
    
    // UIVIEW with 4 Buttons
    [self createAndAddFourButtonView];

    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 520 + self.gabIfStatusUnknown);
    [self.view addSubview:self.scrollView];
    
}

- (void) createAskFriendsForStatusButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"details_unknown-info.png"];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"DetailsViewAskFriendsButtonLabel", @"") forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    button.titleLabel.numberOfLines = 2;
    [button setContentEdgeInsets:UIEdgeInsetsMake(5, 55, 0, 10)];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    button.titleLabel.textColor = [UIColor darkGrayColor];

    button.frame = CGRectMake(20, 220, self.view.bounds.size.width-40, buttonImage.size.height);
    [button addTarget:self action:@selector(askFriendsForStatusButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:button];
}

- (void)createThumbnails {
    int start = 18+[UIImage imageNamed:@"details_btn-photoupload.png"].size.width;
    int gab = 8;
    
    UIImage *thumbnailImage = [UIImage imageNamed:@"details_background-thumbnail.png"];
    
    for (int i = 0; i < self.imageCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(start+i*thumbnailImage.size.width+i*gab, 9, thumbnailImage.size.width, thumbnailImage.size.height)];
        [self.imageScrollView addSubview:imageView];
        [self.imageViewsInScrollView addObject:imageView];
    }
    
    int scrollWidth = (self.imageCount+1)*[UIImage imageNamed:@"details_btn-photoupload.png"].size.width+(self.imageCount+3)*gab;
    self.imageScrollView.contentSize = CGSizeMake(scrollWidth, self.imageScrollView.frame.size.height);
}

- (void) createAndAddImageScrollView {
    
    self.imageViewsInScrollView = [NSMutableArray new];
    
   
    UIImage *uploadBackground = [UIImage imageNamed:@"details_background-photoupload.png"];
    
    self.imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 294+self.gabIfStatusUnknown, self.view.bounds.size.width, uploadBackground.size.height)];
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
    self.fourButtonView.frame = CGRectMake(10, 390+self.gabIfStatusUnknown, 320-20, 75);
   // self.fourButtonView.backgroundColor = [UIColor greenColor];
   
    int buttonWidth = 68;
    int buttonHeight = 62;
    int imagePlusGab = buttonWidth + (((300)-(4*buttonWidth)) / 3);
    int gabBetweenLabels = 3;
    int labelWidth = self.fourButtonView.frame.size.width / 4 - gabBetweenLabels;
    int startLabelX = (labelWidth-buttonWidth)/2;
    
    // PHONE
    self.callButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.callButton.frame = CGRectMake(0, 0,buttonWidth,buttonHeight);
    [self.callButton setImage: [UIImage imageNamed:@"more-buttons_phone.png"] forState: UIControlStateNormal];
    [self.callButton setImage: [UIImage imageNamed:@"more-buttons_phone-deactive.png"] forState: UIControlStateDisabled];
    [self.callButton addTarget:self action:@selector(call) forControlEvents:UIControlEventTouchUpInside];

    UILabel *callLabel = [self createBelowButtonLabel:NSLocalizedString(@"DetailsView4ButtonViewCallLabel", @"")];
    callLabel.frame = CGRectMake(self.callButton.frame.origin.x-startLabelX,buttonHeight+5,labelWidth, 16);

    // WEBSITE
    self.websiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.websiteButton.frame = CGRectMake(imagePlusGab+0, 0,buttonWidth,buttonHeight);
    [self.websiteButton setImage: [UIImage imageNamed:@"more-buttons_url.png"] forState: UIControlStateNormal];
    [self.websiteButton setImage: [UIImage imageNamed:@"more-buttons_url-deactive.png"] forState: UIControlStateDisabled];
    [self.websiteButton addTarget:self action:@selector(openWebpage) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *websiteLabel = [self createBelowButtonLabel:NSLocalizedString(@"DetailsView4ButtonViewWebsiteLabel", @"")];
    websiteLabel.frame = CGRectMake(self.websiteButton.frame.origin.x-startLabelX,buttonHeight+5,labelWidth, 16);

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
    [self.fourButtonView addSubview:callLabel];
    [self.fourButtonView addSubview:websiteLabel];
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
    [self updateFields];
    
}

- (void)viewDidAppear:(BOOL)animated {
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.fourButtonView.frame.origin.y + self.fourButtonView.frame.size.height + 10);
    self.fourButtonView.frame = CGRectMake(10, 390+self.gabIfStatusUnknown, 320-20, 75);
    // MAP
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
    NSString *street = self.node.street ?: @"?";
    NSString *houseNumber = self.node.housenumber ?: @"?";
    self.streetLabel.text = [NSString stringWithFormat:@"%@ %@", street, houseNumber];
    NSString *postcode = self.node.postcode ?: @"?";
    NSString *city = self.node.city ?: @"?";
    self.postcodeAndCityLabel.text = [NSString stringWithFormat:@"%@ %@", postcode, city];
    
    [self checkForStatusOfButtons];
    [self setWheelAccessButton];
    [self updateDistanceToAnnotation];
      
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
        self.gabIfStatusUnknown = 62;
        [self createAskFriendsForStatusButton];
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
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(6, -14);
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        annotationView.image = [UIImage imageNamed:[@"marker_" stringByAppendingString:node.wheelchair]];
        return annotationView;
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

    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.node.website]];
        }
    } else if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            NSLog(@"XXXXXXXX open map");
        }
    } else if (actionSheet.tag == 2) {
        if (buttonIndex == 0) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentModalViewController:self.imagePicker animated:YES];
        } else if (buttonIndex == 1) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentModalViewController:self.imagePicker animated:YES];
        }
    }
}

#pragma mark - button handlers

- (void) shareLocationButtonPressed {
    WMShareSocialViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMShareSocialViewController"];
    vc.title = NSLocalizedString(@"ShareLocationViewHeadline", @"");
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void) askFriendsForStatusButtonPressed {
    WMShareSocialViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMShareSocialViewController"];
   // vc.title = @"ASK FRIENDS";
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void) showAccessOptions {
    WMWheelchairStatusViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMWheelchairStatusViewController"];
    vc.delegate = self;
    vc.title = NSLocalizedString(@"WheelAccessStatusViewHeadline", @"");
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)accessButtonPressed:(NSString*)wheelchairAccess {
    self.node.wheelchair = wheelchairAccess;
}


- (void) call {
    
    NSString *phoneLinkString = [NSString stringWithFormat:@"tel:%@", self.node.phone];
    NSURL *phoneLinkURL = [NSURL URLWithString:phoneLinkString];
    [[UIApplication sharedApplication] openURL:phoneLinkURL];

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

