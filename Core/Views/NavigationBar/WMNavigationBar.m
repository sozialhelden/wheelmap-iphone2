//
//  WMNavigationBar.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMNavigationBar.h"
#import "WMWheelmapAPI.h"

@implementation WMNavigationBar

#pragma mark - Initialization

- (instancetype)initFromNibWithFrame:(CGRect)frame {
	self = (WMNavigationBar *) [WMNavigationBar loadFromNib:@"WMNavigationBar"];
	if (self != nil) {
		self.frame = frame;
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self initViews];
}

- (void)initViews {
	[self.cancelButtonLeft setTitle:L(@"Cancel") forState:UIControlStateNormal];
	[self.cancelButtonRight setTitle:L(@"Cancel") forState:UIControlStateNormal];
	[self.editButton setTitle:L(@"NavBarEditButton") forState:UIControlStateNormal];
	[self.saveButton setTitle:L(@"NavBarSaveButton") forState:UIControlStateNormal];
	[self.cancelSearchButton setTitle:L(@"Cancel") forState:UIControlStateNormal];

	if (self.backButton.isRightToLeftDirection == YES) {
		[self.backButton setImage:[UIImage imageNamed:@"buttons_back-btn.png"].rightToLeftMirrowedImage forState:UIControlStateNormal];
	}

	// We have to set the button types to -1 first to make shure that the following button types are diferent to the formers ones. Otherwise the show/hide logic isn't executed.
	self.leftButtonStyle = -1;
	self.rightButtonStyle = -1;
	self.leftButtonStyle = kWMNavigationBarLeftButtonStyleDashboardButton;
	self.rightButtonStyle = kWMNavigationBarRightButtonStyleCreatePOIButton;

	self.searchTextField.delegate = self;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateButtonsForNetworkStatus:) name:kReachabilityChangedNotification object:nil];
}

#pragma mark - View lifecycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBActions

- (IBAction)pressedBackButton:(WMButton*)sender {
    if ([self.delegate respondsToSelector:@selector(pressedBackButton:)]) {
        [self.delegate pressedBackButton:self];
    }
}

- (IBAction)pressedDashboardButton:(WMButton*)sender {
    if ([self.delegate respondsToSelector:@selector(pressedDashboardButton:)]) {
        [self.delegate pressedDashboardButton:self];
    }
}

- (IBAction)pressedEditButton:(WMButton*)sender {
    if ([self.delegate respondsToSelector:@selector(pressedEditButton:)]) {
        [self.delegate pressedEditButton:self];
    }
}

- (IBAction)pressedCancelButton:(WMButton*)sender {
    if ([self.delegate respondsToSelector:@selector(pressedCancelButton:)]) {
        [self.delegate pressedCancelButton:self];
    }
}

- (IBAction)pressedSaveButton:(WMButton*)sender {
    if ([self.delegate respondsToSelector:@selector(pressedSaveButton:)]) {
        [self.delegate pressedSaveButton:self];
    }
}

- (IBAction)pressedAddButton:(WMButton*)sender {
    if ([self.delegate respondsToSelector:@selector(pressedCreatePOIButton:)]) {
        [self.delegate pressedCreatePOIButton:self];
    }
}

- (IBAction)pressedSearchCancelButton:(WMButton*)sender {
    [self hideSearchBar];
    if ([self.delegate respondsToSelector:@selector(pressedSearchCancelButton:)]) {
        [self.delegate pressedSearchCancelButton:self];
    }
}

#pragma mark - Bar Style Changes

- (void)setLeftButtonStyle:(WMNavigationBarLeftButtonStyle)leftButtonStyle {
    if (self.leftButtonStyle == leftButtonStyle) {
        return; // same style do not need to update buttons!
    }
    _leftButtonStyle = leftButtonStyle;

    WMButton *previousButton = self.currentLeftButton;
	self.currentLeftButton = [self buttonForNavigationBarLeftType:leftButtonStyle];
	[self replaceButton:previousButton withButton:self.currentLeftButton];
}

- (void)setRightButtonStyle:(WMNavigationBarRightButtonStyle)rightButtonStyle {
    if (self.rightButtonStyle == rightButtonStyle) {
        return;
    }
    _rightButtonStyle = rightButtonStyle;

	WMButton *previousButton = self.currentRightButton;
	self.currentRightButton = [self buttonForNavigationBarRightType:rightButtonStyle];
	[self replaceButton:previousButton withButton:self.currentRightButton];
}

- (void)replaceButton:(WMButton *)previousButton withButton:(WMButton *)newButton {
	newButton.alpha = 0.0;
	newButton.hidden = NO;

	__weak typeof (self) weakSelf = self;
	[UIView animateWithDuration:K_ANIMATION_DURATION_SHORT animations:^(void) {
		previousButton.alpha = 0.0;
		newButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		previousButton.hidden = YES;
		[weakSelf updateButtonsForNetworkStatus:nil];
	}];
}

