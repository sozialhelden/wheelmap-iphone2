//
//  WMPOIStateFilterPopoverView.h
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMPOIStateFilterPopoverView : UIView

@property (nonatomic, strong) id<WMPOIStateFilterPopoverViewDelegate>	delegate;

@property (nonatomic) WMPOIStateType								stateType;

#pragma mark - Initialization

- (id)initWithOrigin:(CGPoint)origin;

#pragma mark - Public methods

- (void)refreshPositionWithOrigin:(CGPoint)origin;

- (void)updateFilterButtons;

@end
