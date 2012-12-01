//
//  WMButton.h
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMButton : UIButton

@property BOOL disabled;
@property BOOL enabledToggle;
@property (nonatomic, strong) UIView* normalView;
@property (nonatomic, strong) UIView* highlightedView;
@property (nonatomic, strong) UIView* selectedView; // if this is set, self.selected will be automatically set according to the user interaction
@property BOOL enabledHighlightedForSelectedStatus; // default is YES. if this is NO, touch down on the selected button will not show highlighted image
-(void)setView:(UIView*)view forControlState:(UIControlState)state;

@end
