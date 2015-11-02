//
//  WMToolBar_iPad.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMToolBar_iPad.h"
#import "WMWheelmapAPI.h"

@implementation WMToolBar_iPad {
    
    WMDataManager *dataManager;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        dataManager = [[WMDataManager alloc] init];
        dataManager.delegate = self;

        // adjust iphone superclasses properties to ipad
        [self.toggleButton removeFromSuperview];
        [searchButton removeFromSuperview];
        
        self.wheelChairStatusFilterButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        categoryFilterButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        currentLocationButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

        categoryFilterButton.frame = CGRectMake(categoryFilterButton.frame.origin.x - 15.0f, categoryFilterButton.frame.origin.y, categoryFilterButton.frame.size.width, categoryFilterButton.frame.size.height);
        self.wheelChairStatusFilterButton.frame = CGRectMake(categoryFilterButton.frame.origin.x - self.wheelChairStatusFilterButton.frame.size.width - 5.0f, self.wheelChairStatusFilterButton.frame.origin.y, self.wheelChairStatusFilterButton.frame.size.width, self.wheelChairStatusFilterButton.frame.size.height);
        
        currentLocationButton.frame = CGRectMake(self.wheelChairStatusFilterButton.frame.origin.x - currentLocationButton.frame.size.width - 5.0f , currentLocationButton.frame.origin.y, currentLocationButton.frame.size.width, currentLocationButton.frame.size.height);
        
        self.infoButton = [WMButton buttonWithType:UIButtonTypeCustom];
        self.infoButton.frame = CGRectMake(2, 0, K_TOOLBAR_BUTTONS_WITH, K_TOOLBAR_BAR_HEIGHT);
        [self.infoButton setImage:[UIImage imageNamed:@"ipad_buttons_credits.png"] forState:UIControlStateNormal];
        [self.infoButton addTarget:self action:@selector(pressedInfoButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.infoButton];
        
        self.loginButton = [WMButton buttonWithType:UIButtonTypeCustom];
        self.loginButton.frame = CGRectMake(self.infoButton.frame.origin.x + self.infoButton.frame.size.width + 5.0f, 0, K_TOOLBAR_BUTTONS_WITH, K_TOOLBAR_BAR_HEIGHT);
        [self.loginButton setImage:[UIImage imageNamed:@"ipad_buttons_login.png"] forState:UIControlStateNormal];
        [self.loginButton setImage:[UIImage imageNamed:@"ipad_buttons_loggedin.png"] forState:UIControlStateSelected];
        [self.loginButton addTarget:self action:@selector(pressedLoginButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.loginButton];
        
        self.helpButton = [WMButton buttonWithType:UIButtonTypeCustom];
        self.helpButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.helpButton.frame = CGRectMake(currentLocationButton.frame.origin.x - K_TOOLBAR_BUTTONS_WITH - 5.0f, 0, K_TOOLBAR_BUTTONS_WITH, K_TOOLBAR_BAR_HEIGHT);
        [self.helpButton setBackgroundImage:[UIImage imageNamed:@"toolbar_button-search-active.png"] forState:UIControlStateSelected];
        [self.helpButton setImage:[UIImage imageNamed:@"ipad_buttons_mithelfen.png"] forState:UIControlStateNormal];
        [self.helpButton addTarget:self action:@selector(pressedHelpButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.helpButton];
        
        self.numberOfPlacesLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.loginButton.frame.origin.x + self.loginButton.frame.size.width + 5.0f, 0, 320.0f - (self.loginButton.frame.origin.x + self.loginButton.frame.size.width + 5.0f), 54.0f)];
        self.numberOfPlacesLabel.text = @"";
        self.numberOfPlacesLabel.alpha = 0.0;
        self.numberOfPlacesLabel.textColor = [UIColor colorWithRed:106.0f/255.0f green:120.0f/255.0f blue:134.0f/255.0f alpha:1.0f];
        self.numberOfPlacesLabel.adjustsFontSizeToFitWidth = YES;
        self.numberOfPlacesLabel.font = [UIFont systemFontOfSize:22.0f];
        self.numberOfPlacesLabel.textAlignment = NSTextAlignmentCenter;
        self.numberOfPlacesLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:self.numberOfPlacesLabel];

		if (WMWheelmapAPI.isStagingBackend == YES) {
			UILabel *stagingDebugLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.numberOfPlacesLabel.frame.size.height)];
			stagingDebugLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			stagingDebugLabel.text = @"(Staging)";
			stagingDebugLabel.textAlignment = NSTextAlignmentCenter;
			stagingDebugLabel.textColor = [UIColor redColor];
			[self addSubview:stagingDebugLabel];
		}

        [dataManager fetchTotalNodeCount];
    }
    
    return self;
}

- (void)pressedInfoButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(pressedInfoButton:)]) {
        [self.delegate pressedInfoButton:self];
    }
}

- (void)pressedLoginButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(pressedLoginButton:)]) {
        [self.delegate pressedLoginButton:self];
    }
}

- (void)pressedHelpButton:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if ([self.delegate respondsToSelector:@selector(pressedHelpButton:)]) {
        [self.delegate pressedHelpButton:self];
    }
}

- (void)updateLoginButton {
    if ([dataManager userIsAuthenticated]) {
        self.loginButton.selected = YES;
    } else {
        self.loginButton.selected = NO;
    }
}

#pragma mark - WMDataManager Delegate
- (void) dataManager:(WMDataManager *)aDataManager didReceiveTotalNodeCount:(NSNumber *)count {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formattedCount = [formatter stringFromNumber:count];
    
    self.numberOfPlacesLabel.text = [NSString stringWithFormat:@"%@ %@", formattedCount, NSLocalizedString(@"Places", nil)];
    [UIView animateWithDuration:0.5
                          delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void)
     {
         self.numberOfPlacesLabel.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         
         
     }];
    
}

- (void)dataManager:(WMDataManager *)aDataManager fetchTotalNodeCountFailedWithError:(NSError *)error {
    NSNumber *totalCountFromFile = [aDataManager totalNodeCountFromUserDefaults];
    if (totalCountFromFile != nil) {
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *formattedCount = [formatter stringFromNumber:totalCountFromFile];
        
        self.numberOfPlacesLabel.text = [NSString stringWithFormat:@"%@ %@", formattedCount, NSLocalizedString(@"Places", nil)];
    }

    [UIView animateWithDuration:0.5
                          delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void)
     {
         self.numberOfPlacesLabel.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         
         
     }];
    
}

@end
