//
//  WMOSMLoginViewController.h
//  Wheelmap
//
//  Created by npng on 04/30/15.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

@interface WMOSMLoginViewController : WMViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIButton* cancelButton;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UIView *navigationBar;

-(IBAction)pressedCancelButton:(id)sender;

- (void)loadRegisterUrl;
- (void)loadLoginUrl;
//- (void)loadForgotPasswordUrl;
- (IBAction)whyOSM:(id)sender;

@end
