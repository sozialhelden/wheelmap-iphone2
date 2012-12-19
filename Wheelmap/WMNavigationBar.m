//
//  WMNavigationBar.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMNavigationBar.h"

@implementation WMNavigationBar
@synthesize leftButtonStyle = _leftButtonStyle;
@synthesize rightButtonStyle = _rightButtonStyle;
@synthesize title = _title;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        backgroundImg = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundImg.image = [UIImage imageNamed:@"navigationbar_background.png"];
        backgroundImg.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:backgroundImg];
        
        currentLeftButton = nil;
        currentRightButton = nil;
        self.leftButtonStyle = -1;
        self.rightButtonStyle = -1;
        
        // init all buttons here
        CGRect leftButtonRect = CGRectMake(5, 5, 40, 40);
        dashboardButton = [WMButton buttonWithType:UIButtonTypeCustom];
        dashboardButton.frame = leftButtonRect;
        dashboardButton.backgroundColor = [UIColor clearColor];
        [dashboardButton setImage:[UIImage imageNamed:@"navigationbar_homebutton.png"] forState:UIControlStateNormal];
        dashboardButton.contentMode = UIViewContentModeCenter;
        dashboardButton.hidden = YES;
        [dashboardButton addTarget:self action:@selector(pressedDashboardButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dashboardButton];
        
        // back button
        UIImageView* backBtnBgImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 37)];
        backBtnBgImg.image = [[UIImage imageNamed:@"buttons_back-btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 10)];
        WMLabel* backBtnLabel = [[WMLabel alloc] initWithFrame:CGRectMake(15, 0, 100, 35)];
        backBtnLabel.fontSize = 13.0;
        backBtnLabel.text = NSLocalizedString(@"BackButton", nil);
        backBtnLabel.textColor = [UIColor whiteColor];
        CGSize expSize = [backBtnLabel.text sizeWithFont:backBtnLabel.font constrainedToSize:CGSizeMake(100, 17)];
        if (expSize.width < 40) expSize = CGSizeMake(40, expSize.height);
        backBtnLabel.frame = CGRectMake(backBtnLabel.frame.origin.x, backBtnLabel.frame.origin.y, expSize.width, backBtnLabel.frame.size.height);
        backBtnBgImg.frame  = CGRectMake(0, 0, backBtnLabel.frame.size.width+20, 37);
        [backBtnBgImg addSubview:backBtnLabel];
        backButton = [WMButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(5, 6, backBtnBgImg.frame.size.width, backBtnBgImg.frame.size.height);
        [backButton setView:backBtnBgImg forControlState:UIControlStateNormal];
        backButton.hidden = YES;
        [backButton addTarget:self action:@selector(pressedBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
        
        // cancel button
        UIImageView* normalBtnImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 37)];
        normalBtnImg.image = [[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        WMLabel* normalBtnLabel = [[WMLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 35)];
        normalBtnLabel.fontSize = 13.0;
        normalBtnLabel.text = NSLocalizedString(@"Cancel", nil);
        normalBtnLabel.textAlignment = UITextAlignmentCenter;
        normalBtnLabel.textColor = [UIColor whiteColor];
        expSize = [normalBtnLabel.text sizeWithFont:normalBtnLabel.font constrainedToSize:CGSizeMake(100, 17)];
        if (expSize.width < 40) expSize = CGSizeMake(40, expSize.height);
        normalBtnLabel.frame = CGRectMake(normalBtnLabel.frame.origin.x, normalBtnLabel.frame.origin.y, expSize.width, normalBtnLabel.frame.size.height);
        normalBtnImg.frame  = CGRectMake(0, 0, normalBtnLabel.frame.size.width+10, 37);
        normalBtnLabel.center = CGPointMake(normalBtnImg.center.x, normalBtnLabel.center.y);
        [normalBtnImg addSubview:normalBtnLabel];
        cancelButton = [WMButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(5, 6, normalBtnImg.frame.size.width, normalBtnImg.frame.size.height);
        cancelButton.backgroundColor = [UIColor clearColor];
        [cancelButton setView:normalBtnImg forControlState:UIControlStateNormal];
        cancelButton.hidden = YES;
        [cancelButton addTarget:self action:@selector(pressedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
        CGRect rightButtonRect = CGRectMake(self.frame.size.width-5-40, 5, 40, 40);
        // mithilfe button
        contributeButton = [WMButton buttonWithType:UIButtonTypeCustom];
        contributeButton.frame = rightButtonRect;
        contributeButton.backgroundColor = [UIColor clearColor];
        [contributeButton setImage:[UIImage imageNamed:@"navigationbar_addbutton.png"] forState:UIControlStateNormal];
        contributeButton.contentMode = UIViewContentModeCenter;
        contributeButton.hidden = YES;
        [contributeButton addTarget:self action:@selector(pressedContributeButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:contributeButton];
        
        
        // edit button
        normalBtnImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 37)];
        normalBtnImg.image = [[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        normalBtnLabel = [[WMLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 35)];
        normalBtnLabel.fontSize = 13.0;
        normalBtnLabel.text = NSLocalizedString(@"NavBarEditButton", nil);
        normalBtnLabel.textAlignment = UITextAlignmentCenter;
        normalBtnLabel.textColor = [UIColor whiteColor];
        expSize = [normalBtnLabel.text sizeWithFont:normalBtnLabel.font constrainedToSize:CGSizeMake(100, 17)];
        if (expSize.width < 40) expSize = CGSizeMake(40, expSize.height);
        normalBtnLabel.frame = CGRectMake(normalBtnLabel.frame.origin.x, normalBtnLabel.frame.origin.y, expSize.width, normalBtnLabel.frame.size.height);
        normalBtnImg.frame  = CGRectMake(0, 0, normalBtnLabel.frame.size.width+10, 37);
        normalBtnLabel.center = CGPointMake(normalBtnImg.center.x, normalBtnLabel.center.y);
        [normalBtnImg addSubview:normalBtnLabel];
        editButton = [WMButton buttonWithType:UIButtonTypeCustom];
        editButton.frame = CGRectMake(self.frame.size.width-normalBtnImg.frame.size.width-5, 6, normalBtnImg.frame.size.width, normalBtnImg.frame.size.height);
        editButton.backgroundColor = [UIColor clearColor];
        [editButton setView:normalBtnImg forControlState:UIControlStateNormal];
        editButton.hidden = YES;
        [editButton addTarget:self action:@selector(pressedEditButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:editButton];
        
        // save button
        normalBtnImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 37)];
        normalBtnImg.image = [[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        normalBtnLabel = [[WMLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 35)];
        normalBtnLabel.fontSize = 13.0;
        normalBtnLabel.text = NSLocalizedString(@"NavBarSaveButton", nil);
        normalBtnLabel.textAlignment = UITextAlignmentCenter;
        normalBtnLabel.textColor = [UIColor whiteColor];
        expSize = [normalBtnLabel.text sizeWithFont:normalBtnLabel.font constrainedToSize:CGSizeMake(100, 17)];
        if (expSize.width < 40) expSize = CGSizeMake(40, expSize.height);
        normalBtnLabel.frame = CGRectMake(normalBtnLabel.frame.origin.x, normalBtnLabel.frame.origin.y, expSize.width, normalBtnLabel.frame.size.height);
        normalBtnImg.frame  = CGRectMake(0, 0, normalBtnLabel.frame.size.width+10, 37);
        normalBtnLabel.center = CGPointMake(normalBtnImg.center.x, normalBtnLabel.center.y);
        [normalBtnImg addSubview:normalBtnLabel];
        saveButton = [WMButton buttonWithType:UIButtonTypeCustom];
        saveButton.frame = CGRectMake(self.frame.size.width-normalBtnImg.frame.size.width-5, 6, normalBtnImg.frame.size.width, normalBtnImg.frame.size.height);
        saveButton.backgroundColor = [UIColor clearColor];
        saveButton.hidden = YES;
        [saveButton setView:normalBtnImg forControlState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(pressedSaveButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:saveButton];
        
        noneButton = [WMButton buttonWithType:UIButtonTypeCustom];
        noneButton.frame = rightButtonRect;
        noneButton.hidden = YES;
        [self addSubview:noneButton];
        
                
        // titleLabel
        titleLabel = [[WMLabel alloc] initWithFrame:self.bounds];
        titleLabel.fontSize = 20.0;
        titleLabel.fontType = kWMLabelFontTypeBold;
        titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:titleLabel];
        
        // initial styles
        self.leftButtonStyle = kWMNavigationBarLeftButtonStyleDashboardButton;
        self.rightButtonStyle = kWMNavigationBarRightButtonStyleContributeButton;
        
        // search bar
        searchBarContainer = [[UIImageView alloc] initWithFrame:self.bounds];
        searchBarContainer.userInteractionEnabled = YES;
        searchBarContainer.image = [UIImage imageNamed:@"search_background.png"];
        searchBarContainer.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
        [self addSubview:searchBarContainer];
    
        // search cancel button
        normalBtnImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        normalBtnImg.image = [[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        normalBtnLabel = [[WMLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        normalBtnLabel.fontSize = 13.0;
        normalBtnLabel.text = NSLocalizedString(@"Cancel", nil);
        normalBtnLabel.textAlignment = UITextAlignmentCenter;
        normalBtnLabel.textColor = [UIColor whiteColor];
        expSize = [normalBtnLabel.text sizeWithFont:normalBtnLabel.font constrainedToSize:CGSizeMake(100, 17)];
        if (expSize.width < 40) expSize = CGSizeMake(40, expSize.height);
        normalBtnLabel.frame = CGRectMake(normalBtnLabel.frame.origin.x, normalBtnLabel.frame.origin.y, expSize.width, normalBtnLabel.frame.size.height);
        normalBtnImg.frame  = CGRectMake(0, 0, normalBtnLabel.frame.size.width+10, 40);
        normalBtnLabel.center = CGPointMake(normalBtnImg.center.x, normalBtnLabel.center.y);
        [normalBtnImg addSubview:normalBtnLabel];
        searchBarCancelButton = [WMButton buttonWithType:UIButtonTypeCustom];
        searchBarCancelButton.frame = CGRectMake(self.frame.size.width-5-normalBtnImg.frame.size.width, 5, normalBtnImg.frame.size.width, normalBtnImg.frame.size.height);
        searchBarCancelButton.backgroundColor = [UIColor clearColor];
        [searchBarCancelButton setView:normalBtnImg forControlState:UIControlStateNormal];
        [searchBarCancelButton addTarget:self action:@selector(pressedSearchCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [searchBarContainer addSubview:searchBarCancelButton];
        
        // search text field
        searchBarTextFieldBg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, searchBarCancelButton.frame.origin.x - 5 - 5, 40)];
        searchBarTextFieldBg.image = [[UIImage imageNamed:@"search_searchbar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [searchBarContainer addSubview:searchBarTextFieldBg];
        searchBarTextFieldBg.userInteractionEnabled = YES;
        
        searchBarTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, searchBarTextFieldBg.frame.size.width-10, 30)];
        searchBarTextField.placeholder = NSLocalizedString(@"Search keyword", nil);
        searchBarTextField.delegate = self;
        [searchBarTextFieldBg addSubview:searchBarTextField];
        
        
        

        
        
    }
    
    return self;
}

#pragma mark - Button Handlers
-(void)pressedBackButton:(WMButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(pressedBackButton:)]) {
        [self.delegate pressedBackButton:self];
    }
    
}
-(void)pressedDashboardButton:(WMButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(pressedDashboardButton:)]) {
        [self.delegate pressedDashboardButton:self];
    }
    
}
-(void)pressedEditButton:(WMButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(pressedEditButton:)]) {
        [self.delegate pressedEditButton:self];
    }
    
}
-(void)pressedCancelButton:(WMButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(pressedCancelButton:)]) {
        [self.delegate pressedCancelButton:self];
    }
    
}
-(void)pressedSaveButton:(WMButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(pressedSaveButton:)]) {
        [self.delegate pressedSaveButton:self];
    }
    
}
-(void)pressedContributeButton:(WMButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(pressedContributeButton:)]) {
        [self.delegate pressedContributeButton:self];
    }
    
}

