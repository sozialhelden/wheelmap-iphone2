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
@property (strong, nonatomic) IBOutlet UILabel *shareLocationLabel;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *smsButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)twitterButtonPressed:(id)sender;
- (IBAction)facebookButtonPressed:(id)sender;
- (IBAction)smsButtonPressed:(id)sender;
- (IBAction)emailButtonPressed:(id)sender;
- (IBAction)closeButtonPressed:(id)sender;


@end
