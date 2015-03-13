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
#import "WMDataManager.h"

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
    }/* else {
        [self loadRegisterUrl];
    }*/
    
}

- (void)loadRegisterUrl {
    self.titleLabel.text = NSLocalizedString(@"RegisterNew", nil);

    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMConfigFilename ofType:@"plist"]];
    NSString *baseURL = config[@"apiBaseURL"];
    
    urlString = [NSString stringWithFormat:@"%@%@", baseURL, WM_REGISTER_LINK];
    
    //NSURL *url = [NSURL URLWithString:urlString];
    
    //NSLog(@"Loading URL %@", url);
    
	//[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

- (void)loadLoginUrl {
    self.titleLabel.text = @"";
    
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMConfigFilename ofType:@"plist"]];
    NSString *baseURL = config[@"apiBaseURL"];
    urlString = [NSString stringWithFormat:@"%@%@", baseURL, WEB_LOGIN_LINK];
    
    //NSURL *url = [NSURL URLWithString:urlString];
    //NSLog(@"Loading URL %@", url);

	//[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)loadForgotPasswordUrl {
    self.titleLabel.text = @"";
    
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WMConfigFilename ofType:@"plist"]];
    NSString *baseURL = config[@"apiBaseURL"];
    urlString = [NSString stringWithFormat:@"%@%@", baseURL, FORGOT_PASSWORD_LINK];
    
    //NSURL *url = [NSURL URLWithString:urlString];
    //NSLog(@"Loading URL %@", url);

	//[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"WebView loading failed: %@",error.localizedDescription);
}

-(IBAction)pressedCancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSLog(@"req: %@\n", request);
    if([webView.request.URL.absoluteString containsString:@"www.facebook.com"]){
        return NO;
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    if([webView.request.URL.absoluteString containsString:@"/after_signup_edit"]){
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[webView.request.URL.absoluteString stringByReplacingOccurrencesOfString:@"/after_signup_edit" withString:@"/edit"]]]];
    }else if([webView.request.URL.absoluteString containsString:@"/edit"]){
        NSString *apiToken = [self.webView stringByEvaluatingJavaScriptFromString:@"$('#user_authentication_token').val();"];
        if(![apiToken isEqualToString:@"undefined"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveAuthenticationData"
                                                                object:self
                                                              userInfo:@{@"authData":@{@"api_key":apiToken}}];
            //[self.loginVC.dataManager didReceiveAuthenticationData: forAccount:@"wheelmapApp"];
            [self dismissViewControllerAnimated:YES];
        }
    }
}

@end