-(void)pressedSearchCancelButton:(WMButton*)sender
{
    [self hideSearchBar];
}

#pragma mark - Bar Style Changes

-(void)setLeftButtonStyle:(WMNavigationBarLeftButtonStyle)leftButtonStyle
{
    if (_leftButtonStyle == leftButtonStyle) {
        return; // same style do not need to update buttons!
    }
    
    _leftButtonStyle = leftButtonStyle;
    UIView* prevButton = currentLeftButton;
    switch (leftButtonStyle) {
        case kWMNavigationBarLeftButtonStyleDashboardButton:
            currentLeftButton = dashboardButton;
            break;
        case kWMNavigationBarLeftButtonStyleBackButton:
            currentLeftButton = backButton;
            break;
        case kWMNavigationBarLeftButtonStyleCancelButton:
            currentLeftButton = cancelButton;
            break;
        default:
            currentLeftButton = dashboardButton;
            break;
    }
    // effect here!
    currentLeftButton.alpha = 0.0;
    currentLeftButton.hidden = NO;
    
    [self adjustTitleLabelFrame];
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         prevButton.alpha = 0.0;
         currentLeftButton.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         prevButton.hidden = YES;
         
     }
     ];
}

-(void)setRightButtonStyle:(WMNavigationBarRightButtonStyle)rightButtonStyle
{
    if (_rightButtonStyle == rightButtonStyle) {
        return;
    }
    
    _rightButtonStyle = rightButtonStyle;
    UIView* prevButton = currentRightButton;
    switch (rightButtonStyle) {
        case kWMNavigationBarRightButtonStyleContributeButton:
            currentRightButton = contributeButton;
            break;
        case kWMNavigationBarRightButtonStyleEditButton:
            currentRightButton = editButton;
            break;
        case kWMNavigationBarRightButtonStyleSaveButton:
            currentRightButton = saveButton;
            break;
        case kWMNavigationBarRightButtonStyleNone:
            currentRightButton = noneButton;
            break;
        default:
            currentRightButton = contributeButton;
            break;
    }
    // effect here!
    currentRightButton.alpha = 0.0;
    currentRightButton.hidden = NO;
    
    [self adjustTitleLabelFrame];
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         prevButton.alpha = 0.0;
         currentRightButton.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
         prevButton.hidden = YES;

     }
     ];

}

