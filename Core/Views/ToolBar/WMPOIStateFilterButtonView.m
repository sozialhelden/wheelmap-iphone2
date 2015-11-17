//
//  WMPOIStateFilterButtonView.m
//  Wheelmap
//
//  Created by npng on 11/28/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMPOIStateFilterButtonView.h"

@interface WMPOIStateFilterButtonView ()

@property (weak, nonatomic) IBOutlet UIImageView *			yesDotImageView;
@property (weak, nonatomic) IBOutlet UIImageView *			limitedDotImageView;
@property (weak, nonatomic) IBOutlet UIImageView *			noDotImageView;
@property (weak, nonatomic) IBOutlet UIImageView *			unknownDotImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	dotsContainerViewWidthConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *			iconImageView;

@end

@implementation WMPOIStateFilterButtonView

#pragma mark - Initialization

- (instancetype)initFromNibToView:(UIView *)view {
	self = [NSBundle.mainBundle loadNibNamed:@"WMPOIStateFilterButtonView" owner:self options:nil].firstObject;

	if (self != nil) {
		self.frame = view.bounds;
		[view addSubview:self];
		[self initConstraints];
	}
	return self;
}

- (void)initConstraints {
	[self.superview addConstraint:[NSLayoutConstraint
								   constraintWithItem:self.superview
								   attribute:NSLayoutAttributeTrailingMargin
								   relatedBy:NSLayoutRelationEqual
								   toItem:self
								   attribute:NSLayoutAttributeTrailingMargin
								   multiplier:1.0
								   constant:0.0]];
	[self.superview addConstraint:[NSLayoutConstraint
								   constraintWithItem:self.superview
								   attribute:NSLayoutAttributeLeadingMargin
								   relatedBy:NSLayoutRelationEqual
								   toItem:self
								   attribute:NSLayoutAttributeLeadingMargin
								   multiplier:1.0
								   constant:0.0]];
	[self.superview addConstraint:[NSLayoutConstraint
								   constraintWithItem:self.superview
								   attribute:NSLayoutAttributeTopMargin
								   relatedBy:NSLayoutRelationEqual
								   toItem:self
								   attribute:NSLayoutAttributeTopMargin
								   multiplier:1.0
								   constant:0.0]];
	[self.superview addConstraint:[NSLayoutConstraint
								   constraintWithItem:self.superview
								   attribute:NSLayoutAttributeBottomMargin
								   relatedBy:NSLayoutRelationEqual
								   toItem:self
								   attribute:NSLayoutAttributeBottomMargin
								   multiplier:1.0
								   constant:0.0]];
	[self layoutIfNeeded];
}

#pragma mark - IBActions

- (IBAction)pressedButton:(id)sender {
	if (self.delegate != nil) {
		[self.delegate didPressPOIStateFilterButtonForStateType:self.statusType];
	}
}


#pragma mark - Public Setter

- (void)setStatusType:(WMPOIStateType)statusType {
	_statusType = statusType;

	if (self.statusType == WMPOIStateTypeToilet) {
		self.dotsContainerViewWidthConstraint.constant = self.calculatedFrameWidth;
		self.limitedDotImageView.alpha = 0;
		[self layoutIfNeeded];
		self.iconImageView.image = [UIImage imageNamed:@"ToolbarToiletStateIcon"];
	} else {
		self.iconImageView.image = [UIImage imageNamed:@"ToolbarWheelchairStateIcon"];
	}
}

- (void)setSelectedGreenDot:(BOOL)selectedGreenDot {
	_selectedGreenDot = selectedGreenDot;
    if (!self.selectedGreenDot) {
        [self deselectDot:self.yesDotImageView];
    } else {
        [self selectDot:self.yesDotImageView];
    }
}

- (void)setSelectedYellowDot:(BOOL)selectedYellowDot {
    _selectedYellowDot = selectedYellowDot;
    if (!self.selectedYellowDot) {
        [self deselectDot:self.limitedDotImageView];
    } else {
        [self selectDot:self.limitedDotImageView];
        
    }
}

- (void)setSelectedRedDot:(BOOL)selectedRedDot {
	_selectedRedDot = selectedRedDot;
    if (!_selectedRedDot) {
        [self deselectDot:self.noDotImageView];
    } else {
        [self selectDot:self.noDotImageView];
    }
}

- (void)setSelectedNoneDot:(BOOL)selectedNoneDot {
    _selectedNoneDot = selectedNoneDot;
    if (!_selectedNoneDot) {
        [self deselectDot:self.unknownDotImageView];
    } else {
        [self selectDot:self.unknownDotImageView];
    }
}

#pragma mark - Helper

- (CGFloat)calculatedFrameWidth {
	CGFloat width;
	if (self.statusType == WMPOIStateTypeWheelchair) {
		// As we have 4 icons for the wheelchair state, use a 4 times width as view width
		width = (4 * K_POI_STATE_FILTER_BUTTON_DOTS_WIDTH) +  (3 * K_POI_STATE_FILTER_BUTTON_DOTS_X_OFFSET);
	} else {
		// As we have 3 icons for the wheelchair state, use a 3 times width as view width
		width = (3 * K_POI_STATE_FILTER_BUTTON_DOTS_WIDTH) + (2 * K_POI_STATE_FILTER_BUTTON_DOTS_X_OFFSET);
	}
	return width;
}

- (void)deselectDot:(UIImageView*)dot {
    // deselection effect here
    dot.hidden = YES;
}

- (void)selectDot:(UIImageView*)dot {
    // selection effect here
    dot.hidden = NO;
}

@end
