//
//  WMWheelchairStatusViewController.m
//  Wheelmap
//
//  Created by Dorian Roy on 26.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMWheelchairStatusViewController.h"


@interface WMWheelchairStatusViewController ()

@end

@implementation WMWheelchairStatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.noButton.titleLabel.text = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


/* Set a fixed size for view in popovers */

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(320, 480);
}



- (void)viewDidUnload {
    [self setYesButton:nil];
    [self setLimitedButton:nil];
    [self setNoButton:nil];
    [super viewDidUnload];
}

- (IBAction)accessButtonPressed:(id)sender {
    
    UIButton *button = (UIButton*) sender;
    
    if (button.tag == 0) {
        self.wheelchairAccess = @"yes";
    } else if (button.tag == 1) {
        self.wheelchairAccess = @"limited";
    } else if (button.tag == 2) {
        self.wheelchairAccess = @"no";
    }
}

- (void) saveAccessStatus {
    [self.delegate accessButtonPressed:self.wheelchairAccess];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
