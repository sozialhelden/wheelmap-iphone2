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
    
    self.title = @"Details";

	
    NSAssert(self.node, @"You need to set a node before this view controller can be presented");
    
    
    // SCROLLVIEW
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 640);
    [self.view addSubview:self.scrollView];    
    
    // MAPVIEW
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 110)];
    self.mapView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.mapView.layer.borderWidth = 1.0f;
    [self.scrollView addSubview:self.mapView];
    WMMapAnnotation *annotation = [[WMMapAnnotation alloc] initWithNode:self.node];
    [self.mapView addAnnotation:annotation];
    // location to zoom in
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = self.node.lat.doubleValue;  // increase to move upwards
    zoomLocation.longitude = self.node.lon.doubleValue; // increase to move to the right
    // region to display
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 100, 50);
    // display the region
    [self.mapView setRegion:viewRegion animated:YES];
    
    // NAME
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, 125, self.view.bounds.size.width-STARTLEFT*2, 20)];
   // self.titleLabel.backgroundColor = [UIColor orangeColor];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.text = self.node.name ?: @"?";
    [self.scrollView addSubview:self.titleLabel];

    // CATEGORY / NOTE TYPE
    self.nodeTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, 147, self.view.bounds.size.width-STARTLEFT*2, 16)];
 //   self.nodeTypeLabel.backgroundColor = [UIColor orangeColor];
    self.nodeTypeLabel.textColor = [UIColor darkGrayColor];
    self.nodeTypeLabel.font = [UIFont systemFontOfSize:11];
    self.nodeTypeLabel.text = self.node.node_type.localized_name ?: @"?";
    [self.scrollView addSubview:self.nodeTypeLabel];

    // WHEEL ACCESS BUTTON
    UIImage *accessImage;
    if ([self.node.wheelchair isEqualToString:@"yes"]) {
        accessImage = [UIImage imageNamed:@"details_btn-status-yes.png"];
    } else if ([self.node.wheelchair isEqualToString:@"no"]) {
        accessImage = [UIImage imageNamed:@"details_btn-status-no.png"];
    } else if ([self.node.wheelchair isEqualToString:@"limited"]) {
        accessImage = [UIImage imageNamed:@"details_btn-status-limited.png"];
    } else if ([self.node.wheelchair isEqualToString:@"unknown"]) {
        accessImage = [UIImage imageNamed:@"details_btn-status-unknown.png"];
    }
              
    self.wheelAccessButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.wheelAccessButton.titleLabel.text = self.node.wheelchair_description;
    self.wheelAccessButton.frame = CGRectMake(10, 175, accessImage.size.width, accessImage.size.height);
    [self.wheelAccessButton setImage: accessImage forState: UIControlStateNormal];
    [self.wheelAccessButton addTarget:self action:@selector(showAccessOptions) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.wheelAccessButton];
    
    // STREET
    self.streetLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, 234, 225, 16)];
   // self.streetLabel.backgroundColor = [UIColor orangeColor];
    self.streetLabel.textColor = [UIColor darkGrayColor];
    self.streetLabel.font = [UIFont systemFontOfSize:11];
    NSString *houseNumber = self.node.housenumber ?: @"";
    self.streetLabel.text = [NSString stringWithFormat:@"%@ %@", self.node.street, houseNumber];
    [self.scrollView addSubview:self.streetLabel];
    
    // POSTCODE AND CITY
    self.postcodeAndCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(STARTLEFT, 250, 225, 16)];
   // self.postcodeAndCityLabel.backgroundColor = [UIColor orangeColor];
    self.postcodeAndCityLabel.textColor = [UIColor darkGrayColor];
    self.postcodeAndCityLabel.font = [UIFont systemFontOfSize:11];
    NSString *postcodeAndCity = [NSString stringWithFormat:@"%@, %@", self.node.postcode, self.node.city];
    self.postcodeAndCityLabel.text = postcodeAndCity ?: @"Postcode and City";
    [self.scrollView addSubview:self.postcodeAndCityLabel];
    
    // DISTANCE
    self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-75, 265, 60, 20)];
    //self.distanceLabel.backgroundColor = [UIColor orangeColor];
    self.distanceLabel.textColor = [UIColor darkGrayColor];
    self.distanceLabel.font = [UIFont systemFontOfSize:11];
    self.distanceLabel.textAlignment = UITextAlignmentCenter;
    self.distanceLabel.text = @"3,5 km" ?: @"N/A";
    [self.scrollView addSubview:self.distanceLabel];
 
    // IMAGESCROLLVIEW
    [self createAndAddImageScrollView];
    
    // UIVIEW with 4 Buttons
    [self createAndAddFourButtonView];

    // MORE INFO BUTTON
    UIImage *moreInfo = [UIImage imageNamed:@"details_btn-additional-info.png"];
    self.moreInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.moreInfoButton.titleLabel.text = self.node.wheelchair_description;
    self.moreInfoButton.frame = CGRectMake(10, 480, moreInfo.size.width, moreInfo.size.height);
    [self.moreInfoButton setImage: moreInfo forState: UIControlStateNormal];
    [self.moreInfoButton addTarget:self action:@selector(showAccessOptions) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.moreInfoButton];
}


