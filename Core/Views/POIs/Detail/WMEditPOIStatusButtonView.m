//
//  WMEditPOIStatusButtonView.m
//  Wheelmap
//
//  Created by SMF on 02.11.15.
//  Copyright © 2015 Sozialhelden e.V. All rights reserved.
//

#import "WMEditPOIStatusButtonView.h"

@interface WMEditPOIStatusButtonView ()

@property (weak, nonatomic) IBOutlet UIButton *							button;
@property (weak, nonatomic) IBOutlet UIImageView *						checkmarkImageView;

@property (weak, nonatomic) IBOutlet WMLabel *							titleLabel;
@property (weak, nonatomic) IBOutlet WMLabel *							descriptionLabel;

@property (nonatomic) BOOL												selected;
@property (strong, nonatomic) NSString *								statusString;

@end

@implementation WMEditPOIStatusButtonView

#pragma mark - Initialization

- (instancetype)init {
	self = [super init];

	if (self != nil) {
		[self initDefaultValues];
	}
	return self;
}

- (instancetype)initFromNibToView:(UIView *)view {
	self = [NSBundle.mainBundle loadNibNamed:@"WMEditPOIStatusButtonView" owner:self options:nil].firstObject;

	if (self != nil) {
		self.frame = view.bounds;
		[view addSubview:self];
		[self initDefaultValues];
		[self initConstraints];
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	[self initDefaultValues];
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

- (void)initDefaultValues {
	self.selected = NO;
	self.statusString = K_STATE_YES;
}

#pragma mark - Public Setter

- (void)setStatusType:(WMEditPOIStatusType)statusType {
	_statusType = statusType;

	[self updateViewContent];
}

- (void)setCurrentStatus:(NSString *)statusString {
	self.statusString = statusString;

	[self updateViewContent];
}

- (void)setSelected:(BOOL)selected {
	_selected = selected;

	[self updateViewContent];
}

#pragma mark - IBOutlet actions

- (IBAction)buttonPressed:(id)sender {
	if (self.delegate != nil) {
		[self.delegate didSelectStatus:self.statusString];
	}
}

#pragma mark - Helper

- (void)updateViewContent {
	[self.button setImage:[self imageForStatus:self.statusString] forState:UIControlStateNormal];
	self.titleLabel.text = [self titleForStatus:self.statusString];
	self.descriptionLabel.text = [self descriptionForStatus:self.statusString];
	self.checkmarkImageView.hidden = !self.selected;
}

#pragma mark - Content helper

- (UIImage *)imageForStatus:(NSString *)statusString {
	if ([statusString isEqualToString:K_STATE_LIMITED]) {
		return [UIImage imageNamed:@"details_label-limited"];
	} else if ([statusString isEqualToString:K_STATE_NO]) {
		return [UIImage imageNamed:@"details_label-no.png"];
	} else if ([statusString isEqualToString:K_STATE_YES]) {
		return [UIImage imageNamed:@"details_label-yes.png"];
	} else {
		return nil;
	}
}

- (NSString *)titleForStatus:(NSString *)statusString {
	if (self.statusType == WMEditPOIStatusTypeWheelchair) {
		if ([statusString isEqualToString:K_STATE_LIMITED]) {
			return L(@"WheelchairAccessLimited");
		} else if ([statusString isEqualToString:K_STATE_NO]) {
			return L(@"WheelchairAccessNo");
		} else if ([statusString isEqualToString:K_STATE_YES]) {
			return L(@"WheelchairAccessYes");
		}
	} else if (self.statusType == WMEditPOIStatusTypeToilet) {
		if ([statusString isEqualToString:K_STATE_NO]) {
			return L(@"ToiletAccessNo");
		} else if ([statusString isEqualToString:K_STATE_YES]) {
			return L(@"ToiletAccessYes");
		}
	}
	return nil;
}

- (NSString *)descriptionForStatus:(NSString *)statusString {
	if (self.statusType == WMEditPOIStatusTypeWheelchair) {
		if ([statusString isEqualToString:K_STATE_LIMITED]) {
			return L(@"WheelchairAccessContentLimited");
		} else if ([statusString isEqualToString:K_STATE_NO]) {
			return L(@"WheelchairAccessContentNo");
		} else if ([statusString isEqualToString:K_STATE_YES]) {
			return L(@"WheelchairAccessContentYes");
		}
	} else if (self.statusType == WMEditPOIStatusTypeToilet) {
		if ([statusString isEqualToString:K_STATE_NO]) {
			return L(@"ToiletAccessContentNo");
		} else if ([statusString isEqualToString:K_STATE_YES]) {
			return L(@"ToiletAccessContentYes");
		}
	}
	return nil;
}

@end
