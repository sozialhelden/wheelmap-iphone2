//
//  WMNavigationBar.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMNavigationBar.h"
#import "Reachability.h"
#import "WMWheelmapAPI.h"

@implementation WMNavigationBar
@synthesize leftButtonStyle = _leftButtonStyle;
@synthesize rightButtonStyle = _rightButtonStyle;
@synthesize title = _title;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = YES;

        // Initialization code
        backgroundImg = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundImg.image = [UIImage imageNamed:@"navigationbar_background.png"];
        backgroundImg.contentMode = UIViewContentModeScaleToFill;
        backgroundImg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:backgroundImg];
        
        currentLeftButton = nil;
        currentRightButton = nil;
        self.leftButtonStyle = -1;
        self.rightButtonStyle = -1;
        
        // init all buttons here
        CGRect leftButtonRect = CGRectMake(5, 3, 40, 40);
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
        backBtnBgImg.image = [[UIImage imageNamed:@"buttons_back-btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 10)];
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
        backButton.frame = CGRectMake(8, 6, backBtnBgImg.frame.size.width, backBtnBgImg.frame.size.height);
        [backButton setView:backBtnBgImg forControlState:UIControlStateNormal];
        backButton.hidden = YES;
        [backButton addTarget:self action:@selector(pressedBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
        
        // cancel button
        UIImageView* normalBtnImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 37)];
        normalBtnImg.image = [[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 10, 20, 10)];
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

        UIImageView* normalBtnImg1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 37)];
        normalBtnImg1.image = [[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 10, 20, 10)];
        WMLabel* normalBtnLabel1 = [[WMLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 35)];
        normalBtnLabel1.fontSize = 13.0;
        normalBtnLabel1.text = NSLocalizedString(@"Cancel", nil);
        normalBtnLabel1.textAlignment = UITextAlignmentCenter;
        normalBtnLabel1.textColor = [UIColor whiteColor];
        expSize = [normalBtnLabel1.text sizeWithFont:normalBtnLabel1.font constrainedToSize:CGSizeMake(100, 17)];
        if (expSize.width < 40) expSize = CGSizeMake(40, expSize.height);
        normalBtnLabel1.frame = CGRectMake(normalBtnLabel.frame.origin.x, normalBtnLabel1.frame.origin.y, expSize.width, normalBtnLabel1.frame.size.height);
        normalBtnImg1.frame  = CGRectMake(0, 0, normalBtnLabel1.frame.size.width+10, 37);
        normalBtnLabel1.center = CGPointMake(normalBtnImg1.center.x, normalBtnLabel1.center.y);
        [normalBtnImg1 addSubview:normalBtnLabel1];
        cancelButtonRight = [WMButton buttonWithType:UIButtonTypeCustom];
        cancelButtonRight.frame = rightButtonRect;
        cancelButtonRight.backgroundColor = [UIColor clearColor];
        [cancelButtonRight setView:normalBtnImg1 forControlState:UIControlStateNormal];
        cancelButtonRight.hidden = YES;
        cancelButtonRight.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cancelButtonRight addTarget:self action:@selector(pressedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButtonRight];
        
        // mithilfe button
        self.contributeButton = [WMButton buttonWithType:UIButtonTypeCustom];
        self.contributeButton.frame = rightButtonRect;
        self.contributeButton.backgroundColor = [UIColor clearColor];
        [self.contributeButton setImage:[UIImage imageNamed:@"navigationbar_addbutton.png"] forState:UIControlStateNormal];
        self.contributeButton.contentMode = UIViewContentModeCenter;
        self.contributeButton.hidden = YES;
        [self.contributeButton addTarget:self action:@selector(pressedContributeButton:) forControlEvents:UIControlEventTouchUpInside];
        self.contributeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.contributeButton];
        
        
        // edit button
        normalBtnImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 37)];
        normalBtnImg.image = [[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 10, 20, 10)];
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
        
        self.editButton = [WMButton buttonWithType:UIButtonTypeCustom];
        self.editButton.frame = CGRectMake(self.frame.size.width-normalBtnImg.frame.size.width-9, 6, normalBtnImg.frame.size.width, normalBtnImg.frame.size.height);
        self.editButton.backgroundColor = [UIColor clearColor];
        [self.editButton setView:normalBtnImg forControlState:UIControlStateNormal];
        self.editButton.hidden = YES;
        self.editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.editButton addTarget:self action:@selector(pressedEditButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.editButton];
        
        // save button
        normalBtnImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 37)];
        normalBtnImg.image = [[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 10, 20, 10)];
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
        saveButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [saveButton setView:normalBtnImg forControlState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(pressedSaveButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:saveButton];
        
        noneButton = [WMButton buttonWithType:UIButtonTypeCustom];
        noneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        noneButton.frame = rightButtonRect;
        noneButton.hidden = YES;
        [self addSubview:noneButton];
        
        noneButtonLeft = [WMButton buttonWithType:UIButtonTypeCustom];
        noneButtonLeft.frame = leftButtonRect;
        noneButtonLeft.hidden = YES;
        [self addSubview:noneButtonLeft];
        
        // titleLabel)
        titleLabel = [[WMLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, self.bounds.size.height)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        titleLabel.fontSize = 20.0;
        titleLabel.fontType = kWMLabelFontTypeBold;
        titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:titleLabel];
        
        // initial styles
        self.leftButtonStyle = kWMNavigationBarLeftButtonStyleDashboardButton;
        self.rightButtonStyle = kWMNavigationBarRightButtonStyleContributeButton;
        
        // search bar
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            searchBarContainer = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.origin.x + 50.0f, self.bounds.origin.y, 320.0f - 50.0f, self.bounds.size.height)];
        } else {
            searchBarContainer = [[UIImageView alloc] initWithFrame:self.bounds];
        }
        searchBarContainer.userInteractionEnabled = YES;
        searchBarContainer.image = [UIImage imageNamed:@"search_background.png"];
        searchBarContainer.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
        [self addSubview:searchBarContainer];
    
        // search cancel button
        normalBtnImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        normalBtnImg.image = [[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 10, 15, 10)];
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
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
        } else {
            searchBarCancelButton = [WMButton buttonWithType:UIButtonTypeCustom];
            searchBarCancelButton.frame = CGRectMake(searchBarContainer.frame.size.width-5-normalBtnImg.frame.size.width, 5, normalBtnImg.frame.size.width, normalBtnImg.frame.size.height);
            searchBarCancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            searchBarCancelButton.backgroundColor = [UIColor clearColor];
            [searchBarCancelButton setView:normalBtnImg forControlState:UIControlStateNormal];
            [searchBarCancelButton addTarget:self action:@selector(pressedSearchCancelButton:) forControlEvents:UIControlEventTouchUpInside];
            [searchBarContainer addSubview:searchBarCancelButton];
        }
        
        // search text field
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            searchBarTextFieldBg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, searchBarContainer.frame.size.width - 10.0f, 40)];
        } else {
            searchBarTextFieldBg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, searchBarCancelButton.frame.origin.x - 5 - 5, 40)];
        }
        searchBarTextFieldBg.image = [[UIImage imageNamed:@"search_searchbar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        searchBarTextFieldBg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [searchBarContainer addSubview:searchBarTextFieldBg];
        searchBarTextFieldBg.userInteractionEnabled = YES;
        
        searchBarTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, searchBarTextFieldBg.frame.size.width-10, 30)];
        searchBarTextField.placeholder = NSLocalizedString(@"SearchForPlace", nil);
        searchBarTextField.delegate = self;
        searchBarTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        searchBarTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        searchBarTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        searchBarTextField.returnKeyType = UIReturnKeySearch;
        [searchBarTextFieldBg addSubview:searchBarTextField];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
        
        
    }
    
    return self;
}

