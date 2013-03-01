//
//  WMRegisterViewController.m
//  Wheelmap
//
//  Created by npng on 12/12/12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMRegisterViewController.h"
#import "WMWheelmapAPI.h"
#import "Constants.h"

@implementation WMRegisterViewController {
    
    NSString *urlString;
}


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
    
    // clear the cookies first, as the webview would otherwise send the api token
    // but at this point, the user did not log into the app, so the satandard app user is sent, which is bad
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    
    [self.cancelButton setTitle:NSLocalizedString(@"Ready", nil) forState:UIControlStateNormal];
    
    self.webView.scrollView.scrollsToTop = YES;
    
    if (urlString != nil) {
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSLog(@"Loading URL %@", url);
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    } else {
        [self loadRegisterUrl];
    }
}

- (void)loadRegisterUrl {
    self.titleLabel.text = NSLocalizedString(@"RegisterNew", nil);

    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMConfigFilename ofType:@"plist"]];
    NSString *baseURL = config[@"apiBaseURL"];
    
    urlString = [NSString stringWithFormat:@"%@%@", baseURL, WM_REGISTER_LINK];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSLog(@"Loading URL %@", url);
    
	[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

- (void)loadLoginUrl {
    self.titleLabel.text = @"";
    
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMConfigFilename ofType:@"plist"]];
    NSString *baseURL = config[@"apiBaseURL"];
    urlString = [NSString stringWithFormat:@"%@%@", baseURL, WEB_LOGIN_LINK];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"Loading URL %@", url);

	[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)loadForgotPasswordUrl {
    self.titleLabel.text = @"";
    
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMConfigFilename ofType:@"plist"]];
    NSString *baseURL = config[@"apiBaseURL"];
    urlString = [NSString stringWithFormat:@"%@%@", baseURL, FORGOT_PASSWORD_LINK];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"Loading URL %@", url);

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

