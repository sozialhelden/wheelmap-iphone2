//
//  WMEditPOIViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 04.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "WMEditPOIViewController.h"
#import "WMEditPOIStateViewController.h"
#import "WMPOIViewController.h"
#import "WMEditPOIPositionViewController.h"
#import "NodeType.h"
#import "WMEditPOICategoryViewController.h"
#import "WMEditPOITypeViewController.h"
#import "WMDataManagerDelegate.h"
#import "WMCategory.h"
#import "Node.h"
#import "NodeType.h"
#import "WMIPadRootViewController.h"
#import "WMPOIIPadNavigationController.h"

@interface WMEditPOIViewController ()

@end

@implementation WMEditPOIViewController {
    
    BOOL hasCoordinate;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.scrollView.scrollsToTop = YES;

    self.scrollView.backgroundColor = [UIColor wmGreyColor];
    
    self.dataManager = [[WMDataManager alloc] init];
    self.dataManager.useForTemporaryObjects = !self.editView;
    self.dataManager.delegate = self;
    
	// Do any additional setup after loading the view.
    self.currentCategory = self.node.node_type.category;
    self.currentNodeType = self.node.node_type;
    self.currentWheelchairState = self.node.wheelchair;
	self.currentToiletState = self.node.wheelchair_toilet;
	self.nameTextField.delegate = self;
    self.infoTextView.delegate = self;
    self.streetTextField.delegate = self;
    self.housenumberTextField.delegate = self;
    self.postcodeTextField.delegate = self;
    self.cityTextField.delegate = self;
    self.websiteTextField.delegate = self;
    self.phoneTextField.delegate = self;
	self.infoPlaceholderTextView.placeholder = NSLocalizedString(@"DetailsView4ButtonViewInfoLabel", @"");
    self.streetTextField.placeholder = NSLocalizedString(@"EditPOIViewStreet", @"");
    self.streetTextField.placeholder = NSLocalizedString(@"EditPOIViewHousenumber", @"");
    self.streetTextField.placeholder = NSLocalizedString(@"EditPOIViewPostcode", @"");
    self.streetTextField.placeholder = NSLocalizedString(@"EditPOIViewCity", @"");
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    
    // WHEEL ACCESS
	self.wheelchairStateButtonView = [[WMPOIStateButtonView alloc] initFromNibToView:self.wheelchairStateButtonContainerView];
	self.wheelchairStateButtonView.statusType = WMPOIStateTypeWheelchair;
	self.wheelchairStateButtonView.statusString = self.currentWheelchairState;
	self.wheelchairStateButtonView.showStateDelegate = self;

	self.toiletStateButtonView = [[WMPOIStateButtonView alloc] initFromNibToView:self.toiletStateButtonContainerView];
	self.toiletStateButtonView.statusType = WMPOIStateTypeToilet;
	self.toiletStateButtonView.statusString = self.currentToiletState;
	self.toiletStateButtonView.showStateDelegate = self;

    self.nameLabel.text = NSLocalizedString(@"EditPOIViewNameLabel", @"");
    self.nodeTypeLabel.text = NSLocalizedString(@"EditPOIViewNodeTypeLabel", @"");
    self.categoryLabel.text = NSLocalizedString(@"EditPOIViewCategoryLabel", @"");
    self.infoLabel.text = NSLocalizedString(@"DetailsView4ButtonViewInfoLabel", @"");
    self.addressLabel.text = NSLocalizedString(@"EditPOIViewAddressLabel", @"");
    self.websiteLabel.text = NSLocalizedString(@"EditPOIViewWebsiteLabel", @"");
    self.phoneLabel.text = NSLocalizedString(@"EditPOIViewPhoneLabel", @"");
	self.position.text = NSLocalizedString(@"EditPOIViewPositionLabel", nil);
	
    self.streetTextField.placeholder = NSLocalizedString(@"Street Placeholder", nil);
    self.housenumberTextField.placeholder = NSLocalizedString(@"Housenumber Placeholder", nil);
    self.postcodeTextField.placeholder = NSLocalizedString(@"Postcode Placeholder", nil);
    self.cityTextField.placeholder = NSLocalizedString(@"City Placeholder", nil);

	[self.setMarkerButton addTarget:self action:@selector(pushToSetMarkerView) forControlEvents:UIControlEventTouchUpInside];
	[self.setMarkerButton setTitle:NSLocalizedString(@"EditPOIViewSetMarkerButton", @"") forState:UIControlStateNormal];
    if (self.editView == NO) {
		self.currentCoordinate = kCLLocationCoordinate2DInvalid;
		self.node = [self.dataManager createNode];
		hasCoordinate = NO;
	} else if (self.node.lat != nil && self.node.lon != nil) {
		self.currentCoordinate = CLLocationCoordinate2DMake(self.node.lat.doubleValue, self.node.lon.doubleValue);
		[self.setMarkerButton setTitle:[NSString stringWithFormat:@"(%0.5f, %0.5f)", self.node.lat.doubleValue, self.node.lon.doubleValue] forState:UIControlStateNormal];
	}

    [self.wheelchairStateButtonView updateViewContent];
	[self.toiletStateButtonView updateViewContent];

    [self styleInputView:self.nameInputView];
    [self styleInputView:self.nodeTypeInputView];
    [self styleInputView:self.categoryInputView];
    [self styleInputView:self.positionInputView];
    [self styleInputView:self.infoInputView];
    [self styleInputView:self.addressInputView];
    [self styleInputView:self.websiteInputView];
    [self styleInputView:self.phoneInputView];

    // progress wheel
    progressWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    progressWheel.frame = CGRectMake(0, 0, 50, 50);
    progressWheel.backgroundColor = [UIColor blackColor];
    progressWheel.center = CGPointMake(self.view.center.x, self.view.center.y-40);
    progressWheel.hidden = YES;
    progressWheel.layer.cornerRadius = 5.0;
    progressWheel.layer.masksToBounds = YES;
    [self.view addSubview:progressWheel];

	if (self.view.isRightToLeftDirection == YES) {
		self.setCategoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
		self.setNodeTypeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
		self.setMarkerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

		if (SYSTEM_VERSION_LESS_THAN(@"9.0") == YES) {
			// As UITextFields doesn't support right to left automatically on prior iOS9 devices, we have to do it on our own.
			self.nameTextField.textAlignment = NSTextAlignmentRight;
			self.infoTextView.textAlignment = NSTextAlignmentRight;
			self.streetTextField.textAlignment = NSTextAlignmentRight;
			self.housenumberTextField.textAlignment = NSTextAlignmentRight;
			self.postcodeTextField.textAlignment = NSTextAlignmentRight;
			self.cityTextField.textAlignment = NSTextAlignmentRight;
			self.websiteTextField.textAlignment = NSTextAlignmentRight;
			self.phoneTextField.textAlignment = NSTextAlignmentRight;
		}
	}
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"NavBarTitleEdit", nil);
    self.navigationBarTitle = self.title;
    
    [(WMPOIIPadNavigationController *)self.navigationController changeScreenStatusFor:self];

    [self updateFields];

	if (UIDevice.currentDevice.isIPad == YES) {
		self.scrollViewContentWidthConstraint.constant = K_POPOVER_VIEW_WIDTH;
	} else {
		self.scrollViewContentWidthConstraint.constant = self.view.frameWidth;
	}
	self.scrollViewContentHeightConstraint.constant = self.phoneInputView.frameY + self.phoneInputView.frameHeight + self.webSiteInputViewBottomConstraint.constant;

	self.preferredContentSize = CGSizeMake(self.scrollViewContentWidthConstraint.constant, self.scrollViewContentHeightConstraint.constant);
}

