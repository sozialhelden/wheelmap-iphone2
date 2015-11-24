//
//  WMToolbar_iPad.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMToolbar_iPad.h"
#import "WMWheelmapAPI.h"

@implementation WMToolbar_iPad {
    
    WMDataManager *dataManager;
}

#pragma mark - Initialization

- (instancetype)initFromNibWithFrame:(CGRect)frame {
	self = (WMToolbar_iPad *) [WMToolbar_iPad loadFromNib:@"WMToolbar-iPad"];
	if (self != nil) {
		self.frame = frame;
		[self initPOIStateFilterButtons];
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	self.stagingEnvironmentDebugLabel.hidden = (WMWheelmapAPI.isStagingBackend == NO);

	dataManager = [[WMDataManager alloc] init];
	dataManager.delegate = self;
	[dataManager fetchTotalNodeCount];
}

#pragma mark - IBActions

- (IBAction)creditsButtonPreseed:(id)sender {
	if ([self.delegate respondsToSelector:@selector(pressedCreditsButton:)]) {
		[self.delegate pressedCreditsButton:self];
	}
}

- (IBAction)loginButtonPressed:(id)sender {
	if ([self.delegate respondsToSelector:@selector(pressedLoginButton:)]) {
		[self.delegate pressedLoginButton:self];
	}
}

- (IBAction)contributeButtonPressed:(id)sender {
	self.contributeButton.selected = !self.contributeButton.selected;

	if ([self.delegate respondsToSelector:@selector(pressedContributeButton:)]) {
		[self.delegate pressedContributeButton:self];
	}
}

- (IBAction)currentLocationButtonPressed:(id)sender {
	if ([self.delegate respondsToSelector:@selector(pressedCurrentLocationButton:)]) {
		[self.delegate pressedCurrentLocationButton:self];
	}
}

#pragma mark -

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
                     animations:^(void) {
         self.numberOfPlacesLabel.alpha = 1.0;
     } completion:nil];
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
                     animations:^(void) {
         self.numberOfPlacesLabel.alpha = 1.0;
     } completion:nil];
}

@end
