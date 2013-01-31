//
//  WMViewController.h
//  Wheelmap
//
//  Created by npng on 11/27/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMPopoverController.h"

@interface WMViewController : UIViewController

@property (nonatomic, strong) WMPopoverController* popover;
@property (nonatomic) CGRect popoverButtonFrame;
@property (nonatomic, strong) UIViewController* baseController;

@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) NSString* navigationBarTitle;

- (void)presentForcedModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;

@end
