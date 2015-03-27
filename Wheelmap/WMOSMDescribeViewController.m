//
//  WMOSMDescribeViewController.m
//  Wheelmap
//
//  Created by Dirk Tech on 04/30/15.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMOSMDescribeViewController.h"
#import "WMWheelmapAPI.h"
#import "Constants.h"
#import "WMRegisterViewController.h"

@implementation WMOSMDescribeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.backgroundColor = [UIColor wmGreyColor];
    
    [self.okButton setTitle:NSLocalizedString(@"FirstStartButton", nil) forState:UIControlStateNormal];
    [self.okButton setBackgroundImage:[[UIImage imageNamed:@"buttons_btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 10)] forState:UIControlStateNormal];
    
/*    CGSize stringsize = [self.okButton.titleLabel.text boundingRectWithSize:CGSizeMake(300.0f, FLT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{NSFontAttributeName:self.okButton.titleLabel.font}
                                                                    context:nil].size;
    //or whatever font you're using
    [self.okButton setFrame:CGRectMake(320.0f - stringsize.width - 20.0f, self.loginLabel.frame.origin.y + self.loginLabel.frame.size.height + 20.0f, stringsize.width + 10.0f, stringsize.height + 10.0f)];
*/    
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

