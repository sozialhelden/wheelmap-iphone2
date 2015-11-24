//
//  WMToolbar.h
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMPOIStateFilterButtonView.h"

@class WMToolbar;

typedef enum {
	kWMToolbarButtonCurrentLocation,
    kWMToolbarButtonSearch,
    kWMToolbarButtonWheelchairStateFilter,
	kWMToolbarButtonToiletStateFilter,
    kWMToolbarButtonCategoryFilter
} WMToolbarButtonType;

@interface WMToolbar : UIView<WMPOIStateFilterButtonViewDelegate>

@property (weak, nonatomic) IBOutlet WMButton *					mapListToggleButton;
@property (weak, nonatomic) IBOutlet WMButton *					searchButton;
@property (weak, nonatomic) IBOutlet UIView *					wheelchairStateFilterButtonContainerView;
@property (strong, nonatomic) WMPOIStateFilterButtonView *		wheelchairStateFilterButton;
@property (weak, nonatomic) IBOutlet UIView *					toiletStateFilterButtonContainerView;
@property (strong, nonatomic) WMPOIStateFilterButtonView *		toiletStateFilterButton;
@property (weak, nonatomic) IBOutlet WMButton *					categoryButton;

@property (nonatomic, strong) id<WMToolbarDelegate>				delegate;

#pragma mark - Initialization

- (instancetype)initFromNibWithFrame:(CGRect)frame;

- (void)initPOIStateFilterButtons;

#pragma mark - Public methods

- (CGFloat)middlePointOfWheelchairStateFilterButton;
- (CGFloat)middlePointOfToiletStateFilterButton;
- (CGFloat)middlePointOfCategoryFilterButton;

#pragma mark Show/Hide buttons

- (void)showAllButtons;
- (void)showButton:(WMToolbarButtonType)type;
- (void)hideButton:(WMToolbarButtonType)type;

- (void)selectSearchButton;
- (void)deselectSearchButton;
- (void)selectCategoryButton;
- (void)deselectCategoryButton;

- (void)clearWheelchairStateFilterButton;   // this will enable all filter buttons on
- (void)clearToiletStateFilterButton; // this will enable all filter buttons on

@end
