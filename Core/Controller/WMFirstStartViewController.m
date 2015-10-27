//
//  WMFirstStartViewController.m
//  Wheelmap
//
//  Created by Michael Thomas on 12/12/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMFirstStartViewController.h"
#import "WMWheelmapAPI.h"
#import "Constants.h"
#import "WMRegisterViewController.h"

@implementation WMFirstStartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.backgroundColor = [UIColor wmGreyColor];
    
    self.firstTextLabel.text = NSLocalizedString(@"FirstStartBothAccounts", nil);
    self.secondTextLabel.text = NSLocalizedString(@"FirstStartNoAccount", nil);
    self.registerLabel.text = NSLocalizedString(@"FirstStartNoAccountRegister", nil);
    self.thirdtextLabel.text = NSLocalizedString(@"FirstStartOnlyOSM", nil);
    
    self.loginLabel.text = NSLocalizedString(@"Sign In Button", nil);
    
    [self.okButton setTitle:NSLocalizedString(@"FirstStartButton", nil) forState:UIControlStateNormal];
    
    [self adjustLabelHeightToText:self.firstTextLabel];
    
    self.secondTextLabel.frame = CGRectMake(self.secondTextLabel.frame.origin.x, self.firstTextLabel.frame.origin.y + self.firstTextLabel.frame.size.height + 20.0f, self.secondTextLabel.frame.size.width, self.secondTextLabel.frame.size.height);
    [self adjustLabelHeightToText:self.secondTextLabel];
    
    self.registerLabel.frame = CGRectMake(self.registerLabel.frame.origin.x, self.secondTextLabel.frame.origin.y + self.secondTextLabel.frame.size.height, self.registerLabel.frame.size.width, self.registerLabel.frame.size.height);
    [self adjustLabelHeightToText:self.registerLabel];
    self.registerButton.frame = self.registerLabel.frame;
    
    self.thirdtextLabel.frame = CGRectMake(self.thirdtextLabel.frame.origin.x, self.registerLabel.frame.origin.y + self.registerLabel.frame.size.height + 20.0f, self.thirdtextLabel.frame.size.width, self.thirdtextLabel.frame.size.height);
    [self adjustLabelHeightToText:self.thirdtextLabel];
    
    self.loginLabel.frame = CGRectMake(self.loginLabel.frame.origin.x, self.thirdtextLabel.frame.origin.y + self.thirdtextLabel.frame.size.height, self.loginLabel.frame.size.width, self.loginLabel.frame.size.height);
    [self adjustLabelHeightToText:self.loginLabel];
    self.loginButton.frame = self.loginLabel.frame;
    
    CGSize stringsize = [self.okButton.titleLabel.text boundingRectWithSize:CGSizeMake(300.0f, FLT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{NSFontAttributeName:self.okButton.titleLabel.font}
                                                                    context:nil].size;
    //or whatever font you're using
    [self.okButton setFrame:CGRectMake(320.0f - stringsize.width - 20.0f, self.loginLabel.frame.origin.y + self.loginLabel.frame.size.height + 20.0f, stringsize.width + 10.0f, stringsize.height + 10.0f)];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.okButton.frame.origin.y + self.okButton.frame.size.height + 10.0f);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)pressedOkButton:(id)sender
{
    [self dismissViewControllerAnimated:YES];
}

-(IBAction)pressedLoginButton:(id)sender
{
    // use this when websites are optimized for mobile
	WMRegisterViewController *registerViewController = [UIStoryboard instantiatedRegisterViewController];
    [registerViewController loadLoginUrl];
    [self presentViewController:registerViewController animated:YES];
}

-(IBAction)pressedRegisterButton:(id)sender
{
	WMRegisterViewController *registerViewController = [UIStoryboard instantiatedRegisterViewController];
    [registerViewController loadRegisterUrl];
    [self presentViewController:registerViewController animated:YES];
}

- (void)adjustLabelHeightToText:(UILabel *)label {
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    
    CGSize expectedLabelSize = [label.text boundingRectWithSize:maximumLabelSize
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:label.font}
                                                        context:nil].size;
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
}

@end

