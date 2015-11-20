//
//  WMIntroViewController.h
//  Wheelmap
//
//  Created by Hans Seiffert on 17.11.15.
//  Copyright © 2015 Sozialhelden e.V. All rights reserved.
//

#import "WMViewController.h"

@interface WMIntroViewController : WMViewController<UIScrollViewDelegate, UIWebViewDelegate>

@property (strong, nonatomic) UIPopoverController	*popoverController;

@end
