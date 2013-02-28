//
//  WMFirstStartViewController.m
//  Wheelmap
//
//  Created by Michael Thomas on 12/12/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMFirstStartViewController.h"
#import "WMWheelmapAPI.h"

@implementation WMFirstStartViewController

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
    
    [self.cancelButton setTitle:NSLocalizedString(@"Ready", nil) forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)pressedCancelButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end