-(WMNavigationBarLeftButtonStyle)leftButtonStyle
{
    return _leftButtonStyle;
}

-(WMNavigationBarRightButtonStyle)rightButtonStyle
{
    return _rightButtonStyle;
}

-(void)setTitle:(NSString *)title
{
    if ([_title isEqualToString:title] || title.length == 0) {
        return; // same string. do not need to update title!
    }
    _title = title;
    titleLabel.alpha = 0.0;
    titleLabel.text = title;
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         titleLabel.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
        
         
     }
     ];
}

-(NSString*)title
{
    return _title;
}

-(void)adjustTitleLabelFrame
{
    CGFloat originX = currentLeftButton.frame.origin.x+currentLeftButton.frame.size.width;
    CGFloat width = currentRightButton.frame.origin.x - originX;
    
    titleLabel.frame = CGRectMake(originX+5, titleLabel.frame.origin.y, width-10, titleLabel.frame.size.height);
    
}

-(void)showSearchBar
{
    if (isSearchBarVisible)
        return;
    
    [self toggleSearchBar];
}

-(void)hideSearchBar
{
    if (!isSearchBarVisible)
        return;
    
    [self toggleSearchBar];
    
}
-(void)toggleSearchBar
{
    if (isSearchBarVisible) {
        [searchBarTextField resignFirstResponder];
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseOut
                         animations:^(void)
         {
             searchBarContainer.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
             titleLabel.alpha = 1.0;
         }
                         completion:^(BOOL finished)
         {
             isSearchBarVisible = NO;
             
             
         }
         ];
    } else {
        [searchBarTextField becomeFirstResponder];
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^(void)
         {
             searchBarContainer.transform = CGAffineTransformMakeTranslation(0, 0);
             titleLabel.alpha = 0.2;
         }
                         completion:^(BOOL finished)
         {
             isSearchBarVisible = YES;
             
             
         }
         ];
    }
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideSearchBar];
    [searchBarTextField resignFirstResponder];
    
    if (textField.text && textField.text.length > 0) {
        if ([self.delegate respondsToSelector:@selector(searchStringIsGiven:)]) {
            [self.delegate searchStringIsGiven:textField.text];
        }
    }
    
    
    return YES;
}


@end
