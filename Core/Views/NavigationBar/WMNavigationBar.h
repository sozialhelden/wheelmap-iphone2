//
//  WMNavigationBar.h
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMNavigationBar : UIView <UITextFieldDelegate> {
    UIImageView* backgroundImg; // background image
    
    BOOL isSearchBarVisible;
}

@property (nonatomic, strong) NSString *						title;

@property (nonatomic, strong) WMButton *						currentLeftButton;
@property (nonatomic, strong) WMButton *						currentRightButton;

@property (weak, nonatomic) IBOutlet WMButton *					dashboardButton;
@property (weak, nonatomic) IBOutlet WMButton *					backButton;
@property (weak, nonatomic) IBOutlet WMButton *					cancelButtonLeft;
@property (weak, nonatomic) IBOutlet WMButton *					cancelButtonRight;
@property (weak, nonatomic) IBOutlet WMButton *					addButton;
@property (weak, nonatomic) IBOutlet WMButton *					editButton;
@property (weak, nonatomic) IBOutlet WMButton *					saveButton;
@property (weak, nonatomic) IBOutlet WMLabel *					titleLabel;

@property (weak, nonatomic) IBOutlet UIView *					searchContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *		searchContainerViewTopConstraint;
@property (weak, nonatomic) IBOutlet UITextField *				searchTextField;
@property (weak, nonatomic) IBOutlet WMButton *					cancelSearchButton;

@property (nonatomic) WMNavigationBarLeftButtonStyle			leftButtonStyle;
@property (nonatomic) WMNavigationBarRightButtonStyle			rightButtonStyle;

@property (nonatomic, strong) id<WMNavigationBarDelegate>	delegate;
@property (nonatomic) BOOL										searchBarEnabled;

#pragma mark - Initialization

- (instancetype)initFromNibWithFrame:(CGRect)frame;

#pragma mark - Search

- (void)showSearchBar;
- (void)hideSearchBar;
- (NSString *)getSearchString;
- (void)clearSearchText;
- (void)dismissSearchKeyboard;

#pragma mark - Buttons

- (void)enableRightButton:(WMNavigationBarRightButtonStyle)type;
- (void)disableRightButton:(WMNavigationBarRightButtonStyle)type;

@end
