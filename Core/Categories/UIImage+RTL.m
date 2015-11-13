//
//  UIImage+RTL.m
//  Wheelmap
//
//  Created by Hans Seiffert on 12/11/15.
//  Copyright (c) 2015 Sozialhelden e.V. All rights reserved.
//

#import "UIImage+RTL.h"

@implementation UIImage (RTL)

- (UIImage *)rightToLeftMirrowedImage {
	return [UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
}

@end
