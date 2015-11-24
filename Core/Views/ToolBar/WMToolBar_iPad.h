//
//  WMToolbar_iPad.h
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMToolbar.h"
#import "WMPOIStateFilterButtonView.h"
#import "WMDataManager.h"

@class WMToolbar_iPad;

@interface WMToolbar_iPad : WMToolbar <WMDataManagerDelegate>

@property (weak, nonatomic) IBOutlet WMButton *		creditsButton;
@property (weak, nonatomic) IBOutlet WMButton *		loginButton;

@property (weak, nonatomic) IBOutlet UILabel *		numberOfPlacesLabel;
@property (weak, nonatomic) IBOutlet UILabel *		stagingEnvironmentDebugLabel;

@property (weak, nonatomic) IBOutlet WMButton *		contributeButton;
@property (weak, nonatomic) IBOutlet WMButton *		currentLocationButton;

- (void)updateLoginButton;

@end
