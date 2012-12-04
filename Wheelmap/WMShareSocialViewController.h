//
//  WMShareSocialViewController.h
//  Wheelmap
//
//  Created by Andrea Gerlach on 01.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMShareSocialViewController : WMViewController

@property (nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)twitterButtonPressed:(id)sender;
- (IBAction)facebookButtonPressed:(id)sender;
- (IBAction)smsButtonPressed:(id)sender;
- (IBAction)emailButtonPressed:(id)sender;


@end
