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
        searchButton.frame = CGRectMake(10, 7, 40, 40);
        searchButton.backgroundColor = [UIColor clearColor];
        [searchButton setImage:[UIImage imageNamed:@"toolbar_icon-search.png"] forState:UIControlStateNormal];
        searchButton.contentMode = UIViewContentModeCenter;
        [searchButton addTarget:self action:@selector(pressedSearchButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:searchButton];
    }
    
    return self;
}

- (void)pressedSearchButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(pressedSearchButton:)]) {
        sender.selected = !sender.selected;
        
        [self.delegate pressedSearchButton:sender.selected];
    }
}

@end
