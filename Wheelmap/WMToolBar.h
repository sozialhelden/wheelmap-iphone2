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

@protocol WMToolBarDelegate <NSObject>

@required
-(void)pressedToggleButton:(WMToolBar*)toolBar;
-(void)pressedCurrentLocationButton:(WMToolBar*)toolBar;
-(void)pressedSearchButton:(WMToolBar*)toolBar;
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

@end
