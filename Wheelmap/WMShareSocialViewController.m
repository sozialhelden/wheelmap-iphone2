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
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 500);
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
- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}
@end