- (void)setTitle:(NSString *)title {
    if ([_title isEqualToString:title] || title.length == 0) {
        return; // same string. do not need to update title!
    }

    _title = title;

	self.titleLabel.alpha = 0.0;
    self.titleLabel.text = title;
    [UIView animateWithDuration:0.3 animations:^(void) {
         self.titleLabel.alpha = 1.0;
     } completion:nil];
}

#pragma mark - Search (public)

- (NSString *)getSearchString {
    return self.searchTextField.text;
}

- (void)clearSearchText {
    self.searchTextField.text = @"";
}

- (void)showSearchBar {
    if (isSearchBarVisible)
        return;
    
    [self toggleSearchBar];
}

- (void)hideSearchBar {
    if (!isSearchBarVisible)
        return;
    
    [self toggleSearchBar];
}

#pragma mark - Search (private)

- (void)toggleSearchBar {
    if (isSearchBarVisible == YES) {
        [self.searchTextField resignFirstResponder];

		self.searchContainerViewTopConstraint.constant = self.searchContainerView.frameHeight;
		[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void) {
			[self.searchContainerView layoutIfNeeded];
		} completion:^(BOOL finished) {
			isSearchBarVisible = NO;
		}];
    } else {
        [self.searchTextField becomeFirstResponder];

		self.searchContainerViewTopConstraint.constant = 0;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void) {
			[self.searchContainerView layoutIfNeeded];
         } completion:^(BOOL finished) {
             isSearchBarVisible = YES;
		 }];
    }
}

#pragma mark - Buttons (public)

- (void)enableRightButton:(WMNavigationBarRightButtonStyle)type {
	UIView* targetButton = [self buttonForNavigationBarRightType:type];
	targetButton.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.5 animations:^(void) {
         targetButton.alpha = 1.0;
     } completion:nil];
}

- (void)disableRightButton:(WMNavigationBarRightButtonStyle)type {
	UIView* targetButton = [self buttonForNavigationBarRightType:type];
    [UIView animateWithDuration:0.5 animations:^(void) {
         targetButton.alpha = 0.3;
     } completion:^(BOOL finished) {
         targetButton.userInteractionEnabled = NO;
     }];
}

#pragma mark - Buttons (private)

- (WMButton *)buttonForNavigationBarLeftType:(WMNavigationBarLeftButtonStyle)type {
	WMButton *button;
	switch (type) {
		case kWMNavigationBarLeftButtonStyleDashboardButton:
			button = self.dashboardButton;
			break;
		case kWMNavigationBarLeftButtonStyleBackButton:
			button = self.backButton;
			break;
		case kWMNavigationBarLeftButtonStyleCancelButton:
			button = self.cancelButtonLeft;
			break;
		default:
			button = nil;
			break;
	}
	return button;
}

- (WMButton *)buttonForNavigationBarRightType:(WMNavigationBarRightButtonStyle)type {
	WMButton *button;
	switch (type) {
		case kWMNavigationBarRightButtonStyleCreatePOIButton:
			button = self.addButton;
			break;
		case kWMNavigationBarRightButtonStyleEditButton:
			button = self.editButton;
			break;
		case kWMNavigationBarRightButtonStyleSaveButton:
			button = self.saveButton;
			break;
		case kWMNavigationBarRightButtonStyleCancelButton:
			button = self.cancelButtonRight;
			break;
		default:
			button = nil;
			break;
	}
	return button;
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hideSearchBar];
    [self.searchTextField resignFirstResponder];
    
    if (textField.text && textField.text.length > 0) {
        if ([self.delegate respondsToSelector:@selector(searchStringIsGiven:)]) {
            [self.delegate searchStringIsGiven:textField.text];
        }
    }
    return YES;
}

- (void)dismissSearchKeyboard {
    [self.searchTextField resignFirstResponder];
}

#pragma mark - Network Status Changes

- (void)updateButtonsForNetworkStatus:(NSNotification*)notice {
    NetworkStatus networkStatus = [[[WMWheelmapAPI sharedInstance] internetReachable] currentReachabilityStatus];
    
    switch (networkStatus) {
        case NotReachable:
            [self disableRightButton:kWMNavigationBarRightButtonStyleCreatePOIButton];
            [self disableRightButton:kWMNavigationBarRightButtonStyleEditButton];
            [self disableRightButton:kWMNavigationBarRightButtonStyleSaveButton];
            break;
        default:
            [self enableRightButton:kWMNavigationBarRightButtonStyleCreatePOIButton];
            [self enableRightButton:kWMNavigationBarRightButtonStyleEditButton];
            [self enableRightButton:kWMNavigationBarRightButtonStyleSaveButton];
            break;
    }
}

@end
