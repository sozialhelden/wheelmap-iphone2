//
//  UIView+RTL.m
//  Wheelmap
//
//  Created by Hans Seiffert on 12/11/15.
//  Copyright (c) 2015 Sozialhelden e.V. All rights reserved.
//

#import "UIView+RTL.h"

@implementation UIView (RTL)

- (BOOL)isRightToLeftDirection {
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
		return ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft);
	} else {
		return UIApplication.sharedApplication.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
	}
}

@end
