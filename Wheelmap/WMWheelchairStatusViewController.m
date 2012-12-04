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
    self.title = @"Bearbeiten";
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
    
    [self.delegate accessButtonPressed:sender];
    
    UIButton *button = (UIButton*) sender;
    
    if (button.tag == 0) {
        NSLog(@"XXXXXXXX Hier bin ich XXXXXXXX YES");
    } else if (button.tag == 1) {
        NSLog(@"XXXXXXXX Hier bin ich XXXXXXXX LIMITED");
    } else if (button.tag == 2) {
        NSLog(@"XXXXXXXX Hier bin ich XXXXXXXX NO");
    }
}

@end