- (void)viewDidLayoutSubviews {

}

- (void) updateFields {
    self.nameTextField.text = self.node.name;
    [self.setNodeTypeButton setTitle:self.currentNodeType.localized_name forState:UIControlStateNormal];
    [self.setCategoryButton setTitle:self.currentCategory.localized_name forState:UIControlStateNormal];
    self.wheelchairStateButtonView.statusString = self.currentWheelchairState;
	self.toiletStateButtonView.statusString = self.currentToiletState;
    self.infoTextView.text = self.node.wheelchair_description;
	// Show the infoTextView if no info is set.
	self.infoPlaceholderTextView.hidden = !(self.infoTextView.text == nil || self.infoTextView.text.length == 0);
    self.streetTextField.text = self.node.street;
    self.housenumberTextField.text = self.node.housenumber;
    self.postcodeTextField.text = self.node.postcode;
    self.cityTextField.text = self.node.city;
    self.websiteTextField.text = self.node.website;
    self.phoneTextField.text = self.node.phone;
}

- (void)dealloc {
	// unregister for keyboard notifications while not visible.
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	// unregister for keyboard notifications while not visible.
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) styleInputView: (UIView*) inputView {
    [inputView.layer setCornerRadius:5.0f];
    [inputView.layer setMasksToBounds:YES];
    inputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    inputView.layer.borderWidth = 1.0f;
    
}

