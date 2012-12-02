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
        backBtnLabel.text = @"Zurück";
        backBtnLabel.textColor = [UIColor whiteColor];
        CGSize expSize = [backBtnLabel.text sizeWithFont:backBtnLabel.font constrainedToSize:CGSizeMake(100, 17)];
        backBtnLabel.frame = CGRectMake(backBtnLabel.frame.origin.x, backBtnLabel.frame.origin.y, expSize.width, backBtnLabel.frame.size.height);
        backBtnBgImg.frame  = CGRectMake(0, 0, backBtnLabel.frame.size.width+20, 37);
        [backBtnBgImg addSubview:backBtnLabel];
        backButton = [WMButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(5, 6, backBtnBgImg.frame.size.width, backBtnBgImg.frame.size.height);
        [backButton setView:backBtnBgImg forControlState:UIControlStateNormal];
        backButton.hidden = YES;
        [backButton addTarget:self action:@selector(pressedBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
        
        cancelButton = [WMButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = leftButtonRect;
        cancelButton.backgroundColor = UIColorFromRGB(0xDB4D6D);
        cancelButton.hidden = YES;
        [cancelButton addTarget:self action:@selector(pressedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
        
        CGRect rightButtonRect = CGRectMake(self.frame.size.width-5-40, 5, 40, 40);
        contributeButton = [WMButton buttonWithType:UIButtonTypeCustom];
        contributeButton.frame = rightButtonRect;
        contributeButton.backgroundColor = [UIColor clearColor];
        [contributeButton setImage:[UIImage imageNamed:@"navigationbar_addbutton.png"] forState:UIControlStateNormal];
        contributeButton.contentMode = UIViewContentModeCenter;
        contributeButton.hidden = YES;
        [contributeButton addTarget:self action:@selector(pressedContributeButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:contributeButton];
        
        editButton = [WMButton buttonWithType:UIButtonTypeCustom];
        editButton.frame = rightButtonRect;
        editButton.backgroundColor = [UIColor blackColor];
        editButton.hidden = YES;
        [editButton addTarget:self action:@selector(pressedEditButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:editButton];
        
        saveButton = [WMButton buttonWithType:UIButtonTypeCustom];
        saveButton.frame = rightButtonRect;
        saveButton.backgroundColor = [UIColor greenColor];
        saveButton.hidden = YES;
        [saveButton addTarget:self action:@selector(pressedSaveButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:saveButton];
        
                
        // titleLabel
        titleLabel = [[WMLabel alloc] initWithFrame:self.bounds];
        titleLabel.fontSize = 20.0;
        titleLabel.fontType = kWMLabelFontTypeBold;
        titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:titleLabel];
        
        // initial styles
        self.leftButtonStyle = kWMNavigationBarLeftButtonStyleDashboardButton;
        self.rightButtonStyle = kWMNavigationBarRightButtonStyleContributeButton;
        self.title = @"Orte in deiner Nähe";
        
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
    if ([_title isEqualToString:title]) {
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

-(void)showNavigationBar
{
    if (isVisible)
        return;
    
    [self toggleNavigationBar];
}

-(void)hideNavigationBar
{
    if (!isVisible)
        return;
    
    [self toggleNavigationBar];
    
}
-(void)toggleNavigationBar
{
    if (isVisible) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseOut
                         animations:^(void)
         {
             self.transform = CGAffineTransformMakeTranslation(0, -55);
         }
                         completion:^(BOOL finished)
         {
             isVisible = NO;
             
         }
         ];
    } else {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^(void)
         {
             self.transform = CGAffineTransformMakeTranslation(0, 0);
         }
                         completion:^(BOOL finished)
         {
             isVisible = YES;
             
         }
         ];
    }
}


@end
