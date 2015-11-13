//
//  WMIPadMapNavigationBar.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMIPadMapNavigationBar.h"
#import "WMWheelmapAPI.h"

@interface WMIPadMapNavigationBar ()

@property (weak, nonatomic) IBOutlet WMButton *		searchButton;

@end

@implementation WMIPadMapNavigationBar

#pragma mark - Initialization

- (instancetype)initFromNibWithFrame:(CGRect)frame {
	self = (WMIPadMapNavigationBar *) [WMIPadMapNavigationBar loadFromNib:@"WMIPadMapNavigationBar"];
	if (self != nil) {
		self.frame = frame;
	}
	return self;
}
#pragma mark - IBActions

- (IBAction)pressedSearchButton:(WMButton *)sender {
    if ([self.delegate respondsToSelector:@selector(pressedSearchButton:)]) {
        sender.selected = !sender.selected;
        
        if (!sender.selected) {
            [self hideSearchBar];
        }
        
        [self.delegate pressedSearchButton:sender.selected];
    }
}

- (void)pressedSearchCancelButton:(WMButton*)sender {
    self.searchButton.selected = NO;
    [self hideSearchBar];
    if ([self.delegate respondsToSelector:@selector(pressedSearchCancelButton:)]) {
        [self.delegate pressedSearchCancelButton:self];
    }
}

#pragma mark - Search (public)

- (void)showSearchBar {
	// do nothing, but override the logic from the parent class
}

- (void)hideSearchBar {
	// do nothing, but override the logic from the parent class
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.searchButton.selected = YES;
    return [super textFieldShouldReturn:textField];
}

@end
