//
//  WMPOIListCell.m
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMPOIsListTableViewCell.h"

@implementation WMPOIsListTableViewCell

- (void)awakeFromNib {
	[super awakeFromNib];

	if (self.isRightToLeftDirection == YES) {
		// As Marquee label doesn't support right to left automatically on prior iOS9 devices, we have to do it on our own.
		self.titleLabel.textAlignment = NSTextAlignmentRight;
		self.nodeTypeLabel.textAlignment = NSTextAlignmentRight;
	}
}

@end

