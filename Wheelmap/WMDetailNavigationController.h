//
//  WMDetailNavigationController.h
//  Wheelmap
//
//  Created by Michael Thomas on 23.01.13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMNavigationBar.h"
#import "WMToolBar.h"

@interface WMDetailNavigationController : UINavigationController <WMNavigationBarDelegate>

@property (nonatomic, strong) WMNavigationBar* customNavigationBar;

-(void)presentLoginScreenWithButtonFrame:(CGRect)frame;

@end
