//
//  WMToolBar.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMToolBar.h"
#import "Constants.h"


@implementation WMToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self setBackgroundColor:[UIColor wmNavigationBackgroundColor]];
        
        currentLocationButton = [WMButton buttonWithType:UIButtonTypeCustom];
        currentLocationButton.frame = CGRectMake(2, 3, 58, 58);
        [currentLocationButton setImage:[UIImage imageNamed:@"ToolbarCenterIcon"] forState:UIControlStateNormal];
        [currentLocationButton addTarget:self action:@selector(pressedCurrentLocationButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:currentLocationButton];
        
        searchButton = [WMButton buttonWithType:UIButtonTypeCustom];
        searchButton.frame = CGRectMake(currentLocationButton.topRightX+4, 3, 58, 58);
        [searchButton setImage:[UIImage imageNamed:@"ToolbarSearchIcon"] forState:UIControlStateNormal];

        [searchButton addTarget:self action:@selector(pressedSearchButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:searchButton];
        
        // toggle button uses setView:forControlState: method
        self.toggleButton = [WMButton buttonWithType:UIButtonTypeCustom];
        self.toggleButton.frame = CGRectMake(0, 3, 68, 58);
        self.toggleButton.center = CGPointMake(self.center.x, self.toggleButton.center.y);
        UIImageView* toggleBtnNormalView = [[UIImageView alloc] initWithFrame:self.toggleButton.bounds];
        UIImageView* toggleBtnListIcon = [[UIImageView alloc] initWithFrame:toggleBtnNormalView.bounds];
        toggleBtnListIcon.image = [UIImage imageNamed:@"ToolbarMapIcon"];
        toggleBtnListIcon.contentMode = UIViewContentModeCenter;
        [toggleBtnNormalView addSubview:toggleBtnListIcon];
        [self.toggleButton setView:toggleBtnNormalView forControlState:UIControlStateNormal];
        
        UIImageView* toggleBtnHighlightedView = [[UIImageView alloc] initWithFrame:self.toggleButton.bounds];
        toggleBtnListIcon = [[UIImageView alloc] initWithFrame:toggleBtnNormalView.bounds];
        toggleBtnListIcon.image = [UIImage imageNamed:@"ToolbarListIcon"];
        toggleBtnListIcon.contentMode = UIViewContentModeCenter;
        [toggleBtnHighlightedView addSubview:toggleBtnListIcon];
        [self.toggleButton setView:toggleBtnHighlightedView forControlState:UIControlStateHighlighted];
        
        UIImageView* toggleBtnSelectedView = [[UIImageView alloc] initWithFrame:self.toggleButton.bounds];
        UIImageView* toggleBtnMapIcon = [[UIImageView alloc] initWithFrame:toggleBtnSelectedView.bounds];
        toggleBtnMapIcon.image = [UIImage imageNamed:@"ToolbarListIcon"];
        toggleBtnMapIcon.contentMode = UIViewContentModeCenter;
        [toggleBtnSelectedView addSubview:toggleBtnMapIcon];
        [self.toggleButton setView:toggleBtnSelectedView forControlState:UIControlStateSelected];
        self.toggleButton.enabledToggle = YES;
    
        [self.toggleButton addTarget:self action:@selector(pressedToggleButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.toggleButton];
        
        categoryFilterButton = [WMButton buttonWithType:UIButtonTypeCustom];
        categoryFilterButton.frame = CGRectMake(self.frame.size.width-2-58, 3, 58, 58);
        [categoryFilterButton setImage:[UIImage imageNamed:@"ToolbarKategorieIcon"] forState:UIControlStateNormal];
        [categoryFilterButton addTarget:self action:@selector(pressedCategoryFilterButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:categoryFilterButton];
        self.middlePointOfCategoryFilterButton = categoryFilterButton.frame.origin.x+(categoryFilterButton.frame.size.width/2.0);
        
        self.wheelChairStatusFilterButton = [[WMWheelchairStatusButton alloc] initWithFrame:CGRectMake(categoryFilterButton.frame.origin.x-4-58, 5, 56, 56)];
        self.wheelChairStatusFilterButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self.wheelChairStatusFilterButton addTarget:self action:@selector(pressedWheelChairStatusFilterButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.wheelChairStatusFilterButton];
        self.middlePointOfWheelchairFilterButton = self.wheelChairStatusFilterButton.frame.origin.x+(self.wheelChairStatusFilterButton.frame.size.width/2.0);
        
    }
    
    return self;
}

- (CGFloat)middlePointOfCategoryFilterButton {
    return categoryFilterButton.frame.origin.x+(categoryFilterButton.frame.size.width/2.0);
}

- (CGFloat)middlePointOfWheelchairFilterButton {
    return self.wheelChairStatusFilterButton.frame.origin.x+(self.wheelChairStatusFilterButton.frame.size.width/2.0);
}

-(void)selectSearchButton {
    searchButton.selected = YES;
}

-(void)deselectSearchButton {
    searchButton.selected = NO;
}

-(void)selectCategoryButton {
    categoryFilterButton.selected = YES;
}

-(void)deselectCategoryButton {
    categoryFilterButton.selected = NO;
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
        sender.selected = !sender.selected;
        
        [self.delegate pressedSearchButton:sender.selected];
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

#pragma mark - Show/Hide buttons
-(void)showAllButtons
{
    currentLocationButton.hidden = NO;
    currentLocationButton.userInteractionEnabled = YES;
    searchButton.hidden = NO;
    searchButton.userInteractionEnabled = YES;
    self.wheelChairStatusFilterButton.hidden = NO;
    self.wheelChairStatusFilterButton.userInteractionEnabled = YES;
    categoryFilterButton.hidden = NO;
    categoryFilterButton.userInteractionEnabled = YES;

    [UIView animateWithDuration:0.3 animations:^(void)
     {
         currentLocationButton.alpha = 1.0;
         searchButton.alpha = 1.0;
         self.wheelChairStatusFilterButton.alpha = 1.0;
         categoryFilterButton.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         
         
     }
     ];
    
}
-(void)showButton:(WMToolBarButtonType)type
{
    UIView* targetButton;
    
    switch (type) {
        case kWMToolBarButtonCurrentLocation:
            targetButton = currentLocationButton;
            break;
        case kWMToolBarButtonSearch:
            targetButton = searchButton;
            break;
        case kWMToolBarButtonWheelChairFilter:
            targetButton = self.wheelChairStatusFilterButton;
            break;
        case kWMToolBarButtonCategoryFilter:
            targetButton = categoryFilterButton;
            break;
        default:
            break;
    }
    
    targetButton.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.5 animations:^(void)
     {
         targetButton.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         
         
     }
     ];
    
    
}
-(void)hideButton:(WMToolBarButtonType)type
{
    UIView* targetButton;
    
    switch (type) {
        case kWMToolBarButtonCurrentLocation:
            targetButton = currentLocationButton;
            break;
        case kWMToolBarButtonSearch:
            targetButton = searchButton;
            break;
        case kWMToolBarButtonWheelChairFilter:
            targetButton = self.wheelChairStatusFilterButton;
            break;
        case kWMToolBarButtonCategoryFilter:
            targetButton = categoryFilterButton;
            break;
        default:
            break;
    }
    
    
    [UIView animateWithDuration:0.5 animations:^(void)
     {
         targetButton.alpha = 0.3;
     }
                     completion:^(BOOL finished)
     {
         targetButton.userInteractionEnabled = NO;
         
     }
     ];

}

- (void)clearWheelChairStatusFilterButton
{
    self.wheelChairStatusFilterButton.selectedGreenDot = YES;
    self.wheelChairStatusFilterButton.selectedYellowDot = YES;
    self.wheelChairStatusFilterButton.selectedRedDot = YES;
    self.wheelChairStatusFilterButton.selectedNoneDot = YES;

}

@end
