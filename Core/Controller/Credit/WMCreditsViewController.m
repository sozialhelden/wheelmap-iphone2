//
//  WMCreditsViewController.m
//  Wheelmap
//
//  Created by Taehun Kim on 1/7/13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

#import "WMCreditsViewController.h"
#import "WMAnalytics.h"

@interface WMCreditsViewController ()

@property (weak, nonatomic) IBOutlet UIView *				navigationBarView;
@property (nonatomic, weak) IBOutlet WMButton *				doneButton;
@property (nonatomic, weak) IBOutlet WMLabel *				titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *				appVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *				creditsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *				mapSourceLabel;

@property (weak, nonatomic) IBOutlet MarqueeLabel *			mapIconsLabel;
@property (weak, nonatomic) IBOutlet MarqueeLabel *			pictogramsLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	pictogramsLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	scrollViewContentHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *	scrollViewContentWidthConstraint;

@end

@implementation WMCreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titleLabel.text = L(@"Credits");
    [self.doneButton setTitle:L(@"Ready") forState:UIControlStateNormal];
    
    self.appVersionLabel.text = [NSString stringWithFormat:@"iOS App Version: %@ (Build %@)",
								 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
								 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];

    self.creditsTitleLabel.text = L(@"Credits:");

	self.mapSourceLabel.text = L(@"credits.map.data.title");

    self.mapIconsLabel.text = @"Map Icons Collection https://mapicons.mapsmarker.com";

    self.pictogramsLabel.text = @"Entypo pictograms by Daniel Bruce";

	[self.pictogramsLabel layoutIfNeeded];

	if (self.view.isRightToLeftDirection == YES && SYSTEM_VERSION_LESS_THAN(@"9.0") == YES) {
		// As Marquee label doesn't support right to left automatically on prior iOS9 devices, we have to do it on our own.
		self.mapSourceLabel.textAlignment = NSTextAlignmentRight;
		self.pictogramsLabel.textAlignment = NSTextAlignmentRight;
	}
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[WMAnalytics trackScreen:K_INFO_SCREEN];
}

- (void)viewDidLayoutSubviews {
	// Update the scroll view content size if a view was layoutet.
	self.scrollViewContentWidthConstraint.constant = self.view.frameWidth;
	self.scrollViewContentHeightConstraint.constant = self.pictogramsLabel.frameY + self.pictogramsLabel.frameHeight + self.pictogramsLabelBottomConstraint.constant;

	// Set the preferred content size to make sure the popover controller has the right size.
	self.preferredContentSize =  CGSizeMake(self.scrollViewContentWidthConstraint.constant, self.scrollViewContentHeightConstraint.constant + self.navigationBarView.frameHeight);
}

#pragma mark - IBActions

- (IBAction)pressedOSMButton {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:OSM_URL]];
}

- (IBAction)pressedODDbLButton {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ODBL_URL]];
}

- (IBAction)pressedDoneButton:(id)sender {
    [self dismissViewControllerAnimated:YES];
}

@end