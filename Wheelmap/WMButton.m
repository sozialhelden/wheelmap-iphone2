//
//  WMButton.m
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMButton.h"
#define HIGHLIGHTED_ALPHA 0.5

@implementation WMButton

@synthesize selected = _selected;
@synthesize disabled = _disabled;
@synthesize enabledToggle = _enabledToggle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.normalView = nil;
        self.highlightedView = nil;
        self.selectedView = nil;
        [self addTarget:self action:@selector(buttonTouchedDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(buttonTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addTarget:self action:@selector(buttonTouchedUp:) forControlEvents:UIControlEventTouchUpOutside];
        
    }
    return self;
}

-(void)setView:(UIView*)view forControlState:(UIControlState)state
{
    switch (state) {
        case UIControlStateNormal:
            self.normalView = view;
            self.normalView.userInteractionEnabled = NO;
            [self addSubview:self.normalView];
            break;
        case UIControlStateHighlighted:
            self.highlightedView = view;
            self.highlightedView.userInteractionEnabled = NO;
            [self addSubview:self.highlightedView];
            break;
        case UIControlStateSelected:
            self.selectedView = view;
            self.selectedView.userInteractionEnabled = NO;
            [self addSubview:self.selectedView];
            break;
        default:
            break;
    }
    
    // adjust button size
    if (self.frame.size.width < view.frame.size.width) {
        //update width
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, view.frame.size.width, self.frame.size.height);
    }
    
    if (self.frame.size.height < view.frame.size.height) {
        // update height;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, view.frame.size.height);
    }
    
    // initial status
    self.highlightedView.hidden = YES;
    self.selectedView.hidden = YES;
    self.enabledHighlightedForSelectedStatus = YES;
}

#pragma mark __set views for control states
-(void)buttonTouchedDown:(WMButton*)btn
{
    if (_selected)
        return; // this ensures selected = highlighted.
    
    if (self.highlightedView) {
        self.highlightedView.hidden = NO;
        self.normalView.hidden = YES;
        self.selectedView.hidden = YES;
    } else {
        // only normal view is set
        self.normalView.alpha = HIGHLIGHTED_ALPHA;
    }
    
}

-(void)buttonTouchedUp:(WMButton*)btn
{
    if (self.selectedView) {
        _selected = !_selected;
        if (_selected) {
            self.selectedView.hidden = NO;
            self.highlightedView.hidden = YES;
            self.normalView.hidden = YES;
        } else {
            self.selectedView.hidden = YES;
            self.highlightedView.hidden = YES;
            self.normalView.hidden = NO;
        }
    } else {
        if (self.highlightedView) {
            self.normalView.hidden = NO;
            self.highlightedView.hidden = YES;
            self.selectedView.hidden = YES;
        } else {
            // only normal view is set
            self.normalView.alpha = 1.0;
        }
        
    }
    
}

-(void)setSelected:(BOOL)s
{
    [super setSelected:s];
    _selected = s;
    
    if (!self.selectedView)
        return;
    
    if (_selected) {
        self.selectedView.hidden = NO;
        self.highlightedView.hidden = YES;
        self.normalView.hidden = YES;
    } else {
        self.selectedView.hidden = YES;
        self.highlightedView.hidden = YES;
        self.normalView.hidden = NO;
    }
}

-(BOOL)selected
{
    return _selected;
}

-(void)setDisabled:(BOOL)disabled
{
    _disabled = disabled;
    if (disabled) {
        self.selected = YES;
        self.enabled = NO;
    } else {
        self.selected = NO;
        self.enabled = YES;
    }
}
-(BOOL)disabled
{
    return _disabled;
}

-(void)setEnabledToggle:(BOOL)enabledToggle
{
    _enabledToggle = enabledToggle;
    if (enabledToggle) {
        [self removeTarget:self action:@selector(buttonTouchedUp:) forControlEvents:UIControlEventTouchUpOutside];
    } else {
        [self addTarget:self action:@selector(buttonTouchedUp:) forControlEvents:UIControlEventTouchUpOutside];
    }
}

-(BOOL)enabledToggle
{
    return _enabledToggle;
}

@end
