//
//  WMToolbar.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMToolbar.h"

@implementation WMToolbar

#pragma mark - Initialization

- (instancetype)initFromNibWithFrame:(CGRect)frame {
	self = (WMToolbar *) [WMToolbar loadFromNib:@"WMToolbar"];
	if (self != nil) {
		self.frame = frame;
		[self initPOIStateFilterButtons];
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	self.mapListToggleButton.enabledToggle = YES;
}

- (void)initPOIStateFilterButtons {
	self.wheelchairStateFilterButton = [[WMPOIStateFilterButtonView alloc] initFromNibToView:self.wheelchairStateFilterButtonContainerView];
	self.wheelchairStateFilterButton.statusType = WMPOIStateTypeWheelchair;
	self.wheelchairStateFilterButton.delegate = self;
	self.toiletStateFilterButton = [[WMPOIStateFilterButtonView alloc] initFromNibToView:self.toiletStateFilterButtonContainerView];
	self.toiletStateFilterButton.statusType = WMPOIStateTypeToilet;
	self.toiletStateFilterButton.delegate = self;
}

#pragma mark - IBActions

- (IBAction)mapListToggleButtonPressed:(id)sender {
	if ([self.delegate respondsToSelector:@selector(pressedMapListToggleButton:)]) {
		[self.delegate pressedMapListToggleButton:self];
	}
}

- (IBAction)searchButtonPressed:(id)sender {
	if ([self.delegate respondsToSelector:@selector(pressedSearchButton:)]) {
		self.searchButton.selected = !self.searchButton.selected;
		[self.delegate pressedSearchButton:self.searchButton.selected];
	}
}

- (IBAction)categoryButtonPressed:(id)sender {
	if ([self.delegate respondsToSelector:@selector(pressedCategoryFilterButton:sourceView:)]) {
		[self.delegate pressedCategoryFilterButton:self sourceView:self.categoryButton];
	}
}

#pragma mark - Public methods

- (CGFloat)middlePointOfWheelchairStateFilterButton {
	return self.wheelchairStateFilterButtonContainerView.frame.origin.x+(self.wheelchairStateFilterButtonContainerView.frame.size.width/2.0);
}

- (CGFloat)middlePointOfToiletStateFilterButton {
	return self.toiletStateFilterButtonContainerView.frame.origin.x+(self.toiletStateFilterButtonContainerView.frame.size.width/2.0);
}

- (CGFloat)middlePointOfCategoryFilterButton {
	return self.categoryButton.frame.origin.x+(self.categoryButton.frame.size.width/2.0);
}

- (void)selectSearchButton {
	self.searchButton.selected = YES;
}

- (void)deselectSearchButton {
	self.searchButton.selected = NO;
}

- (void)selectCategoryButton {
	self.categoryButton.selected = YES;
}

- (void)deselectCategoryButton {
	self.categoryButton.selected = NO;
}


#pragma mark Show/Hide buttons

-(void)showAllButtons {
    self.searchButton.hidden = NO;
    self.searchButton.userInteractionEnabled = YES;
    self.wheelchairStateFilterButton.hidden = NO;
    self.wheelchairStateFilterButton.userInteractionEnabled = YES;
	self.toiletStateFilterButton.hidden = NO;
	self.toiletStateFilterButton.userInteractionEnabled = YES;
	self.categoryButton.hidden = NO;
    self.categoryButton.userInteractionEnabled = YES;

    [UIView animateWithDuration:0.3 animations:^(void) {
        self.searchButton.alpha = 1.0;
        self.wheelchairStateFilterButton.alpha = 1.0;
		self.toiletStateFilterButton.alpha = 1.0;
		self.categoryButton.alpha = 1.0;
	} completion:nil];
}

- (void)showButton:(WMToolbarButtonType)type {
    UIView* targetButton;
    switch (type) {
        case kWMToolbarButtonSearch:
            targetButton = self.searchButton;
            break;
        case kWMToolbarButtonWheelchairStateFilter:
            targetButton = self.wheelchairStateFilterButton;
            break;
		case kWMToolbarButtonToiletStateFilter:
			targetButton = self.toiletStateFilterButton;
			break;
        case kWMToolbarButtonCategoryFilter:
            targetButton = self.categoryButton;
            break;
        default:
            break;
    }
    
    targetButton.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.5 animations:^(void) {
         targetButton.alpha = 1.0;
     } completion:nil];
}

- (void)hideButton:(WMToolbarButtonType)type {
    UIView* targetButton;
    
    switch (type) {
        case kWMToolbarButtonSearch:
            targetButton = self.searchButton;
            break;
        case kWMToolbarButtonWheelchairStateFilter:
            targetButton = self.wheelchairStateFilterButton;
            break;
		case kWMToolbarButtonToiletStateFilter:
			targetButton = self.toiletStateFilterButton;
			break;
        case kWMToolbarButtonCategoryFilter:
            targetButton = self.categoryButton;
            break;
        default:
            break;
    }

    [UIView animateWithDuration:0.5 animations:^(void) {
         targetButton.alpha = 0.3;
	} completion:^(BOOL finished) {
         targetButton.userInteractionEnabled = NO;
	}];
}

- (void)clearWheelchairStateFilterButton {
    self.wheelchairStateFilterButton.selectedGreenDot = YES;
    self.wheelchairStateFilterButton.selectedYellowDot = YES;
    self.wheelchairStateFilterButton.selectedRedDot = YES;
    self.wheelchairStateFilterButton.selectedNoneDot = YES;
}

- (void)clearToiletStateFilterButton {
	self.toiletStateFilterButton.selectedGreenDot = YES;
	self.toiletStateFilterButton.selectedRedDot = YES;
	self.toiletStateFilterButton.selectedNoneDot = YES;
}

#pragma mark - WMPOIStateFilterButtonViewView

- (void)didPressPOIStateFilterButtonForStateType:(WMPOIStateType)stateType {
	if (stateType == WMPOIStateTypeWheelchair) {
		if ([self.delegate respondsToSelector:@selector(pressedWheelchairStateFilterButton:sourceView:)]) {
			[self.delegate pressedWheelchairStateFilterButton:self sourceView:self.wheelchairStateFilterButtonContainerView];
		}
	} else if (stateType == WMPOIStateTypeToilet) {
		if ([self.delegate respondsToSelector:@selector(pressedToiletStateFilterButton:sourceView:)]) {
			[self.delegate pressedToiletStateFilterButton:self sourceView:self.toiletStateFilterButtonContainerView];
		}
	}
}

@end
