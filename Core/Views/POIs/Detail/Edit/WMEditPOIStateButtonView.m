//
//  WMEditPOIStateButtonView.m
//  Wheelmap
//
//  Created by SMF on 02.11.15.
//  Copyright © 2015 Sozialhelden e.V. All rights reserved.
//

#import "WMEditPOIStateButtonView.h"

@interface WMEditPOIStateButtonView ()

@property (weak, nonatomic) IBOutlet UIImageView *						checkmarkImageView;

@property (weak, nonatomic) IBOutlet WMLabel *							descriptionLabel;

@property (nonatomic) BOOL												selected;

@end

@implementation WMEditPOIStateButtonView

#pragma mark - Initialization

- (instancetype)initFromNibToView:(UIView *)view {
	self = [NSBundle.mainBundle loadNibNamed:@"WMEditPOIStateButtonView" owner:self options:nil].firstObject;

	if (self != nil) {
		self.frame = view.bounds;
		[view addSubview:self];
		[self initDefaultValues];
		[self initConstraints];
	}
	return self;
}

- (void)initDefaultValues {
	[super initDefaultValues];
	self.statusString = K_STATE_YES;
}

#pragma mark - Public Setter

- (void)setSelected:(BOOL)selected {
	_selected = selected;

	[self updateViewContent];
}

#pragma mark - IBOutlet actions

- (IBAction)buttonPressed:(id)sender {
	if (self.editStateDelegate != nil) {
		[self.editStateDelegate didSelectStatus:self.statusString];
	}
}

#pragma mark - Helper

- (void)updateViewContent {
	[super updateViewContent];
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
