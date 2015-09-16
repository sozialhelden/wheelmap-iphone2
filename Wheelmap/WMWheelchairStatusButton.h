//
//  WMWheelchairStatusButton.h
//  Wheelmap
//
//  Created by npng on 11/28/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMButton.h"

@interface WMWheelchairStatusButton : WMButton
{
    UIImageView* dotGreen;
    UIImageView* dotYellow;
    UIImageView* dotRed;
    UIImageView* dotNone;
}

@property (nonatomic) BOOL selectedGreenDot;
@property (nonatomic) BOOL selectedYellowDot;
@property (nonatomic) BOOL selectedRedDot;
@property (nonatomic) BOOL selectedNoneDot;

@end
