//
//  WMWheelChairStatusFilterPopoverView.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMWheelChairStatusFilterPopoverView.h"
#import "WMDataManager.h"

@implementation WMWheelChairStatusFilterPopoverView {
    
    WMDataManager *dataManager;
}

- (id)initWithOrigin:(CGPoint)origin
{
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, 201, 55)];
    if (self) {
        
        dataManager = [[WMDataManager alloc] init];
        
        // Initialization code
        buttonGreen = [WMButton buttonWithType:UIButtonTypeCustom];
        buttonGreen.frame = CGRectMake(0, 0, 53, 60);
        [buttonGreen setImage:[UIImage imageNamed:@"toolbar_statusfilter-yes.png"] forState:UIControlStateNormal];
        [buttonGreen setImage:[UIImage imageNamed:@"toolbar_statusfilter-yes-active.png"] forState:UIControlStateHighlighted];
        [buttonGreen setImage:[UIImage imageNamed:@"toolbar_statusfilter-yes-active.png"] forState:UIControlStateSelected];
        [buttonGreen setImage:[UIImage imageNamed:@"toolbar_statusfilter-yes-active.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
        [buttonGreen addTarget:self action:@selector(pressedGreenButton:) forControlEvents:UIControlEventTouchUpInside];
        buttonGreen.selected = YES;
        [self addSubview:buttonGreen];
        
        buttonYellow = [WMButton buttonWithType:UIButtonTypeCustom];
        buttonYellow.frame = CGRectMake(50, 0, 51, 60);
        [buttonYellow setImage:[UIImage imageNamed:@"toolbar_statusfilter-limited.png"] forState:UIControlStateNormal];
        [buttonYellow setImage:[UIImage imageNamed:@"toolbar_statusfilter-limited-active.png"] forState:UIControlStateHighlighted];
        [buttonYellow setImage:[UIImage imageNamed:@"toolbar_statusfilter-limited-active.png"] forState:UIControlStateSelected];
        [buttonYellow setImage:[UIImage imageNamed:@"toolbar_statusfilter-limited-active.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
        [buttonYellow addTarget:self action:@selector(pressedYellowButton:) forControlEvents:UIControlEventTouchUpInside];
        buttonYellow.selected = YES;
        [self addSubview:buttonYellow];
        
        buttonRed = [WMButton buttonWithType:UIButtonTypeCustom];
        buttonRed.frame = CGRectMake(100, 0, 51, 60);
        [buttonRed setImage:[UIImage imageNamed:@"toolbar_statusfilter-no.png"] forState:UIControlStateNormal];
        [buttonRed setImage:[UIImage imageNamed:@"toolbar_statusfilter-no-active.png"] forState:UIControlStateHighlighted];
        [buttonRed setImage:[UIImage imageNamed:@"toolbar_statusfilter-no-active.png"] forState:UIControlStateSelected];
        [buttonRed setImage:[UIImage imageNamed:@"toolbar_statusfilter-no-active.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
        [buttonRed addTarget:self action:@selector(pressedRedButton:) forControlEvents:UIControlEventTouchUpInside];
        buttonRed.selected = YES;
        [self addSubview:buttonRed];
        
        buttonNone = [WMButton buttonWithType:UIButtonTypeCustom];
        buttonNone.frame = CGRectMake(150, 0, 53, 60);
        [buttonNone setImage:[UIImage imageNamed:@"toolbar_statusfilter-unknown.png"] forState:UIControlStateNormal];
        [buttonNone setImage:[UIImage imageNamed:@"toolbar_statusfilter-unknown-active.png"] forState:UIControlStateHighlighted];
        [buttonNone setImage:[UIImage imageNamed:@"toolbar_statusfilter-unknown-active.png"] forState:UIControlStateSelected];
        [buttonNone setImage:[UIImage imageNamed:@"toolbar_statusfilter-unknown-active.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
        [buttonNone addTarget:self action:@selector(pressedNoneButton:) forControlEvents:UIControlEventTouchUpInside];
        buttonNone.selected = YES;
        [self addSubview:buttonNone];
        
        
    }
    return self;
}

- (void)updateFilterButtons {
    if (![dataManager getGreenFilterStatus]) {
        buttonGreen.selected = !buttonGreen.selected;
        if ([self.delegate respondsToSelector:@selector(pressedButtonOfDotType:selected:)])
            [self.delegate pressedButtonOfDotType:kDotTypeGreen selected:buttonGreen.selected];
    }
    if (![dataManager getYellowFilterStatus]) {
        buttonYellow.selected = !buttonYellow.selected;
        if ([self.delegate respondsToSelector:@selector(pressedButtonOfDotType:selected:)])
            [self.delegate pressedButtonOfDotType:kDotTypeYellow selected:buttonYellow.selected];
    }
    if (![dataManager getRedFilterStatus]) {
        buttonRed.selected = !buttonRed.selected;
        if ([self.delegate respondsToSelector:@selector(pressedButtonOfDotType:selected:)])
            [self.delegate pressedButtonOfDotType:kDotTypeRed selected:buttonRed.selected];
    }
    if (![dataManager getNoneFilterStatus]) {
        buttonNone.selected = !buttonNone.selected;
        if ([self.delegate respondsToSelector:@selector(pressedButtonOfDotType:selected:)])
            [self.delegate pressedButtonOfDotType:kDotTypeNone selected:buttonNone.selected];
    }
}

#pragma mark - Button Handlers

-(void)pressedGreenButton:(WMButton*)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(pressedButtonOfDotType:selected:)])
        [self.delegate pressedButtonOfDotType:kDotTypeGreen selected:sender.selected];
    
    [dataManager saveNewFilterSettingsWithGreen:buttonGreen.selected yellow:buttonYellow.selected red:buttonRed.selected none:buttonNone.selected];
}

-(void)pressedYellowButton:(WMButton*)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(pressedButtonOfDotType:selected:)])
        [self.delegate pressedButtonOfDotType:kDotTypeYellow selected:sender.selected];
    
    [dataManager saveNewFilterSettingsWithGreen:buttonGreen.selected yellow:buttonYellow.selected red:buttonRed.selected none:buttonNone.selected];

}

-(void)pressedRedButton:(WMButton*)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(pressedButtonOfDotType:selected:)])
        [self.delegate pressedButtonOfDotType:kDotTypeRed selected:sender.selected];
    
    [dataManager saveNewFilterSettingsWithGreen:buttonGreen.selected yellow:buttonYellow.selected red:buttonRed.selected none:buttonNone.selected];
}

-(void)pressedNoneButton:(WMButton*)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(pressedButtonOfDotType:selected:)])
        [self.delegate pressedButtonOfDotType:kDotTypeNone selected:sender.selected];
    
    [dataManager saveNewFilterSettingsWithGreen:buttonGreen.selected yellow:buttonYellow.selected red:buttonRed.selected none:buttonNone.selected];
}

@end

