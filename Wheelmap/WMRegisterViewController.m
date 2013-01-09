//
//  WMRegisterViewController.m
//  Wheelmap
//
//  Created by npng on 12/12/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMRegisterViewController.h"
#import "WMWheelmapAPI.h"

#define WMRegistrationURL @"http://staging.wheelmap.org/en/oauth/register_osm"

@implementation WMRegisterViewController

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
    
    NSURL *url = [NSURL URLWithString:WMRegistrationURL];
    
	[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"WebView loading failed: %@",error.localizedDescription);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"WebView finished loading");
}

-(IBAction)pressedCancelButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
