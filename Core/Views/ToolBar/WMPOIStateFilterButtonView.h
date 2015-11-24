//
//  WMPOIStateFilterButtonView.h
//  Wheelmap
//
//  Created by npng on 11/28/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

@interface WMPOIStateFilterButtonView : WMButton

@property (nonatomic) id<WMPOIStateFilterButtonViewDelegate>	delegate;

@property (nonatomic) WMPOIStateType							statusType;

@property (nonatomic) BOOL										selectedGreenDot;
@property (nonatomic) BOOL										selectedYellowDot;
@property (nonatomic) BOOL										selectedRedDot;
@property (nonatomic) BOOL										selectedNoneDot;

#pragma mark - Initialization

- (instancetype)initFromNibToView:(UIView *)view;

@end