- (void)categoryChosen:(WMCategory *)category {
    self.currentCategory = category;
    BOOL nodeTypeStillValid = NO;
    NodeType* fallBackNodeType = nil;
    for (NodeType *nt in self.currentCategory.nodeType) {
        if (!fallBackNodeType) {
            fallBackNodeType = nt;
        }
        if ([nt isEqual:self.currentNodeType]) {
            nodeTypeStillValid = YES;
        }
    }
    if (!nodeTypeStillValid) {
        self.currentNodeType = fallBackNodeType;
        
    }
    
    DKLog(K_VERBOSE_EDIT_POI, @"NODE TYPE = %@", self.currentNodeType);
}

- (void)nodeTypeChosen:(NodeType*)nodeType {
    self.currentNodeType= nodeType;
    
    DKLog(K_VERBOSE_EDIT_POI, @"NODE TYPE = %@", self.currentNodeType);
    
    [self.setNodeTypeButton setTitle:self.currentNodeType.localized_name forState:UIControlStateNormal];
}

- (void)markerSet:(CLLocationCoordinate2D)coord {
    hasCoordinate = YES;
    self.currentCoordinate = coord;
    [self.setMarkerButton setTitle:[NSString stringWithFormat:@"(%0.5f, %0.5f)", coord.latitude, coord.longitude] forState:UIControlStateNormal];
}

