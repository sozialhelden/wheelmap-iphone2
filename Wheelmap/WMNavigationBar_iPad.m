//
//  WMNavigationBar_iPad.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMNavigationBar_iPad.h"
#import "Reachability.h"
#import "WMWheelmapAPI.h"

@implementation WMNavigationBar_iPad

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [dashboardButton removeFromSuperview];
        
        searchButton = [WMButton buttonWithType:UIButtonTypeCustom];
        searchButton.frame = CGRectMake(4, 5, 42, 40);
        searchButton.backgroundColor = [UIColor clearColor];
        [searchButton setImage:[UIImage imageNamed:@"ipad_buttons_icon-search.png"] forState:UIControlStateNormal];
        [searchButton setImage:[UIImage imageNamed:@"ipad_buttons_icon-search-active.png"] forState:UIControlStateSelected];
        searchButton.contentMode = UIViewContentModeCenter;
        [searchButton addTarget:self action:@selector(pressedSearchButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:searchButton];
        
        titleLabel.frame = CGRectMake(self.bounds.size.width/2, titleLabel.frame.origin.y, self.bounds.size.width/2 - 100.0f, titleLabel.frame.size.height);
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
    
    return self;
}

- (void)pressedSearchButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(pressedSearchButton:)]) {
        sender.selected = !sender.selected;
        
        if (!sender.selected) {
            [self hideSearchBar];
        }
        
        [self.delegate pressedSearchButton:sender.selected];
    }
}

-(void)pressedSearchCancelButton:(WMButton*)sender
{
    searchButton.selected = NO;
    [self hideSearchBar];
    if ([self.delegate respondsToSelector:@selector(pressedSearchCancelButton:)]) {
        [self.delegate pressedSearchCancelButton:self];
    }
}

-(void)showSearchBar
{
}

-(void)hideSearchBar
{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    searchButton.selected = YES;
    return [super textFieldShouldReturn:textField];
}

@end
