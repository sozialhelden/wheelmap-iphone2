//
//  WMPOIStateFilterPopoverView.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMPOIStateFilterPopoverView.h"
#import "WMDataManager.h"

@interface WMPOIStateFilterPopoverView ()

@property (weak, nonatomic) IBOutlet WMButton *				yesButton;
@property (weak, nonatomic) IBOutlet WMButton *				limitedButton;
@property (weak, nonatomic) IBOutlet WMButton *				noButton;
@property (weak, nonatomic) IBOutlet WMButton *				unknownButton;

@end

@implementation WMPOIStateFilterPopoverView {
    
    WMDataManager *dataManager;
}

#pragma mark - Initialization

- (id)initWithOrigin:(CGPoint)origin {
	self = (WMPOIStateFilterPopoverView *) [WMPOIStateFilterPopoverView loadFromNib:@"WMPOIStateFilterPopoverView"];
    if (self) {
		self.frame = CGRectMake(origin.x, origin.y, self.calculatedFrameWidth, K_POI_STATUS_FILTER_POPOVER_VIEW_HEIGHT);
		dataManager = [[WMDataManager alloc] init];

		if (self.isRightToLeftDirection == YES) {
			// We have to adjust the following button images to support the right to left UI.
			[self.yesButton setImage:[UIImage imageNamed:@"toolbar_statusfilter-yes-rtl.png"] forState:UIControlStateNormal];
			[self.yesButton setImage:[UIImage imageNamed:@"toolbar_statusfilter-yes-active-rtl.png"] forState:UIControlStateSelected];
			[self.yesButton setImage:[UIImage imageNamed:@"toolbar_statusfilter-yes-active-rtl.png"] forState:UIControlStateHighlighted];
			[self.unknownButton setImage:[UIImage imageNamed:@"toolbar_statusfilter-unknown.png"].rightToLeftMirrowedImage forState:UIControlStateNormal];
			[self.unknownButton setImage:[UIImage imageNamed:@"toolbar_statusfilter-unknown-active.png"].rightToLeftMirrowedImage forState:UIControlStateSelected];
			[self.unknownButton setImage:[UIImage imageNamed:@"toolbar_statusfilter-unknown-active.png"].rightToLeftMirrowedImage forState:UIControlStateHighlighted];
		}
    }
    return self;
}

#pragma mark - Public methods

- (void)refreshPositionWithOrigin:(CGPoint)origin {
	[self setFrameOrigin:origin];
}

- (void)setStateType:(WMPOIStateType)stateType {
	_stateType = stateType;
	[self setFrameWidth:self.calculatedFrameWidth];
}

- (void)updateFilterButtons {
	self.yesButton.selected = [dataManager getPOIStateYesFilterStatus:self.stateType];
	self.limitedButton.selected = [dataManager getPOIStateLimitedFilterStatus:self.stateType];
	self.noButton.selected = [dataManager getPOIStateNoFilterStatus:self.stateType];
	self.unknownButton.selected = [dataManager getPOIStateUnkownFilterStatus:self.stateType];

	if (self.delegate != nil) {
		[self.delegate didSelect:self.yesButton.selected dot:kDotTypeYes forStateType:self.stateType];
		[self.delegate didSelect:self.limitedButton.selected dot:kDotTypeLimited forStateType:self.stateType];
		[self.delegate didSelect:self.noButton.selected dot:kDotTypeNo forStateType:self.stateType];
		[self.delegate didSelect:self.unknownButton.selected dot:kDotTypeUnknown forStateType:self.stateType];
	}
}

#pragma mark - Button Handlers

- (IBAction)didPressStateButton:(WMButton*)pressedButton {
    pressedButton.selected = !pressedButton.selected;

	DotType dotType = kDotTypeUnknown;
	if (pressedButton == self.yesButton) {
		dotType = kDotTypeYes;
	} else if (pressedButton == self.limitedButton) {
		dotType = kDotTypeLimited;
	} else if (pressedButton == self.noButton) {
		dotType = kDotTypeNo;
	}

	[self didSelect:pressedButton.selected dotType:dotType];
}

#pragma mark - Helper

- (CGFloat)calculatedFrameWidth {
	CGFloat width;
	if (self.stateType == WMPOIStateTypeWheelchair) {
		// As we have 4 icons for the wheelchair state, use a 4 times width as view width
		width = 4 * K_POI_STATUS_FILTER_POPOVER_BUTTON_WIDTH;
	} else {
		// As we have 3 icons for the wheelchair state, use a 3 times width as view width. The contraints of the buttons are: fixed width for the three buttons which are always visible, the fourth one has no width constraint. That's it's width will be 0 if we decrease the superview width.
		width = 3 * K_POI_STATUS_FILTER_POPOVER_BUTTON_WIDTH;
	}
	return width;
}

- (void)didSelect:(BOOL)selected dotType:(DotType)dotType {
	if (self.delegate != nil) {
		[self.delegate didSelect:selected dot:dotType forStateType:self.stateType];
	}

	if (self.stateType == WMPOIStateTypeWheelchair) {
		[dataManager savePOIWheelchairStateFilterSettingsWithYes:self.yesButton.selected limited:self.limitedButton.selected no:self.noButton.selected unknown:self.unknownButton.selected];
	} else if (self.stateType == WMPOIStateTypeToilet) {
		[dataManager savePOIToiletStateFilterSettingsWithYes:self.yesButton.selected no:self.noButton.selected unknown:self.unknownButton.selected];
	}
}

@end