- (IBAction)toiletStateButtonPressed:(id)sender {
	[self buttonPressed];

	WMEditPOIStateViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMEditPOIStateViewController"];
	vc.hideSaveButton = YES;
	vc.title = NSLocalizedString(@"EditPOIStateHeadline", nil);
	vc.navigationBarTitle = vc.title;
	vc.delegate = self;
	vc.node = self.node;
	vc.useCase = WMEditPOIStateUseCasePOICreation;
	vc.statusType = WMPOIStateTypeToilet;
	[self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)setNodeType:(id)sender {
    [self buttonPressed];
    
    WMEditPOITypeViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMEditPOITypeViewController"];
    vc.title =  NSLocalizedString(@"NavBarTitleSetNodeType", nil);
    vc.navigationBarTitle = vc.title;
    vc.delegate = self;
    vc.nodeArray = [self.currentCategory sortedNodeTypes];
    vc.currentNodeType = self.currentNodeType;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)setCategory:(id)sender {
    [self buttonPressed];
    
    WMEditPOICategoryViewController* categoryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WMEditPOICategoryViewController"];
    categoryViewController.title = NSLocalizedString(@"EditPOIViewCategoryLabel", @"");
    categoryViewController.navigationBarTitle = categoryViewController.title;
    categoryViewController.delegate = self;
    categoryViewController.categoryArray = self.dataManager.categories;
    categoryViewController.currentCategory = self.currentCategory;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}

- (void) buttonPressed {
    [self.nameTextField resignFirstResponder];
    [self.infoTextView resignFirstResponder];
    [self.streetTextField resignFirstResponder];
    [self.housenumberTextField resignFirstResponder];
    [self.postcodeTextField resignFirstResponder];
    [self.cityTextField resignFirstResponder];
    [self.websiteTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    
}

- (void) pushToSetMarkerView {
    [self.nameTextField resignFirstResponder];
    [self.infoTextView resignFirstResponder];
    [self.streetTextField resignFirstResponder];
    [self.housenumberTextField resignFirstResponder];
    [self.postcodeTextField resignFirstResponder];
    [self.cityTextField resignFirstResponder];
    [self.websiteTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    
    WMEditPOIPositionViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMEditPOIPositionViewController"];
    vc.node = self.node;
    vc.delegate = self;
    vc.currentCoordinate = self.currentCoordinate;
    vc.initialCoordinate = self.initialCoordinate;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)saveCurrentEntriesToCurrentNode {
    
    self.node.name = self.nameTextField.text;
    self.node.node_type = self.currentNodeType;
    self.node.wheelchair = self.currentWheelchairState;
	self.node.wheelchair_toilet = self.currentToiletState;
    self.node.wheelchair_description = self.infoTextView.text;
    self.node.street = self.streetTextField.text;
    self.node.housenumber = self.housenumberTextField.text;
    self.node.postcode = self.postcodeTextField.text;
    self.node.city = self.cityTextField.text;
    self.node.website = self.websiteTextField.text;
    self.node.phone = self.phoneTextField.text;
    if (hasCoordinate == YES) {
        self.node.lat = [NSNumber numberWithDouble:self.currentCoordinate.latitude];
        self.node.lon = [NSNumber numberWithDouble:self.currentCoordinate.longitude];
    }
}

- (void) saveEditedData {
    
    DKLog(K_VERBOSE_EDIT_POI, @"Node: %@ %@", self.node.lat, self.node.lon);
    
    [self saveCurrentEntriesToCurrentNode];
    
    if (!self.editView && (self.node.name == nil || self.node.name.length < 1)) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"NodeNoNameSet", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (self.currentCategory == nil) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"NodeNoCategorySet", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
        return;
    }

	if (!self.node.lat || !self.node.lon) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"PleaseSetMarker", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
		[alert show];
		return;
	}

    [self.dataManager updateNode:self.node];
    
    progressWheel.hidden = NO;
    [progressWheel startAnimating];
}

- (void) dataManager:(WMDataManager *)dataManager didUpdateNode:(Node *)node {
    progressWheel.hidden = YES;
    [progressWheel stopAnimating];

    if (UIDevice.currentDevice.isIPad == YES) {
        [self dismissViewControllerAnimated:YES];
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"SaveSucess", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    
    [alert show];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)dataManager:(WMDataManager *)dataManager updateNode:(Node *)node failedWithError:(NSError *)error {
    progressWheel.hidden = YES;
    [progressWheel stopAnimating];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SaveNodeFailed", nil) message:error.wheelmapErrorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    
    [alert show];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.streetTextField) {
        [self.housenumberTextField becomeFirstResponder];
    } else if (textField == self.housenumberTextField) {
        [self.postcodeTextField becomeFirstResponder];
        
    } else if (textField == self.postcodeTextField) {
        [self.cityTextField becomeFirstResponder];
    }
    
    [self saveCurrentEntriesToCurrentNode];
    
    return YES;
}


- (BOOL)textViewShouldReturn:(UITextView *)textView{
    
    [textView resignFirstResponder];
    [self saveCurrentEntriesToCurrentNode];
    return YES;
}

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)aRange replacementText:(NSString *)aText {
    
    NSString* newText = [self.infoTextView.text stringByReplacingCharactersInRange:aRange withString:aText];
    
    if (aTextView == self.infoTextView) {

		self.infoInputViewHeightConstraint.constant = self.infoTextView.contentSize.height + (2 * self.infoTextViewTopConstraint.constant);

		[UIView animateWithDuration:K_ANIMATION_DURATION_SHORT animations:^{
			[self.view layoutIfNeeded];
		}];

		self.infoPlaceholderTextView.hidden = (newText.length > 0);
    }
    
    if([aText isEqualToString:@"\n"]) {
        [aTextView resignFirstResponder];
        return NO;
    }
    
    if([newText length] > 255) {
        return NO; // can't enter more text
    } else {
        return YES;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    if (UIDevice.currentDevice.isIPad == NO) {
		[self keyboardDidMove:notification];
    }

	self.keyboardIsShown = NO;

    [self saveCurrentEntriesToCurrentNode];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if (UIDevice.currentDevice.isIPad == NO) {
        
        if (self.keyboardIsShown) {
            return;
        }

		[self keyboardDidMove:notification];
    }
    
    self.keyboardIsShown = YES;
}

- (void)keyboardDidMove:(NSNotification *)notification {
	// Adjust the keyboard bottom spacing to match the keyboard position
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	[UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
	[UIView setAnimationBeginsFromCurrentState:YES];

	BOOL isOpening = ([notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y > [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y);

	UIEdgeInsets contentInset = self.scrollView.contentInset;
	contentInset.bottom = (isOpening ? [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height : 0);
	self.scrollView.contentInset = contentInset;
	self.scrollView.scrollIndicatorInsets = contentInset;
	[self.scrollView layoutIfNeeded];

	[UIView commitAnimations];
}

#pragma mark - WMEditPOIStateDelegate

- (void)didSelectStatus:(NSString*)state forStatusType:(WMPOIStateType)statusType {
	if (statusType == WMPOIStateTypeWheelchair) {
		self.currentWheelchairState = state;
		self.wheelchairStateButtonView.statusString = state;
	} else if (statusType == WMPOIStateTypeToilet) {
		self.currentToiletState = state;
		self.toiletStateButtonView.statusString = state;
	}
}

#pragma mark - WMPOIStateButtonViewDelegate

- (void)didPressedEditStateButton:(NSString *)state forStateType:(WMPOIStateType)stateType {
	[self buttonPressed];

	WMEditPOIStateViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WMEditPOIStateViewController"];
	vc.hideSaveButton = YES;
	vc.title = NSLocalizedString(@"EditPOIStateHeadline", nil);
	vc.navigationBarTitle = vc.title;
	vc.delegate = self;
	vc.node = self.node;
	vc.useCase = WMEditPOIStateUseCasePOICreation;
	if (stateType == WMPOIStateTypeWheelchair) {
		vc.statusType = WMPOIStateTypeWheelchair;
		[vc setCurrentState:self.currentWheelchairState];
	} else if (stateType == WMPOIStateTypeToilet) {
		vc.statusType = WMPOIStateTypeToilet;
		[vc setCurrentState:self.currentToiletState];
	}
	[self.navigationController pushViewController:vc animated:YES];
}

@end