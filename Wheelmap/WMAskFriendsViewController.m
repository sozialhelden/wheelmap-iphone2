//
//  WMAskFriendsViewController.m
//  Wheelmap
//
//  Created by Andrea Gerlach on 01.12.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMAskFriendsViewController.h"

@interface WMAskFriendsViewController ()

@end

@implementation WMAskFriendsViewController

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
    self.title = @"ASK_FRIEND";
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
@end