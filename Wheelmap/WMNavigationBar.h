//
//  WMNavigationBar.h
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMNavigationBarDelegate.h"

typedef enum {
    kWMNavigationBarLeftButtonStyleDashboardButton,
    kWMNavigationBarLeftButtonStyleBackButton,
    kWMNavigationBarLeftButtonStyleCancelButton,
    kWMNavigationBarLeftButtonStyleNone
} WMNavigationBarLeftButtonStyle;

typedef enum {
    kWMNavigationBarRightButtonStyleContributeButton,
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
    
    UIView* currentLeftButton;  // both pointers hook the current button objects
    UIView* currentRightButton;
    
    BOOL isSearchBarVisible;
    
    UIImageView* searchBarContainer;
    UIImageView* searchBarTextFieldBg;
    UITextField* searchBarTextField;
    WMButton* searchBarCancelButton;
    
    
}

@property (nonatomic, strong) WMButton* editButton;
@property (nonatomic, strong) WMButton* contributeButton; // Mithilfe Button
@property (nonatomic) WMNavigationBarLeftButtonStyle leftButtonStyle;
@property (nonatomic) WMNavigationBarRightButtonStyle rightButtonStyle;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) id<WMNavigationBarDelegate> delegate;
@property (nonatomic) BOOL searchBarEnabled;


//-(id)initWithSize:(CGSize)size;
-(void)showSearchBar;
-(void)hideSearchBar;
- (NSString *)getSearchString;

-(void)showRightButton:(WMNavigationBarRightButtonStyle)type;
-(void)hideRightButton:(WMNavigationBarRightButtonStyle)type;

- (void)adjustButtonsToPopoverPresentation;
@end
