//
//  UIToolbar+CustomSize.m
//  Wheelmap
//
//  Created by npng on 12/1/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "UIToolbar+CustomSize.h"

@implementation UIToolbar (CustomSize)

-(CGSize)sizeThatFits:(CGSize)size
{
    CGSize result = [super sizeThatFits:size];
    result.height = K_TOOLBAR_BAR_HEIGHT;
    return result;
}
@end
