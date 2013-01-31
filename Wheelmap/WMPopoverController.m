//
//  WMPopoverController.m
//  Wheelmap
//
//  Created by Michael Thomas on 31.01.13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

#import "WMPopoverController.h"

@implementation WMPopoverController

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated {
    
    self.isShowing = YES;
    self.delegate = self;
    [super presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirections animated:animated];
}

- (void)dismissPopoverAnimated:(BOOL)animated {
    
    self.isShowing = NO;
    [super dismissPopoverAnimated:animated];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.isShowing = NO;
}

@end
