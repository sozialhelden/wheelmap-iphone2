//
//  WMPOIStateFilterButton.h
//  Wheelmap
//
//  Created by npng on 11/28/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

@interface WMPOIStateFilterButton : WMButton {
    UIImageView* dotGreen;
    UIImageView* dotYellow;
    UIImageView* dotRed;
    UIImageView* dotNone;
}

@property (nonatomic) WMPOIStateType	statusType;

@property (nonatomic) BOOL					selectedGreenDot;
@property (nonatomic) BOOL					selectedYellowDot;
@property (nonatomic) BOOL					selectedRedDot;
@property (nonatomic) BOOL					selectedNoneDot;

@end
