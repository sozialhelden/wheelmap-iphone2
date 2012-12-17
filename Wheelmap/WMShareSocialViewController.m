//
//  WMShareSocialViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 01.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMShareSocialViewController.h"

@interface WMShareSocialViewController ()

@end

@implementation WMShareSocialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
	// Do any additional setup after loading the view.
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.smsButton.frame.origin.y + self.smsButton.frame.size.height+10);
    [self.twitterButton setTitle:NSLocalizedString(@"twitter", @"") forState:UIControlStateNormal];
    [self.facebookButton setTitle:NSLocalizedString(@"facebook", @"") forState:UIControlStateNormal];
    [self.emailButton setTitle:NSLocalizedString(@"email", @"") forState:UIControlStateNormal];
    [self.smsButton setTitle:NSLocalizedString(@"sms", @"") forState:UIControlStateNormal];
    NSLog(@"XXXXXXXX Hier bin ich XXXXXXXX %@", self.shareLocationLabel.text);


}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"Sharing", nil);
    self.navigationBarTitle = self.title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)twitterButtonPressed:(id)sender {
        NSLog(@"Twitter Button pressed");
}

- (IBAction)facebookButtonPressed:(id)sender {
        NSLog(@"Facebook Button pressed");
}

- (IBAction)smsButtonPressed:(id)sender {
        NSLog(@"SMS Button pressed");
}

- (IBAction)emailButtonPressed:(id)sender {
        NSLog(@"EMail Button pressed");
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setShareLocationLabel:nil];
    [self setSmsButton:nil];
    [self setTwitterButton:nil];
    [self setFacebookButton:nil];
    [self setEmailButton:nil];
    [self setSmsButton:nil];
    [super viewDidUnload];
}
@end
