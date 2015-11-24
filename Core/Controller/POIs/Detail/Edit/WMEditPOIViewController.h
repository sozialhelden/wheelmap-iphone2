//
//  WMEditPOIViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 04.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WMDataManagerDelegate.h"
#import "WMPOIStateButtonView.h"

@class Node, WMCategory, NodeType;

@interface WMEditPOIViewController : WMViewController <UITextFieldDelegate, UITextViewDelegate, WMDataManagerDelegate, WMEditPOIStateDelegate, WMPOIStateButtonViewDelegate> {
    UIActivityIndicatorView* progressWheel;
}

@property (nonatomic, strong) WMDataManager *				dataManager;

#pragma mark - ScrollView
@property (weak, nonatomic) IBOutlet UIScrollView *			scrollView;
@property (weak, nonatomic) IBOutlet UIView *				scrollViewContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	scrollViewContentWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	scrollViewContentHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	scrollViewBottomConstraint;

#pragma mark - Name
@property (weak, nonatomic) IBOutlet UIView *				nameInputView;
@property (weak, nonatomic) IBOutlet UILabel *				nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *			nameTextField;

#pragma mark - Type
@property (weak, nonatomic) IBOutlet UIView *				nodeTypeInputView;
@property (weak, nonatomic) IBOutlet UILabel *				nodeTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *				setNodeTypeButton;

#pragma mark - Category
@property (weak, nonatomic) IBOutlet UIView *				categoryInputView;
@property (weak, nonatomic) IBOutlet UILabel *				categoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *				setCategoryButton;

#pragma mark - Marker
@property (weak, nonatomic) IBOutlet UIView *				positionInputView;
@property (weak, nonatomic) IBOutlet UILabel *				position;
@property (weak, nonatomic) IBOutlet UIButton *				setMarkerButton;
@property (assign) BOOL										editView;

#pragma mark - State Access Buttons
@property (weak, nonatomic) IBOutlet UIView *				wheelchairStateButtonContainerView;
@property (strong, nonatomic) WMPOIStateButtonView *		wheelchairStateButtonView;
@property (weak, nonatomic) IBOutlet UIView *				toiletStateButtonContainerView;
@property (strong, nonatomic) WMPOIStateButtonView *		toiletStateButtonView;

#pragma mark - Wheelchair Description
@property (weak, nonatomic) IBOutlet UIView *				infoInputView;
@property (weak, nonatomic) IBOutlet UILabel *				infoLabel;
@property (weak, nonatomic) IBOutlet UITextView *			infoTextView;
@property (weak, nonatomic) IBOutlet UITextField *			infoPlaceholderTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	infoTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	infoInputViewHeightConstraint;

#pragma mark - Address
@property (weak, nonatomic) IBOutlet UIView *				addressInputView;
@property (weak, nonatomic) IBOutlet UILabel *				addressLabel;
@property (weak, nonatomic) IBOutlet UITextField *			streetTextField;
@property (weak, nonatomic) IBOutlet UITextField *			housenumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *			postcodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *			cityTextField;

#pragma mark - Website
@property (weak, nonatomic) IBOutlet UIView *				websiteInputView;
@property (weak, nonatomic) IBOutlet UILabel *				websiteLabel;
@property (weak, nonatomic) IBOutlet UITextField *			websiteTextField;

#pragma mark - Phone
@property (weak, nonatomic) IBOutlet UIView *				phoneInputView;
@property (weak, nonatomic) IBOutlet UILabel *				phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *			phoneTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	phoneInputViewBottomConstraint;


#pragma mark - 
@property (nonatomic) Node *								node;
@property (nonatomic, assign) BOOL							keyboardIsShown;
@property (nonatomic, strong) UIImage *						accessImage;
@property (nonatomic, strong) NSString *					currentWheelchairState;
@property (nonatomic, strong) NSString *					currentToiletState;
@property (nonatomic, strong) WMCategory *					currentCategory;
@property (nonatomic, strong) NodeType *					currentNodeType;
@property (nonatomic, strong) NSString *					currentInfoFieldText;
@property (nonatomic, assign) CLLocationCoordinate2D		currentCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D		initialCoordinate;

@property (nonatomic, assign) BOOL							isRootViewController;


- (IBAction)setNodeType:(id)sender;
- (IBAction)setCategory:(id)sender;
- (void)categoryChosen:(WMCategory*)category;
- (void)nodeTypeChosen:(NodeType*)nodeType;
- (void)markerSet:(CLLocationCoordinate2D)coord;
- (void)saveEditedData;

@end
