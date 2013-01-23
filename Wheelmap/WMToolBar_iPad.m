//
//  WMToolBar_iPad.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMToolBar_iPad.h"
#import "WMDataManager.h"

@implementation WMToolBar_iPad {
    
    WMDataManager *dataManager;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        dataManager = [[WMDataManager alloc] init];
        
        // adjust iphone superclasses properties to ipad
        [self.toggleButton removeFromSuperview];
        [searchButton removeFromSuperview];
        
        self.wheelChairStatusFilterButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        categoryFilterButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        currentLocationButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

        categoryFilterButton.frame = CGRectMake(categoryFilterButton.frame.origin.x - 15.0f, categoryFilterButton.frame.origin.y, categoryFilterButton.frame.size.width, categoryFilterButton.frame.size.height);
        self.wheelChairStatusFilterButton.frame = CGRectMake(categoryFilterButton.frame.origin.x - self.wheelChairStatusFilterButton.frame.size.width - 5.0f, self.wheelChairStatusFilterButton.frame.origin.y, self.wheelChairStatusFilterButton.frame.size.width, self.wheelChairStatusFilterButton.frame.size.height);
        
        currentLocationButton.frame = CGRectMake(self.wheelChairStatusFilterButton.frame.origin.x - currentLocationButton.frame.size.width - 5.0f , currentLocationButton.frame.origin.y, currentLocationButton.frame.size.width, currentLocationButton.frame.size.height);
        
        infoButton = [WMButton buttonWithType:UIButtonTypeCustom];
        infoButton.frame = CGRectMake(2, 3, 58, 58);
        [infoButton setBackgroundImage:[UIImage imageNamed:@"toolbar_button.png"] forState:UIControlStateNormal];
        [infoButton setImage:[UIImage imageNamed:@"ipad_buttons_credits.png"] forState:UIControlStateNormal];
        [infoButton addTarget:self action:@selector(pressedInfoButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:infoButton];
        
        self.loginButton = [WMButton buttonWithType:UIButtonTypeCustom];
        self.loginButton.frame = CGRectMake(infoButton.frame.origin.x + infoButton.frame.size.width + 5.0f, 3, 58, 58);
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"toolbar_button.png"] forState:UIControlStateNormal];
        [self.loginButton setImage:[UIImage imageNamed:@"ipad_buttons_login.png"] forState:UIControlStateNormal];
        [self.loginButton addTarget:self action:@selector(pressedLoginButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.loginButton];
        
        helpButton = [WMButton buttonWithType:UIButtonTypeCustom];
        helpButton.frame = CGRectMake(320.0f - 58.0f, 3, 58, 58);
        [helpButton setBackgroundImage:[UIImage imageNamed:@"toolbar_button.png"] forState:UIControlStateNormal];
        [helpButton setImage:[UIImage imageNamed:@"ipad_buttons_mithelfen.png"] forState:UIControlStateNormal];
        [helpButton addTarget:self action:@selector(pressedHelpButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:helpButton];
    }
    
    return self;
}

- (void)pressedInfoButton:(id)sender {
    
}

- (void)pressedLoginButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(pressedLoginButton:)]) {
        [self.delegate pressedLoginButton:self];
    }
}

- (void)pressedHelpButton:(id)sender {
    
}

@end
