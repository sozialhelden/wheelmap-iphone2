//
//  WMToolBar.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMToolBar.h"


@implementation WMToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        backgroundImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 60)];
        backgroundImg.image = [UIImage imageNamed:@"toolbar_background.png"];
        [self addSubview:backgroundImg];
        
        currentLocationButton = [WMButton buttonWithType:UIButtonTypeCustom];
        currentLocationButton.frame = CGRectMake(2, 3, 58, 58);
        [currentLocationButton setBackgroundImage:[UIImage imageNamed:@"toolbar_button.png"] forState:UIControlStateNormal];
        [currentLocationButton setImage:[UIImage imageNamed:@"toolbar_icon-location.png"] forState:UIControlStateNormal];
        [currentLocationButton addTarget:self action:@selector(pressedCurrentLocationButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:currentLocationButton];
        
        searchButton = [WMButton buttonWithType:UIButtonTypeCustom];
        searchButton.frame = CGRectMake(currentLocationButton.topRightX+4, 1, 58, 58);
        [searchButton setBackgroundImage:[UIImage imageNamed:@"toolbar_button.png"] forState:UIControlStateNormal];
        [searchButton setImage:[UIImage imageNamed:@"toolbar_icon-search.png"] forState:UIControlStateNormal];

        [searchButton addTarget:self action:@selector(pressedSearchButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:searchButton];
        
        // toggle button uses setView:forControlState: method
        self.toggleButton = [WMButton buttonWithType:UIButtonTypeCustom];
        self.toggleButton.frame = CGRectMake(floor((self.frame.size.width-71)/2.0), -2, 71, 62);
        UIImageView* toggleBtnNormalView = [[UIImageView alloc] initWithFrame:self.toggleButton.bounds];
        toggleBtnNormalView.image = [UIImage imageNamed:@"toolbar_toggle-btn.png"];
        UIImageView* toggleBtnListIcon = [[UIImageView alloc] initWithFrame:toggleBtnNormalView.bounds];
        toggleBtnListIcon.image = [UIImage imageNamed:@"toolbar_toggle-map.png"];
        toggleBtnListIcon.contentMode = UIViewContentModeCenter;
        [toggleBtnNormalView addSubview:toggleBtnListIcon];
        [self.toggleButton setView:toggleBtnNormalView forControlState:UIControlStateNormal];
        
        UIImageView* toggleBtnHighlightedView = [[UIImageView alloc] initWithFrame:self.toggleButton.bounds];
        toggleBtnHighlightedView.image = [UIImage imageNamed:@"toolbar_toggle-btn.png"];
        toggleBtnListIcon = [[UIImageView alloc] initWithFrame:toggleBtnNormalView.bounds];
        toggleBtnListIcon.image = [UIImage imageNamed:@"toolbar_toggle-map.png"];
        toggleBtnListIcon.contentMode = UIViewContentModeCenter;
        [toggleBtnHighlightedView addSubview:toggleBtnListIcon];
        [self.toggleButton setView:toggleBtnHighlightedView forControlState:UIControlStateHighlighted];
        
        UIImageView* toggleBtnSelectedView = [[UIImageView alloc] initWithFrame:self.toggleButton.bounds];
        toggleBtnSelectedView.image = [UIImage imageNamed:@"toolbar_toggle-btn.png"];
        UIImageView* toggleBtnMapIcon = [[UIImageView alloc] initWithFrame:toggleBtnSelectedView.bounds];
        toggleBtnMapIcon.image = [UIImage imageNamed:@"toolbar_toggle-list.png"];
        toggleBtnMapIcon.contentMode = UIViewContentModeCenter;
        [toggleBtnSelectedView addSubview:toggleBtnMapIcon];
        [self.toggleButton setView:toggleBtnSelectedView forControlState:UIControlStateSelected];
        self.toggleButton.enabledToggle = YES;
    
        [self.toggleButton addTarget:self action:@selector(pressedToggleButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.toggleButton];
        
        categoryFilterButton = [WMButton buttonWithType:UIButtonTypeCustom];
        categoryFilterButton.frame = CGRectMake(self.frame.size.width-2-58, 1, 58, 58);
        [categoryFilterButton setBackgroundImage:[UIImage imageNamed:@"toolbar_button.png"] forState:UIControlStateNormal];
        [categoryFilterButton setImage:[UIImage imageNamed:@"toolbar_icon-category.png"] forState:UIControlStateNormal];
        [categoryFilterButton addTarget:self action:@selector(pressedCategoryFilterButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:categoryFilterButton];
        self.middlePointOfCategoryFilterButton = categoryFilterButton.frame.origin.x+(categoryFilterButton.frame.size.width/2.0);
        
        self.wheelChairStatusFilterButton = [[WMWheelchairStatusButton alloc] initWithFrame:CGRectMake(categoryFilterButton.frame.origin.x-4-58, 1, 58, 58)];
        [self.wheelChairStatusFilterButton addTarget:self action:@selector(pressedWheelChairStatusFilterButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.wheelChairStatusFilterButton];
        self.middlePointOfWheelchairFilterButton = self.wheelChairStatusFilterButton.frame.origin.x+(self.wheelChairStatusFilterButton.frame.size.width/2.0);
        
    }
    
    return self;
}

#pragma mark -
#pragma mark Button Handler
-(void)pressedToggleButton:(WMButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(pressedToggleButton:)]) {
        [self.delegate pressedToggleButton:self];
    }
}

-(void)pressedCurrentLocationButton:(WMButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(pressedCurrentLocationButton:)]) {
        [self.delegate pressedCurrentLocationButton:self];
    }
}

-(void)pressedSearchButton:(WMButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(pressedSearchButton:)]) {
        [self.delegate pressedSearchButton:self];
    }
}

-(void)pressedWheelChairStatusFilterButton:(WMWheelchairStatusButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(pressedWheelChairStatusFilterButton:)]) {
        [self.delegate pressedWheelChairStatusFilterButton:self];
    }
}

-(void)pressedCategoryFilterButton:(WMButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(pressedCategoryFilterButton:)]) {
        [self.delegate pressedCategoryFilterButton:self];
    }
}

@end
