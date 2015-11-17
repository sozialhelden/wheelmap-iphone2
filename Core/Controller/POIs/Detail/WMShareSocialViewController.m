//
//  WMShareSocialViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 01.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMShareSocialViewController.h"
#import "WMSharingManager.h"

@interface WMShareSocialViewController () {
    WMSharingManager* sharingManager;
}

@property (nonatomic) IBOutlet UIScrollView *					scrollView;

@property (weak, nonatomic) IBOutlet UIButton *					twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *					facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *					emailButton;
@property (weak, nonatomic) IBOutlet UIButton *					smsButton;
@property (weak, nonatomic) IBOutlet UIButton *					closeButton;
@property (strong, nonatomic) IBOutlet UILabel *				titleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *		scrollViewContentViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *		scrollViewContentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *		smsButtonBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *		navigationBarHeightConstraint;

@end

@implementation WMShareSocialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // sharing manager
    sharingManager = [[WMSharingManager alloc] initWithBaseViewController:self];
    
	// Do any additional setup after loading the view.
    [self.twitterButton setTitle:L(@"twitter") forState:UIControlStateNormal];
    [self.facebookButton setTitle:L(@"facebook") forState:UIControlStateNormal];
    [self.emailButton setTitle:L(@"email") forState:UIControlStateNormal];
    [self.smsButton setTitle:L(@"sms") forState:UIControlStateNormal];
    
    [self.closeButton setTitle:L(@"Cancel") forState:UIControlStateNormal];
    
    self.titleLabel.text = L(@"NavBarTitleSharing");

	if (UIDevice.isIPad == YES) {
		self.navigationBarHeightConstraint.constant = 0;
	}
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = L(@"NavBarTitleSharing");
    self.navigationBarTitle = self.title;
}

- (void)viewDidLayoutSubviews {
	self.scrollViewContentViewWidthConstraint.constant = self.view.frameWidth;
	self.scrollViewContentViewHeightConstraint.constant = self.smsButton.frameY + self.smsButton.frameHeight + self.smsButtonBottomConstraint.constant;

	self.preferredContentSize = CGSizeMake(self.scrollViewContentViewWidthConstraint.constant, self.scrollViewContentViewHeightConstraint.constant);
}

#pragma mark - IBAction

- (IBAction)twitterButtonPressed:(id)sender {
    [sharingManager tweet:self.shareLocationLabel.text];
}

- (IBAction)facebookButtonPressed:(id)sender {
    [sharingManager facebookPosting:self.shareURlString];
}

- (IBAction)smsButtonPressed:(id)sender {
    [sharingManager sendSMSwithBody:self.shareLocationLabel.text];
}

- (IBAction)emailButtonPressed:(id)sender {
    [sharingManager sendMailWithSubject:L(@"ShareLocationLabel") andBody:self.shareLocationLabel.text];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES];
}

#pragma mark -

// sharing viewcontrollers are always presented modally, so don't override for ipad
- (void)presentViewController:(UIViewController *)modalViewController animated:(BOOL)animated{
    [self presentForcedModalViewController:modalViewController animated:animated];
}

@end
