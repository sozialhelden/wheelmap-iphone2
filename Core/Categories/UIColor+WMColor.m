//
//  WMColor.m
//  Wheelmap
//
//  Created by Stefan Nietert on 10/02/14.
//  Copyright (c) 2014 Sozialhelden e.V. All rights reserved.
//

#import "UIColor+WMColor.h"

@implementation UIColor (WMColor)

+ (UIColor *)wmBlueColor{
    return [UIColor  colorWithRed:39/255.0f green:54/255.0f blue:69/255.0f alpha:1.0f];
}

+ (UIColor *)wmGreyColor{
    return [UIColor colorWithRed:248/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f];
}

+ (UIColor *)wmNavigationBackgroundColor{
    return [UIColor colorWithRed:0.153 green:0.212 blue:0.271 alpha:1];
}

@end