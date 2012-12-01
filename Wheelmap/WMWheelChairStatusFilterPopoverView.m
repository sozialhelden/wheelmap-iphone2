//
//  WMWheelChairStatusFilterPopoverView.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMWheelChairStatusFilterPopoverView.h"

@implementation WMWheelChairStatusFilterPopoverView

- (id)initWithOrigin:(CGPoint)origin
{
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, 201, 55)];
    if (self) {
        // Initialization code
        buttonGreen = [WMButton buttonWithType:UIButtonTypeCustom];
        buttonGreen.frame = CGRectMake(0, 0, 51, 55);
        [buttonGreen setImage:[UIImage imageNamed:@"toolbar_statusfilter-yes.png"] forState:UIControlStateNormal];
        [buttonGreen setImage:[UIImage imageNamed:@"toolbar_statusfilter-yes-active.png"] forState:UIControlStateHighlighted];
        [buttonGreen setImage:[UIImage imageNamed:@"toolbar_statusfilter-yes-active.png"] forState:UIControlStateSelected];
        [buttonGreen setImage:[UIImage imageNamed:@"toolbar_statusfilter-yes-active.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
        [buttonGreen addTarget:self action:@selector(pressedGreenButton:) forControlEvents:UIControlEventTouchUpInside];
        buttonGreen.selected = YES;
        [self addSubview:buttonGreen];
        
        buttonYellow = [WMButton buttonWithType:UIButtonTypeCustom];
        buttonYellow.frame = CGRectMake(51, 0, 50, 55);
        [buttonYellow setImage:[UIImage imageNamed:@"toolbar_statusfilter-limited.png"] forState:UIControlStateNormal];
        [buttonYellow setImage:[UIImage imageNamed:@"toolbar_statusfilter-limited-active.png"] forState:UIControlStateHighlighted];
        [buttonYellow setImage:[UIImage imageNamed:@"toolbar_statusfilter-limited-active.png"] forState:UIControlStateSelected];
        [buttonYellow setImage:[UIImage imageNamed:@"toolbar_statusfilter-limited-active.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
        [buttonYellow addTarget:self action:@selector(pressedYellowButton:) forControlEvents:UIControlEventTouchUpInside];
        buttonYellow.selected = YES;
        [self addSubview:buttonYellow];
        
        buttonRed = [WMButton buttonWithType:UIButtonTypeCustom];
        buttonRed.frame = CGRectMake(101, 0, 50, 55);
        [buttonRed setImage:[UIImage imageNamed:@"toolbar_statusfilter-no.png"] forState:UIControlStateNormal];
        [buttonRed setImage:[UIImage imageNamed:@"toolbar_statusfilter-no-active.png"] forState:UIControlStateHighlighted];
        [buttonRed setImage:[UIImage imageNamed:@"toolbar_statusfilter-no-active.png"] forState:UIControlStateSelected];
        [buttonRed setImage:[UIImage imageNamed:@"toolbar_statusfilter-no-active.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
        [buttonRed addTarget:self action:@selector(pressedRedButton:) forControlEvents:UIControlEventTouchUpInside];
        buttonRed.selected = YES;
        [self addSubview:buttonRed];
        
        buttonNone = [WMButton buttonWithType:UIButtonTypeCustom];
        buttonNone.frame = CGRectMake(151, 0, 50, 55);
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
#pragma mark - Button Handlers

-(void)pressedGreenButton:(WMButton*)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(pressedButtonOfDotType:selected:)])
        [self.delegate pressedButtonOfDotType:kDotTypeGreen selected:sender.selected];
    
}

-(void)pressedYellowButton:(WMButton*)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(pressedButtonOfDotType:selected:)])
        [self.delegate pressedButtonOfDotType:kDotTypeYellow selected:sender.selected];
    
}

-(void)pressedRedButton:(WMButton*)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(pressedButtonOfDotType:selected:)])
        [self.delegate pressedButtonOfDotType:kDotTypeRed selected:sender.selected];
    
}

-(void)pressedNoneButton:(WMButton*)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(pressedButtonOfDotType:selected:)])
        [self.delegate pressedButtonOfDotType:kDotTypeNone selected:sender.selected];
    
}

@end

