//
//  WMToolBar.h
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMWheelchairStatusButton.h"

@class WMToolBar;

typedef enum {
    kWMToolBarToggleViewStateList,
    kWMToolBarToggleViewStateMap
} WMToolBarToggleViewState;

typedef enum {
    kWMToolBarButtonCurrentLocation,
    kWMToolBarButtonSearch,
    kWMToolBarButtonWheelChairFilter,
    kWMToolBarButtonCategoryFilter
} WMToolBarButtonType;

@protocol WMToolBarDelegate <NSObject>

@required
-(void)pressedToggleButton:(WMToolBar*)toolBar;
-(void)pressedCurrentLocationButton:(WMToolBar*)toolBar;
-(void)pressedSearchButton:(BOOL)selected;
-(void)pressedWheelChairStatusFilterButton:(WMToolBar*)toolBar;
-(void)pressedCategoryFilterButton:(WMToolBar*)toolBar;
@end

@interface WMToolBar : UIView
{
    UIImageView* backgroundImg;
    WMButton* currentLocationButton;
    WMButton* searchButton;
    WMButton* categoryFilterButton;
    
    BOOL isVisible;
}

@property (nonatomic, strong) id<WMToolBarDelegate> delegate;
@property (nonatomic, strong) WMWheelchairStatusButton* wheelChairStatusFilterButton;
@property (nonatomic, strong) WMButton* toggleButton;
@property (nonatomic) CGFloat middlePointOfWheelchairFilterButton; // this will be updated by initialisation of the button
@property (nonatomic) CGFloat middlePointOfCategoryFilterButton; // this too

-(void)showAllButtons;
-(void)showButton:(WMToolBarButtonType)type;
-(void)hideButton:(WMToolBarButtonType)type;
-(void)selectSearchButton;
-(void)deselectSearchButton;

-(void)clearWheelChairStatusFilterButton;   // this will enable all filter buttons on

@end