- (void) createAndAddImageScrollView {
    
    self.imageViewsInScrollView = [NSMutableArray new];
    
   
    UIImage *uploadBackground = [UIImage imageNamed:@"details_background-photoupload.png"];
    
    self.imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 294, self.view.bounds.size.width, uploadBackground.size.height)];
    self.imageScrollView.backgroundColor = [UIColor colorWithPatternImage:uploadBackground];
    [self.imageScrollView setShowsHorizontalScrollIndicator:NO];
    
    UIImage *cameraButtonImage = [UIImage imageNamed:@"details_btn-photoupload.png"];
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake(10, 9, cameraButtonImage.size.width, cameraButtonImage.size.height);
    [cameraButton setImage: cameraButtonImage forState: UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(cameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    int start = 18+cameraButtonImage.size.width;
    int gab = 8;
    int imageCount = 3;

    UIImage *thumbnailImage = [UIImage imageNamed:@"details_background-thumbnail.png"];

    for (int i = 0; i < imageCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(start+i*thumbnailImage.size.width+i*gab, 9, thumbnailImage.size.width, thumbnailImage.size.height)];
        imageView.image = thumbnailImage;
        [self.imageScrollView addSubview:imageView];
        [self.imageViewsInScrollView addObject:imageView];
    }

    int scrollWidth = (imageCount+1)*cameraButtonImage.size.width+(imageCount+3)*gab;
    self.imageScrollView.contentSize = CGSizeMake(scrollWidth, self.imageScrollView.frame.size.height);
    
    [self.imageScrollView addSubview:cameraButton];
    [self.scrollView addSubview:self.imageScrollView];
}

- (void)createAndAddFourButtonView {
  
    UIImage *buttonBackgroundImage = [UIImage imageNamed:@"details_btn-more-active.png"];
    
    int buttonWidth = buttonBackgroundImage.size.width;
    int buttonHeight = buttonBackgroundImage.size.height;
    
    UIView *fourButtonView = [[UIView alloc] initWithFrame:CGRectMake(20, 390, self.view.bounds.size.width-40, 75)];
    //fourButtonView.backgroundColor = [UIColor greenColor];
    
   
    
    int imagePlusGab = buttonWidth + (((self.view.bounds.size.width-40)-(4*buttonWidth)) / 3);
    
    
    self.callButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.callButton.frame = CGRectMake(0, 0,buttonWidth,buttonHeight);
    [self.callButton setBackgroundImage:buttonBackgroundImage forState: UIControlStateNormal];
    [self.callButton setImage: [UIImage imageNamed:@"details_btn-more-phone-active.png"] forState: UIControlStateNormal];
     [self.callButton setImage: [UIImage imageNamed:@"details_btn-more-phone-active.png"] forState: UIControlStateNormal];
    [self.callButton addTarget:self action:@selector(showAccessOptions:) forControlEvents:UIControlEventTouchUpInside];

    UILabel *callLabel = [self createBelowButtonLabel:@"Anrufen NL"];
    callLabel.frame = CGRectMake(0,buttonHeight+5,buttonWidth, 16);

    
    self.websiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.websiteButton.frame = CGRectMake(imagePlusGab, 0,buttonWidth,buttonHeight);
    [self.websiteButton setImage: buttonBackgroundImage forState: UIControlStateNormal];
    [self.websiteButton addTarget:self action:@selector(showAccessOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *websiteLabel = [self createBelowButtonLabel:@"Website NL"];
    websiteLabel.frame = CGRectMake(imagePlusGab,buttonHeight+5,buttonWidth, 16);

    
    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentButton.frame = CGRectMake(2*imagePlusGab, 0,buttonWidth,buttonHeight);
    [self.commentButton setImage: buttonBackgroundImage forState: UIControlStateNormal];
    [self.commentButton addTarget:self action:@selector(showAccessOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *infoLabel = [self createBelowButtonLabel:@"Info NL"];
    infoLabel.frame = CGRectMake(2*imagePlusGab,buttonHeight+5,buttonWidth, 16);

    self.naviButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.naviButton.frame = CGRectMake(3*imagePlusGab, 0,buttonWidth,buttonHeight);
    [self.naviButton setImage: buttonBackgroundImage forState: UIControlStateNormal];
    [self.naviButton addTarget:self action:@selector(showAccessOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *routeLabel = [self createBelowButtonLabel:@"Route NL"];
    routeLabel.frame = CGRectMake(3*imagePlusGab,buttonHeight+5,buttonWidth, 16);

    
    [fourButtonView addSubview:self.callButton];
    [fourButtonView addSubview:self.websiteButton];
    [fourButtonView addSubview:self.commentButton];
    [fourButtonView addSubview:self.naviButton];
    [fourButtonView addSubview:callLabel];
    [fourButtonView addSubview:websiteLabel];
    [fourButtonView addSubview:infoLabel];
    [fourButtonView addSubview:routeLabel];
    
    
    [self.scrollView addSubview:fourButtonView];
}

- (UILabel*) createBelowButtonLabel: (NSString*) title {
    
    UILabel *belowButtonLabel = [UILabel new];
    belowButtonLabel.backgroundColor = [UIColor orangeColor];
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

- (void) showAccessOptions {
    WMWheelchairStatusViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMWheelchairStatusView"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) cameraButtonPressed {
    NSLog(@"Camera Button pressed");
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
     
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
    } else {
        
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    }
    
    [self presentModalViewController:self.imagePicker animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImageView *selectedImage = [self.imageViewsInScrollView objectAtIndex:0];
    selectedImage.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissModalViewControllerAnimated:YES];
    
}




@end

