//
//  WMNavigationBar.h
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kWMNavigationBarLeftButtonStyleDashboardButton,
    kWMNavigationBarLeftButtonStyleBackButton,
    kWMNavigationBarLeftButtonStyleCancelButton,
    kWMNavigationBarLeftButtonStyleNone
} WMNavigationBarLeftButtonStyle;

typedef enum {
    kWMNavigationBarRightButtonStyleCreatePOIButton,
    kWMNavigationBarRightButtonStyleEditButton,
    kWMNavigationBarRightButtonStyleSaveButton,
    kWMNavigationBarRightButtonStyleCancelButton,
    kWMNavigationBarRightButtonStyleNone
} WMNavigationBarRightButtonStyle;



@interface WMNavigationBar : UIView <UITextFieldDelegate>
{
    UIImageView* backgroundImg; // background image
    
    WMLabel* titleLabel;

    WMButton* dashboardButton;
    WMButton* cancelButton;
    WMButton* cancelButtonRight;
    WMButton* backButton;
    WMButton* saveButton;
    WMButton* noneButton;
    WMButton* noneButtonLeft;
   
    UIView* currentLeftButton;  // both pointers hook the current button objects
    UIView* currentRightButton;
    
    BOOL isSearchBarVisible;
    
    UIImageView* searchBarContainer;
    UIImageView* searchBarTextFieldBg;
    UITextField* searchBarTextField;
    WMButton* searchBarCancelButton;
    
    
}

@property (nonatomic, strong) WMButton *					editButton;
@property (nonatomic, strong) WMButton *					createPOIButton;
@property (nonatomic) WMNavigationBarLeftButtonStyle		leftButtonStyle;
@property (nonatomic) WMNavigationBarRightButtonStyle		rightButtonStyle;
@property (nonatomic, strong) NSString *					title;
@property (nonatomic, strong) id<WMNavigationBarDelegate>	delegate;
@property (nonatomic) BOOL									searchBarEnabled;


- (void)showSearchBar;
- (void)hideSearchBar;
- (NSString *)getSearchString;
- (void)clearSearchText;

- (void)showRightButton:(WMNavigationBarRightButtonStyle)type;
- (void)hideRightButton:(WMNavigationBarRightButtonStyle)type;

- (void)adjustButtonsToPopoverPresentation;
- (void)dismissSearchKeyboard;
@end
