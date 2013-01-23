//
//  WMToolBar_iPad.h
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMToolBar.h"
#import "WMWheelchairStatusButton.h"

@class WMToolBar_iPad;

@interface WMToolBar_iPad : WMToolBar

@property (nonatomic, strong) WMButton *infoButton;
@property (nonatomic, strong) WMButton *loginButton;
@property (nonatomic, strong) WMButton *helpButton;

@end
