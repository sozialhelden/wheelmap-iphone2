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
    kWMNavigationBarLeftButtonStyleCancelButton
} WMNavigationBarLeftButtonStyle;

typedef enum {
    kWMNavigationBarRightButtonStyleContributeButton,
    kWMNavigationBarRightButtonStyleEditButton,
    kWMNavigationBarRightButtonStyleSaveButton,
    kWMNavigationBarRightButtonStyleNone
} WMNavigationBarRightButtonStyle;



@interface WMNavigationBar : UIView
{
    UIImageView* backgroundImg; // background image
    
    WMLabel* titleLabel;

    WMButton* dashboardButton;
    WMButton* cancelButton;
    WMButton* editButton;
    WMButton* contributeButton; // Mithilfe Button
    WMButton* backButton;
    WMButton* saveButton;
    WMButton* noneButton;
    
    UIView* currentLeftButton;  // both pointers hook the current button objects
    UIView* currentRightButton;
    
    BOOL isVisible;
    
}

@property (nonatomic) WMNavigationBarLeftButtonStyle leftButtonStyle;
@property (nonatomic) WMNavigationBarRightButtonStyle rightButtonStyle;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) id<WMNavigationBarDelegate> delegate;

//-(id)initWithSize:(CGSize)size;
-(void)showNavigationBar;
-(void)hideNavigationBar;
@end
