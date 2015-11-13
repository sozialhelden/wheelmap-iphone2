//
//  WMOSMDescriptionViewController.m
//  Wheelmap
//
//  Created by Dirk Tech on 04/30/15.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMOSMDescriptionViewController.h"
#import "WMWheelmapAPI.h"

@interface WMOSMDescriptionViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *			scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	scrollViewContentWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	scrollViewContentHeightConstraint;

@property (nonatomic, weak) IBOutlet UILabel *				whyOSMLabel;
@property (nonatomic, weak) IBOutlet UITextView	*			whyOSMTextView;

@property (nonatomic, weak) IBOutlet UIButton *				okButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	okButtonBottomConstraint;

@end

@implementation WMOSMDescriptionViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.backgroundColor = [UIColor wmGreyColor];

    [self.whyOSMLabel setText:L(@"WhyOSMAccount")];
    [self.whyOSMTextView setText:L(@"DescribeWhyOSMAccount")];
    
    [self.okButton setTitle:L(@"FirstStartButton") forState:UIControlStateNormal];
	[self.okButton setBackgroundColor:[UIColor wmNavigationBackgroundColor]];
	self.okButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);

	self.scrollViewContentWidthConstraint.constant = self.view.frameWidth;
	self.scrollViewContentHeightConstraint.constant = self.okButton.frameY + self.okButton.frameHeight + self.okButtonBottomConstraint.constant;

	self.preferredContentSize = CGSizeMake(self.scrollViewContentWidthConstraint.constant, self.scrollViewContentHeightConstraint.constant);
}

#pragma mark - IBActions

-(IBAction)pressedOkButton:(id)sender {
    [self dismissViewControllerAnimated:YES];
}

@end

