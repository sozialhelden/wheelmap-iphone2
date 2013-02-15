//
//  WMTermsViewController.m
//  Wheelmap
//
//  Created by npng on 12/12/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMTermsViewController.h"
#import "Constants.h"

@implementation WMTermsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        terms = WheelMapTermsURL;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = NSLocalizedString(@"TermsTitle", nil);
    self.titleLabel.adjustsFontSizeToFitWidth = YES;

    [self.cancelButton setTitle:NSLocalizedString(@"Ready", nil) forState:UIControlStateNormal];
    
    NSURL *url = [NSURL URLWithString:terms];
    
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

- (void)showDataTerms:(BOOL)showDataTerms {
    if (showDataTerms) {
        terms = WheelMapDataTermsURL;
    } else {
        terms = WheelMapTermsURL;
    }
}

@end
