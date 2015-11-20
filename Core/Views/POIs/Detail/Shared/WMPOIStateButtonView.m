//
//  WMPOIStateButtonView.m
//  Wheelmap
//
//  Created by Hans Seiffert on 03.11.15.
//
//

#import "WMPOIStateButtonView.h"

@implementation WMPOIStateButtonView

#pragma mark - Initialization

- (instancetype)init {
	self = [super init];

	if (self != nil) {
		[self initDefaultValues];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [NSBundle.mainBundle loadNibNamed:@"WMPOIStateButtonView" owner:self options:nil].firstObject;

	if (self != nil) {
		self.translatesAutoresizingMaskIntoConstraints = YES;
		self.frame = frame;
		[self initDefaultValues];
	}
	return self;
}

- (instancetype)initFromNibToView:(UIView *)view {
	self = [NSBundle.mainBundle loadNibNamed:@"WMPOIStateButtonView" owner:self options:nil].firstObject;

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
	self.statusString = K_STATE_YES;
}

#pragma mark - Public Setter

- (void)setStatusString:(NSString *)statusString {
	_statusString = statusString;

	[self updateViewContent];
}
- (void)setStatusType:(WMPOIStateType)statusType {
	_statusType = statusType;

	[self updateViewContent];
}

#pragma mark - IBOutlet actions

- (IBAction)buttonPressed:(id)sender {
	if (self.showStateDelegate != nil) {
		[self.showStateDelegate didPressedEditStateButton:self.statusString forStateType:self.statusType];
	}
}

#pragma mark - Helper

- (void)updateViewContent {
	UIImage *backgroundImage = [self imageForStatus:self.statusString];
	if (self.button.isRightToLeftDirection == YES) {
		backgroundImage = backgroundImage.rightToLeftMirrowedImage;
	}
	[self.button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
	self.titleLabel.text = [self titleForStatus:self.statusString];
}

#pragma mark - Content helper

- (UIImage *)imageForStatus:(NSString *)statusString {
	if ([statusString isEqualToString:K_STATE_LIMITED]) {
		return [UIImage imageNamed:@"details_btn-status-limited"];
	} else if ([statusString isEqualToString:K_STATE_NO]) {
		return [UIImage imageNamed:@"details_btn-status-no.png"];
	} else if ([statusString isEqualToString:K_STATE_YES]) {
		return [UIImage imageNamed:@"details_btn-status-yes.png"];
	} else {
		return [UIImage imageNamed:@"details_btn-status-unknown.png"];
	}
}

- (NSString *)titleForStatus:(NSString *)statusString {
	if (self.statusType == WMPOIStateTypeWheelchair) {
		if ([statusString isEqualToString:K_STATE_LIMITED]) {
			return L(@"WheelchairAccessLimited");
		} else if ([statusString isEqualToString:K_STATE_NO]) {
			return L(@"WheelchairAccessNo");
		} else if ([statusString isEqualToString:K_STATE_YES]) {
			return L(@"WheelchairAccessYes");
		} else {
			return L(@"WheelchairAccessUnkown");
		}
	} else if (self.statusType == WMPOIStateTypeToilet) {
		if ([statusString isEqualToString:K_STATE_NO]) {
			return L(@"ToiletAccessNo");
		} else if ([statusString isEqualToString:K_STATE_YES]) {
			return L(@"ToiletAccessYes");
		} else {
			return L(@"ToiletAccessUnknown");
		}
	}
	return nil;
}

@end