- (void)setSearchBarEnabled:(BOOL)searchBarEnabled {
    _searchBarEnabled = searchBarEnabled;
    if (searchBarEnabled) {
        searchBarContainer.transform = CGAffineTransformMakeTranslation(0, 0);
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if ([self.delegate respondsToSelector:@selector(pressedSearchCancelButton:)]) {
        [self.delegate pressedSearchCancelButton:self];
    }
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
        case kWMNavigationBarLeftButtonStyleNone:
            currentLeftButton = noneButtonLeft;
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
            currentRightButton = self.contributeButton;
            break;
        case kWMNavigationBarRightButtonStyleEditButton:
            currentRightButton = self.editButton;
            break;
        case kWMNavigationBarRightButtonStyleSaveButton:
            currentRightButton = saveButton;
            break;
        case kWMNavigationBarRightButtonStyleNone:
            currentRightButton = noneButton;
            break;
        case kWMNavigationBarRightButtonStyleCancelButton:
            currentRightButton = cancelButtonRight;
            break;
        default:
            currentRightButton = self.contributeButton;
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
         [self networkStatusChanged:nil];

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
    
    NSLog(@"X = %f", currentRightButton.frame.origin.x);
    
    titleLabel.frame = CGRectMake(originX+5, titleLabel.frame.origin.y, width-10, titleLabel.frame.size.height);
    
}

- (NSString *)getSearchString {
    return searchBarTextField.text;
}

- (void)clearSearchText {
    searchBarTextField.text = @"";
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

-(void)showRightButton:(WMNavigationBarRightButtonStyle)type
{
    UIView* targetButton;
    
    switch (type) {
        case kWMNavigationBarRightButtonStyleContributeButton:
            targetButton = self.contributeButton;
            break;
        case kWMNavigationBarRightButtonStyleEditButton:
            targetButton = self.editButton;
            break;
        case kWMNavigationBarRightButtonStyleSaveButton:
            targetButton = saveButton;
            break;
        default:
            targetButton = noneButton;
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
-(void)hideRightButton:(WMNavigationBarRightButtonStyle)type
{
    UIView* targetButton;
    
    switch (type) {
        case kWMNavigationBarRightButtonStyleContributeButton:
            targetButton = self.contributeButton;
            break;
        case kWMNavigationBarRightButtonStyleEditButton:
            targetButton = self.editButton;
            break;
        case kWMNavigationBarRightButtonStyleSaveButton:
            targetButton = saveButton;
            break;
        default:
            targetButton = noneButton;
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

- (void)adjustButtonsToPopoverPresentation {
    // back button
    UIImageView* backBtnBgImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
    backBtnBgImg.image = [[UIImage imageNamed:@"buttons_back-btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 10)];
    WMLabel* backBtnLabel = [[WMLabel alloc] initWithFrame:CGRectMake(15, 0, 100, 30)];
    backBtnLabel.fontSize = 13.0;
    backBtnLabel.text = NSLocalizedString(@"BackButton", nil);
    backBtnLabel.textColor = [UIColor whiteColor];
    CGSize expSize = [backBtnLabel.text sizeWithFont:backBtnLabel.font constrainedToSize:CGSizeMake(100, 17)];
    if (expSize.width < 40) expSize = CGSizeMake(40, expSize.height);
    backBtnLabel.frame = CGRectMake(backBtnLabel.frame.origin.x, backBtnLabel.frame.origin.y, expSize.width, backBtnLabel.frame.size.height);
    backBtnBgImg.frame  = CGRectMake(0, 0, backBtnLabel.frame.size.width+20, 32);
    [backBtnBgImg addSubview:backBtnLabel];
    
    BOOL hidden = backButton.hidden;
    
    [backButton removeFromSuperview];
    
    backButton = [WMButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(8, 12, backBtnBgImg.frame.size.width, backBtnBgImg.frame.size.height);
    [backButton setView:backBtnBgImg forControlState:UIControlStateNormal];
    backButton.hidden = hidden;
    [backButton addTarget:self action:@selector(pressedBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    
    // cancel button
    hidden = cancelButton.hidden;
    
    [cancelButton removeFromSuperview];
    
    UIImageView* normalBtnImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
    normalBtnImg.image = [[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 10, 20, 10)];
    WMLabel* normalBtnLabel = [[WMLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    normalBtnLabel.fontSize = 13.0;
    normalBtnLabel.text = NSLocalizedString(@"Cancel", nil);
    normalBtnLabel.textAlignment = UITextAlignmentCenter;
    normalBtnLabel.textColor = [UIColor whiteColor];
    expSize = [normalBtnLabel.text sizeWithFont:normalBtnLabel.font constrainedToSize:CGSizeMake(100, 17)];
    if (expSize.width < 40) expSize = CGSizeMake(40, expSize.height);
    normalBtnLabel.frame = CGRectMake(normalBtnLabel.frame.origin.x, normalBtnLabel.frame.origin.y, expSize.width, normalBtnLabel.frame.size.height);
    normalBtnImg.frame  = CGRectMake(0, 0, normalBtnLabel.frame.size.width+10, 32);
    normalBtnLabel.center = CGPointMake(normalBtnImg.center.x, normalBtnLabel.center.y);
    [normalBtnImg addSubview:normalBtnLabel];
    cancelButton = [WMButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(5, 12, normalBtnImg.frame.size.width, normalBtnImg.frame.size.height);
    cancelButton.backgroundColor = [UIColor clearColor];
    [cancelButton setView:normalBtnImg forControlState:UIControlStateNormal];
    cancelButton.hidden = hidden;
    [cancelButton addTarget:self action:@selector(pressedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    hidden = cancelButtonRight.hidden;
    
    [cancelButtonRight removeFromSuperview];
    
    cancelButtonRight = [WMButton buttonWithType:UIButtonTypeCustom];
    cancelButtonRight.frame = CGRectMake(self.frame.size.width-normalBtnImg.frame.size.width-9, 12, normalBtnImg.frame.size.width, normalBtnImg.frame.size.height);
    cancelButtonRight.backgroundColor = [UIColor clearColor];
    [cancelButtonRight setView:normalBtnImg forControlState:UIControlStateNormal];
    cancelButtonRight.hidden = hidden;
    cancelButtonRight.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [cancelButtonRight addTarget:self action:@selector(pressedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButtonRight];
    
    // edit button
    hidden = self.editButton.hidden;
    
    [self.editButton removeFromSuperview];
    
    normalBtnImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
    normalBtnImg.image = [[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 10, 20, 10)];
    normalBtnLabel = [[WMLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    normalBtnLabel.fontSize = 13.0;
    normalBtnLabel.text = NSLocalizedString(@"NavBarEditButton", nil);
    normalBtnLabel.textAlignment = UITextAlignmentCenter;
    normalBtnLabel.textColor = [UIColor whiteColor];
    expSize = [normalBtnLabel.text sizeWithFont:normalBtnLabel.font constrainedToSize:CGSizeMake(100, 17)];
    if (expSize.width < 40) expSize = CGSizeMake(40, expSize.height);
    normalBtnLabel.frame = CGRectMake(normalBtnLabel.frame.origin.x, normalBtnLabel.frame.origin.y, expSize.width, normalBtnLabel.frame.size.height);
    normalBtnImg.frame  = CGRectMake(0, 0, normalBtnLabel.frame.size.width+10, 32);
    normalBtnLabel.center = CGPointMake(normalBtnImg.center.x, normalBtnLabel.center.y);
    [normalBtnImg addSubview:normalBtnLabel];
    
    self.editButton = [WMButton buttonWithType:UIButtonTypeCustom];
    self.editButton.frame = CGRectMake(self.frame.size.width-normalBtnImg.frame.size.width-9, 12, normalBtnImg.frame.size.width, normalBtnImg.frame.size.height);
    self.editButton.backgroundColor = [UIColor clearColor];
    [self.editButton setView:normalBtnImg forControlState:UIControlStateNormal];
    self.editButton.hidden = YES;
    self.editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.editButton addTarget:self action:@selector(pressedEditButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.editButton];
    
    // save button
    hidden = saveButton.hidden;
    
    [saveButton removeFromSuperview];
    
    normalBtnImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
    normalBtnImg.image = [[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 10, 20, 10)];
    normalBtnLabel = [[WMLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    normalBtnLabel.fontSize = 13.0;
    normalBtnLabel.text = NSLocalizedString(@"NavBarSaveButton", nil);
    normalBtnLabel.textAlignment = UITextAlignmentCenter;
    normalBtnLabel.textColor = [UIColor whiteColor];
    expSize = [normalBtnLabel.text sizeWithFont:normalBtnLabel.font constrainedToSize:CGSizeMake(100, 17)];
    if (expSize.width < 40) expSize = CGSizeMake(40, expSize.height);
    normalBtnLabel.frame = CGRectMake(normalBtnLabel.frame.origin.x, normalBtnLabel.frame.origin.y, expSize.width, normalBtnLabel.frame.size.height);
    normalBtnImg.frame  = CGRectMake(0, 0, normalBtnLabel.frame.size.width+10, 32);
    normalBtnLabel.center = CGPointMake(normalBtnImg.center.x, normalBtnLabel.center.y);
    [normalBtnImg addSubview:normalBtnLabel];
    saveButton = [WMButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake(self.frame.size.width-normalBtnImg.frame.size.width-5, 12, normalBtnImg.frame.size.width, normalBtnImg.frame.size.height);
    saveButton.backgroundColor = [UIColor clearColor];
    saveButton.hidden = hidden;
    saveButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [saveButton setView:normalBtnImg forControlState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(pressedSaveButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:saveButton];
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

- (void)dismissSearchKeyboard {
    [searchBarTextField resignFirstResponder];
}

#pragma mark - Network Status Changes
-(void)networkStatusChanged:(NSNotification*)notice
{
    NetworkStatus networkStatus = [[[WMWheelmapAPI sharedInstance] internetReachable] currentReachabilityStatus];
    
    switch (networkStatus)
    {
        case NotReachable:
            NSLog(@"INTERNET IS NOT AVAILABLE!");
            [self hideRightButton:kWMNavigationBarRightButtonStyleContributeButton];
            [self hideRightButton:kWMNavigationBarRightButtonStyleEditButton];
            [self hideRightButton:kWMNavigationBarRightButtonStyleSaveButton];
            break;
            
        default:
            [self showRightButton:kWMNavigationBarRightButtonStyleContributeButton];
            [self showRightButton:kWMNavigationBarRightButtonStyleEditButton];
            [self showRightButton:kWMNavigationBarRightButtonStyleSaveButton];
            
            break;
    }
}



@end
