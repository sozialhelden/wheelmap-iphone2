//
//  WMShareSocialViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 01.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMShareSocialViewController : WMViewController

@property (strong, nonatomic) NSString *	shareURlString;

@property (strong, nonatomic) IBOutlet UIView *					titleView;
@property (strong, nonatomic) IBOutlet UILabel *				shareLocationLabel;

@end
