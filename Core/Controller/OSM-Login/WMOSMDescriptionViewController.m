//
//  WMOSMDescriptionViewController.m
//  Wheelmap
//
//  Created by Dirk Tech on 04/30/15.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMOSMDescriptionViewController.h"
#import "WMWheelmapAPI.h"

@implementation WMOSMDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.backgroundColor = [UIColor wmGreyColor];

    [self.whyOSMLabel setText:NSLocalizedString(@"WhyOSMAccount", nil)];
    [self.whyOSMTextView setText:NSLocalizedString(@"DescribeWhyOSMAccount", nil)];
    
    [self.okButton setTitle:NSLocalizedString(@"FirstStartButton", nil) forState:UIControlStateNormal];
	[self.okButton setBackgroundColor:[UIColor wmNavigationBackgroundColor]];
	self.okButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.okButton.frame.origin.y + self.okButton.frame.size.height + 10.0f);
}

-(IBAction)pressedOkButton:(id)sender {
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

