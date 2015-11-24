//
//  UINavigationBar+CustomSize.m
//  Wheelmap
//
//  Created by npng on 12/1/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "UINavigationBar+CustomSize.h"

@implementation UINavigationBar (CustomSize)
-(CGSize)sizeThatFits:(CGSize)size
{
    CGSize result = [super sizeThatFits:size];
    result.height = K_NAVIGATION_BAR_HEIGHT;
    return result;
}
@end
