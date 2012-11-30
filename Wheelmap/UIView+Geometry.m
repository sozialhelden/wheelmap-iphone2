//
//  UIView+Geometry.m
//  Wheelmap
//
//  Created by npng on 11/28/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "UIView+Geometry.h"

@implementation UIView (Geometry)

-(CGFloat)topRightX
{
    return self.frame.origin.x+self.frame.size.width;
}
-(CGFloat)leftBottomY
{
    return self.frame.origin.y+self.frame.size.height;
}

@end
