//
//  WMCategoryFilterTableViewCell.m
//  Wheelmap
//
//  Created by npng on 11/29/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMCategoryFilterTableViewCell.h"

#define K_CHECKMARK_WIDTH	25.0f

@implementation WMCategoryFilterTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		if (self.isRightToLeftDirection == YES) {
			// As Marquee label doesn't support right to left automatically on prior iOS9 devices, we have to do it on our own.
			self.titleLabel.textAlignment = NSTextAlignmentRight;
			self.checked = YES;
		}
    }
    return self;
}

- (void)setChecked:(BOOL)checked {
	_checked = checked;

	if (self.checked == YES) {
		self.checkmarkWidthConstraint.constant = K_CHECKMARK_WIDTH;
	} else {
		self.checkmarkWidthConstraint.constant = 0;
	}
	[self.checkmarkImageView layoutIfNeeded];
}

#pragma mark - Set Title

- (void)setTitle:(NSString *)title {
	_title = title;
    self.titleLabel.text = title;
}

@end
